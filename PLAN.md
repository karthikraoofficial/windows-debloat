# Plan — 2026-10-29

**Win11Debloat tag: `2026.08.24`** (commit `f431c56`, released 2026-08-24, the latest release). It's cloned into `./Win11Debloat/`, which is gitignored. The scripts below refuse to run if the clone is at any other tag.

Nothing in this plan has been run. Each step waits for you to type **"go"**, and Claude never reboots.

| Step | What | One UAC prompt runs | Changes the system? |
|---|---|---|---|
| A | Turn on System Restore for C:, restore point, app lists, registry exports | [scripts/step-a-backups.ps1](scripts/step-a-backups.ps1) | Turns System Restore on (approved 2026-10-29) |
| B | Ads, tips, Bing, Copilot/Recall policy, Game Bar, widgets | [scripts/step-b-tweaks.ps1](scripts/step-b-tweaks.ps1) | Registry and policy only, plus removes `Microsoft.BingSearch` (see B notes) |
| C | Remove 23 Want gone apps for all users and from provisioning | [scripts/step-c-remove-apps.ps1](scripts/step-c-remove-apps.ps1) | Uninstalls apps |

The inputs for all three steps (pinned tag, Step B switches, app lists, registry keys) live in one file: [scripts/debloat-lists.psd1](scripts/debloat-lists.psd1). The two test files read the same file. [tests/Plan.Tests.ps1](tests/Plan.Tests.ps1) checks the following:

- every Step B switch exists in the pinned tag, and none is a forbidden one (defaults mode, `-DisableWidgets`, `-ForceRemoveEdge`, …)
- every Want gone app is in Win11Debloat's catalog or handled directly
- no removal wildcard (`*name*`) can match a Must keep app or any other installed package
- no wrapper uses defaults mode, saved settings or a reboot

Current result: 69/69 pass. The main suite is unchanged from the baseline: 45 pass and 23 fail, and the 23 failures are the Want gone items.

---

## How each step runs elevated and logs

VS Code isn't elevated, so each step is started with one UAC prompt. Click **Yes**. A PowerShell window opens, runs the step and closes.

```powershell
$repo = 'C:\Users\Karthik Rao\Documents\VS Code\Windows Debloat'
Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$repo\scripts\step-a-backups.ps1`""
# Step B / Step C: the same line with step-b-tweaks.ps1 / step-c-remove-apps.ps1
```

| Step | Log | Backups |
|---|---|---|
| A | `logs\stepA-<time>.log` | `backups\<time>\` |
| B | `logs\stepB-<time>\stepB.log` + `Win11Debloat.log` (Win11Debloat's own transcript) | Win11Debloat's JSON registry backup is copied into `backups\` |
| C | `logs\stepC-<time>\stepC.log` + `Win11Debloat.log` | — (Step A's app lists) |

`logs/` and `backups/` are gitignored (docs/adr/0002). Win11Debloat runs in a child `powershell.exe` (Windows PowerShell 5.1; the tag refuses to run under pwsh 7) with `-Silent`, so it never waits on a key press or prompt. Each of its runs ends by restarting Explorer: the taskbar flickers, and nothing reboots.

---

## Step A: backups

[scripts/step-a-backups.ps1](scripts/step-a-backups.ps1) does this, in order, and stops at the first error:

1. `Enable-ComputerRestore -Drive C:\`: turns System Restore on (it was **off** at audit time; approved 2026-10-29).
2. `Checkpoint-Computer -Description "Before Win11Debloat 2026.08.24" -RestorePointType MODIFY_SETTINGS`, then reads it back with `Get-ComputerRestorePoint`. **If no restore point appears, the script stops and Step B must not run.**
3. Saves `appx-allusers.csv` (`Get-AppxPackage -AllUsers`) and `appx-provisioned.csv` (`Get-AppxProvisionedPackage -Online`).
4. Runs `reg export` on each of the 21 keys that Step B touches (listed in `BackupKeys` in the lists file). Keys that don't exist yet (most of the policy keys) go into `absent-keys.txt` instead, because undoing them means deleting them.

Claude then shows you the restore point name and number and the backup folder, and waits for **"go"**.

---

## Step B: registry and privacy tweaks

Exact Win11Debloat command (from the repo root, run by [scripts/step-b-tweaks.ps1](scripts/step-b-tweaks.ps1)):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Win11Debloat\Win11Debloat.ps1 -Silent -LogPath .\logs\stepB-<time> `
  -DisableSuggestions -DisableLockscreenTips -DisableSettings365Ads -DisableBing `
  -DisableCopilot -DisableRecall -DisableDVR -DisableGameBarIntegration
```

