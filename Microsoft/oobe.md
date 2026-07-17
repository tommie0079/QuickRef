#Skip oobe
```
net.exe user Windows VLFK_admin123 /add
```
###ENTER
```
net.exe localgroup administrators Windows /add
```
###ENTER
```
cd oobe
```
###ENTER
```
msoobe.exe && shutdown.exe /r
```
