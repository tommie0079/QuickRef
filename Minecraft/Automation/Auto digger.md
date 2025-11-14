Use AutoHotkey Dash v2

Use Delete button to start/stop digging

```

#Requires AutoHotkey v2.0
#SingleInstance Force
 
toggle := false
spamDelay := 10     ; << faster
holdTime := 5       ; << faster
 
Delete::   ; toggle with DELETE
{
    global toggle
    toggle := !toggle
 
    if (toggle) {
 
        SendEvent("{XButton2 down}")
        SendEvent("{RButton down}")
 
        SetTimer(ShiftSpam, 1)
    } else {
 
        SetTimer(ShiftSpam, 0)
        SendEvent("{XButton2 up}")
        SendEvent("{RButton up}")
    }
}
 
ShiftSpam() {
    global toggle, spamDelay, holdTime
    if (!toggle)
        return
 
    SendEvent("{Shift down}")
    Sleep(holdTime)
    SendEvent("{Shift up}")
    Sleep(spamDelay)
}
```
