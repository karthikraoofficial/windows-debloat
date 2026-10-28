# Step B (PLAN.md): registry and privacy tweaks. Runs the pinned Win11Debloat with explicit switches,
# then sets the widgets policy. Never reboots. Needs admin (run via UAC).
$ErrorActionPreference = 'Stop'

$repo  = Split-Path $PSScriptRoot -Parent
$lists = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'debloat-lists.psd1')
$w11   = Join-Path $repo 'Win11Debloat'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logs  = Join-Path $repo "logs\stepB-$stamp"
New-Item -ItemType Directory -Force -Path $logs | Out-Null
Start-Transcript -Path (Join-Path $logs 'stepB.log') | Out-Null

try {
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $admin) { throw 'Step B must run elevated.' }

    # Native stderr would be a terminating error under 'Stop' in PowerShell 5.1, so native calls run with 'Continue'.
    $tag = & { $ErrorActionPreference = 'Continue'; & git -C $w11 describe --tags --exact-match 2>$null }
    if ($tag -ne $lists.PinnedTag) { throw "Win11Debloat is at '$tag', expected pinned tag $($lists.PinnedTag)." }

    $switches = @($lists.StepBSwitches | ForEach-Object { "-$_" })
    Write-Host "> Win11Debloat $tag $($switches -join ' ')"
    # Win11Debloat writes its own log (Win11Debloat.log) into -LogPath, and a JSON registry backup into Win11Debloat\Backups.
    $exit = & { $ErrorActionPreference = 'Continue'; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $w11 'Win11Debloat.ps1') -Silent -LogPath $logs @switches | Out-Host; $LASTEXITCODE }
    Write-Host "  Win11Debloat exit code: $exit"

    $p = $lists.WidgetsPolicy
    Write-Host "> Hiding widgets by policy: $($p.Key)\$($p.Name) = $($p.Value)"
    $ok = & { $ErrorActionPreference = 'Continue'; & reg.exe add $p.Key /v $p.Name /t REG_DWORD /d $p.Value /f *> $null; $LASTEXITCODE -eq 0 }
    if (-not $ok) { throw 'Setting the widgets policy failed.' }

    $backup = Get-ChildItem (Join-Path $w11 'Backups') -Filter '*.json' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime | Select-Object -Last 1
    if ($backup) {
        Copy-Item $backup.FullName (Join-Path $repo 'backups') -Force
        Write-Host "  Copied Win11Debloat registry backup $($backup.Name) to backups\"
    }

    Write-Host ''
    Write-Host 'Step B done. A sign-out or reboot is needed for Start, taskbar and policy changes to show. Claude will not reboot.'
}
finally {
    Stop-Transcript | Out-Null
}
