# 1. Use Win11Debloat, pinned to a release tag, with explicit parameters

**Status:** accepted (2026-10-28)

## Context

The laptop needs ads, tips, widgets, Bing search, Copilot/Recall and a list of apps removed. We could write our own PowerShell script or use a maintained third-party one. Win11Debloat (github.com/Raphire/Win11Debloat) is widely used, ships revert `.reg` files, and has a parameter per change.

## Decision

- Use Win11Debloat rather than a hand-written script.
- Clone it at the latest **release tag**, never `master`, and record the tag in `PLAN.md`.
- Run it with **explicit parameters only**. Don't use its default/recommended mode, which can change between releases.
- Run registry tweaks (Step B) and app removal (Step C) as separate runs.

## Consequences

- A re-run after a feature update uses a newer tag; the parameter mapping in `PLAN.md` must be checked against that tag's README first.
- We trust a third-party script with admin rights, so the plan step reads the script before anything runs.
