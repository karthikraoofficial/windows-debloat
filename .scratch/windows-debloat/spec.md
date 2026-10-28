# PRD: Debloat this laptop safely with Win11Debloat

**Status:** done

## Problem Statement

My Windows 11 Home laptop shows ads, tips and suggestions in Start, Settings and the lock screen, silently installs promoted apps, puts widgets and Bing results in my way, and came with apps I never use (Clipchamp, Xbox overlays, Maps, To Do, Dev Home…). Microsoft can also add Copilot and Recall later. I want this gone without breaking anything I rely on, and I want to be able to undo it and redo it after big Windows feature updates.

## Solution

Use Win11Debloat, pinned to a release tag, in four steps, each in a fresh Claude session:

1. **Audit** the machine (read-only) → `audit.md`.
2. **Plan**: map the script's parameters to my Must keep / Want gone lists → `PLAN.md`, which I review.
3. **Execute** `PLAN.md`: Step A backups, Step B registry/privacy tweaks, Step C app removal, each waiting for my "go".
4. **Verify** after I reboot → `verify.md`, with a test suite that turns green.

## User Stories

1. As the laptop owner, I want a read-only audit first, so that I know the starting state before anything changes.
2. As the laptop owner, I want the audit to stop if the device is managed by an organisation, so that I don't fight a policy I don't control.
3. As the laptop owner, I want my installed apps grouped as bloat / keep / unsure, so that I can decide on the unsure ones myself.
4. As the laptop owner, I want Start, Settings and lock-screen suggestions turned off, so that I stop seeing ads.
5. As the laptop owner, I want silent installs of promoted apps turned off, so that apps stop appearing on their own.
6. As the laptop owner, I want widgets hidden from the taskbar, so that the news feed is gone.
7. As the laptop owner, I want Bing results removed from Start search, so that search only finds local things.
8. As the laptop owner, I want Copilot and Recall blocked by policy, so that a future update can't switch them on.
9. As the laptop owner, I want Xbox and gaming components removed, so that I don't carry gaming overlays I don't use.
10. As the laptop owner, I want the Microsoft extras on my Want gone list removed for my account and for new accounts, so that they don't come back with a new user profile.
11. As the laptop owner, I want OneDrive, Phone Link, Teams, new Outlook and my small tools kept, so that my daily workflow is unchanged.
12. As the laptop owner, I want an active antivirus, the Store, Windows Update, Edge, network, Bluetooth and printing to keep working, so that the machine stays maintainable.
13. As the laptop owner, I want a restore point, an app list and registry exports before any change, so that I can undo everything.
14. As the laptop owner, I want the exact commands written down before they run, so that I can review them.
15. As the laptop owner, I want registry tweaks and app removal to be separate commands, so that a problem in one doesn't block undoing the other.
16. As the laptop owner, I want each step to wait for my "go", so that I stay in control.
17. As the laptop owner, I want every run logged to `./logs/`, so that I can see what happened.
18. As the laptop owner, I want revert notes for each step, so that I know how to undo it.
19. As the laptop owner, I want Claude never to reboot, so that I choose when it happens.
20. As the laptop owner, I want a test suite that checks every Must keep and Want gone item, so that verification is repeatable.
21. As the laptop owner, I want to re-run the verification after a feature update, so that I can spot ads or apps that came back.
22. As the laptop owner, I want to re-run Step B/C with a newer Win11Debloat tag and the same plan, so that re-debloating is cheap.
23. As the laptop owner, I want backups and logs kept out of the public repo, so that machine details don't leak.

## Implementation Decisions

