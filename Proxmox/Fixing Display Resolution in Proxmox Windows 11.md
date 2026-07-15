# Proxmox SPICE Console – Setup

Fix for: clicking the SPICE console downloads `pve-spice.vv` instead of opening it.

## On your PC (SPICE client)

1. Download **virt-viewer** (Windows MSI): https://virt-manager.org/download/
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
