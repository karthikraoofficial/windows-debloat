# Verify — 2026-10-29

Run after the owner rebooted (last boot 2026-10-29 00:52, after Step C finished at 00:47). Build 26200.9711, the same as at audit time, so this is the first verify, not a re-check after a feature update. Nothing was changed. The only things launched were Edge, the Store and a Windows Update search.

**Result: everything passes.** `Invoke-Pester .\tests` → **137 passed, 0 failed** (`Debloat.Tests.ps1` + `Plan.Tests.ps1`).

## Want gone

| Item | Result | Evidence |
|---|---|---|
| Start/Settings suggestions | PASS | ContentDeliveryManager `SystemPaneSuggestionsEnabled`, `SubscribedContent-310093/338388/338389/338393/353694/353696` = 0; `Start_IrisRecommendations` = 0 |
| Settings M365 ads | PASS | Policy `CloudContent\DisableConsumerAccountStateContent` = 1 |
| Silently installed apps | PASS | `SilentInstalledAppsEnabled` = 0, `SoftLandingEnabled` = 0 |
| Lock-screen tips | PASS | `SubscribedContent-338387Enabled` = 0, `RotatingLockScreenOverlayEnabled` = 0 |
| Widgets on the taskbar | PASS | `TaskbarDa` = 0 (switched off by hand in Settings, ADR-0003). WebExperience is still installed (Unsure, kept on purpose) |
| Bing results in Start search | PASS | Policy `DisableSearchBoxSuggestions` = 1, `AllowCortana` = 0, Bing Search app gone |
| Copilot blocked by policy | PASS | `TurnOffWindowsCopilot` = 1 (HKCU + HKLM), `ShowCopilotButton` = 0, no Copilot app |
| Recall blocked by policy | PASS | `DisableAIDataAnalysis` = 1 (HKCU + HKLM), `AllowRecallEnablement` = 0, `TurnOffSavingSnapshots` = 1 |
| Game Bar overlays | PASS | `GameDVR_Enabled` = 0, `AppCaptureEnabled` = 0, policy `AllowGameDVR` = 0, `UseNexusForGameBarEnabled` = 0; `ms-gamebar:` points at `systray.exe`; the 3 overlay packages are gone |
| Xbox identity provider, Xbox TCUI, Gaming app, Edge Game Assist | PASS | Not installed (suite) |
| Microsoft extras (Clipchamp, Mail & Calendar, Maps, To Do, Power Automate, Dev Home, Get Help, Tips, Bing Search/News/Weather, Start Experiences, Solitaire, People, Office hub, classic Teams) | PASS | None installed for this user (suite). Step C's after-check (`logs/stepC-20261029-004644/stepC.log`) found none left for any user or in provisioning, and nothing has been reinstalled since the reboot (AppX deployment log) |
| Telemetry stays minimal | PASS | DiagTrack disabled, `AllowTelemetry` < 2 (suite) |

## Must keep

