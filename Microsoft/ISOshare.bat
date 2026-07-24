@echo off
REM Map the ISO share to drive Z: and keep it across reboots.
REM Remove any existing Z: mapping first so re-running doesn't error.
net use Z: /delete /yes >nul 2>&1
net use Z: \\192.168.1.2\ISOs /user:192.168.1.2\iso LAB_admin123 /persistent:yes
explorer Z:
