# 02: Verification test suite, red first

**What to build:** A Pester suite that checks every Must keep and Want gone item from CLAUDE.md. Run before any change, it records the baseline: Want gone tests fail, Must keep tests pass.

**Blocked by:** 01

**Status:** done

- [x] One test per Want gone setting and app
- [x] One test per Must keep app, plus Defender, Windows Update, Bluetooth, Spooler, network and Edge
- [x] Baseline result recorded in audit.md
- [x] Runs without admin

## Comments

- Closed in 1d1ec16. tests/Debloat.Tests.ps1 written; baseline 44 passed / 24 failed: 23 expected Want gone fails plus the Defender test (Avast, see PRD open question). Baseline recorded in audit.md.
