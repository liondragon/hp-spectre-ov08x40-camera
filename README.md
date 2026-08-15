# HP Spectre x360 Ubuntu Camera Fix for IPU6 and ov08x40

This project contains Linux and libcamera patches for the built-in webcam in
an HP Spectre x360 14-eu0xxx with an OVTI08F4 / OmniVision ov08x40 sensor.

The original symptoms were a black camera, "No camera available", and this
sensor probe error:

```text
ov08x40: error reading chip-id register: -121
```

This is hands-on Linux camera work, not a one-click installer.

## Target setup

- HP Spectre x360 2-in-1 Laptop 14-eu0xxx
- OVTI08F4 / OmniVision ov08x40 camera
- Ubuntu 26.04 LTS
- Linux `7.0.0-29-generic`
- Intel IPU6 and libcamera simple IPA

## What is included

### Linux kernel

- [ov08x40 crop-selection patch](patches/linux/0001-media-i2c-ov08x40-add-crop-selection.patch)
- [HP-specific INT3472 handshake-delay patch](patches/linux/0002-platform-x86-int3472-add-hp-spectre-handshake-delay.patch)

The crop patch gives libcamera the sensor rectangles it asks for. The INT3472
patch keeps the normal 45 ms delay everywhere else and uses 150 ms only on the
matching HP Spectre family.

### libcamera

- [ov08x40 sensor properties](patches/libcamera/0001-libcamera-sensor-add-ov08x40-properties.patch)
- [simple IPA Adjust defaults](patches/libcamera/0002-ipa-simple-read-adjust-defaults-from-tuning.patch)
- [simple IPA AGC limits](patches/libcamera/0003-ipa-simple-read-agc-limits-from-tuning.patch)
- [ov08x40 tuning installation](patches/libcamera/0004-ipa-simple-add-ov08x40-tuning.patch)

The ov08x40 sensor helper is not duplicated here because it is already in
libcamera upstream.

## Start here

1. Read the [installation and rollback guide](docs/install.md).
2. Run `scripts/check-system.sh` on the HP laptop.
3. Use `scripts/apply-patches.sh --check` against clean Linux and libcamera
   source trees before applying anything.
4. Build first. Do not install a module that failed its checks or was built for
   a different kernel.
5. After rebooting, run `scripts/verify-camera.sh`.

The exact source bases and current test results are in
[validation.md](docs/validation.md).

## Status

This patch set applies and builds against the source revisions listed in
[validation.md](docs/validation.md). The exact patch set was tested on the
target laptop with Secure Boot enabled, including kernel module loading,
libcamera capture, PipeWire, and GNOME Snapshot. The included color profile
improves warm indoor lighting but is not calibrated for every camera or room.

## Upstream status

See [upstream-status.md](docs/upstream-status.md) for the current merge and
submission status of each change.

## Privacy and license

Please read [PRIVACY.md](PRIVACY.md) before posting logs or test images.
Documentation is under [CC BY 4.0](LICENSE.md). Patch code keeps the license of
the project it changes, and the tuning file is `CC0-1.0`.
