# Build, Install and Roll Back

These steps are for people who are comfortable recovering from a bad kernel
module. Read the whole page before changing the laptop.

## 1. Confirm the machine

Run:

```bash
./scripts/check-system.sh
```

The INT3472 patch currently matches:

```text
System vendor: HP
Product name: HP Spectre x360 2-in-1 Laptop 14-eu0xxx
Camera ACPI ID: OVTI08F4
```

Do not install that patch on a different model without reviewing its DMI match
and power requirements.

## 2. Get matching source trees

Use Linux source that matches the kernel you will boot. For upstream review,
use a current Linux tree. For a local Ubuntu module, use the matching Ubuntu
kernel source whenever possible.

Clone libcamera from its official repository:

```bash
git clone https://git.libcamera.org/libcamera/libcamera.git
```

Keep both trees clean before applying anything.

## 3. Check and apply the patches

Check without changing either tree:

```bash
./scripts/apply-patches.sh --check /path/to/linux /path/to/libcamera
```

Apply after the check succeeds:

```bash
./scripts/apply-patches.sh --apply /path/to/linux /path/to/libcamera
```

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
  -Dpipelines=simple -Dipas=simple
meson compile -C build
```

Test from the build tree first if possible. A system-wide `/usr/local` install
can take precedence over distribution libraries and affect every camera app.
Only install it after recording the distribution package versions and making
sure you can remove the local files:

```bash
sudo meson install -C build
sudo ldconfig
```

## 6. Route desktop apps through libcamera

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

## 7. Verify

```bash
./scripts/verify-camera.sh
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

Remove the WirePlumber override and restart the user services. Reboot to load
the stock kernel modules again.
