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

## Fix 3 — Force resolution via PowerShell (temporary, no driver needed)

```powershell
$code = @"
using System;
using System.Runtime.InteropServices;
public class Display {
    [DllImport("user32.dll")] public static extern int ChangeDisplaySettings(ref DEVMODE dm, int flags);
    [StructLayout(LayoutKind.Sequential)] public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmDeviceName;
        public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra;
        public int dmFields;
        public int dmPositionX, dmPositionY, dmDisplayOrientation, dmDisplayFixedOutput;
        public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmFormName;
        public short dmLogPixels; public int dmBitsPerPel, dmPelsWidth, dmPelsHeight, dmDisplayFlags, dmDisplayFrequency;
    }
    public static void Set(int w, int h) {
        var dm = new DEVMODE(); dm.dmSize = (short)Marshal.SizeOf(dm);
        dm.dmPelsWidth = w; dm.dmPelsHeight = h; dm.dmFields = 0x80000 | 0x100000;
        ChangeDisplaySettings(ref dm, 0);
    }
}
"@
Add-Type $code
[Display]::Set(1920, 1080)
```

> This only works if the current driver supports the target resolution.
> Fixes 1 or 2 are the proper long-term solution.

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

**Step 4 — If nothing works, set resolution directly via PowerShell (Fix 3 above).**

It bypasses the Settings UI entirely and sets the resolution via the Windows API,
regardless of any policy restrictions.
