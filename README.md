# Windows Debloat

Removes ads, suggestions and unwanted apps from a Windows 11 Home laptop using [Win11Debloat](https://github.com/Raphire/Win11Debloat), with backups first and a test suite to prove nothing important broke.

What stays and what goes is listed in [CLAUDE.md](CLAUDE.md) (Must keep / Want gone).

## The flow

Each step runs in a fresh Claude Code session (`/clear` in between).

1. **Audit** (read-only) → [audit.md](audit.md)
2. **Plan**: clone Win11Debloat at the latest release tag and write `PLAN.md` (backups, tweaks command, app list, revert notes). Review it yourself.
3. **Execute** `PLAN.md`: Step A backups → "go" → Step B tweaks → "go" → Step C app removal. Logs go to `./logs/`. Claude never reboots.
4. **Verify** after you reboot → `verify.md`.

After a big Windows feature update, run step 4 again. If things came back, pull the latest Win11Debloat tag and re-run step 3 with the same `PLAN.md`.

Work is tracked as a PRD and tickets under [.scratch/windows-debloat/](.scratch/windows-debloat/), with a [kanban board](.scratch/windows-debloat/BOARD.md).

## Tests

Windows PowerShell 5.1, no admin needed:

```powershell
Invoke-Pester .\tests
```

Before the debloat, the Want gone tests fail and the Must keep tests pass. After it, everything should pass.

## Admin audit

Some checks (System Restore, provisioned apps) need admin. This read-only script runs them behind a UAC prompt:

```powershell
Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "<repo>\scripts\audit-admin.ps1" -OutFile "<repo>\admin-audit.txt"'
```

## Reverting

`PLAN.md` holds revert notes for each step: the restore point, the undo `.reg` files Win11Debloat ships, and reinstall commands for removed apps. Backups and logs stay on this machine only; they are gitignored because the repo is public.
