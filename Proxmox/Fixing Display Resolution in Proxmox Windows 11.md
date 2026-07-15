# Proxmox SPICE Console – Setup

Fix for: clicking the SPICE console downloads `pve-spice.vv` instead of opening it.

## On your PC (SPICE client)

1. Download **virt-viewer** (Windows 64‑bit MSI, direct link):
   https://releases.pagure.org/virt-viewer/virt-viewer-x64-11.0-1.0.msi
   (all builds: https://releases.pagure.org/virt-viewer/)
2. Install it (includes `remote-viewer.exe`).
3. Associate `.vv` files with Remote Viewer:
   - Right‑click a `pve-spice.vv` → **Open with** → **Choose another app**
   - Browse to `C:\Program Files\VirtViewer <version>\bin\remote-viewer.exe`
   - Check **Always use this app**.

## On the VM (Proxmox)

1. VM → **Hardware** → **Display** → set to **SPICE (qxl)**.
2. In the Windows guest, mount the **virtio-win** ISO and install **spice-guest-tools**
   (enables clipboard, dynamic resolution, USB redirect).

## Use it

- VM → **Console** dropdown → **SPICE** → the `.vv` now opens directly in Remote Viewer.

## No client install alternative

- Set **Display = Default (noVNC)** to run the console in‑browser (no extra software,
  fewer features than SPICE).

## Can't install a SPICE client? Fix resolution without it

**Option A – RDP (best, no install, native resolution)**
1. In the Windows guest: **Settings → System → Remote Desktop → On**.
2. Note the VM's IP (`ipconfig` in the guest).
3. On your PC run the built‑in client: `mstsc` → enter the VM IP → connect.
   - RDP auto‑matches your window/monitor size and resizes dynamically.
   - Requires network reachability to the VM and Windows Pro/Enterprise in the guest.

**Option B – Browser console (noVNC), no install**
1. VM → **Hardware → Display → Default (std)** (or **VirtIO-GPU**).
2. Open **Console** (noVNC) in the browser.
3. In the guest: **Settings → Display** → pick the resolution you want.
4. For more/auto resolutions, install the guest GPU driver from the **virtio-win** ISO
   *inside the VM* (done on the VM, not your locked‑down PC).
5. noVNC toolbar has a **scaling** option (Local scaling / full‑screen) to fit your screen.
