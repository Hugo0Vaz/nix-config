/**
 * Webfetch Extension for Pi
 *
 * Registers a `webfetch` tool that fetches and extracts readable text from a
 * URL.  Ideal for reading full pages after a `websearch`.
 *
 * No external dependencies — uses Node.js built-in `fetch` and regex-based
 * HTML-to-text extraction.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

// ── Configuration ───────────────────────────────────────────────────────────

const DEFAULT_MAX_BYTES = 1_000_000; // 1 MB
const DEFAULT_TIMEOUT_MS = 15_000;
const MAX_CONTENT_LENGTH = 50_000; // chars returned to the LLM
const USER_AGENT = "Mozilla/5.0 (compatible; pi-webfetch/1.0)";

// ── HTML-to-text extraction ─────────────────────────────────────────────────

/** Naive HTML entity decoder for the most common entities. */
function decodeEntities(html: string): string {
  return html
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/&#x27;/g, "'")
    .replace(/&#(\d+);/g, (_m, d) => String.fromCodePoint(Number(d)))
    .replace(/&#[xX]([0-9a-fA-F]+);/g, (_m, h) =>
      String.fromCodePoint(Number.parseInt(h, 16)),
    );
}

/** Extract text content from an HTML string. */
function htmlToText(html: string): string {
  // Remove unwanted elements entirely
  let text = html
    .replace(
      /<(script|style|noscript|nav|footer|header|aside|iframe|svg|canvas)\b[\s\S]*?<\/\1\s*>/gi,
      "",
    )
    // Self-closing / void elements
    .replace(/<(br|hr)\s*\/?>/gi, "\n")
    // Headings get newlines
    .replace(/<h([1-6])[\s\S]*?<\/h\1\s*>/gi, "\n\n$&\n\n")
    // Block elements get newlines
    .replace(
      /<\/(div|p|li|dt|dd|tr|article|section|main|figure|figcaption|pre|blockquote|details|summary|fieldset|form|table|ul|ol|dl)\s*>/gi,
      "\n",
    )
    // Links — keep text, drop href
    .replace(/<a\b[^>]*>/gi, " ")
    .replace(/<\/a\s*>/gi, " ")
    // Strip remaining tags
    .replace(/<[^>]*>/g, " ")
    // Decode entities
    .replace(/&[#a-z0-9]+;/gi, (m) => {
      try {
        return decodeEntities(m);
      } catch {
        return m;
      }
    });

  // Collapse whitespace
  text = text
    .split("\n")
    .map((l) => l.replace(/\s+/g, " ").trim())
    .filter((l) => l.length > 0)
    .join("\n");

  return text;
}

/** Extract the <title> from raw HTML. */
function extractTitle(html: string): string {
  const m = /<title[\s>][\s\S]*?<\/title\s*>/gi.exec(html);
  if (!m) return "";
  return htmlToText(m[0]).trim();
}

// ── HTTP fetching ───────────────────────────────────────────────────────────

interface FetchResult {
  url: string;
  finalUrl: string;
  status: number;
  contentType: string | null;
  contentLength: number | null;
  title: string;
  text: string;
  truncated: boolean;
}

async function fetchUrl(
  url: string,
  maxBytes: number,
  signal?: AbortSignal,
): Promise<FetchResult> {
  // Wire up abort + timeout
  const timeoutCtrl = new AbortController();
  const timer = setTimeout(() => timeoutCtrl.abort("timeout"), DEFAULT_TIMEOUT_MS);

  const combinedSignal = signal
    ? AbortSignal.any([signal, timeoutCtrl.signal])
    : timeoutCtrl.signal;

  let response: Response;
  try {
    response = await fetch(url, {
      signal: combinedSignal,
      headers: {
        "Accept": "text/html, text/plain, application/xhtml+xml, */*",
        "User-Agent": USER_AGENT,
      },
      redirect: "follow",
    });
  } finally {
    clearTimeout(timer);
  }

  const contentType = response.headers.get("content-type") ?? null;
  const isHtml = contentType
    ? /html/.test(contentType)
    : true; // assume HTML when no content-type

  // Read body up to maxBytes
  const reader = response.body?.getReader();
  if (!reader) throw new Error("Response body is not readable");

  const chunks: Uint8Array[] = [];
  let totalBytes = 0;
  let truncated = false;

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      if (totalBytes + value.length > maxBytes) {
        chunks.push(value.slice(0, maxBytes - totalBytes));
        totalBytes = maxBytes;
        truncated = true;
        break;
      }
      chunks.push(value);
      totalBytes += value.length;
      if (totalBytes >= maxBytes) {
        truncated = true;
        break;
      }
    }
  } finally {
    reader.releaseLock();
  }

  // Decode
  const decoder = new TextDecoder();
  const raw = decoder.decode(concatBytes(chunks));

  // Extract
  const title = isHtml ? extractTitle(raw) : "";
  const text = isHtml ? htmlToText(raw) : raw.trim();
  const finalText = text.length > MAX_CONTENT_LENGTH
    ? text.slice(0, MAX_CONTENT_LENGTH).replace(/\n\S*$/, "") + "\n…[truncated]"
    : text;

  const contentLength = Number.parseInt(
    response.headers.get("content-length") ?? "",
    10,
  ) || null;

  return {
    url,
    finalUrl: response.url,
    status: response.status,
    contentType,
    contentLength,
    title,
    text: finalText,
    truncated: truncated || text.length > MAX_CONTENT_LENGTH,
  };
}

