# Windows Debloat

Debloats this laptop (Windows 11 Home Single Language 25H2, Acer Aspire A324-51) with [Win11Debloat](https://github.com/Raphire/Win11Debloat) in four steps: Audit → Plan → Execute → Verify. See README.md for the flow and CONTEXT.md for terms.

## Must keep

These must still work after every step. The test suite checks them.

- Microsoft Store (opens and can install), Windows Update, Edge
- An antivirus is active (currently Avast, which keeps Defender switched off)
- Network, Bluetooth, printer devices
- WhatsApp, VS Code, Claude, WSL, Windows Terminal, Notepad, Calculator, Photos, Snipping Tool
- OneDrive, Phone Link + Cross Device, Teams (new, `MSTeams`), new Outlook
- Sticky Notes, Media Player, Sound Recorder, Camera
- Paint, Alarms & Clock, Quick Assist, codecs/media extensions, app runtimes, App Installer/winget

## Want gone

- **Ads, tips and suggestions:** Start/Settings suggestions, silently installed apps, lock-screen tips, widgets on the taskbar, Bing results in Start search
- **Copilot + Recall:** blocked by policy so they can't come back (neither runs today)
- **Xbox/gaming:** Game Bar overlays, Xbox identity provider, Xbox TCUI, Gaming app, Edge Game Assist
- **Microsoft extras:** Clipchamp, Mail & Calendar (old), Maps, To Do, Power Automate, Dev Home, Get Help, Tips, Bing Search, Bing News, Bing Weather, Start Experiences app, Solitaire, People, Office hub, classic Teams (`MicrosoftTeams`)

Anything not on either list is **unsure**: leave it alone unless the user says otherwise.

## Hard rules

- Never reboot. Tell the user when a reboot is needed.
- Never run Step B or Step C without the user typing "go".
- Run Win11Debloat only from a pinned release tag, with explicit parameters (no defaults mode). See docs/adr/0001.
- The plan's inputs (tag, Step B switches, app lists, backup keys) live in `scripts/debloat-lists.psd1`. Change them there and in PLAN.md together; `tests/Plan.Tests.ps1` must stay green.
- Widgets are switched off by hand in Settings (scripts are blocked from writing the widgets policy and `TaskbarDa`), and Edge Game Assist is removed directly, not by Win11Debloat. See docs/adr/0003.
- Never commit `backups/`, `logs/`, `Win11Debloat/`, `*.reg` or `admin-audit.txt`. The repo is public. See docs/adr/0002.
- System Restore was **off** on C: at audit time. The user approved turning it on (2026-10-29); Step A does it before creating the restore point.

## Commands

- Workflow: `/step1-audit`, `/step2-plan`, `/step3-execute`, `/step4-verify` (prompts in `.claude/commands/`; `/clear` between steps)

- Admin read-only audit (UAC prompt): `Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "<repo>\scripts\audit-admin.ps1" -OutFile "<repo>\admin-audit.txt"'`
- Step scripts (one UAC prompt each, only after "go"): `Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "<repo>\scripts\step-a-backups.ps1"'` (likewise `step-b-tweaks.ps1`, `step-c-remove-apps.ps1`)
- Tests (Pester 3.4, Windows PowerShell 5.1): `Invoke-Pester .\tests`

## Agent skills

### Issue tracker

Local markdown under `.scratch/windows-debloat/` (spec.md = PRD, one file per ticket, BOARD.md kanban). See `docs/agents/issue-tracker.md`.

### Triage labels

Default five roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the root. See `docs/agents/domain.md`.
