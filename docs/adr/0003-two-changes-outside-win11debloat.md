# 3. Two changes made outside Win11Debloat

**Status:** accepted (2026-10-29); widgets part amended 2026-10-29 (see *Amendment*)

## Context

ADR 0001 says to make the changes with Win11Debloat, pinned to a tag, with explicit parameters. Reading tag `2026.08.24` showed two Want gone items it can't do the way we need:

- **Widgets.** `-DisableWidgets` sets no registry value. It *uninstalls* `MicrosoftWindows.Client.WebExperience`, `Microsoft.WidgetsPlatformRuntime` and `Microsoft.StartExperiencesApp` (`Scripts/Features/Invoke-Changes.ps1`). The audit put WebExperience in Unsure because it also serves other shell parts.
- **Edge Game Assist.** `Microsoft.Edge.GameAssist` isn't in Win11Debloat's catalog (`Config/Apps.json`), so `-Apps` skips it with "not supported".

## Decision

- Hide widgets with the policy `HKLM\SOFTWARE\Policies\Microsoft\Dsh\AllowNewsAndInterests = 0`, set by `scripts/step-b-tweaks.ps1` right after the Win11Debloat run. We use the policy instead of `HKCU\…\Explorer\Advanced\TaskbarDa = 0` because recent builds block scripts from writing `TaskbarDa`.
- Remove `Microsoft.Edge.GameAssist` with `Remove-AppxPackage -AllUsers` and `Remove-AppxProvisionedPackage` in `scripts/step-c-remove-apps.ps1`. It's listed under `ExtraRemovals` in `scripts/debloat-lists.psd1`.
- Everything else stays inside Win11Debloat.

## Consequences

- Undoing these two isn't covered by Win11Debloat's undo files or its JSON backup. PLAN.md has their revert commands, and Step A exports the `Dsh` key (or records it as absent).
- After a feature update, re-check both against the new tag. `tests/Plan.Tests.ps1` fails if `Microsoft.Edge.GameAssist` joins the catalog, which is the cue to drop the direct removal.
- WebExperience stays installed, so the widgets runtime remains on disk. That's fine because the policy turns the board off.

## Amendment (2026-10-29, Step B run)

The widgets policy couldn't be set. An elevated `reg.exe add` and `New-ItemProperty` both got "Access is denied" on `Dsh\AllowNewsAndInterests`, although Administrators have full control of the key. The UCPD driver is running and is the likely cause (it also guards `TaskbarDa`); Avast wasn't ruled out. Getting around either would mean defeating a security control, so we don't.

- **New decision:** the owner switches widgets off in Settings > Personalization > Taskbar (`TaskbarDa = 0`). `scripts/step-b-tweaks.ps1` prints that reminder and no longer writes the policy. The test accepts either value.
- **Consequence:** this is a user setting, not a policy, so a feature update can turn widgets back on. Step 4 checks for it after every feature update.
- The failed attempt left an empty `Dsh` key. Step A recorded the key as absent, so the revert deletes it.
