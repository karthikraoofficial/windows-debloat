# Audit — 2026-10-28

Read-only. Nothing on the system was changed. Admin-only checks ran through `scripts/audit-admin.ps1` (UAC prompt).

## 1. Windows edition and version

| | |
|---|---|
| Edition | Windows 11 Home Single Language (`CoreSingleLanguage`) |
| Version | 25H2 |
| Build | 26200.9711 |
| Device | Acer Aspire A324-51 (no NPU, not a Copilot+ PC) |

The registry `ProductName` still says "Windows 10". This is a known Microsoft quirk; `Win32_OperatingSystem` reports Windows 11.

## 2. Domain / Entra / MDM

`dsregcmd /status`: AzureAdJoined **NO**, DomainJoined **NO**, EnterpriseJoined **NO**, WorkplaceJoined **NO**.
`HKLM\SOFTWARE\Microsoft\Enrollments` holds only the built-in Deploy/Cloud/Local Authority providers, with no UPN and no MDM URL.

**Result: personal, unmanaged device. Safe to continue.**

## 3. Appx packages

### Installed for this user

**Bloat to remove** (Want gone)
- Clipchamp.Clipchamp
- Microsoft.BingSearch
- Microsoft.GetHelp
- Microsoft.StartExperiencesApp
- Microsoft.Todos
- Microsoft.WindowsMaps
- microsoft.windowscommunicationsapps (old Mail & Calendar)
- Microsoft.PowerAutomateDesktop
- Microsoft.Windows.DevHome
- Microsoft.XboxGameOverlay, Microsoft.XboxGamingOverlay, Microsoft.XboxSpeechToTextOverlay, Microsoft.XboxIdentityProvider
- Microsoft.Edge.GameAssist

**Keep** (Must keep, or needed by something on it)
- Microsoft.WindowsStore, Microsoft.StorePurchaseApp, Microsoft.DesktopAppInstaller, Microsoft.Winget.Source
- Microsoft.SecHealthUI (Defender UI), Microsoft.MicrosoftEdge.Stable
- 5319275A.WhatsAppDesktop, Microsoft.VisualStudioCode, Claude, MicrosoftCorporationII.WindowsSubsystemForLinux, Microsoft.WindowsTerminal
- Microsoft.WindowsNotepad, Microsoft.WindowsCalculator, Microsoft.Windows.Photos, Microsoft.ScreenSketch (Snipping Tool), Microsoft.Paint, Microsoft.WindowsAlarms
- Microsoft.OneDriveSync, Microsoft.YourPhone (Phone Link), MicrosoftWindows.CrossDevice, MSTeams, Microsoft.OutlookForWindows
- Microsoft.MicrosoftStickyNotes, Microsoft.ZuneMusic (Media Player), Microsoft.WindowsSoundRecorder, Microsoft.WindowsCamera
- MicrosoftCorporationII.QuickAssist
- Codecs/extensions: AV1, AVCEncoder, HEIF, MPEG2, Raw, VP9, WebMedia, Webp
- Runtimes: WinAppRuntime.Main.1.8, WinAppRuntime.Main.2, WinAppRuntime.Singleton
- Drivers' control panels: AppUp.IntelGraphicsExperience, RealtekSemiconductorCorp.RealtekAudioControl
- Your own tools: NotepadPlusPlus, JAMSoftware.TreeSizeFreeContextMenu, Microsoft.6365217CE6EB4 (developer-signed, user-installed)

**Unsure** (leave alone unless you say otherwise)
- MicrosoftWindows.Client.WebExperience and Microsoft.WidgetsPlatformRuntime: they host widgets, but WebExperience also serves other shell parts. Hide widgets with a setting instead of removing them.
- Microsoft.ApplicationCompatibilityEnhancements
- MicrosoftWindows.NarratorScript.Excel, MicrosoftWindows.NarratorScript.Outlook (accessibility)

### Provisioned only (not installed for you; installs for new user accounts)

