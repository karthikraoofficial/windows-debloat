# Step C (PLAN.md): remove the Want gone apps for all users and from provisioning.
# Catalog apps go through the pinned Win11Debloat; ExtraRemovals are removed directly. Never reboots. Needs admin.
$ErrorActionPreference = 'Stop'

$repo  = Split-Path $PSScriptRoot -Parent
$lists = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'debloat-lists.psd1')
$w11   = Join-Path $repo 'Win11Debloat'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logs  = Join-Path $repo "logs\stepC-$stamp"
New-Item -ItemType Directory -Force -Path $logs | Out-Null
Start-Transcript -Path (Join-Path $logs 'stepC.log') | Out-Null

function Get-Matches([string]$App) {
    # Same wildcard Win11Debloat uses, so the log shows exactly what each name will hit.
    $installed   = @(Get-AppxPackage -AllUsers -Name "*$App*" | ForEach-Object Name)
    $provisioned = @(Get-AppxProvisionedPackage -Online | Where-Object PackageName -like "*$App*" | ForEach-Object DisplayName)
    [pscustomobject]@{ App = $App; Installed = ($installed | Sort-Object -Unique) -join ';'; Provisioned = ($provisioned | Sort-Object -Unique) -join ';' }
}

try {
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $admin) { throw 'Step C must run elevated.' }

    # Native stderr would be a terminating error under 'Stop' in PowerShell 5.1, so native calls run with 'Continue'.
    $tag = & { $ErrorActionPreference = 'Continue'; & git -C $w11 describe --tags --exact-match 2>$null }
    if ($tag -ne $lists.PinnedTag) { throw "Win11Debloat is at '$tag', expected pinned tag $($lists.PinnedTag)." }

    Write-Host '> Before: what each name matches'
    $before = $lists.WantGoneApps | ForEach-Object { Get-Matches $_ }
    $before | Format-Table -AutoSize | Out-String -Width 250 | Write-Host
    $keep = @($before | ForEach-Object { ($_.Installed + ';' + $_.Provisioned) -split ';' } | Where-Object { $_ -and $lists.MustKeepApps -contains $_ })
    if ($keep.Count) { throw "A removal pattern matches a Must keep app: $($keep -join ', '). Stopping before any removal." }

    $catalogApps = @($lists.WantGoneApps | Where-Object { $lists.ExtraRemovals -notcontains $_ })
    Write-Host "> Win11Debloat $tag -RemoveApps -AppRemovalTarget AllUsers ($($catalogApps.Count) apps)"
    $exit = & { $ErrorActionPreference = 'Continue'; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $w11 'Win11Debloat.ps1') -Silent -LogPath $logs -RemoveApps -Apps ($catalogApps -join ',') -AppRemovalTarget AllUsers | Out-Host; $LASTEXITCODE }
    Write-Host "  Win11Debloat exit code: $exit"

    foreach ($app in $lists.ExtraRemovals) {
        Write-Host "> Removing $app directly (not in Win11Debloat's catalog)"
        Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -AllUsers -ErrorAction Continue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $app |
            Remove-AppxProvisionedPackage -Online -AllUsers -ErrorAction Continue | Out-Null
    }

    Write-Host '> After: anything still present'
    $left = $lists.WantGoneApps | ForEach-Object { Get-Matches $_ } | Where-Object { $_.Installed -or $_.Provisioned }
    if ($left) { $left | Format-Table -AutoSize | Out-String -Width 250 | Write-Host; Write-Host "FAILED: $(@($left).Count) app(s) still present." }
    else { Write-Host '  All Want gone apps are gone for all users and from provisioning.' }

    Write-Host ''
    Write-Host 'Step C done. A reboot is recommended so Start and the taskbar refresh. Claude will not reboot.'
}
finally {
    Stop-Transcript | Out-Null
}
