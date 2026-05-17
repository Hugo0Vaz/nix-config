/**
 * Guardrail: Write/Edit Scope
 *
 * Blocks write and edit operations targeting paths outside the project
 * root (current working directory).
 *
 * Defaults to DISABLED. Toggle with /write-scope or /write-scope on|off.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { resolve } from "node:path";

// ── State ────────────────────────────────────────────────────────────────────
const CUSTOM_TYPE = "guardrails-write-scope";
let enabled = false;

// ── Extension ────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // Restore persisted state on startup/reload
  pi.on("session_start", async (_event, ctx) => {
    const entries = ctx.sessionManager.getBranch();
    for (let i = entries.length - 1; i >= 0; i--) {
      const entry = entries[i];
      if (entry.type === "custom" && entry.customType === CUSTOM_TYPE) {
        enabled = entry.data?.enabled === true;
        break;
      }
    }
  });

  // Toggle command
  pi.registerCommand("write-scope", {
    description: "Toggle write-scope guardrail (blocks writes/edits outside project root)",
    getArgumentCompletions: (prefix: string) => {
      const options = [
        { value: "on", label: "on  — enable write-scope guardrail" },
        { value: "off", label: "off — disable write-scope guardrail" },
      ];
      return options.filter((o) => o.value.startsWith(prefix));
    },
    handler: async (args, ctx) => {
      const prev = enabled;
      if (args === "on") enabled = true;
      else if (args === "off") enabled = false;
      else enabled = !enabled;
      if (enabled === prev) return;

      pi.appendEntry(CUSTOM_TYPE, { enabled });
      ctx.ui.notify(
        enabled
          ? "📁 Write-scope guardrail enabled — writes/edits limited to project root"
          : "Write-scope guardrail disabled",
        enabled ? "warning" : "info",
      );
    },
  });

  // Gate
  pi.on("tool_call", async (event, ctx) => {
    if (!enabled) return;
    if (event.toolName !== "write" && event.toolName !== "edit") return;

    const targetPath = (event.input.path as string) ?? "";
    const resolvedTarget = resolve(ctx.cwd, targetPath);
    const resolvedCwd = resolve(ctx.cwd);

    if (resolvedTarget === resolvedCwd || resolvedTarget.startsWith(resolvedCwd + "/")) {
      return;
    }

    if (ctx.hasUI) {
      ctx.ui.notify(
        `Blocked ${event.toolName} outside project: ${targetPath}`,
        "warning",
      );
    }

    return {
      block: true,
      reason:
        `Path "${targetPath}" resolves outside the project root (${ctx.cwd}). ` +
        "Write/edit operations are restricted to the project directory.",
    };
  });
}
