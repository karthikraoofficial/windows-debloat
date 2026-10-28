# 01: Audit the machine (Prompt 1)

**What to build:** A read-only audit of this laptop saved as audit.md: Windows edition/version/build, domain/Entra/MDM status (stop if managed), Appx packages grouped as bloat/keep/unsure, the state of ads, Spotlight, widgets, Bing in search, Copilot, Recall and telemetry, and whether System Restore is on for C:.

**Blocked by:** None (can start immediately)

**Status:** done

- [x] audit.md answers all five audit questions
- [x] Admin-only checks run through a read-only script with a UAC prompt
- [x] Nothing on the system is changed

## Comments

- Closed in 1d1ec16. audit.md written. Not managed (no domain/Entra/MDM). System Restore is OFF on C: (turning it on moved to ticket 04, needs the owner's OK). Extra finding: Avast is the active antivirus, so Defender is off (open question in the PRD).
