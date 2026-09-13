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
- Linux `7.0.0-29-generic` (original validation); current Ubuntu kernel
  backports are recorded in [validation.md](docs/validation.md)
- Intel IPU6 and libcamera softisp IPA

## What is included

### Linux kernel

- [ov08x40 crop-selection patch](patches/linux/0001-media-i2c-ov08x40-add-crop-selection.patch)
- [INT3472 200 ms handshake-delay patch](patches/linux/0002-platform-x86-int3472-increase-handshake-delay.patch)

The crop patch gives libcamera the sensor rectangles it asks for. The accepted
INT3472 patch raises the default handshake delay to 200 ms for systems that use
that power path; it supersedes the original HP-specific 150 ms submission.

### libcamera

- [ov08x40 sensor properties](patches/libcamera/0001-libcamera-sensor-add-ov08x40-properties.patch)
- [configurable AGC settling tolerance](patches/libcamera/0002-ipa-libipa-agc-add-exposure-tolerance.patch)
- [ov08x40 softisp tuning](patches/libcamera/0003-ipa-softisp-add-ov08x40-tuning.patch)

The ov08x40 sensor helper is not duplicated here because it is already in
libcamera upstream. The sensor properties and configured AGC tolerance together
prevent the periodic exposure pulsing reproduced on the target camera; this is
separate from color tuning. Other common-AGC users keep their existing behavior
because the new tolerance defaults to zero.

## Start here

1. Read the [installation and rollback guide](docs/install.md).
2. Run `scripts/check-system.sh` on the HP laptop.
3. Check each patch against the exact base recorded in
   [patches/README.md](patches/README.md) before applying anything.
4. Build first. Do not install a module that failed its checks or was built for
   a different kernel.
5. Install the included dma-heap rule for CPU softisp buffer access.
6. After rebooting, run `scripts/verify-camera.sh`.

The exact source bases and current test results are in
[validation.md](docs/validation.md).

## Status

The original patch set was tested on the target laptop with Secure Boot
enabled, including kernel module loading, libcamera capture, PipeWire, and
GNOME Snapshot. Current patch preparation and test results are recorded in
[validation.md](docs/validation.md). The included color matrix improved warm
indoor lighting on the tested unit but is not a laboratory calibration for
every camera or room.

## Upstream status

See [upstream-status.md](docs/upstream-status.md) for the current merge and
submission status of each change.

## Privacy and license

Please read [PRIVACY.md](PRIVACY.md) before posting logs or test images.
Documentation is under [CC BY 4.0](LICENSE.md). Patch code keeps the license of
the project it changes, and the tuning file is `CC0-1.0`.