function concatBytes(chunks: Uint8Array[]): Uint8Array {
  const total = chunks.reduce((s, c) => s + c.length, 0);
  const out = new Uint8Array(total);
  let offset = 0;
  for (const c of chunks) {
    out.set(c, offset);
    offset += c.length;
  }
  return out;
}

// ── Formatting ──────────────────────────────────────────────────────────────

function formatFetch(result: FetchResult): string {
  const lines: string[] = [
    `**URL:** ${result.url}`,
  ];

  if (result.finalUrl !== result.url) {
    lines.push(`**Redirected to:** ${result.finalUrl}`);
  }

  if (result.title) {
    lines.push(`**Title:** ${result.title}`);
  }

  lines.push(
    `**Status:** ${result.status} · **Type:** ${result.contentType ?? "unknown"}`,
  );

  if (result.truncated) {
    lines.push(
      `⚠️ Content was truncated (limit ${MAX_CONTENT_LENGTH.toLocaleString()} chars). Use a more specific URL for fuller results.`,
    );
  }

  lines.push("");
  lines.push("---");
  lines.push("");
  lines.push(result.text);

  return lines.join("\n");
}

// ── Extension ───────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "webfetch",
    label: "Web Fetch",
    description:
      "Fetch and extract readable text content from a URL. " +
      "Use this after websearch to read a specific page in full, " +
      "or to access documentation, articles, and other web resources directly.",
    promptSnippet:
      "Fetch and extract text content from a URL (HTML pages, plain text)",
    promptGuidelines: [
      "Use webfetch after websearch when you need to read a specific page in full detail.",
      "Prefer the most specific URL possible — article pages, not section indexes.",
    ],
    parameters: Type.Object({
      url: Type.String({
        description: "The URL to fetch. Must be a full HTTP or HTTPS URL.",
      }),
    }),
    async execute(
      _toolCallId,
      params: { url: string },
      signal,
      onUpdate,
    ) {
      // Basic URL validation
      let url: string;
      try {
        url = new URL(params.url).toString();
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
          throw new Error("Only HTTP and HTTPS URLs are supported");
        }
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        return {
          content: [{ type: "text", text: `Invalid URL: ${msg}` }],
          details: { error: msg },
          isError: true,
        };
      }

      onUpdate?.({
        content: [{ type: "text", text: `Fetching ${url}…` }],
      });

      try {
        const result = await fetchUrl(url, DEFAULT_MAX_BYTES, signal);
        const formatted = formatFetch(result);

        return {
          content: [{ type: "text", text: formatted }],
          details: {
            url: result.url,
            finalUrl: result.finalUrl,
            status: result.status,
            contentType: result.contentType,
            contentLength: result.contentLength,
            title: result.title,
            truncated: result.truncated,
            textLength: result.text.length,
          },
        };
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        return {
          content: [
            {
              type: "text",
              text: `Web fetch failed for ${url}: ${message}`,
            },
          ],
          details: { url, error: message },
          isError: true,
        };
      }
    },
  });
}
