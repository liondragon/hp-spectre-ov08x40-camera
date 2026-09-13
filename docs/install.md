# Build, Install and Roll Back

These steps are for people who are comfortable recovering from a bad kernel
module. Read the whole page before changing the laptop.

## 1. Confirm the machine

Run:

```bash
./scripts/check-system.sh
```

This repository has been validated on:

```text
System vendor: HP
Product name: HP Spectre x360 2-in-1 Laptop 14-eu0xxx
Camera ACPI ID: OVTI08F4
```

The current INT3472 patch raises the handshake delay globally for sensors that
use that power sequence; it is not HP- or DMI-specific. The remaining patches
and these installation steps are validated only on the machine above. Review
the camera hardware and source compatibility before using them elsewhere.

## 2. Get matching source trees

These installation steps use the matching Ubuntu kernel source for the kernel
you will boot. The helper below applies the complete local-install set; it is
not an upstream-submission helper. For upstream review, use a current Linux
tree and check only the standalone crop-selection patch.

Clone libcamera from its official repository:

```bash
git clone https://git.libcamera.org/libcamera/libcamera.git
```

Keep both trees clean before applying anything. A Git worktree is preferred.
The helper also supports an extracted, non-Git Linux source package, but it
cannot verify that such a tree is pristine; keep a disposable copy or backup
for rollback.

## 3. Check and apply the local-install patches

Set the path to this repository once; later commands may run from other source
trees:

```bash
camera_repo=/path/to/hp-spectre-ov08x40-camera
```

Check without changing either tree:

```bash
"$camera_repo/scripts/apply-patches.sh" --check /path/to/linux /path/to/libcamera
```

Apply after the check succeeds:

```bash
"$camera_repo/scripts/apply-patches.sh" --apply /path/to/linux /path/to/libcamera
```

The included INT3472 patch is the tested Ubuntu 7.0.14 backport of Hans de
Goede's accepted 200 ms change. It is not the already-accepted upstream mail
patch and should not be submitted upstream.

## 4. Build the kernel modules

For a matching source tree and installed kernel headers:

```bash
kernel_release=$(uname -r)
kernel_source=/path/to/linux

make -C "/lib/modules/$kernel_release/build" \
  M="$kernel_source/drivers/media/i2c" ov08x40.ko

make -C "/lib/modules/$kernel_release/build" \
  M="$kernel_source/drivers/platform/x86/intel/int3472" \
  NOSTDINC_FLAGS="-I$kernel_source/include -nostdinc" modules
```

If source and headers have drifted, stop rather than forcing the build.

Secure Boot systems require each module to be signed with a private key that
is enrolled on that laptop. Keep the key outside the repository. The signing
command has this general form:

```bash
sign_file="/usr/src/linux-headers-$kernel_release/scripts/sign-file"
"$sign_file" sha512 /private/path/MOK.priv /private/path/MOK.der module.ko
```

Back up any existing overrides, then install the three modules:

```bash
sudo install -d "/lib/modules/$kernel_release/updates/hp-spectre-camera"
sudo install -m 0644 "$kernel_source/drivers/media/i2c/ov08x40.ko" \
  "/lib/modules/$kernel_release/updates/hp-spectre-camera/"
sudo install -m 0644 \
  "$kernel_source/drivers/platform/x86/intel/int3472/intel_skl_int3472_common.ko" \
  "$kernel_source/drivers/platform/x86/intel/int3472/intel_skl_int3472_discrete.ko" \
  "/lib/modules/$kernel_release/updates/hp-spectre-camera/"
sudo depmod -a "$kernel_release"
sudo update-initramfs -u -k "$kernel_release"
```

Updating the initramfs is required because Ubuntu may otherwise load an older
copy of these modules during boot. Reboot instead of trying to replace an
active camera power driver in place.

## 5. Build libcamera

The libcamera patches use Meson and Ninja:

```bash
cd /path/to/libcamera
meson setup build --prefix=/usr/local \
  -Dpipelines=simple -Dipas=softisp -Dsoftisp-gpu=disabled -Dtest=true
meson compile -C build
```

The GPU softisp backend is disabled because it produced horizontal corruption
at 1280x720 on the tested IPU6 path. The CPU backend produced a clean frame at
the same output size.

Test from the build tree first if possible. A system-wide `/usr/local` install
can take precedence over distribution libraries and affect every camera app.
Only install it after recording the distribution package versions and making
sure you can remove the local files:

```bash
sudo meson install -C build
sudo ldconfig
```

## 6. Allow CPU softisp buffer allocation

The CPU softisp path allocates buffers from `/dev/dma_heap`. Install the
included udev rule and reload it:

```bash
sudo install -m 0644 "$camera_repo/config/99-libcamera-dma-heap.rules" \
  /etc/udev/rules.d/99-libcamera-dma-heap.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=dma_heap
```

Confirm that your account belongs to the `video` group and that the heap
devices are group-readable and group-writable:

```bash
id -nG
find /dev/dma_heap -maxdepth 1 -type c -printf '%M %G %p\n'
```

If the account was just added to `video`, sign out and back in before testing.

## 7. Route desktop apps through libcamera

Create `~/.config/wireplumber/wireplumber.conf.d/99-libcamera-only.conf`:

```text
wireplumber.profiles = {
  main = {
    monitor.v4l2 = disabled
    monitor.libcamera = optional
  }
}
```

Restart the user services or sign out and back in:

```bash
systemctl --user restart pipewire wireplumber \
  xdg-desktop-portal xdg-desktop-portal-gnome
```

## 8. Verify

```bash
"$camera_repo/scripts/verify-camera.sh"
```

Then test the camera in one desktop app.

## Rollback

Remove only the override directory created above:

```bash
kernel_release=$(uname -r)
sudo find "/lib/modules/$kernel_release/updates/hp-spectre-camera" \
  -depth -delete
sudo depmod -a "$kernel_release"
sudo update-initramfs -u -k "$kernel_release"
```

Remove the local libcamera install using the build tree:

```bash
sudo ninja -C /path/to/libcamera/build uninstall
sudo ldconfig
```

Remove the dma-heap rule if it was added for this setup:

```bash
sudo unlink /etc/udev/rules.d/99-libcamera-dma-heap.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=dma_heap
```

Remove the WirePlumber override and restart the user services. Reboot to load
the stock kernel modules again.
