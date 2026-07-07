# yt-dlp Quick Notes

## Install

```powershell
winget install DenoLand.Deno
winget install yt-dlp
```

> **`winget` not recognized?** Install/update **App Installer** from the Microsoft Store, then open a new terminal. Or run:
>
> ```powershell
> Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
> ```

## Update

```powershell
yt-dlp.exe -U
```

Update every 30 / 60 min if needed.

## Download (best video + audio, recode to MP4)

```powershell
yt-dlp.exe -f "bv*+ba/b" --recode-video mp4 --postprocessor-args "VideoConvertor:-c:v libx264 -crf 18 -c:a aac" "https://www.youtube.com/watch?v=kBUiyiUQm5o"
```
