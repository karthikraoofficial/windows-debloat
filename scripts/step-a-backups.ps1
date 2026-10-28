# Step A (PLAN.md): turn on System Restore for C:, create a restore point, save the app lists
# and export the registry keys Step B touches. Changes nothing else. Needs admin (run via UAC).
$ErrorActionPreference = 'Stop'

$repo  = Split-Path $PSScriptRoot -Parent
$lists = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'debloat-lists.psd1')
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$out   = Join-Path $repo "backups\$stamp"
New-Item -ItemType Directory -Force -Path $out, (Join-Path $repo 'logs') | Out-Null
Start-Transcript -Path (Join-Path $repo "logs\stepA-$stamp.log") | Out-Null

try {
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $admin) { throw 'Step A must run elevated.' }

    Write-Host '> Turning on System Restore for C: (approved 2026-10-29)'
    Enable-ComputerRestore -Drive "$env:SystemDrive\"

    $name = "Before Win11Debloat $($lists.PinnedTag)"
    Write-Host "> Creating restore point '$name'"
    Checkpoint-Computer -Description $name -RestorePointType MODIFY_SETTINGS
    $rp = Get-ComputerRestorePoint | Where-Object Description -eq $name | Select-Object -Last 1
    if (-not $rp) { throw 'Restore point was not created. Stop here; do not run Step B.' }
    Write-Host "  Restore point #$($rp.SequenceNumber) created $($rp.ConvertToDateTime($rp.CreationTime))"

    Write-Host '> Saving app lists'
    Get-AppxPackage -AllUsers | Select-Object Name, Version, PackageFullName, NonRemovable |
        Sort-Object Name | Export-Csv (Join-Path $out 'appx-allusers.csv') -NoTypeInformation
    Get-AppxProvisionedPackage -Online | Select-Object DisplayName, Version, PackageName |
        Sort-Object DisplayName | Export-Csv (Join-Path $out 'appx-provisioned.csv') -NoTypeInformation

    Write-Host '> Exporting registry keys'
    $absent = @()
    $i = 0
    foreach ($key in $lists.BackupKeys) {
        $i++
        $file = Join-Path $out ('{0:D2}-{1}.reg' -f $i, ($key -replace '[\\ ]', '_'))
        # Native stderr would be a terminating error under 'Stop' in PowerShell 5.1, so relax it here.
        $exists = & { $ErrorActionPreference = 'Continue'; & reg.exe query $key *> $null; $LASTEXITCODE -eq 0 }
        if (-not $exists) { $absent += $key; continue }
        & { $ErrorActionPreference = 'Continue'; & reg.exe export $key $file /y *> $null }
        if ($LASTEXITCODE -ne 0) { throw "reg export failed for $key" }
    }
    # Keys that didn't exist: to revert, delete them (see PLAN.md, Revert).
    $absent | Set-Content (Join-Path $out 'absent-keys.txt') -Encoding UTF8
    Write-Host "  Exported $($lists.BackupKeys.Count - $absent.Count) keys; $($absent.Count) did not exist (listed in absent-keys.txt)"

    Write-Host ''
    Write-Host "Step A done. Backups: $out"
}
finally {
    Stop-Transcript | Out-Null
}
