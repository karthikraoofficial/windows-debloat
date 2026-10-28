# 04: Step A: backups

**What to build:** System Restore turned on for C: (approved by the owner 2026-10-29), a restore point created, the Appx list saved, and registry exports of the keys Step B touches, all in a gitignored backups folder.

**Blocked by:** 03

**Status:** done

- [x] Restore point name and backup folder shown to the user
- [x] Waits for "go" before Step B

## Comments

- 2026-10-29: Owner approved turning on System Restore for C:. Still runs inside Step A, after PLAN.md is reviewed.
- 2026-10-29: PLAN.md approved (ticket 03). Runs `scripts/step-a-backups.ps1`; backups go to `backups/<time>/`, log to `logs/stepA-<time>.log`.
- Closed 2026-10-29. Ran `scripts/step-a-backups.ps1` at 1d480a5; log `logs/stepA-20261029-003259.log`. System Restore on for C:; restore point #1 "Before Win11Debloat 2026.08.24". Backups in `backups/20261029-003259/`: both app lists (236 all-users, 63 provisioned), 11 registry exports, 10 absent keys in `absent-keys.txt`.
