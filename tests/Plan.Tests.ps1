# Guards for PLAN.md: the Step B/C inputs in scripts/debloat-lists.psd1 and the wrapper scripts.
# Pester 3.4. Reads files and the current user's Appx list only. Runs without admin.
# Checks against the Win11Debloat clone are skipped when ./Win11Debloat is absent (it is gitignored).

$repo      = Split-Path $PSScriptRoot -Parent
$listsPath = Join-Path $repo 'scripts\debloat-lists.psd1'
$w11       = Join-Path $repo 'Win11Debloat'
$lists     = if (Test-Path $listsPath) { Import-PowerShellDataFile $listsPath } else { $null }

Describe 'Plan inputs: lists file' {
    It 'scripts/debloat-lists.psd1 exists' { Test-Path $listsPath | Should Be $true }
    It 'pins a Win11Debloat tag' { $lists.PinnedTag | Should Match '^\d{4}\.\d{2}\.\d{2}$' }
    It 'has Want gone, Must keep and Step B lists' {
        @($lists.WantGoneApps).Count  | Should BeGreaterThan 0
        @($lists.MustKeepApps).Count  | Should BeGreaterThan 0
        @($lists.StepBSwitches).Count | Should BeGreaterThan 0
    }
}

Describe 'Plan inputs: Step C never touches a Must keep app' {
    It 'no app is on both lists' {
        @($lists.WantGoneApps | Where-Object { $lists.MustKeepApps -contains $_ }) | Should BeNullOrEmpty
    }
    # Win11Debloat removes by wildcard (*name*), so check what each pattern would hit.
    foreach ($app in $lists.WantGoneApps) {
        It "*$app* matches no Must keep app" {
            @($lists.MustKeepApps | Where-Object { $_ -like "*$app*" }) | Should BeNullOrEmpty
        }
        It "*$app* matches only itself among installed packages" {
            @(Get-AppxPackage | Where-Object { $_.Name -like "*$app*" -and $_.Name -ne $app }) | Should BeNullOrEmpty
        }
    }
    It 'extra removals are a subset of Want gone' {
        @($lists.ExtraRemovals | Where-Object { $lists.WantGoneApps -notcontains $_ }) | Should BeNullOrEmpty
    }
}

Describe 'Plan inputs: Step B switches' {
    $forbidden = 'RunDefaults', 'RunDefaultsLite', 'RunSavedSettings', 'Config', 'RemoveApps', 'Apps',
                 'DisableWidgets', 'ForceRemoveEdge', 'DisableStoreSearchSuggestions', 'DisableStartPhoneLink',
                 'DisableNotifications', 'DisableUpdateASAP', 'PreventUpdateAutoReboot', 'Sysprep', 'User'
    foreach ($s in $lists.StepBSwitches) {
        It "$s is not a forbidden switch" { $forbidden -contains $s | Should Be $false }
    }
}

Describe 'Plan inputs: match the pinned Win11Debloat clone' {
    $present = Test-Path (Join-Path $w11 'Win11Debloat.ps1')

    It 'clone is checked out at the pinned tag' -Skip:(-not $present) {
        (& git -C $w11 describe --tags --exact-match 2>$null) | Should Be $lists.PinnedTag
    }
    It 'every Step B switch is a Win11Debloat parameter' -Skip:(-not $present) {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $w11 'Win11Debloat.ps1'), [ref]$null, [ref]$null)
        $params = @($ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
        @($lists.StepBSwitches | Where-Object { $params -notcontains $_ }) | Should BeNullOrEmpty
    }
    It 'every Want gone app is in the Win11Debloat catalog or an extra removal' -Skip:(-not $present) {
        $catalog = @((Get-Content (Join-Path $w11 'Config\Apps.json') -Raw | ConvertFrom-Json).Apps | ForEach-Object { @($_.AppId) })
        @($lists.WantGoneApps | Where-Object { $catalog -notcontains $_ -and $lists.ExtraRemovals -notcontains $_ }) | Should BeNullOrEmpty
    }
    It 'extra removals really are missing from the catalog' -Skip:(-not $present) {
        $catalog = @((Get-Content (Join-Path $w11 'Config\Apps.json') -Raw | ConvertFrom-Json).Apps | ForEach-Object { @($_.AppId) })
        @($lists.ExtraRemovals | Where-Object { $catalog -contains $_ }) | Should BeNullOrEmpty
    }
}

Describe 'Plan wrappers: explicit parameters only' {
    foreach ($name in 'step-a-backups.ps1', 'step-b-tweaks.ps1', 'step-c-remove-apps.ps1') {
        $path = Join-Path $repo "scripts\$name"
        It "$name exists" { Test-Path $path | Should Be $true }
        It "$name never uses defaults mode, saved settings or reboots" {
            $text = Get-Content $path -Raw
            $text | Should Not Match '-RunDefaults|-RunSavedSettings|-Config\b|Restart-Computer|shutdown(\.exe)?\s+/r'
            $text | Should Not Match "-Apps\s+['""]?Default"
        }
    }
}
