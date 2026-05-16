/**
 * Guardrail: Privacy Mode
 *
 * Blocks read operations on files that may contain secrets, credentials,
 * or private keys. Covers the `read` and `grep` tools, plus common
 * bash commands that read file contents (cat, less, head, tail).
 *
 * Defaults to DISABLED. Toggle with /privacy or /privacy on|off.
 *
 * Sensitive paths are matched by:
 *   • File name (e.g., ".env", "credentials", "id_rsa")
 *   • File extension (e.g., ".pem", ".key")
 *   • Directory component (e.g., ".ssh/", ".gnupg/")
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { resolve, basename } from "node:path";

// ── State ────────────────────────────────────────────────────────────────────
const CUSTOM_TYPE = "guardrails-privacy";
let enabled = false;

// ── Sensitive path patterns ──────────────────────────────────────────────────

const SENSITIVE_PATTERNS: Array<{ pattern: string; type: "name" | "ext" | "dir" }> = [
  { pattern: ".env", type: "name" },
  { pattern: ".env.local", type: "name" },
  { pattern: ".env.production", type: "name" },
  { pattern: ".env.development", type: "name" },
  { pattern: "secrets", type: "name" },
  { pattern: "secret", type: "name" },
  { pattern: "credentials", type: "name" },
  { pattern: ".ssh", type: "dir" },
  { pattern: ".gnupg", type: "dir" },
  { pattern: ".aws", type: "dir" },
  { pattern: ".config/gcloud", type: "dir" },
  { pattern: ".pem", type: "ext" },
  { pattern: ".key", type: "ext" },
  { pattern: ".crt", type: "ext" },
  { pattern: ".cert", type: "ext" },
  { pattern: ".pkcs12", type: "ext" },
  { pattern: ".pfx", type: "ext" },
  { pattern: "token", type: "name" },
  { pattern: "tokens", type: "name" },
  { pattern: "password", type: "name" },
  { pattern: "passwords", type: "name" },
  { pattern: "api_key", type: "name" },
  { pattern: "apikey", type: "name" },
  { pattern: ".netrc", type: "name" },
  { pattern: ".htpasswd", type: "name" },
  { pattern: "auth.json", type: "name" },
  { pattern: "pgpass", type: "name" },
  { pattern: ".my.cnf", type: "name" },
  { pattern: "id_rsa", type: "name" },
  { pattern: "id_ed25519", type: "name" },
  { pattern: "id_ecdsa", type: "name" },
  { pattern: "id_dsa", type: "name" },
  { pattern: "known_hosts", type: "name" },
];

// ── Helpers ──────────────────────────────────────────────────────────────────

function isSensitivePath(targetPath: string, cwd: string): boolean {
  const resolved = resolve(cwd, targetPath);
  const normalized = resolved.toLowerCase();
  const name = basename(resolved).toLowerCase();

  return SENSITIVE_PATTERNS.some(({ pattern, type }) => {
    const p = pattern.toLowerCase();
    switch (type) {
      case "name":
        return name === p;
      case "ext":
        return name.endsWith(p);
      case "dir":
        return normalized.includes(`/${p}/`) || normalized.endsWith(`/${p}`);
      default:
        return false;
    }
  });
}

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
  pi.registerCommand("privacy", {
    description: "Toggle privacy guardrail (blocks reads on secrets, keys, .env, etc.)",
    getArgumentCompletions: (prefix: string) => {
      const options = [
        { value: "on", label: "on  — enable privacy guardrail" },
        { value: "off", label: "off — disable privacy guardrail" },
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
          ? "🔐 Privacy guardrail enabled"
          : "Privacy guardrail disabled",
        enabled ? "warning" : "info",
      );
    },
  });

  // Gate
  pi.on("tool_call", async (event, ctx) => {
    if (!enabled) return;

    // --- Block read tool on sensitive paths ---
    if (event.toolName === "read") {
      const targetPath = (event.input.path as string) ?? "";
      if (!targetPath) return;

      if (isSensitivePath(targetPath, ctx.cwd)) {
        if (ctx.hasUI) {
          ctx.ui.notify(`Privacy: blocked read on ${targetPath}`, "warning");
        }
        return {
          block: true,
          reason:
            `Reading "${targetPath}" is blocked by privacy guardrail. ` +
            "This path matches sensitive file patterns (secrets, credentials, keys).",
        };
      }
    }

    // --- Block grep tool on sensitive directories ---
    if (event.toolName === "grep") {
      const targetPath = ((event.input.path || event.input.directory) as string) ?? "";
      if (!targetPath) return;

      if (isSensitivePath(targetPath, ctx.cwd)) {
        if (ctx.hasUI) {
          ctx.ui.notify(`Privacy: blocked grep on ${targetPath}`, "warning");
        }
        return {
          block: true,
          reason:
            `Searching "${targetPath}" is blocked by privacy guardrail. ` +
            "This path matches sensitive file patterns.",
        };
      }
    }

    // --- Block bash commands that read sensitive files ---
    if (event.toolName === "bash") {
      const command = (event.input.command as string) ?? "";
      const readPattern = /\b(?:cat|less|head|tail|strings|bat|nl)\s+(['"]?)([^\s'";|&`$()]+)\1?/gi;

      let match: RegExpExecArray | null;
      while ((match = readPattern.exec(command)) !== null) {
        const filePath = match[2];
        if (filePath && isSensitivePath(filePath, ctx.cwd)) {
          if (ctx.hasUI) {
            ctx.ui.notify(`Privacy: blocked reading ${filePath} via bash`, "warning");
          }
          return {
            block: true,
            reason: `Reading "${filePath}" via bash is blocked by privacy guardrail.`,
          };
        }
      }
    }
  });
}
