# Read-only audit checks that need admin rights. Changes nothing.
# Usage (from a normal shell): Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File scripts\audit-admin.ps1 -OutFile admin-audit.txt'
param([string]$OutFile = "$PSScriptRoot\..\admin-audit.txt")

$out = New-Object System.Collections.Generic.List[string]
function Section($name) { $out.Add(""); $out.Add("===== $name =====") }

Section 'Restore points'
try { Get-ComputerRestorePoint -ErrorAction Stop | Select-Object SequenceNumber, Description, CreationTime | Format-Table -AutoSize | Out-String | ForEach-Object { $out.Add($_) } }
catch { $out.Add("Get-ComputerRestorePoint error: $($_.Exception.Message)") }

Section 'Shadow storage for C:'
$out.Add((vssadmin list shadowstorage /for=C: | Out-String))

Section 'System Restore protection (SPP\Clients)'
$cVol = (Get-Volume -DriveLetter C).UniqueId
$out.Add("C: volume = $cVol")
try {
    $clients = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SPP\Clients' -ErrorAction Stop
    $clients.PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object { $out.Add("$($_.Name) = $($_.Value -join '; ')") }
    $guid = ($cVol -replace '.*Volume\{', '' -replace '\}.*', '')
    $protected = ($clients.PSObject.Properties | Where-Object { ($_.Value -join ' ') -match [regex]::Escape($guid) }) -ne $null
    $out.Add("C: protected = $protected")
} catch { $out.Add("SPP\Clients error: $($_.Exception.Message)") }

Section 'Provisioned Appx packages'
try { Get-AppxProvisionedPackage -Online -ErrorAction Stop | Sort-Object DisplayName | ForEach-Object { $out.Add($_.DisplayName) } }
catch { $out.Add("error: $($_.Exception.Message)") }

Section 'Recall optional feature'
try {
    $f = Get-WindowsOptionalFeature -Online -FeatureName Recall -ErrorAction Stop
    if ($f) { $out.Add("Recall = $($f.State)") } else { $out.Add('Recall feature not present') }
} catch { $out.Add("Recall: $($_.Exception.Message)") }

$out | Set-Content -Path $OutFile -Encoding utf8
