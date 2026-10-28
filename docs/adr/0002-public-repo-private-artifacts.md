# 2. Public repo, machine artifacts stay local

**Status:** accepted (2026-10-28)

## Context

The owner wants the repo on GitHub as a public repo. The work produces registry exports, run logs and admin audit output that can contain user paths, SIDs and device identifiers.

## Decision

- Commit the docs, plan, tickets, scripts, tests, `audit.md` and later `verify.md`. These hold the OS build, device model and app names, which the owner is fine publishing.
- Gitignore `backups/`, `logs/`, `Win11Debloat/` (third-party clone), `*.reg` and `admin-audit.txt`.

## Consequences

- Backups exist only on this laptop. Losing the disk loses them; the restore point lives on the same disk anyway.
- Before each commit, check that nothing from the ignored paths was force-added.
