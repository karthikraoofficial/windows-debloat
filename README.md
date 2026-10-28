# Windows Debloat

Removes ads, suggestions and unwanted apps from a Windows 11 Home laptop using [Win11Debloat](https://github.com/Raphire/Win11Debloat), with backups first and a test suite to prove nothing important broke.

What stays and what goes is listed in [CLAUDE.md](CLAUDE.md) (Must keep / Want gone).

## The flow

Each step is a slash command in Claude Code (saved in [.claude/commands/](.claude/commands/)). Run `/clear`, then type the command. Nothing to paste.

| Type | What it does | You then |
|---|---|---|
| `/step1-audit` | Read-only audit → [audit.md](audit.md) (done) | — |
| `/step2-plan` | Clones Win11Debloat at the latest tag, writes [PLAN.md](PLAN.md) (done, tag `2026.08.24`) | Read PLAN.md, edit if needed, say OK |
| `/step3-execute` | Backups → waits for "go" → tweaks → waits for "go" → app removal. Logs to `./logs/` | Type "go" twice, click Yes on UAC, then reboot yourself |
| `/step4-verify` | Runs the tests and manual checks → [verify.md](verify.md) (done, all pass) | Read verify.md |

Each part of `/step3-execute` runs one script from [scripts/](scripts/) (`step-a-backups.ps1`, `step-b-tweaks.ps1`, `step-c-remove-apps.ps1`) behind a UAC prompt. What they change comes from [scripts/debloat-lists.psd1](scripts/debloat-lists.psd1); to change the plan, edit that file and PLAN.md together.

Claude never reboots. After a big Windows feature update, run `/step4-verify` again. If things came back, it tells you what to re-run.

Work is tracked as a PRD and tickets under [.scratch/windows-debloat/](.scratch/windows-debloat/), with a [kanban board](.scratch/windows-debloat/BOARD.md).

## Tests

Windows PowerShell 5.1, no admin needed:

```powershell
Invoke-Pester .\tests
```

- `tests/Debloat.Tests.ps1` checks the machine. Before the debloat, the Want gone tests fail and the Must keep tests pass. After it, everything should pass.
- `tests/Plan.Tests.ps1` checks the plan inputs: every Step B switch exists in the pinned tag, no defaults mode, and no Step C name can match a Must keep app. It should always pass. The checks against `Win11Debloat/` need the clone (run `/step2-plan` first).

## Admin audit

Some checks (System Restore, provisioned apps) need admin. This read-only script runs them behind a UAC prompt:

```powershell
Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "<repo>\scripts\audit-admin.ps1" -OutFile "<repo>\admin-audit.txt"'
```

## Reverting

`PLAN.md` holds revert notes for each step: the restore point, the undo `.reg` files Win11Debloat ships, and reinstall commands for removed apps. Backups and logs stay on this machine only; they are gitignored because the repo is public.
