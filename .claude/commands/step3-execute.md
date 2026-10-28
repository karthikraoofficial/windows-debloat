---
description: Step 3 — run PLAN.md one step at a time, waiting for "go" (tickets 04, 05, 06)
---

Read CLAUDE.md and PLAN.md. Execute PLAN.md one step at a time:

1. Step A (backups). Show me the restore point name and backup folder, then wait for "go".
2. Step B (tweaks). Run the exact command from PLAN.md, log output to ./logs/. Report results, then wait for "go".
3. Step C (app removal). Run it, log output, report anything that failed.

Each step needs admin: run it through a UAC prompt as PLAN.md describes.

After all steps, tell me whether a reboot is needed. Do not reboot.

Tracker: close tickets 04, 05 and 06 in .scratch/windows-debloat/ as each step finishes (comment with the commit and the log file name), keep BOARD.md in sync, then commit and push. Never commit backups/ or logs/.
