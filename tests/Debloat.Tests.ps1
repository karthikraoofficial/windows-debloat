# Verification suite for the Must keep / Want gone lists in CLAUDE.md.
# Pester 3.4 (ships with Windows PowerShell 5.1). Run: Invoke-Pester .\tests
# Reads state only. Runs without admin.

function Get-RegValue([string]$Path, [string]$Name) {
    try { (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name } catch { $null }
}

function Test-AppInstalled([string]$Name) {
    [bool](Get-AppxPackage -Name $Name -ErrorAction SilentlyContinue)
}

$lists = Import-PowerShellDataFile (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts\debloat-lists.psd1')

$cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

Describe 'Want gone: ads, tips and suggestions' {
    It 'Settings/Start suggestions are off' { Get-RegValue $cdm 'SystemPaneSuggestionsEnabled' | Should Be 0 }
    It 'silent app installs are off'        { Get-RegValue $cdm 'SilentInstalledAppsEnabled' | Should Be 0 }
    It 'tips and tricks are off'            { Get-RegValue $cdm 'SoftLandingEnabled' | Should Be 0 }
    It 'tips notifications are off'         { Get-RegValue $cdm 'SubscribedContent-338389Enabled' | Should Be 0 }
    It 'Start recommendations are off'      { Get-RegValue $adv 'Start_IrisRecommendations' | Should Be 0 }
    It 'advertising ID is off'              { Get-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' | Should Be 0 }
}

Describe 'Want gone: widgets and Bing in search' {
    It 'widgets are hidden from the taskbar' {
        $taskbar = Get-RegValue $adv 'TaskbarDa'
        $policy  = Get-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests'
        ($taskbar -eq 0 -or $policy -eq 0) | Should Be $true
    }
    It 'Bing results are off in Start search' {
        $bing   = Get-RegValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled'
        $policy = Get-RegValue 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions'
        ($bing -eq 0 -or $policy -eq 1) | Should Be $true
    }
}

Describe 'Want gone: Copilot and Recall are blocked' {
    It 'Copilot is turned off by policy' {
        $u = Get-RegValue 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot'
        $m = Get-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot'
        ($u -eq 1 -or $m -eq 1) | Should Be $true
    }
    It 'Recall snapshots are turned off by policy' {
        $u = Get-RegValue 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis'
        $m = Get-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis'
        ($u -eq 1 -or $m -eq 1) | Should Be $true
    }
    It 'Copilot app is not installed' { Test-AppInstalled 'Microsoft.Copilot' | Should Be $false }
}

Describe 'Want gone: telemetry stays minimal' {
    It 'DiagTrack service is disabled' { (Get-Service DiagTrack).StartType | Should Be 'Disabled' }
    It 'telemetry policy is Required or lower' {
        Get-RegValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' | Should BeLessThan 2
    }
}

Describe 'Want gone: apps are removed' {
    foreach ($app in $lists.WantGoneApps) {
        It "$app is not installed" { Test-AppInstalled $app | Should Be $false }
    }
}

Describe 'Must keep: apps are still installed' {
    foreach ($app in $lists.MustKeepApps) {
        It "$app is installed" { Test-AppInstalled $app | Should Be $true }
    }
}

Describe 'Must keep: system services and devices' {
    It 'an antivirus is active' {
        # productState bits 12-15 = 0x1 means real-time protection is on
        $on = @(Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct |
            Where-Object { ($_.productState -band 0xF000) -eq 0x1000 })
        $on.Count | Should BeGreaterThan 0
    }
    It 'Windows Update is not disabled'    { (Get-Service wuauserv).StartType | Should Not Be 'Disabled' }
    It 'Bluetooth service is not disabled' { (Get-Service bthserv).StartType | Should Not Be 'Disabled' }
    It 'Print Spooler is running'          { (Get-Service Spooler).Status | Should Be 'Running' }
    It 'a network adapter is up'           { @(Get-NetAdapter | Where-Object Status -eq 'Up').Count | Should BeGreaterThan 0 }
    It 'Edge executable exists' {
        $edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe")
        @($edge | Where-Object { Test-Path $_ }).Count | Should BeGreaterThan 0
    }
}
