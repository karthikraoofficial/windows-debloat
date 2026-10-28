# Single source for the plan's inputs. Used by scripts/step-*.ps1 and tests/*.Tests.ps1.
# The lists mirror "Must keep" / "Want gone" in CLAUDE.md. See PLAN.md for why each item is here.
@{
    # Win11Debloat release tag the plan was written against (docs/adr/0001).
    PinnedTag = '2026.08.24'

    # Step B: Win11Debloat switches. Each one is explained in PLAN.md.
    StepBSwitches = @(
        'DisableSuggestions'
        'DisableLockscreenTips'
        'DisableSettings365Ads'
        'DisableBing'
        'DisableCopilot'
        'DisableRecall'
        'DisableDVR'
        'DisableGameBarIntegration'
    )

    # Step B: widgets are hidden by policy, not with -DisableWidgets (that uninstalls WebExperience).
    WidgetsPolicy = @{ Key = 'HKLM\SOFTWARE\Policies\Microsoft\Dsh'; Name = 'AllowNewsAndInterests'; Value = 0 }

    # Step C: Want gone apps, removed for all users and from provisioning.
    WantGoneApps = @(
        'Clipchamp.Clipchamp'
        'Microsoft.BingSearch'
        'Microsoft.BingNews'
        'Microsoft.BingWeather'
        'Microsoft.GetHelp'
        'Microsoft.Getstarted'
        'Microsoft.StartExperiencesApp'
        'Microsoft.Todos'
        'Microsoft.WindowsMaps'
        'microsoft.windowscommunicationsapps'
        'Microsoft.PowerAutomateDesktop'
        'Microsoft.Windows.DevHome'
        'Microsoft.MicrosoftSolitaireCollection'
        'Microsoft.People'
        'Microsoft.MicrosoftOfficeHub'
        'MicrosoftTeams'
        'Microsoft.XboxGameOverlay'
        'Microsoft.XboxGamingOverlay'
        'Microsoft.XboxSpeechToTextOverlay'
        'Microsoft.XboxIdentityProvider'
        'Microsoft.Xbox.TCUI'
        'Microsoft.GamingApp'
        'Microsoft.Edge.GameAssist'
    )

    # Want gone apps that Win11Debloat's catalog (Config/Apps.json) doesn't know. Step C removes these directly.
    ExtraRemovals = @(
        'Microsoft.Edge.GameAssist'
    )

    # Must keep apps the test suite checks are still installed.
    MustKeepApps = @(
        'Microsoft.WindowsStore', 'Microsoft.StorePurchaseApp', 'Microsoft.DesktopAppInstaller', 'Microsoft.SecHealthUI',
        'Microsoft.MicrosoftEdge.Stable', '5319275A.WhatsAppDesktop', 'Microsoft.VisualStudioCode', 'Claude',
        'MicrosoftCorporationII.WindowsSubsystemForLinux', 'Microsoft.WindowsTerminal', 'Microsoft.WindowsNotepad',
        'Microsoft.WindowsCalculator', 'Microsoft.Windows.Photos', 'Microsoft.ScreenSketch', 'Microsoft.Paint',
        'Microsoft.WindowsAlarms', 'Microsoft.OneDriveSync', 'Microsoft.YourPhone', 'MicrosoftWindows.CrossDevice',
        'MSTeams', 'Microsoft.OutlookForWindows', 'Microsoft.MicrosoftStickyNotes', 'Microsoft.ZuneMusic',
        'Microsoft.WindowsSoundRecorder', 'Microsoft.WindowsCamera', 'MicrosoftCorporationII.QuickAssist'
    )

    # Step A: registry keys the Step B changes touch. Exported to backups/ before Step B.
    BackupKeys = @(
        'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        'HKCU\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications'
        'HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested'
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackupReminder'
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Mobility'
        'HKCU\Software\Policies\Microsoft\Windows\Explorer'
        'HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot'
        'HKCU\Software\Policies\Microsoft\Windows\WindowsAI'
        'HKCU\System\GameConfigStore'
        'HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR'
        'HKCU\Software\Microsoft\GameBar'
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR'
        'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
        'HKLM\SOFTWARE\Policies\Microsoft\Dsh'
        'HKCR\ms-gamebar'
        'HKCR\ms-gamebarservices'
    )
}
