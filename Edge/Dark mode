# Edge Dark Mode Tester

Quick shortcuts for testing Microsoft Edge's dark mode settings in a separate test profile, so your normal Edge profile is never touched.

## Edge pages

| Page | Address |
|------|---------|
| Appearance settings | `edge://settings/appearance` |
| Force dark mode flag | `edge://flags/#enable-force-dark` |

> **Note:** `edge://` links can't be clicked from a web page. Copy the address and paste it into Edge's address bar.

## Scripts

### `Open-Test.bat`
Opens Edge with a clean test profile, with both pages in tabs.

```bat
@echo off
start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --user-data-dir="%LOCALAPPDATA%\EdgeTestProfile" --no-first-run edge://flags/#enable-force-dark edge://settings/appearance
```

### `Reset.bat`
Deletes the test profile so the next launch starts at factory defaults.

```bat
@echo off
rd /s /q "%LOCALAPPDATA%\EdgeTestProfile" 2>nul
if exist "%LOCALAPPDATA%\EdgeTestProfile" (
    echo Could not reset. Close the test Edge window and try again.
) else (
    echo Test profile reset to factory defaults.
)
pause
```

## How to use

1. Run `Open-Test.bat` and change the dark mode settings.
2. Close the test Edge window when you're done.
3. Run `Reset.bat` to start fresh.
