Build, sign and package a NotchTerm release for Sparkle auto-update.

The pipeline lives in `distribute.sh` at the repo root — do not reimplement it here.

## Step 1 — Check versions

Read `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.yml` and the newest
`<sparkle:version>` in `appcast.xml`. `CURRENT_PROJECT_VERSION` must be greater than it —
Sparkle compares build numbers, not marketing versions. If it isn't, ask the user for the
new version/build and update `project.yml` first.

## Step 2 — Build

```bash
./distribute.sh
```

If it fails, show the last 40 lines of output and stop.

## Step 3 — Report

Show the zip path and size, then the publish commands the script printed. Do not run the
`gh release` / `git push` steps without the user's confirmation.

First-launch instructions for new users (ad-hoc signed, not notarized):

```bash
xattr -cr /Applications/NotchTerm.app
```

Or: open once, then System Settings → Privacy & Security → "Open Anyway".
