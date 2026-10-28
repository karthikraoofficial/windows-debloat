# 05: Step B: registry and privacy tweaks

**What to build:** The exact Step B command from PLAN.md run, output logged to ./logs/, results reported. The ads, widgets, Bing, Copilot and Recall tests in the suite turn green.

**Blocked by:** 02, 04

**Status:** done

- [x] Runs only after the user types "go"
- [x] Log saved in ./logs/
- [x] Setting tests from ticket 02 pass (after reboot if needed); widgets once the owner switches them off in Settings
- [x] No reboot

## Comments

- 2026-10-29: PLAN.md approved (ticket 03). Runs `scripts/step-b-tweaks.ps1`: 8 Win11Debloat switches plus the widgets policy (ADR-0003).
- Closed 2026-10-29. Ran `scripts/step-b-tweaks.ps1` at 1d480a5 after "go"; log `logs/stepB-20261029-003605/` (`stepB.log`, `Win11Debloat.log`, `widgets-retry.log`). All 8 switches applied, exit code 0; Bing Search removed; Win11Debloat's JSON backup copied to `backups/`. The widgets policy (`Dsh\AllowNewsAndInterests`) was refused with "Access is denied" even elevated, by both `reg.exe` and `New-ItemProperty`, likely because of the UCPD driver. The owner chose to switch widgets off in Settings; ADR-0003 is amended, and the script no longer writes the policy (scope change committed with this close). Suite after Step B: every ads, Bing, Copilot and Recall test passes. Widgets is waiting on the Settings toggle; the other failures are Step C apps.
