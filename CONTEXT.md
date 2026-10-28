# Context

Terms used across this repo's docs, tickets and tests.

- **Must keep** — things that must still work after every step. The list lives in `CLAUDE.md`; the test suite checks it.
- **Want gone** — settings and apps the debloat turns off or removes. The list lives in `CLAUDE.md`.
- **Unsure** — an app on neither list. Left alone unless the owner decides.
- **Bloat** — an installed or provisioned app that is on the Want gone list.
- **Provisioned app** — an Appx package staged for new user accounts. Removing it for the current user only leaves it to come back for new profiles.
- **Audit** — the read-only first step; its result is `audit.md`.
- **Step A / Step B / Step C** — the three parts of `PLAN.md`: backups, registry/privacy tweaks, app removal. Each waits for the owner's "go".
- **Pinned tag** — the Win11Debloat release tag the plan was written against. Never run from `master`. Recorded as `PinnedTag` in the lists file; the step scripts refuse any other tag.
- **Lists file** — `scripts/debloat-lists.psd1`. One place for the pinned tag, Step B switches, Want gone / Must keep apps and the registry keys Step A exports. Read by the step scripts and the tests.
- **Step script** — `scripts/step-a-backups.ps1`, `step-b-tweaks.ps1`, `step-c-remove-apps.ps1`. Each runs one step of `PLAN.md` behind one UAC prompt and logs to `logs/`.
- **Catalog** — Win11Debloat's list of apps it knows how to remove (`Win11Debloat/Config/Apps.json`). `-Apps` skips anything not in it.
- **Extra removal** — a Want gone app missing from the catalog, so Step C removes it directly (currently only `Microsoft.Edge.GameAssist`). See docs/adr/0003.
- **Widgets policy** — `HKLM\SOFTWARE\Policies\Microsoft\Dsh\AllowNewsAndInterests = 0`, how Step B hides widgets instead of `-DisableWidgets` (which uninstalls WebExperience).
- **Baseline** — the test-suite result recorded before any change (Want gone red, Must keep green).
- **Feature-update regression** — ads, settings or apps that a Windows feature update turns back on or reinstalls. Found by re-running the suite.
