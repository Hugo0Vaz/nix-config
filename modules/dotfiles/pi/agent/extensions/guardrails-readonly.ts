/**
 * Guardrail: Read-Only Toggle
 *
 * A global toggle that restricts pi to read-only tools (read, grep, find,
 * ls).  Write, edit, and bash are blocked while active.
 *
 * State is persisted in the session and restored on startup/reload.
 * A status indicator is shown in the footer when read-only mode is on.
 *
 * Commands:
 *   /readonly        Toggle read-only mode
 *   /readonly on     Enable read-only mode
 *   /readonly off    Disable read-only mode
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

const READ_ONLY_TOOLS = ["read", "grep", "find", "ls"];
let isReadOnly = false;
// Snapshot of active tools taken before entering read-only mode, so we can
// restore the exact previous set when toggling off.
let previousTools: string[] | null = null;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function applyReadOnly(pi: ExtensionAPI, ui: ExtensionContext["ui"]) {
  if (isReadOnly) {
    previousTools = pi.getActiveTools();
    ui.setStatus("guardrails-readonly", "🔒 read-only");
    pi.setActiveTools(READ_ONLY_TOOLS);
  } else {
    const restore = previousTools ?? pi.getAllTools().map((t) => t.name);
    ui.setStatus("guardrails-readonly", undefined);
    pi.setActiveTools(restore);
    previousTools = null;
  }
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  // Restore state from session on startup / reload
  pi.on("session_start", async (_event, ctx) => {
    const entries = ctx.sessionManager.getBranch();
    // Walk backwards to find the most recent toggle on this branch
    for (let i = entries.length - 1; i >= 0; i--) {
      const entry = entries[i];
      if (entry.type === "custom" && entry.customType === "guardrails-readonly") {
        isReadOnly = entry.data?.enabled === true;
        break;
      }
    }
    applyReadOnly(pi, ctx.ui);
  });

  // Register /readonly command
  pi.registerCommand("readonly", {
    description: "Toggle read-only mode (blocks write, edit, bash)",
    getArgumentCompletions: (prefix: string) => {
      const options = [
        { value: "on", label: "on  — enable read-only" },
        { value: "off", label: "off — disable read-only" },
      ];
      const filtered = options.filter((o) => o.value.startsWith(prefix));
      return filtered.length > 0 ? filtered : null;
    },
    handler: async (args, ctx) => {
      const prev = isReadOnly;

      if (args === "on") isReadOnly = true;
      else if (args === "off") isReadOnly = false;
      else isReadOnly = !isReadOnly;

      if (isReadOnly === prev) return;

      applyReadOnly(pi, ctx.ui);
      pi.appendEntry("guardrails-readonly", { enabled: isReadOnly });

      ctx.ui.notify(
        isReadOnly
          ? "🔒 Read-only mode enabled — write, edit, and bash blocked"
          : "🔓 Read-only mode disabled — all tools available",
        isReadOnly ? "warning" : "info",
      );
    },
  });
}
