# 03: Clone Win11Debloat at the latest tag and write PLAN.md (Prompt 2)

**What to build:** Win11Debloat cloned at the latest release tag into a gitignored folder, every parameter listed with what it changes, mapped against the Must keep / Want gone lists and audit.md, and PLAN.md written with Step A (backups), Step B (tweaks command), Step C (app list + command), revert notes and recommended skips.

**Blocked by:** 01

**Status:** done

- [x] Tag recorded in PLAN.md
- [x] Step B and Step C are separate commands with explicit parameters only
- [x] Step A includes turning on System Restore for C: (off at audit time, approved 2026-10-29)
- [x] Revert notes cover each step
- [x] Nothing is run; user reviews PLAN.md

## Comments

- Closed in 6c91701. PLAN.md approved 2026-10-29 against Win11Debloat `2026.08.24`. Step B: 8 explicit switches plus the widgets policy. Step C: 22 apps through Win11Debloat plus Edge Game Assist removed directly (ADR 0003). Each step is a script in `scripts/` behind one UAC prompt; inputs in `scripts/debloat-lists.psd1`, guarded by `tests/Plan.Tests.ps1` (69/69).
