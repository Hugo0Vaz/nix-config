/**
 * Guardrail: Dangerous Bash Commands
 *
 * Blocks potentially dangerous bash commands with a confirmation prompt.
 * Defaults to DISABLED. Toggle with /dangerous-bash or /dangerous-bash on|off.
 *
 * Dangerous patterns detected:
 *   • Recursive delete (rm -rf)
 *   • Privilege escalation (sudo)
 *   • World-writable permissions (chmod 777)
 *   • Pipe to shell (curl/wget | bash)
 *   • Write to device (> /dev/...)
 *   • Format filesystem (mkfs)
 *   • dd to device
 *   • Force push (git push --force)
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

// ── State ────────────────────────────────────────────────────────────────────
const CUSTOM_TYPE = "guardrails-bash";
let enabled = false;

// ── Patterns ─────────────────────────────────────────────────────────────────

const DANGEROUS_PATTERNS: Array<{ pattern: RegExp; label: string }> = [
  { pattern: /\brm\s+.*(?:-r|-rf?|--recursive)\b/i, label: "recursive delete (rm -rf)" },
  { pattern: /\bsudo\b/i, label: "privilege escalation (sudo)" },
  { pattern: /\bchmod\b.*777/i, label: "world-writable permissions (chmod 777)" },
  { pattern: /\bcurl\b.+\|.+(?:ba)?sh\b/i, label: "curl pipe to shell" },
  { pattern: /\bwget\b.+\|.+(?:ba)?sh\b/i, label: "wget pipe to shell" },
  { pattern: />\s*\/dev\//i, label: "write to device" },
  { pattern: /\bmkfs\b/i, label: "format filesystem (mkfs)" },
  { pattern: /\bdd\b.*of=\/dev\//i, label: "dd to device" },
  { pattern: /\bgit\s+push\s+--force\b/i, label: "force push (git push --force)" },
];

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
  pi.registerCommand("dangerous-bash", {
    description: "Toggle dangerous-bash guardrail (blocks rm -rf, sudo, curl|bash, etc.)",
    getArgumentCompletions: (prefix: string) => {
      const options = [
        { value: "on", label: "on  — enable dangerous-bash guardrail" },
        { value: "off", label: "off — disable dangerous-bash guardrail" },
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
          ? "🛡️  Dangerous-bash guardrail enabled"
          : "Dangerous-bash guardrail disabled",
        enabled ? "warning" : "info",
      );
    },
  });

  // Gate
  pi.on("tool_call", async (event, ctx) => {
    if (!enabled) return;
    if (event.toolName !== "bash") return;

    const command = (event.input.command as string) ?? "";
    const matches = DANGEROUS_PATTERNS.filter((p) => p.pattern.test(command));
    if (matches.length === 0) return;

    const labels = matches.map((m) => `  • ${m.label}`).join("\n");

    if (!ctx.hasUI) {
      return {
        block: true,
        reason: `Dangerous command blocked in non-interactive mode. Matched:\n${labels}`,
      };
    }

    const choice = await ctx.ui.select(
      `\n⚠️  Dangerous command detected:\n\n    ${command}\n\n  Matched patterns:\n${labels}\n\n  Allow execution?`,
      ["No, block it", "Yes, run it"],
    );

    if (choice !== "Yes, run it") {
      return { block: true, reason: "Blocked by user" };
    }
  });
}