**Bloat to remove:** Microsoft.BingNews, Microsoft.BingWeather, Microsoft.GamingApp, Microsoft.Xbox.TCUI, Microsoft.Getstarted (Tips), Microsoft.MicrosoftSolitaireCollection, Microsoft.People, Microsoft.MicrosoftOfficeHub, MicrosoftTeams (classic Teams), plus the provisioned copies of everything in the list above.

**Unsure:** Microsoft.WindowsFeedbackHub, MicrosoftCorporationII.MicrosoftFamily, Microsoft.ZuneVideo (Films & TV), Microsoft.VCLibs.140.00 (runtime — keep).

## 4. Current state of privacy and ads settings

| Item | State | Evidence |
|---|---|---|
| Ads / suggestions | **ON** | ContentDeliveryManager: SystemPaneSuggestionsEnabled=1, SilentInstalledAppsEnabled=1, SoftLandingEnabled=1, SubscribedContent-338389Enabled=1, PreInstalledAppsEnabled=1, OemPreInstalledAppsEnabled=1, ContentDeliveryAllowed=1. Start recommendations (`Start_IrisRecommendations`) not set = default on. |
| Advertising ID | off | AdvertisingInfo\Enabled=0 |
| Tailored experiences | off | TailoredExperiencesWithDiagnosticDataEnabled=0 |
| Spotlight | off | RotatingLockScreenEnabled=0, RotatingLockScreenOverlayEnabled=0, desktop uses a static wallpaper. No policy blocks it. |
| Widgets | **ON** | `TaskbarDa` not set (default on), WidgetService running, WebExperience installed |
| Bing in search | **ON** | BingSearchEnabled not set, no DisableSearchBoxSuggestions policy, Microsoft.BingSearch installed |
| Copilot | not installed, not blocked | No Copilot app; no TurnOffWindowsCopilot policy |
| Recall | not available, not blocked | Optional feature `Recall` = DisabledWithPayloadRemoved; no NPU; no DisableAIDataAnalysis / AllowRecallEnablement policy |
| Telemetry | already minimal | Policy AllowTelemetry=0 (Home treats it as Required), MaxTelemetryAllowed=1, DiagTrack service Stopped/Disabled |

## 5. System Restore on C:

**OFF.** No volume is listed under `SPP\Clients`, and there are no restore points. (vssadmin shows 8 GB of shadow storage on C:, but that belongs to other shadow copies, not System Restore.)

Step A of the plan can't make a restore point until System Restore is turned on for C:. Turning it on is a system change, so it needs your OK. It's recorded as part of ticket 04.

## Other finding: Defender is off because Avast is active

Security Center lists **Avast Antivirus** (active) and **Windows Defender** (disabled). The WinDefend service is Stopped/Manual and `Get-MpComputerStatus` reports AMRunningMode = Not running. Windows does this automatically when another antivirus registers. It isn't caused by any debloat step, but it conflicts with "Defender is on" in the Must keep list. **Decision (2026-10-29):** keep Avast. The Must keep item is now "an antivirus is active".

## Baseline test run (before any change)

`Invoke-Pester .\tests` → **44 passed, 24 failed.**

- **Failing (expected, Want gone not done yet):** 5 ads/suggestion settings, widgets, Bing in search, Copilot policy, Recall policy, and 14 installed apps (Clipchamp, BingSearch, GetHelp, StartExperiencesApp, Todos, Maps, Mail & Calendar, Power Automate, Dev Home, 4 Xbox packages, Edge Game Assist).
- **Failing (not expected):** "Defender service is running" — see the Avast finding above.
- **Passing:** every Must keep app, Windows Update, Bluetooth, Spooler, network, Edge; advertising ID off; telemetry minimal; Copilot app absent; the provisioned-only bloat isn't installed for this user.

**Re-run 2026-10-29** after switching the Defender test to "an antivirus is active": 45 passed, 23 failed (only the expected Want gone items).
