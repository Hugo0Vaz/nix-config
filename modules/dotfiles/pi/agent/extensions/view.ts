/**
 * View Extension
 *
 * Registers `/view` — exports the current session to HTML
 * and opens the file in the system browser.
 *
 * Usage:
 *   /view              — writes to a timestamped file in $TMPDIR
 *   /view /path.html   — writes to the specified path
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { spawn } from "node:child_process";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { existsSync } from "node:fs";

// ── Resolve the `pi` binary ─────────────────────────────────────────────────

/**
 * Find the `pi` CLI binary so the subprocess invocation is reliable.
 *
 * When running via a shebang script (e.g., /nix/store/.../bin/pi),
 * `process.argv[1]` holds the script path — use it directly to avoid
 * PATH resolution ambiguities. Falls back to `"pi"` otherwise.
 */
function resolvePiBinary(): string {
  const script = process.argv[1];
  if (script && (script.endsWith("/pi") || script.endsWith("/bin/pi"))) {
    return script;
  }
  return "pi";
}

// ── Open in system browser ──────────────────────────────────────────────────

function openInBrowser(filePath: string): void {
  const platform = process.platform;

  if (platform === "darwin") {
    spawn("open", [filePath], { stdio: "ignore", detached: true }).unref();
  } else if (platform === "win32") {
    spawn("cmd", ["/c", "start", "", filePath], {
      stdio: "ignore",
      detached: true,
    }).unref();
  } else {
    // Linux, BSD, etc.
    spawn("xdg-open", [filePath], { stdio: "ignore", detached: true }).unref();
  }
}

// ── Extension ───────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.registerCommand("view", {
    description: "Export session to HTML and open in browser",
    async handler(args, ctx) {
      const sessionFile = ctx.sessionManager.getSessionFile();

      if (!sessionFile || !existsSync(sessionFile)) {
        ctx.ui.notify(
          "No saved session file — /view requires a saved session.",
          "error",
        );
        return;
      }

      const outputPath = args?.trim()
        || join(tmpdir(), `pi-export-${Date.now()}.html`);

      ctx.ui.notify("Exporting session to HTML…", "info");

      const piBin = resolvePiBinary();

      try {
        await new Promise<void>((resolve, reject) => {
          const proc = spawn(piBin, ["--export", sessionFile, outputPath], {
            stdio: "pipe",
          });

          let stderr = "";
          proc.stderr?.on("data", (d: Buffer) => {
            stderr += d.toString();
          });

          proc.on("close", (code) => {
            if (code === 0) {
              resolve();
            } else {
              reject(
                new Error(
                  stderr.trim() || `pi --export exited with code ${code}`,
                ),
              );
            }
          });

          proc.on("error", reject);
        });

        ctx.ui.notify(`Exported → ${outputPath}`, "success");
        openInBrowser(outputPath);
      } catch (err) {
        ctx.ui.notify(
          `Export failed: ${(err as Error).message}`,
          "error",
        );
      }
    },
  });
}
