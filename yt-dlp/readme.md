# yt-dlp Quick Notes

## Install

```powershell
winget install DenoLand.Deno
winget install yt-dlp
```

OR

https://docs.deno.com/runtime/getting_started/installation/
https://github.com/yt-dlp/yt-dlp/releases?

Close and open cmd in the same location

## Download (best video + audio, recode to MP4)

```powershell
yt-dlp.exe -f "bv*+ba/b" --recode-video mp4 --postprocessor-args "VideoConvertor:-c:v libx264 -crf 18 -c:a aac" "https://www.youtube.com/watch?v=kBUiyiUQm5o"
```
A download can take up to 30 / 60 min.

## Update

```powershell
yt-dlp.exe -U
```
