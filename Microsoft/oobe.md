# Skip oobe
```
net.exe user Windows WIN_admin123 /add
```
### ENTER
```
net.exe localgroup administrators Windows /add
```
### ENTER
```
cd oobe
```
### ENTER
```
msoobe.exe && shutdown.exe /r
```
### ENTER


# Go back to oobe
```
cd /d %windir%\system32\oobe
msoobe.exe
```
