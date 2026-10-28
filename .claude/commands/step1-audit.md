---
description: Step 1 — read-only audit of this machine into audit.md (ticket 01)
---

Read CLAUDE.md. Then do a read-only audit of this machine — change nothing.

1. Report Windows edition, version and build (Win 10 or 11, 23H2/24H2/25H2 etc.).
2. Check whether the device is domain-joined, Azure AD/Entra-joined or MDM-enrolled (dsregcmd /status). If it is, stop here and tell me.
3. List installed Appx/MSIX packages (Get-AppxPackage) grouped as: bloat to remove, keep, unsure.
4. Check current state of: ads/suggestions, Spotlight, widgets, Bing in search, Copilot, Recall, telemetry level.
5. Confirm System Restore is enabled on C:.

Admin-only checks: run `scripts/audit-admin.ps1` through a UAC prompt (command in CLAUDE.md) and read `admin-audit.txt`.

Save the findings to audit.md (overwrite, keep the same sections) and run `Invoke-Pester .\tests` to record the test results in it. Give me a short summary.

Tracker: this is ticket 01 in .scratch/windows-debloat/. If it is already done (a re-run after a feature update), add a dated comment to it instead of reopening it.
