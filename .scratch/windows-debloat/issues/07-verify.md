# 07: Verify after reboot (Prompt 4)

**What to build:** After the user reboots, the suite is run again and the manual checks done (Store can install, Windows Update runs a check, Edge launches, devices present). verify.md lists pass/fail per item with suggested fixes. Nothing changed without asking.

**Blocked by:** 05, 06

**Status:** ready-for-agent

- [ ] Invoke-Pester .\tests is green, or each fail explained in verify.md
- [x] Defender/Avast open question resolved (keep Avast; Must keep = an antivirus is active)
- [ ] PRD closed once this ticket ships