| Item | Result | Evidence |
|---|---|---|
| Microsoft Store opens | PASS | `ms-windows-store://home` launched and `WinStore.App` was running |
| Microsoft Store can install | PASS (indirect) | Since the reboot the Store/AppX pipeline installed `WinAppRuntime.Main.2` 2.6.4 and VS Code 1.0.144, with no AppX deployment errors. `winget show --source msstore` resolves Store IDs. No new app was installed for this test, since that would change the system |
| Windows Update runs a check | PASS | `Microsoft.Update.Session` search finished in 22 s (ResultCode 2 = succeeded) and found 2 optional driver updates. `wuauserv` Manual/Running, `UsoSvc` Running |
| An antivirus is active | PASS | Security Center: Avast real-time protection on (`0x41000`); Defender off (`0x60100`), as expected with Avast |
| Edge launches | PASS | `msedge.exe --new-window` started (10 processes) |
| Network | PASS | Wi-Fi adapter (Intel Wi-Fi 6 AX101) Up; HTTPS to microsoft.com reachable |
| Bluetooth | PASS | Intel Wireless Bluetooth adapter Status OK, paired devices still listed. `bthserv` is Manual (trigger-start), not Disabled |
| Printer devices | PASS | Spooler Running; Microsoft Print to PDF, Adobe PDF and OneNote queues Normal. No physical printer is installed (none was listed at audit time either) |
| WhatsApp, VS Code, Claude, WSL, Terminal, Notepad, Calculator, Photos, Snipping Tool, Paint, Alarms, Quick Assist, Sticky Notes, Media Player, Sound Recorder, Camera, codecs, runtimes, App Installer/winget | PASS | All installed (suite) |
| Teams (new, `MSTeams`), new Outlook | PASS | Installed (suite). Only classic Teams (`MicrosoftTeams`) was removed |
| Phone Link + Cross Device | PASS | Installed; `PhoneExperienceHost` and `CrossDeviceService` running |
| OneDrive | PASS (note) | Installed, and no policy blocks it. It isn't running because its autostart was switched off in Task Manager on 2024-10-07 and no account is signed in, both from before this project. Debloat only hid its Explorer ads |
| Search finds local apps/files | PASS | `WSearch` and `SearchHost` running; only web results are off |

## Fails and suggested fixes

None.

Optional, not a fail: if you want OneDrive to sync, turn its autostart back on (Task Manager > Startup apps > OneDrive > Enable) and sign in. That was your own earlier choice, so it was left alone.

## Re-check after the 26H2 feature update — 2026-10-29

**Windows 11 26H2** (build 26300.9711) installed at about 01:39 on 2026-10-29, after the verify above. **Nothing came back, and no re-run of Step B/C is needed.**

- `Invoke-Pester .\tests` → **137 passed, 0 failed**.
- **Want gone:** all still off. `TaskbarDa`, `Start_IrisRecommendations`, `ShowCopilotButton` and the lock-screen/suggestion values are 0; the Copilot, Recall, Game DVR and Settings-ads policies are still set; `ms-gamebar:` still points at `systray.exe`.
- **New apps:** none. Every installed package was already on the machine before the debloat (compared with Step A's `appx-allusers.csv`). None of the 23 removed apps came back for this user.
- **Must keep:** Avast active; Windows Update search OK (2 optional drivers); Edge and the Store open; `winget --source msstore` resolves; Wi-Fi up; Bluetooth adapter OK; Spooler running; no AppX deployment errors since the boot. Phone Link wasn't running yet two minutes after boot. It's still installed and starts on demand.

### Getting 26H2 to download (Windows Update issue)

Before it installed, 26H2 stuck at "Downloading 0%" / "Pending download", and the Windows Update page in Settings showed "Something went wrong". The update log showed each attempt failing while Windows worked out which pieces of the upgrade to download, with `0xC190040F`, and the orchestrator then cancelling with `0x8024A10A`.

- 26H2 had been offered since Oct 21, but its first download attempt was after the debloat, so there's no pre-debloat attempt to compare. Whether the debloat played a part is **unknown**.
- Being on battery wasn't the cause: it also failed on mains power.
- Fix tried, with the owner's OK: stopped `wuauserv` and BITS, renamed `C:\Windows\SoftwareDistribution\Download` to `Download.bak-20261029-011929`, and started both services again (log: `logs/wu-reset-20261029-011929.log`). It still failed straight after. 26H2 downloaded and installed some minutes later, so it's unclear whether the reset helped.
- Tidy-up: `Download.bak-20261029-011929` (about 2.3 GB) can be deleted.

If a future feature update sticks the same way, try the Windows 11 Installation Assistant before resetting anything.

## After a feature update

Run `/step4-verify` again. If anything on Want gone came back, pull the latest Win11Debloat tag, re-run `/step2-plan` to check the parameters still match, then re-run `/step3-execute` with the same PLAN.md.
