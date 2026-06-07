/**
 * Websearch Extension for Pi
 *
 * Registers a `websearch` tool that queries a SearXNG instance via its JSON API
 * and returns formatted results to the LLM.
 *
 * SearXNG JSON API requirement:
 *   The SearXNG server must have `json` in its `search.formats` list.
 *   In settings.yml:
 *     search:
 *       formats:
 *         - html
 *         - json
 *   Or via env: SEARXNG_FORMATS=html,json
 *
 *   Without this, the /search?format=json endpoint returns HTTP 403.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

// ── Configuration ───────────────────────────────────────────────────────────

const SEARX_BASE_URL = "https://searx.hugovaz.dev";
const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 25;

// ── Types ───────────────────────────────────────────────────────────────────

interface SearxResult {
  title: string;
  url: string;
  content: string;
  engine?: string;
  engines?: string[];
  score?: number;
  category?: string;
  publishedDate?: string | null;
}

interface SearxApiResponse {
  query: string;
  number_of_results: number;
  results: SearxResult[];
  answers?: string[];
  corrections?: unknown[];
  infoboxes?: unknown[];
  suggestions?: string[];
  unresponsive_engines?: Array<[string, string]>;
}

// ── Helpers ─────────────────────────────────────────────────────────────────

function escapeMarkdown(text: string): string {
  return text.replace(/([\[\]|*_`~])/g, "\\$1");
}

function truncate(text: string, maxLen: number): string {
  if (text.length <= maxLen) return text;
  return text.slice(0, maxLen).replace(/\s+\S*$/, "") + "…";
}

function formatResults(data: SearxApiResponse, limit: number): string {
  const lines: string[] = [];

  lines.push(`**Search results for:** ${escapeMarkdown(data.query)}`);
  lines.push(
    `**${data.number_of_results.toLocaleString()}** results total · showing top **${Math.min(limit, data.results.length)}**`,
  );

  // Answers / instant answers from engines
  if (data.answers && data.answers.length > 0) {
    lines.push("");
    lines.push("### Instant Answers");
    for (const answer of data.answers.slice(0, 3)) {
      lines.push(`- ${escapeMarkdown(truncate(answer, 300))}`);
    }
  }

  lines.push("");
  lines.push("### Results");

  if (data.results.length === 0) {
    lines.push("_No results found._");
  }

  for (let i = 0; i < Math.min(limit, data.results.length); i++) {
    const r = data.results[i];
    const title = escapeMarkdown(r.title || "Untitled");
    const snippet = escapeMarkdown(truncate(r.content || "", 250));
    const engines = r.engines && r.engines.length > 0
      ? ` • engines: ${r.engines.join(", ")}`
      : r.engine
        ? ` • engine: ${r.engine}`
        : "";

    lines.push(`**${i + 1}. [${title}](${r.url})**`);
    lines.push(`   ${snippet}`);
    if (engines) lines.push(`   ${engines}`);
    if (r.publishedDate) lines.push(`   Date: ${r.publishedDate}`);
  }

  // Unresponsive engines
  if (data.unresponsive_engines && data.unresponsive_engines.length > 0) {
    lines.push("");
    lines.push(
      `⚠️ Unresponsive engines: ${data.unresponsive_engines.map((e) => e[0]).join(", ")}`,
    );
  }

  return lines.join("\n");
}

async function search(
  query: string,
  limit: number,
  engine?: string,
  signal?: AbortSignal,
): Promise<SearxApiResponse> {
  const params = new URLSearchParams();
  params.set("q", query);
  params.set("format", "json");
  params.set("pageno", "1");
  if (engine) params.set("engines", engine);

  const url = `${SEARX_BASE_URL}/search?${params.toString()}`;

  const response = await fetch(url, {
    signal,
    headers: {
      "Accept": "application/json",
      "User-Agent": "pi-websearch-extension/1.0",
    },
  });

  if (!response.ok) {
    if (response.status === 403) {
      throw new Error(
        `${SEARX_BASE_URL} returned 403 Forbidden for JSON API. ` +
        `Enable json in SearXNG search.formats (settings.yml) or set SEARXNG_FORMATS=html,json.`,
      );
    }
    throw new Error(
      `SearXNG search failed: HTTP ${response.status} ${response.statusText}`,
    );
  }

  const data = (await response.json()) as SearxApiResponse;

  // Validate basic structure
  if (!data || !Array.isArray(data.results)) {
    throw new Error(
      `Unexpected response from SearXNG: ${JSON.stringify(data).slice(0, 200)}`,
    );
  }

  return data;
}

// ── Extension ───────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "websearch",
    label: "Web Search",
    description:
      "Search the web using a SearXNG metasearch engine. " +
      "Returns page titles, URLs, and content snippets. " +
      "Use this to find current information, documentation, or answer questions that require up-to-date knowledge.",
    promptSnippet:
      "Search the web using SearXNG metasearch; returns titles, URLs, and snippets",
    promptGuidelines: [
      "Use websearch when the user asks about current events, recent updates, or information beyond your knowledge cutoff.",
      "Cite websearch results with the URL and title when using them to answer.",
    ],
    parameters: Type.Object({
      query: Type.String({
        description:
          "The search query. Be specific and include relevant keywords for better results.",
      }),
      limit: Type.Optional(
        Type.Number({
          description:
            `Number of results to return (default: ${DEFAULT_LIMIT}, max: ${MAX_LIMIT})`,
          minimum: 1,
          maximum: MAX_LIMIT,
        }),
      ),
      engine: Type.Optional(
        Type.String({
          description:
            "Specific search engine to use (e.g., 'google', 'duckduckgo', 'wikipedia'). " +
            "Leave empty to use all configured engines.",
        }),
      ),
    }),
    async execute(
      _toolCallId,
      params: { query: string; limit?: number; engine?: string },
      signal,
      _onUpdate,
    ) {
      const limit = Math.min(params.limit ?? DEFAULT_LIMIT, MAX_LIMIT);

      try {
        const data = await search(params.query, limit, params.engine, signal);
        const formatted = formatResults(data, limit);

        return {
          content: [{ type: "text", text: formatted }],
          details: {
            query: data.query,
            totalResults: data.number_of_results,
            returnedResults: Math.min(limit, data.results.length),
            unresponsiveEngines: data.unresponsive_engines?.map((e) => e[0]),
            searchUrl: `${SEARX_BASE_URL}/search?q=${encodeURIComponent(params.query)}`,
          },
        };
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        return {
          content: [
            {
              type: "text",
              text: `Web search failed: ${message}`,
            },
          ],
          details: { error: message },
          isError: true,
        };
      }
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.notify(
      `Websearch: ${SEARX_BASE_URL}`,
      "info",
    );
  });
}
