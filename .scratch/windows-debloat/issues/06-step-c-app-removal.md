# 06: Step C: app removal

**What to build:** The exact Step C app list from PLAN.md removed for the current user and from provisioning, output logged, failures reported. The Want gone app tests turn green and every Must keep app test stays green.

**Blocked by:** 02, 04

**Status:** ready-for-human

- [ ] Runs only after the user types "go"
- [ ] Log saved in ./logs/
- [ ] Failures listed
- [ ] User told whether a reboot is needed; no reboot

## Comments

- 2026-10-29: PLAN.md approved (ticket 03). Runs `scripts/step-c-remove-apps.ps1`: 22 apps through Win11Debloat plus Microsoft.Edge.GameAssist removed directly (ADR-0003); stops before removing if any pattern matches a Must keep app.
