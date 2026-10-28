# 05: Step B: registry and privacy tweaks

**What to build:** The exact Step B command from PLAN.md run, output logged to ./logs/, results reported. The ads, widgets, Bing, Copilot and Recall tests in the suite turn green.

**Blocked by:** 02, 04

**Status:** ready-for-human

- [ ] Runs only after the user types "go"
- [ ] Log saved in ./logs/
- [ ] Setting tests from ticket 02 pass (after reboot if needed)
- [ ] No reboot

## Comments

- 2026-10-29: PLAN.md approved (ticket 03). Runs `scripts/step-b-tweaks.ps1`: 8 Win11Debloat switches plus the widgets policy (ADR-0003).
