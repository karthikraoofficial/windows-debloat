# 02: Verification test suite, red first

**What to build:** A Pester suite that checks every Must keep and Want gone item from CLAUDE.md. Run before any change, it records the baseline: Want gone tests fail, Must keep tests pass.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] One test per Want gone setting and app
- [ ] One test per Must keep app, plus Defender, Windows Update, Bluetooth, Spooler, network and Edge
- [ ] Baseline result recorded in audit.md
- [ ] Runs without admin
