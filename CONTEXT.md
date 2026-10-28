# Context

Terms used across this repo's docs, tickets and tests.

- **Must keep** — things that must still work after every step. The list lives in `CLAUDE.md`; the test suite checks it.
- **Want gone** — settings and apps the debloat turns off or removes. The list lives in `CLAUDE.md`.
- **Unsure** — an app on neither list. Left alone unless the owner decides.
- **Bloat** — an installed or provisioned app that is on the Want gone list.
- **Provisioned app** — an Appx package staged for new user accounts. Removing it for the current user only leaves it to come back for new profiles.
- **Audit** — the read-only first step; its result is `audit.md`.
- **Step A / Step B / Step C** — the three parts of `PLAN.md`: backups, registry/privacy tweaks, app removal. Each waits for the owner's "go".
- **Pinned tag** — the Win11Debloat release tag the plan was written against. Never run from `master`.
- **Baseline** — the test-suite result recorded before any change (Want gone red, Must keep green).
- **Feature-update regression** — ads, settings or apps that a Windows feature update turns back on or reinstalls. Found by re-running the suite.
