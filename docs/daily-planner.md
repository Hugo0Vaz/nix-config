# Daily Planner — Pi Extension Plan

## Goal

Give the LLM access to the user's full task/event landscape — Google Calendar +
Tasks, Microsoft Graph (Calendar + To Do), and Obsidian vault tasks — so it can
intelligently plan today's actions. Triggered via a shell alias that sets env
vars from `pass` and launches pi.

## Scope

**In scope:**
- Extension that reads config from **environment variables** (vault path,
  credential file paths)
- Three data fetchers: Google, Microsoft, Obsidian
- All **future** calendar events and all **undone/pending** tasks from each
  source
- Auto-inject aggregated context on `session_start` (so `alias` + `-p "plan my
  day"` works immediately)
- A `/daily-plan` command that refreshes and prints the context visible to the
  LLM
- A `gather_daily_context` tool so the LLM can refresh on demand
  mid-conversation
- A companion shell alias `plan-my-day` that exports env vars from `pass` and
  launches pi
- A credential setup guide for Google Cloud Console and Azure AD app
  registration
- Available on **all hosts** (wired via `cli-tools` aspect)

**Out of scope:**
- Mutating tasks/events (read-only)
- Recurring task intelligence (just raw data)
- Multi-user support
- Push notifications / background sync

## Design

### Architecture

```
plan-my-day (shell alias, added to cli-tools.nix)
  ├─ exports OBSIDIAN_VAULT, GOOGLE_CREDENTIALS_FILE, MICROSOFT_CREDENTIALS_FILE from `pass`
  └─ launches: pi -e daily-planner.ts -p "plan my day"

Extension (modules/dotfiles/pi/agent/extensions/daily-planner/):
  ├─ session_start → gather all sources → inject as persistent message
  ├─ /daily-plan command → re-gather + notify user what was injected
  └─ gather_daily_context tool → re-gather + return formatted data to LLM

  Sources:
    ├─ sources/google.ts       → Calendar events (future) + Tasks (pending)
    ├─ sources/microsoft.ts    → Calendar events (future) + To Do (pending)
    └─ sources/obsidian.ts     → `rg` on vault for `- [ ]` tasks (all .md files)
```

### Data Flow

```
session_start fires
  → read env vars (OBSIDIAN_VAULT, GOOGLE_CREDENTIALS, MICROSOFT_CREDENTIALS)
  → parallel fetch from each configured source
  → aggregate → format as a single structured context block
  → inject via before_agent_start { message }
  → LLM receives context in its first turn
```

### Files

| File | Purpose |
|------|---------|
| `modules/dotfiles/pi/agent/extensions/daily-planner/index.ts` | Entry point: reads env, wires events/tool/command |
| `modules/dotfiles/pi/agent/extensions/daily-planner/sources/google.ts` | Google Calendar API v3 + Tasks API v1 via OAuth 2.0 |
| `modules/dotfiles/pi/agent/extensions/daily-planner/sources/microsoft.ts` | Microsoft Graph API (`me/calendar/events`, `me/todo/lists`) via OAuth 2.0 |
| `modules/dotfiles/pi/agent/extensions/daily-planner/sources/obsidian.ts` | Shells out to `rg` on vault path for task patterns; Node.js fallback |
| `modules/dotfiles/pi/agent/extensions/daily-planner/aggregator.ts` | Merges results, formats plaintext for LLM consumption |
| `modules/dotfiles/pi/agent/extensions/daily-planner/auth.ts` | Shared OAuth helpers (token cache, refresh, browser loopback flow) |
| `modules/aspects/cli-tools.nix` | Add `plan-my-day` shell alias |
| `docs/daily-planner.md` | This document |

### API / Interface

**Environment variables:**

```bash
OBSIDIAN_VAULT=/home/hugomvs/vault             # required for Obsidian source
GOOGLE_CREDENTIALS=/path/to/google-oauth.json   # optional, enables Google
MICROSOFT_CREDENTIALS=/path/to/ms-oauth.json    # optional, enables Microsoft
```

**Tool: `gather_daily_context`**
- No parameters
- Returns formatted text block with all events/tasks
- LLM can call anytime to refresh

**Command: `/daily-plan`**
- No args
- Re-runs all fetchers, notifies user of what was gathered
- If agent is idle, injects result as user message (triggering a turn)

**Injected message format** (in `before_agent_start`):

```text
## Today's Context (auto-gathered)

### Google Calendar (3 events)
| Time | Title |
|------|-------|
| 09:00-10:00 | Standup |
| ... | ... |

### Google Tasks (5 pending)
- [ ] Review PR #42
- ...

### Microsoft Calendar (1 event)
...

### Microsoft To Do (2 tasks)
...

### Obsidian Tasks (7 unchecked)
- [ ] Update nix-config docs
- [ ] Call dentist
...
```

## Credential Setup Plan

### Google

1. Go to [Google Cloud Console](https://console.cloud.google.com) → Create
   project
2. Enable **Calendar API** and **Tasks API**
3. Create OAuth 2.0 Client ID (Desktop app type)
4. Download `client_secret_*.json` → encrypt into `pass` as
   `google-calendar-oauth`
5. First run: extension opens browser via loopback redirect for consent, caches
   refresh token at
   `~/.pi/agent/extensions/daily-planner/.google-token.json`
6. Subsequent runs: silent refresh via cached token

### Microsoft

1. Go to [Azure AD App
   Registrations](https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Register new app (Accounts in this organizational directory only — single
   user)
3. Add delegated permissions: `Calendars.Read`, `Tasks.Read`
4. Create client secret → encrypt into `pass` as `microsoft-graph-oauth`
5. Device code flow (no browser redirect URI needed for CLI)
6. Cache token at
   `~/.pi/agent/extensions/daily-planner/.microsoft-token.json`

### Obsidian

- No auth — just needs `OBSIDIAN_VAULT` pointing to vault root.
- Uses `rg` (ripgrep) to find `- [ ]` unchecked checkboxes in all `.md` files.
- Falls back to Node.js `fs` + regex if `rg` is not available.

## Obsidian Task Format

Plain `- [ ] task text` in any `.md` file within the vault. No special plugins
or date metadata required.

## OAuth Flow

Loopback redirect (localhost:PORT) — appropriate for desktop sessions where a
browser is available. The extension starts a temporary HTTP server, opens the
browser to Google's consent page, captures the redirect, and caches the refresh
token.

## Edge Cases & Error Handling

| Failure | Handling |
|---------|----------|
| Env var not set | Skip that source silently, note in context |
| Network error (Google/MS) | Show last-cached data if available, warn |
| OAuth token expired | Attempt refresh; if fails, prompt user to re-auth |
| Vault path doesn't exist | Log warning, skip Obsidian source |
| Vault has no tasks | Report "No unchecked tasks found" |
| `rg` not installed | Fallback to Node.js `fs` + regex |
| All sources fail | Inject message: "⚠️ Could not gather any context" |
| Rate limiting | Backoff, serve stale data |
| Token cache corrupted | Delete cache, trigger re-auth flow |

## Verification

1. **Unit test each source** by running with env vars set and checking output
2. **Integration test**: run `nix develop` then:
   ```bash
   pi -e modules/dotfiles/pi/agent/extensions/daily-planner/index.ts
   ```
   Then type `/daily-plan` — should show gathered context.
3. **Alias test**: create the alias, run `plan-my-day` — should auto-inject
   context + accept prompt.
4. **Tool test**: ask the LLM "what's on my plate today?" — it should call
   `gather_daily_context` and answer.
5. **Nix eval**:
   ```bash
   nix flake check -L --show-trace --no-write-lock-file
   ```
