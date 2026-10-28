# 07: Verify after reboot (Prompt 4)

**What to build:** After the user reboots, the suite is run again and the manual checks done (Store can install, Windows Update runs a check, Edge launches, devices present). verify.md lists pass/fail per item with suggested fixes. Nothing changed without asking.

**Blocked by:** 05, 06

**Status:** done

- [x] Invoke-Pester .\tests is green, or each fail explained in verify.md
- [x] Defender/Avast open question resolved (keep Avast; Must keep = an antivirus is active)
- [x] PRD closed once this ticket ships

## Comments

- Closed 2026-10-29. Verified at e13900f after the owner rebooted (boot 00:52, build 26200.9711, so not a feature-update re-check). `Invoke-Pester .\tests`: 137/137 pass. Manual checks all pass: Store opens (installs checked indirectly through post-reboot Store/AppX updates), Windows Update search succeeds, Avast active, Edge launches, Wi-Fi up, Bluetooth adapter OK, Spooler running. OneDrive is installed but its autostart was switched off by the owner in 2024, before this project. Results in `verify.md`. Nothing changed.
- 2026-10-29: Re-check after the 26H2 feature update (build 26300): suite 137/137, nothing came back, no new apps, so Step B/C don't need a re-run. Before it installed, the 26H2 download kept failing (`0xC190040F`); with the owner's OK the Windows Update download cache was reset (renamed, not deleted). It's unclear whether the debloat or the reset played a part. Written up in `verify.md`.
