# Fixing Display Resolution in Proxmox Windows 11 IoT VM

**Symptom:** Display settings only shows one resolution, or the resolution slider is greyed out.

**Cause:** The VM is using a basic VGA or Standard VGA adapter with no driver — Proxmox
does not pass through a real GPU by default.

---

## Fix 1 — Install the SPICE guest agent and QXL driver (recommended)

In the Proxmox web UI:
1. Select the VM → **Hardware** → **Display**
2. Change Graphic card from `Default` to **SPICE**
3. Also add **VirtIO Serial Port** (required by the guest agent)
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