- **Tool:** Win11Debloat, cloned at the latest release tag into a gitignored folder. No defaults mode; explicit parameters only (ADR-0001).
- **Lists:** the Must keep and Want gone lists live in the project `CLAUDE.md` and drive both the plan and the tests.
- **Step A** turns on System Restore for C: (it was off at audit time; approved 2026-10-29), creates a restore point, saves the Appx list, and exports the registry keys the chosen parameters touch.
- **Step B** and **Step C** are separate Win11Debloat runs, each logged to `./logs/`.
- **Unsure** apps are left alone. Widgets are hidden by a setting, not by removing WebExperience, because Win11Debloat's `-DisableWidgets` uninstalls WebExperience (ADR-0003). The owner switches widgets off in Settings, because scripts are blocked from writing the `Dsh\AllowNewsAndInterests` policy. _(Updated: #03, #05)_
- **Step scripts:** each of Step A/B/C is one script in `scripts/` run behind one UAC prompt. Their inputs (pinned tag `2026.08.24`, Step B switches, app lists, backup keys) live in `scripts/debloat-lists.psd1`, which the tests read too. _(Added: #03)_
- **Extra removal:** `Microsoft.Edge.GameAssist` isn't in Win11Debloat's catalog, so Step C removes it directly (ADR-0003). _(Added: #03)_
- **Telemetry** is already minimal (DiagTrack disabled, policy at Required), so Step B only needs to keep it that way.
- **Repo:** public on GitHub; `backups/`, `logs/`, `Win11Debloat/`, `*.reg` and `admin-audit.txt` are gitignored (ADR-0002).

## Testing Decisions

- One seam: a Pester suite (`tests/`) that reads the registry, services, network adapters and the Appx list. It checks behaviour the user cares about (is the setting off, is the app present) and never Win11Debloat's internals.
- Written before any change (ticket 02): Want gone tests start red, Must keep tests start green. The verify step (ticket 07) turns the whole suite green.
- Things the suite can't check (Store can install, Windows Update finds updates, Edge launches) are checked by hand in `verify.md`.
- No prior art: this is the repo's first test suite.
- A second file, `tests/Plan.Tests.ps1`, guards the plan's inputs rather than the machine: Step B switches exist in the pinned tag, no defaults mode, and no Step C wildcard can match a Must keep app. It's always green. _(Added: #03)_

## Out of Scope

- Edge settings and Edge removal
- OEM drivers and Acer utilities
- Win32 (non-Appx) uninstalls
- Telemetry beyond what Win11Debloat's chosen parameters do
- Antivirus choice: Avast stays. _(Updated 2026-10-29)_

## Further Notes

- **Antivirus (resolved 2026-10-29):** Avast is the active antivirus, so Windows keeps Defender off. The Must keep item is now "an antivirus is active" instead of "Defender is on". _(Updated 2026-10-29)_
- Feature updates often bring ads and apps back: re-run ticket 07's suite, then ticket 05/06 with a newer tag and the same PLAN.md.

## Comments

- 2026-10-28: Tickets 01 (audit) and 02 (verification suite) done in 1d1ec16. Audit confirmed an unmanaged device, System Restore off on C:, and Avast active instead of Defender. Next on the frontier: 03 (PLAN.md).
- 2026-10-29: Owner approved turning on System Restore for C: in Step A (ticket 04), and chose to keep Avast: Must keep now says "an antivirus is active" and the suite checks Security Center instead of the Defender service. Baseline is now 45 passed / 23 failed (all expected Want gone items).
- 2026-10-29: Ticket 03 done. PLAN.md approved against Win11Debloat `2026.08.24`. Scope changes: widgets hidden by policy and Edge Game Assist removed directly, both outside Win11Debloat (ADR-0003); step scripts and a shared lists file added; new `tests/Plan.Tests.ps1`. Next on the frontier: 04 (Step A).
- 2026-10-29: Tickets 04 (Step A) and 05 (Step B) done. Restore point #1 and backups made. Scope change in 05: scripts are blocked from writing the widgets policy (likely UCPD), so the owner switches widgets off in Settings (ADR-0003 amended). Next on the frontier: 06 (Step C).
- 2026-10-29: Ticket 06 (Step C) done: all 23 Want gone apps removed, full suite 137/137. Next on the frontier: 07 (verify, after the owner reboots). The PRD stays open until 07 ships.
- 2026-10-29: Ticket 07 (verify) done: after the reboot the suite is 137/137 and every manual Must keep check passes (`verify.md`). All seven tickets have shipped, so this PRD is closed. After a feature update, re-run `/step4-verify`.
