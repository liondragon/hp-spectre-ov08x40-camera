# Validation Record

Last checked: August 16, 2026

## Source bases

- Linux: `fd923b32d7614047c8b2acecae3915ec94f7afab`
- libcamera: `b8910c9a4961b992a6c5bbe836e2cd1c30626e31`

## Passed

- Both Linux patches apply cleanly to the current Linux revision listed above.
- `drivers/media/i2c/ov08x40.o` compiles in the recorded Linux tree with `W=1`.
- `drivers/platform/x86/intel/int3472/discrete.o` compiles.
- `drivers/platform/x86/intel/int3472/discrete_quirks.o` compiles.
- Both Linux patches pass `scripts/checkpatch.pl --strict` with no findings.
- All libcamera patches apply cleanly to the recorded libcamera base.
- A simple-pipeline, simple-IPA libcamera build completes successfully.
- libcamera `utils/checkstyle.py --staged` reports no issue.
- The YAML parses successfully.

## Hardware testing

The published patches were also applied to the Ubuntu 7.0.12 source shipped by
the `linux-source-7.0.0` package version `7.0.0-29.29` and built for Ubuntu
kernel `7.0.0-29-generic` on the target HP Spectre.

- The three rebuilt modules were signed with an enrolled Secure Boot key,
  installed, added to the initramfs, and loaded after reboot.
- The loaded module source versions matched the rebuilt files.
- The laptop completed 25 consecutive reboots with the patched modules. Every
  boot detected the ov08x40 sensor, libcamera reported one camera, and the
  earlier `-121` sensor probe error did not recur.
- The patched libcamera build captured 60 consecutive 3848x2416 frames at
  30 frames per second through the simple pipeline.
- PipeWire exposed the camera as the built-in front camera, and GNOME Snapshot
  displayed a stable live preview.
- Automatic white balance removed the strong green-yellow cast seen under
  2700 K LED lighting. Exposure, shadow detail, skin tone, and a white reference
  were checked in the live preview.

The included tuning is specific to this camera and laptop family. Automatic
white balance remains enabled, but daylight and other units have not yet been
independently measured.
