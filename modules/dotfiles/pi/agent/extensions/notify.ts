/**
 * Pi Notify Extension
 *
 * Sends a native notification when:
 * 1. The agent asks the user a question
 * 2. The agent finishes its turn and is waiting for input
 *
 * Includes the git repo name in the notification body when running inside
 * a git repository.
 *
 * Supported notification backends (tried in order):
 * - notify-send:  Freedesktop desktop notifications (Linux) — works through tmux
 * - Windows toast: Windows Terminal (WSL)
 * - Kitty OSC 99 (when running in Kitty, skipped in tmux/screen)
 * - OSC 777:      Ghostty, iTerm2, WezTerm, rxvt-unicode (skipped in tmux/screen)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { basename } from "node:path";

// ── Git repository detection ─────────────────────────────────────────────────

let repoName: string | null = null;

function detectRepoName(cwd: string): string | null {
  try {
    const { spawnSync } = require("child_process");
    const result = spawnSync("git", ["rev-parse", "--show-toplevel"], {
      cwd,
      encoding: "utf-8",
      timeout: 2000,
    });
    if (result.status === 0 && result.stdout) {
      return basename(result.stdout.trim());
    }
  } catch {
    // not a git repo, or git not available — that's fine
  }
  return null;
}

// ── Terminal notification helpers ────────────────────────────────────────────

function windowsToastScript(title: string, body: string): string {
  const type = "Windows.UI.Notifications";
  const mgr = `[${type}.ToastNotificationManager, ${type}, ContentType = WindowsRuntime]`;
  const template = `[${type}.ToastTemplateType]::ToastText01`;
  const toast = `[${type}.ToastNotification]::new($xml)`;
  return [
    `${mgr} > $null`,
    `$xml = [${type}.ToastNotificationManager]::GetTemplateContent(${template})`,
    `$xml.GetElementsByTagName('text')[0].AppendChild($xml.CreateTextNode('${body}')) > $null`,
    `[${type}.ToastNotificationManager]::CreateToastNotifier('${title}').Show(${toast})`,
  ].join("; ");
}

function notifyOSC777(title: string, body: string): void {
  process.stdout.write(`\x1b]777;notify;${title};${body}\x07`);
}

function notifyOSC99(title: string, body: string): void {
  process.stdout.write(`\x1b]99;i=1:d=0;${title}\x1b\\`);
  process.stdout.write(`\x1b]99;i=1:p=body;${body}\x1b\\`);
}

function notifyWindows(title: string, body: string): void {
  const { execFile } = require("child_process");
  execFile("powershell.exe", [
    "-NoProfile",
    "-Command",
    windowsToastScript(title, body),
  ]);
}

function notifySendAvailable(): boolean {
  if (
    !(
      (process.env.DISPLAY || process.env.WAYLAND_DISPLAY) &&
      process.env.DBUS_SESSION_BUS_ADDRESS
    )
  ) {
    return false;
  }
  try {
    const { spawnSync } = require("child_process");
    const result = spawnSync("which", ["notify-send"], { timeout: 1000 });
    return result.status === 0;
  } catch {
    return false;
  }
}

function notifySend(title: string, body: string): void {
  const { spawn } = require("child_process");
  const p = spawn("notify-send", ["--app-name=pi", title, body], {
    stdio: "ignore",
    detached: true,
  });
  p.on("error", () => {});
  p.unref();
}

function isInMultiplexer(): boolean {
  return !!(process.env.TMUX || process.env.STY);
}

async function notify(title: string, body: string): Promise<void> {
  // 1. Desktop notification (notify-send) — works through tmux/screen
  if (notifySendAvailable()) {
    notifySend(title, body);
    return;
  }

  // 2. Windows Terminal toast
  if (process.env.WT_SESSION) {
    notifyWindows(title, body);
    return;
  }

  // Terminal escape sequences don't work through multiplexers.
  if (isInMultiplexer()) {
    return;
  }

  // 3. Kitty terminal notification
  if (process.env.KITTY_WINDOW_ID) {
    try {
      notifyOSC99(title, body);
      return;
    } catch {
      // fall through
    }
  }

  // 4. OSC 777 terminal notification (Ghostty, iTerm2, WezTerm, etc.)
  notifyOSC777(title, body);
}

// ── Question detection ───────────────────────────────────────────────────────

function isAskingQuestion(text: string): boolean {
  if (!text) return false;

  const lastQLine = text
    .trimEnd()
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean)
    .at(-1);
  if (lastQLine && lastQLine.endsWith("?")) return true;

  const interrogatives = [
    /^(which|what|where|when|why|how|who|whose)\b/i,
    /^(could|would|should|can|will|shall|do|does|did|is|are|was|were|has|have|had|may|might|must)\s+you\b/i,
    /^(please|pls)\s+(let|tell|show|give|run|try|check|confirm|choose|pick|select|decide|clarify)/i,
    /^(do|does)\s+(this|that|it)\s+(look|seem|sound|make\s+sense)/i,
  ];
  for (const re of interrogatives) {
    if (re.test(lastQLine ?? "")) return true;
  }

  const requestPhrases = [
    /\b(what|which)\s+(do|would|should)\s+you\b/i,
    /\byour (thoughts|preference|opinion|choice|input|call)\b/i,
    /\blet me know\b/i,
    /\b(any|your) (questions?|concerns?)\b/i,
    /\bfeel free to\b/i,
    /\bI('ll| will) (wait|let you)/i,
    /\bwhen you('re| are) ready\b/i,
    /\bawaiting (your|user) (input|response|feedback)\b/i,
  ];
  for (const re of requestPhrases) {
    if (re.test(text)) return true;
  }

  return false;
}

function bodyWithRepo(body: string): string {
  return repoName ? `${repoName} · ${body}` : body;
}

// ── Extension ────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    repoName = detectRepoName(ctx.cwd);
  });

  pi.on("agent_end", async (event) => {
    const lastAssistant = [...event.messages]
      .reverse()
      .find((m) => m.role === "assistant");

    if (lastAssistant) {
      const text = extractText(lastAssistant);
      if (isAskingQuestion(text)) {
        await notify("Pi — Question", bodyWithRepo("The agent is asking you something"));
        return;
      }
    }

    await notify("Pi", bodyWithRepo("Ready for input"));
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

function extractText(message: { content: unknown }): string {
  if (typeof message.content === "string") return message.content;
  if (Array.isArray(message.content)) {
    return (message.content as Array<{ type: string; text?: string }>)
      .filter((b) => b.type === "text")
      .map((b) => b.text ?? "")
      .join("\n");
  }
  return "";
}
