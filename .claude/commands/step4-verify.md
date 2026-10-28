---
description: Step 4 — after reboot, check everything and write verify.md (ticket 07). Also the re-check after a feature update.
---

Read CLAUDE.md, PLAN.md and the latest log in ./logs/.

Run `Invoke-Pester .\tests`, re-check everything from the audit and confirm:
- Each "Want gone" item is actually off
- Each "Must keep" item still works (Store opens and can install, Windows Update runs a check, an antivirus is active, Edge launches, network/Bluetooth/printer devices present)

Write verify.md with pass/fail per item and suggest fixes for any fails. Change nothing without asking.

Tracker: if everything passes, close ticket 07 with the commit, close the PRD (spec.md), update BOARD.md, then commit and push.

If this is a re-check after a Windows feature update and things came back: tell me, then suggest pulling the latest Win11Debloat tag (re-run /step2-plan to check the parameters still match) and re-running /step3-execute with the same PLAN.md.
