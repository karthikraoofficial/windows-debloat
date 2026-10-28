# 06: Step C: app removal

**What to build:** The exact Step C app list from PLAN.md removed for the current user and from provisioning, output logged, failures reported. The Want gone app tests turn green and every Must keep app test stays green.

**Blocked by:** 02, 04

**Status:** done

- [x] Runs only after the user types "go"
- [x] Log saved in ./logs/
- [x] Failures listed (none)
- [x] User told whether a reboot is needed; no reboot

## Comments

- 2026-10-29: PLAN.md approved (ticket 03). Runs `scripts/step-c-remove-apps.ps1`: 22 apps through Win11Debloat plus Microsoft.Edge.GameAssist removed directly (ADR-0003); stops before removing if any pattern matches a Must keep app.
- Closed 2026-10-29. Ran `scripts/step-c-remove-apps.ps1` at 6a1f220 after "go"; log `logs/stepC-20261029-004644/` (`stepC.log`, `Win11Debloat.log`). No removal pattern matched a Must keep app. Win11Debloat removed 22 apps (exit code 0), and Edge Game Assist was removed directly. After-check: all 23 Want gone apps are gone for all users and from provisioning, with no failures. Full suite: 137/137 pass. Reboot needed (owner does it); next is ticket 07.
