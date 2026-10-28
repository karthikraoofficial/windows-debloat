---
description: Step 2 — clone Win11Debloat at the latest tag and write PLAN.md (ticket 03)
---

Read CLAUDE.md and audit.md.

1. Clone github.com/Raphire/Win11Debloat into ./Win11Debloat, checked out at the latest release tag. Tell me the tag. (If the folder exists, fetch tags and check out the latest.)
2. Read the README and the main script. List every available parameter with a one-line description of what it changes.
3. Map those parameters against the "Must keep" and "Want gone" lists in CLAUDE.md and the audit findings.
4. Write PLAN.md with:
   - Step A: backups (turn on System Restore for C: — already approved — then restore point + app list + registry exports of the keys the chosen params touch, into ./backups/)
   - Step B: registry/privacy tweaks — exact command with explicit parameters
   - Step C: app removal — exact list of packages, separate command
   - How each step runs elevated (VS Code isn't admin: use a UAC prompt) and logs to ./logs/
   - Revert notes: how to undo each step (restore point, any undo .reg files the repo ships, reinstall commands for removed apps)
   - Anything you recommend skipping and why

Do not run anything yet. Show me PLAN.md and wait.

When I approve PLAN.md: close ticket 03 in .scratch/windows-debloat/ with the commit, move 04 to Ready on BOARD.md, add an ADR if the plan makes a surprising choice, then commit and push.
