# Fixing Display Resolution in Proxmox Windows 11 IoT VM

**Symptom:** Display settings only shows one resolution, or the resolution slider is greyed out.

**Cause:** The VM is using a basic VGA or Standard VGA adapter with no driver — Proxmox
does not pass through a real GPU by default.

---

## Fix 1 — Install the SPICE guest agent and QXL driver (recommended)

In the Proxmox web UI:
1. Select the VM → **Hardware** → **Display**
2. Change Graphic card from `Default` to **SPICE** → click OK
3. Still in **Hardware** → click **Add** → **Serial Port**
   - Port number: `0` → click Add
4. Reboot the VM

Then inside the VM, install the guest tools:
- Download **virtio-win guest tools** from:
  https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win-guest-tools.exe
- Run the installer — this installs the QXL display driver, SPICE agent, and all VirtIO drivers in one step
- Reboot the VM

After reboot you can set any resolution via Display Settings.

---

## Fix 2 — Use VirtIO GPU (simpler, no SPICE needed)

In the Proxmox web UI:
1. Select the VM → **Hardware** → **Display**
2. Change Graphic card to **VirtIO-GPU**
3. Reboot the VM

Then inside the VM, run the same virtio-win guest tools installer linked above —
it includes the VirtIO GPU driver.

---

## Fix 3 — Inject custom resolution into VirtIO GPU registry

VirtIO GPU DOD ignores `ChangeDisplaySettings` — you must write the desired resolution
directly into the driver's registry key, then reboot.

Run in PowerShell **as Administrator**:

```powershell
# Find the VirtIO / Red Hat display driver registry key
$driverKey = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DriverDesc -like '*VirtIO*' -or $_.DriverDesc -like '*Red Hat*' -or $_.DriverDesc -like '*viogpu*' }

if (-not $driverKey) {
    Write-Host "VirtIO GPU driver key not found. Is the driver installed?" -ForegroundColor Red
} else {
    $driverKey | ForEach-Object {
        Write-Host "Setting custom resolution on: $($_.PSPath)"
        Set-ItemProperty -Path $_.PSPath -Name "CustomXRes" -Value 1920 -Type DWord
        Set-ItemProperty -Path $_.PSPath -Name "CustomYRes" -Value 1080 -Type DWord
        Set-ItemProperty -Path $_.PSPath -Name "CustomBPP"  -Value 32   -Type DWord
    }
    Write-Host "Done. Reboot the VM to apply." -ForegroundColor Green
}
```

Change `1920` / `1080` to your desired resolution, then **reboot**. After reboot the
resolution will be set automatically and the slider in Display Settings will reflect it.

---

## Fix 4 — Use SPICE client auto-resize (no configuration needed)

If you connect to the VM using **virt-viewer** (the SPICE client) instead of the
Proxmox web console, the display resolution automatically matches your client window size.

> **Important:** `remote-viewer` must be run on your **local PC/laptop** — not on the
> Proxmox host, which has no display.

**Step 1 — On the Proxmox host**, generate a `.vv` connection file:
```bash
pvesh create /nodes/$(hostname)/qemu/103/spiceproxy --proxy 192.168.1.x > /tmp/vm103.vv
cat /tmp/vm103.vv
```
Replace `192.168.1.x` with your Proxmox host IP.

**Step 2 — Copy the `.vv` file to your local machine:**
```bash
# Run this on your local Linux/Mac machine
scp root@192.168.1.x:/tmp/vm103.vv ~/vm103.vv
```
On Windows, use WinSCP or:
```powershell
scp root@192.168.1.x:/tmp/vm103.vv C:\Users\you\vm103.vv
```

**Step 3 — Open it with virt-viewer on your local machine:**
- Linux/Mac: `remote-viewer ~/vm103.vv`
- Windows: Download **virt-viewer for Windows** from https://virt-manager.org/download then double-click the `.vv` file

The window will auto-resize the VM display to match your client window.

> **Simpler alternative:** In the Proxmox web UI, click **Console** → the built-in
> noVNC/SPICE console auto-resizes if the SPICE agent is installed in the VM.

---

## Troubleshoot

### Resolution still greyed out after installing guest tools

**Step 1 — Check what display adapter Windows is actually using:**

```powershell
Get-PnpDevice | Where-Object { $_.Class -eq 'Display' } | Select-Object Status, FriendlyName
```

- If it shows **"Standard VGA"** or **"Microsoft Basic Display Adapter"** → the driver did not install. Continue to Step 2.
- If it shows **QXL** or **VirtIO GPU** → the driver is installed but Settings is locked by policy. Skip to Step 3.

---

**Step 2 — Force-install the display driver manually:**

```powershell
# Find the driver INF file from the guest tools installation
Get-ChildItem "C:\Program Files\Virtio-Win\" -Recurse -Filter "*.inf" |
    Where-Object { $_.Name -like '*qxl*' -or $_.Name -like '*viogpu*' }
```

Then install using the exact path returned above. For example:
```powershell
pnputil /add-driver "C:\Program Files\Virtio-Win\Viogpudo\viogpudo.inf" /install /force
pnputil /scan-devices
```

> The folder and filename may vary — use whatever path the search returned, not the example above.

**Common mistake — "Failed to add driver package: Missing or invalid driver package":**
This happens if you copy the placeholder path `...\qxldod.inf` from the docs literally.
Use the exact path printed by the `Get-ChildItem` search above instead.

After installing, reboot and verify the driver loaded:
```powershell
Get-PnpDevice | Where-Object { $_.Class -eq 'Display' } | Select-Object Status, FriendlyName
```
Expected: **VirtIO GPU DOD** with status **OK**. The resolution slider in Display Settings will now work.

Reboot and check Step 1 again.

---

**Step 3 — Remove policy lock on display settings (Windows IoT restriction):**

```powershell
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisplayCP" /f 2>$null
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoDispCPL" /f 2>$null
Stop-Process -Name explorer -Force
```

---

**Step 4 — If nothing works, inject the resolution via registry (Fix 3 above).**

It writes the desired resolution directly into the VirtIO GPU driver key and takes
effect after a reboot, bypassing the Settings UI entirely.