Then one value outside Win11Debloat, to hide widgets:

```powershell
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f
```

| Switch | What it sets | Want gone item | Test it turns green |
|---|---|---|---|
| `-DisableSuggestions` | ContentDeliveryManager: `SystemPaneSuggestionsEnabled`, `SilentInstalledAppsEnabled`, `SoftLandingEnabled`, `SubscribedContent-310093/338388/338389/338393/353694/353696/353698` = 0; `Start_IrisRecommendations` = 0; Settings account notifications, "finish setting up" nags, OneDrive sync-provider ads in Explorer, Backup reminder toasts, "Suggested" toasts, Phone Link *suggestions* (`Mobility\OptedIn`) off | Start/Settings suggestions, silently installed apps | 5 ads/suggestion tests |
| `-DisableLockscreenTips` | `SubscribedContent-338387Enabled`, `RotatingLockScreenOverlayEnabled` = 0 | Lock-screen tips | (already 0; makes it stick) |
| `-DisableSettings365Ads` | Policy `CloudContent\DisableConsumerAccountStateContent` = 1 | Settings suggestions (M365 ads on Settings Home) | — |
| `-DisableBing` | Policy `HKCU\…\Explorer\DisableSearchBoxSuggestions` = 1; `Windows Search\AllowCortana`, `CortanaConsent` = 0. **Also uninstalls `Microsoft.BingSearch` for all users.** | Bing results in Start search; Bing Search app | Bing in search |
| `-DisableCopilot` | `ShowCopilotButton` = 0; policy `TurnOffWindowsCopilot` = 1 (HKCU + HKLM). Also tries to uninstall `Microsoft.Copilot` / Store Copilot; neither is installed, so this is a no-op. | Copilot blocked by policy | Copilot policy |
| `-DisableRecall` | Policy `WindowsAI\DisableAIDataAnalysis` = 1 (HKCU + HKLM), `AllowRecallEnablement` = 0, `TurnOffSavingSnapshots` = 1 | Recall blocked by policy | Recall policy |
| `-DisableDVR` | `GameDVR_Enabled`, `AppCaptureEnabled` = 0; policy `AllowGameDVR` = 0 | Game Bar overlays (game/screen recording) | — |
| `-DisableGameBarIntegration` | `UseNexusForGameBarEnabled` = 0; points `ms-gamebar:` / `ms-gamebarservices:` links at `systray.exe`, so removing Game Bar in Step C doesn't cause "you need an app to open this" pop-ups | Game Bar overlays | — |
| *(reg add)* `Dsh\AllowNewsAndInterests` = 0 | Turns the widgets board off (taskbar and lock screen) without uninstalling anything | Widgets on the taskbar | Widgets |

Win11Debloat first saves its own JSON backup of every value it will change (we don't pass `-SkipRegistryBackup`), and the wrapper copies that file into `backups\`. We don't pass `-CreateRestorePoint`, because Step A already made one.

**Why widgets aren't done with `-DisableWidgets`:** at this tag, that switch sets no registry value. It *uninstalls* `MicrosoftWindows.Client.WebExperience`, `Microsoft.WidgetsPlatformRuntime` and `Microsoft.StartExperiencesApp` (Scripts/Features/Invoke-Changes.ps1). The audit put WebExperience in **Unsure** because it also serves other shell parts, so we hide widgets with the policy instead. `HKCU\…\TaskbarDa` would also work, but recent builds block scripts from writing it (UCPD driver); the policy is reliable, and the test accepts either.

Reboot or sign out after Step B so Start, the taskbar and the policies refresh. Claude will tell you; it won't do it.

---

## Step C: app removal

Exact Win11Debloat command (run by [scripts/step-c-remove-apps.ps1](scripts/step-c-remove-apps.ps1)):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Win11Debloat\Win11Debloat.ps1 -Silent -LogPath .\logs\stepC-<time> `
  -RemoveApps -AppRemovalTarget AllUsers -Apps "Clipchamp.Clipchamp,Microsoft.BingSearch,Microsoft.BingNews,Microsoft.BingWeather,Microsoft.GetHelp,Microsoft.Getstarted,Microsoft.StartExperiencesApp,Microsoft.Todos,Microsoft.WindowsMaps,microsoft.windowscommunicationsapps,Microsoft.PowerAutomateDesktop,Microsoft.Windows.DevHome,Microsoft.MicrosoftSolitaireCollection,Microsoft.People,Microsoft.MicrosoftOfficeHub,MicrosoftTeams,Microsoft.XboxGameOverlay,Microsoft.XboxGamingOverlay,Microsoft.XboxSpeechToTextOverlay,Microsoft.XboxIdentityProvider,Microsoft.Xbox.TCUI,Microsoft.GamingApp"
```

Then one package outside Win11Debloat, because its catalog (`Config/Apps.json`) doesn't list it and would skip it:

```powershell
Get-AppxPackage -AllUsers -Name Microsoft.Edge.GameAssist | Remove-AppxPackage -AllUsers
Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq Microsoft.Edge.GameAssist | Remove-AppxProvisionedPackage -Online -AllUsers
```

`-AppRemovalTarget AllUsers` (the default, passed explicitly) runs `Remove-AppxPackage -AllUsers` and `Remove-ProvisionedAppxPackage`, so the apps don't come back for new accounts. All 22 use Win11Debloat's Appx method; none use winget.

| Package | Want gone item | State now |
|---|---|---|
| Clipchamp.Clipchamp | Clipchamp | installed |
| microsoft.windowscommunicationsapps | Mail & Calendar (old) | installed |
| Microsoft.WindowsMaps | Maps | installed |
| Microsoft.Todos | To Do | installed |
| Microsoft.PowerAutomateDesktop | Power Automate | installed |
| Microsoft.Windows.DevHome | Dev Home | installed |
| Microsoft.GetHelp | Get Help | installed |
| Microsoft.Getstarted | Tips | provisioned |
| Microsoft.BingSearch | Bing Search | installed (Step B removes it first; listed again as a safety net) |
| Microsoft.BingNews | Bing News | provisioned |
| Microsoft.BingWeather | Bing Weather | provisioned |
| Microsoft.StartExperiencesApp | Start Experiences app | installed |
| Microsoft.MicrosoftSolitaireCollection | Solitaire | provisioned |
| Microsoft.People | People | provisioned |
| Microsoft.MicrosoftOfficeHub | Office hub | provisioned |
| MicrosoftTeams | classic Teams (new Teams `MSTeams` stays) | provisioned |
| Microsoft.XboxGameOverlay, Microsoft.XboxGamingOverlay, Microsoft.XboxSpeechToTextOverlay | Game Bar overlays | installed |
| Microsoft.XboxIdentityProvider | Xbox identity provider | installed |
| Microsoft.Xbox.TCUI | Xbox TCUI | provisioned |
| Microsoft.GamingApp | Gaming app | provisioned |
| Microsoft.Edge.GameAssist | Edge Game Assist | installed (direct removal) |

**Safety checks inside the script:**

- **Before removal:** it logs exactly what each `*name*` pattern matches (all users and provisioned). If any match is a Must keep app, it stops before removing anything.
- **After removal:** it lists anything still present and prints FAILED with the count.

Reboot after Step C so Start and the taskbar refresh. Claude will tell you; it won't do it.

---

## Revert notes

**Undo everything at once:** System Restore → "Before Win11Debloat 2026.08.24" (`rstrui.exe`). This reliably rolls back registry and policy changes. It does **not** reliably bring back Store apps, so use the reinstall table below for those.

### Step A

Nothing to undo. Leave System Restore on at least until Step 4 (verify) passes. To turn it off later: `Disable-ComputerRestore -Drive C:\` (this deletes the restore points).

### Step B (elevated PowerShell, from the repo root)

1. **Exact previous values:** `reg import backups\<time>\NN-<key>.reg` for each exported key. Then `reg delete "<key>" /f` for each key in `backups\<time>\absent-keys.txt` (they didn't exist before Step B).
2. **Per feature, back to Windows defaults:** Win11Debloat ships undo files. These set Windows defaults, which may differ slightly from what you had (e.g. `Enable_DVR.reg` sets `AllowGameDVR=1` instead of deleting it).

   | Switch | Undo file |
   |---|---|
   | DisableSuggestions | `Win11Debloat\Regfiles\Undo\Enable_Windows_Suggestions.reg` |
   | DisableLockscreenTips | `…\Undo\Enable_Lockscreen_Tips.reg` |
   | DisableSettings365Ads | `…\Undo\Enable_Settings_365_Ads.reg` |
   | DisableBing | `…\Undo\Enable_Bing_Cortana_In_Search.reg` (then reinstall Bing Search, below) |
   | DisableCopilot | `…\Undo\Enable_Copilot.reg` |
   | DisableRecall | `…\Undo\Enable_AI_Recall.reg` |
   | DisableDVR | `…\Undo\Enable_DVR.reg` |
   | DisableGameBarIntegration | `…\Undo\Enable_Game_Bar_Integration.reg` |

   Run with `reg import "<path>"`, or use Win11Debloat's GUI (run it without parameters → *Restore backup*), which reads the JSON backup in `Win11Debloat\Backups\` (a copy is in `backups\`).
3. **Widgets:** `reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /f`

### Step C

Reinstall with `winget install --id <ID> --source msstore`, or from the Store app. These IDs were checked with `winget show` on 2026-10-29.

| App | Store ID |
|---|---|
| Clipchamp | 9P1J8S7CCWWT |
| Microsoft To Do | 9NBLGGH5R558 |
| Power Automate | 9NFTCH6J7FHV |
| Get Help | 9PKDZBMV1H3T |
| Microsoft News (BingNews) | 9WZDNCRFHVFW |
| MSN Weather (BingWeather) | 9WZDNCRFJ3Q2 |
| Microsoft 365 Copilot (Office hub) | 9WZDNCRD29V9 |
| Xbox (GamingApp) | 9MV0B5HZVK9Z |
| Game Bar (XboxGamingOverlay; pulls its dependencies) | 9NZKPSTSNW4P |
| Xbox Identity Provider | 9WZDNCRD1HKW |
| Xbox Live in-game experience (Xbox.TCUI) | 9NKNC0LD5NN6 |

The following apps can't be reinstalled through winget:

- **Retired by Microsoft:** Mail & Calendar (replaced by new Outlook, which you keep), People, classic Teams (new Teams stays) and Dev Home (its Store ID now points to "Windows Advanced Settings").
- **Not found by winget on 2026-10-29:** Maps, Solitaire and Tips. Search for them in the Store app.
- **Return on their own with Windows or Edge updates:** Bing Search, Start Experiences app and Edge Game Assist. Step 4 (verify) catches it if they do.

---

## Every Win11Debloat parameter at `2026.08.24`

Decision key: **B** = Step B, **C** = Step C, **skip** = not used (reason given), **ctl** = run control.

### Run control

| Parameter | What it does | Decision |
|---|---|---|
| `-Silent` | No prompts or key presses | ctl: used |
| `-LogPath <dir>` | Writes `Win11Debloat.log` transcript into an existing folder | ctl: used (`logs\step?-<time>`) |
| `-CLI` | Use the text menu instead of the GUI | skip: switches run without any menu |
| `-RunDefaults` / `-RunDefaultsLite` | Apply the recommended set | **skip, never**: ADR 0001. The default app list includes Sticky Notes, Alarms, Sound Recorder, Quick Assist and new Teams (`MSTeams`), all Must keep |
| `-RunSavedSettings` / `-Config <file>` | Re-apply a saved selection | skip: not explicit |
| `-Sysprep` | Apply to the Default user profile | skip: not needed |
| `-User <name>` | Apply to another user | skip: one user |
| `-AppRemovalTarget` | `AllUsers` / `CurrentUser` / a user name | C: `AllUsers` |
| `-SkipExplorerRestart` | Don't restart Explorer at the end | skip: the restart is harmless and shows the changes |
| `-CreateRestorePoint` | Make a restore point (turns System Restore on if needed) | skip: Step A does this itself and checks it worked |
| `-SkipRegistryBackup` | Don't write Win11Debloat's JSON backup | skip: we want that backup |
| `-WhatIf` | Dry run, prints what it would do | not used |

### Apps

| Parameter | What it does | Decision |
|---|---|---|
| `-RemoveApps` + `-Apps "<list>"` | Remove listed apps (`Default` = catalog defaults) | C, with an explicit list |
| `-RemoveGamingApps` | Remove Xbox app + Game Bar | skip: covered by the explicit list |
| `-RemoveHPApps` | Remove HP OEM apps | skip: Acer laptop |
| `-ForceRemoveEdge` | Force-uninstall Edge | **skip, never**: Edge is Must keep |

### Privacy and suggested content

| Parameter | What it does | Decision |
|---|---|---|
| `-DisableTelemetry` | Telemetry, activity history, app-launch tracking, ad ID off; disables telemetry scheduled tasks | skip: telemetry is already minimal (policy 0, DiagTrack disabled); ad ID already off |
| `-DisableSuggestions` | Tips, suggestions and silent app installs off | **B** |
| `-DisableLockscreenTips` | Lock-screen tips off | **B** |
| `-DisableNotifications` | All app notifications off | skip: would silence WhatsApp, Outlook, Teams |
| `-DisableLocationServices` | Location off for Windows and apps | skip: not on either list |
| `-DisableFindMyDevice` | Find My Device off | skip: not on either list |
| `-DisableEdgeAds` | Edge policies: new-tab feed, shopping, recommendations off | skip (optional): not on Want gone; Edge would show "managed by your organization" |
| `-DisableSettings365Ads` | Hide M365 ads on Settings Home | **B** |
| `-DisableSettingsHome` | Hide the Settings Home page | skip: Settings365Ads covers the ads |
| `-DisableBraveBloat` | Brave browser policies | skip: no Brave |
| `-DisableDesktopSpotlight` / `-EnableDesktopSpotlight` / `-HideDesktopSpotlightIcon` | Spotlight wallpaper on/off, hide its icon | skip: Spotlight already off |

### AI

| Parameter | What it does | Decision |
|---|---|---|
| `-DisableCopilot` | Copilot off by policy, button hidden, app removed | **B** |
| `-DisableRecall` | Recall off by policy | **B** |
| `-DisableClickToDo` | Click to Do off | skip: Copilot+ PCs only; not on the list |
| `-DisableAISvcAutoStart` | WSAIFabricSvc to manual | skip: not on the list |
| `-DisableEdgeAI` / `-DisablePaintAI` / `-DisableNotepadAI` | AI features in Edge / Paint / Notepad off | skip: not on the list (ask if you want them) |

### Start menu and search

| Parameter | What it does | Decision |
|---|---|---|
| `-DisableBing` | Bing web results + Cortana off in search; removes Bing Search app | **B** |
| `-DisableStoreSearchSuggestions` | Store app suggestions in search off, by denying Everyone access to the Store's `store.db` | skip: changes permissions on a Store file; the Store is Must keep |
| `-DisableStartRecommended` | Hide the whole Recommended section (recent files too) | skip: `Start_IrisRecommendations=0` already removes tips/apps from it |
| `-DisableStartAllApps` / `-StartAllAppsCategory/Grid/List` | Hide All Apps / change its view | skip: layout preference |
| `-DisableStartPhoneLink` | Remove Phone Link pane in Start | skip: Phone Link is Must keep |
| `-ClearStart` / `-ClearStartAllUsers` / `-ReplaceStart` / `-ReplaceStartAllUsers` | Unpin all / replace Start layout | skip: layout preference |

### Taskbar

| Parameter | What it does | Decision |
|---|---|---|
| `-DisableWidgets` | **Uninstalls** WebExperience, WidgetsPlatformRuntime, StartExperiencesApp | skip: WebExperience is Unsure; the widgets policy is used instead (B) |
| `-HideChat` | Hide Chat icon (Windows 10/early 11 only) | skip: n/a on 25H2 |
| `-TaskbarAlignLeft` | Left-align taskbar | skip: preference |
| `-HideSearchTb` / `-ShowSearchIconTb` / `-ShowSearchLabelTb` / `-ShowSearchBoxTb` | Search button style | skip: preference |
| `-HideTaskview` | Hide Task view button | skip: preference |
| `-EnableEndTask` / `-EnableLastActiveClick` | Taskbar right-click End Task; click to cycle windows | skip: preference |
| `-CombineTaskbar{Always,WhenFull,Never}` / `-CombineMMTaskbar{…}` / `-MMTaskbarMode{All,MainActive,Active}` | Button grouping and multi-monitor taskbar | skip: preference |

### System, updates, appearance, Explorer, multitasking

| Parameter | What it does | Decision |
|---|---|---|
| `-DisableDVR` | Game/screen recording off | **B** |
| `-DisableGameBarIntegration` | Controller Game Bar button off; `ms-gamebar` links neutralised | **B** |
| `-DisableUpdateASAP` / `-PreventUpdateAutoReboot` / `-DisableDeliveryOptimization` | Update timing and P2P sharing | skip: Windows Update is Must keep |
| `-DisableDeviceAutoAppDownload` | Stop auto-installing device companion apps | skip (optional): could stop Realtek/Intel control panels returning |
| `-DisableFastStartup` / `-DisableBitlockerAutoEncryption` / `-DisableModernStandbyNetworking` / `-DisableStorageSense` | Power, encryption and disk cleanup | skip: not on either list |
| `-RevertContextMenu` / `-DisableDragTray` / `-DisableMouseAcceleration` / `-DisableStickyKeys` | Context menu, drag tray, input | skip: preference |
| `-EnableDarkMode` / `-DisableTransparency` / `-DisableAnimations` | Appearance | skip: preference |
| `-DisableWindowSnapping` / `-DisableSnapAssist` / `-DisableSnapLayouts` / `-HideTabsInAltTab` / `-Show{3,5,20}TabsInAltTab` | Snapping and Alt+Tab | skip: preference |
| `-ExplorerTo{Home,ThisPC,Downloads,OneDrive}` / `-ShowKnownFileExt` / `-ShowHiddenFolders` / `-HideDupliDrive` / `-HideHome` / `-HideGallery` / `-HideOnedrive` / `-AddFoldersToThisPC` / `-ShowDriveLetters{First,Last}` / `-ShowNetworkDriveLettersFirst` / `-HideDriveLetters` | File Explorer layout | skip: preference (`-HideOnedrive` also conflicts with OneDrive Must keep) |
| `-Hide3dObjects` / `-HideMusic` / `-HideIncludeInLibrary` / `-HideGiveAccessTo` / `-HideShare` | Windows 10-only Explorer tweaks | skip: n/a on 25H2 |
| `-EnableWindowsSandbox` / `-EnableWindowsSubsystemForLinux` | Turn on optional features | skip: WSL is already working |

---

## Recommended skips, in short

- **Defaults mode:** it would remove Sticky Notes, Alarms, Sound Recorder, Quick Assist and new Teams.
- **`-DisableWidgets`:** it uninstalls WebExperience (Unsure). The widgets policy does the job.
- **`-DisableStoreSearchSuggestions`:** it locks a Store database file; the Store is Must keep.
- **`-DisableTelemetry`:** already minimal.
- **`-DisableNotifications`:** it kills every app's notifications.
- **Windows Update tweaks, `-ForceRemoveEdge`, `-DisableStartPhoneLink`, `-HideOnedrive`:** each touches something on Must keep.
- **Unsure apps stay:** WebExperience, WidgetsPlatformRuntime, ApplicationCompatibilityEnhancements, Narrator scripts, Feedback Hub, Family, Films & TV.
- **Optional, your call:** `-DisableEdgeAds` (Edge new-tab feed and shopping ads, but Edge shows "managed by your organization") and `-DisableEdgeAI` / `-DisablePaintAI` / `-DisableNotepadAI`. Say the word and they go into Step B.

## Things to check after the reboot (for Step 4)

- **Phone Link still connects.** `-DisableSuggestions` only turns off Phone Link *suggestions*, not the link itself.
- **OneDrive still syncs.** Only its Explorer ads are hidden.
- **Search still finds local apps and files.** Only web results are off.
