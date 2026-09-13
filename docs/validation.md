# Validation Record

Last checked: September 12, 2026

## Current preparation

- The Linux crop-selection patch and the accepted global 200 ms INT3472
  handshake-delay patch were backported to Ubuntu 7.0.14 source package
  `7.0.0-31.31`.
- The ov08x40 and INT3472 modules build for the exact
  `7.0.0-31-generic` ABI and report matching `vermagic`.
- The prepared libcamera sensor-properties v3, current softisp tuning, and
  common AGC settling patch apply to upstream commit
  `87c7285663aaad7608fdc18d5216ec6811c685c7`.
- That combined current libcamera tree builds successfully on the target
  laptop. A discarded 20-frame capture ran at 30 frames per second, and the
  runtime selected `src/ipa/softisp/data/ov08x40.yaml`.
- In a same-scene comparison, raising the supported common-AGC relative
  luminance target from its `0.16` default to `0.22` raised measured neutral
  wall luminance by about 15% without materially increasing highlight clipping,
  but the live preview showed periodic brightness changes. The pulsing remained
  after restoring the default target, so the custom target was discarded and
  was not the cause.
- A 12-second fixed-region sequence reproduced the pulse under automatic
  exposure: brightness rose by about 2.2% for eight frames every roughly 1.7
  seconds, synchronized with analogue-gain corrections. With exposure fixed at
  33.315 ms and analogue gain fixed at 5.2x, variation fell to about 0.25% and
  the periodic pulse disappeared. This isolates the behavior to automatic
  exposure rather than room-light flicker or unavoidable sensor variation.
- Step-response captures measured two-frame exposure and analogue-gain delays
  from kernel control write to visible effect. Correcting the gain delay alone
  left about 2.1% periodic variation. The 2% AGC settling tolerance alone, with
  the old fallback delay, left about 2.5% variation. With both changes applied,
  analogue gain remained constant after convergence and fixed-region variation
  stayed below 1% without the periodic pulse.
- With both changes applied, an `ExposureValue` step from 0 to +1 and back to 0
  changed mean analogue gain from 5.39x to 6.72x and then to 5.47x, confirming
  that the settling tolerance does not prevent response to larger changes.
- The revised RFC leaves the tolerance disabled unless tuning enables it and
  rebases the filtered exposure when exposure compensation changes. With a 2%
  tolerance enabled, a smaller `ExposureValue` step from 0 to +0.02 changed
  analogue gain from 6.179688x to 6.265625x on the next processed request. The
  return to 0 changed 6.398438x to 6.304688x. Both changes match the expected
  `2^EV` direction and magnitude within sensor gain quantization.
- A fresh, clean, test-enabled CPU-softisp worktree was created from the
  recorded base using the exact three current mail patches, then built in full.
  Meson reported 47 passes, 34 environment-dependent skips, one expected
  failure, and no failed tests. The build enabled the `simple`
  pipeline, `softisp` IPA, and tests; the suite was run with
  `meson test -C build --print-errorlogs`.
- The GPU softisp path produced horizontal corruption at 1280x720 while the
  driver reported a 3904-byte input stride after 4096 bytes was requested and
  DMABUF import fell back to upload. The CPU softisp path produced a clean frame
  at the same output size. This is separate from color tuning.
- The signed kernel backport loaded from the override path on the target
  laptop across 25 consecutive reboots. Every boot had no ov08x40 `-121`
  probe error and enumerated one internal camera.
- A discarded 20-frame 3848x2416 capture completed at 30 frames per second,
  and PipeWire exposed one `Built-in Front Camera` source. No image was
  retained.
- After refreshing PipeWire, WirePlumber, and the desktop portals, GNOME
  Snapshot opened an active stream from that source. Visual color and exposure
  quality still require owner observation rather than automated validation.

## Source bases

- Linux local module build: Ubuntu source package `7.0.0-31.31`; installed
  source tar SHA-256
  `2b3931325008e95281f0747484b0832b07f1f8aa8a94677049b29a9bf4aabf09`
- Linux crop-selection upstream check:
  `fd923b32d7614047c8b2acecae3915ec94f7afab`
- libcamera: `87c7285663aaad7608fdc18d5216ec6811c685c7`

## Passed

- Both installable Linux patches apply to the extracted Ubuntu source package
  listed above. The crop-selection patch also applies cleanly to its separate
  upstream-check revision.
- With the included dma-heap udev rule active and the user in the `video`
  group, CPU softisp can allocate its buffers without running the camera app
  as root.
- `drivers/media/i2c/ov08x40.o` compiles in the recorded Linux tree with `W=1`.
- `drivers/platform/x86/intel/int3472/discrete.o` compiles.
- `drivers/platform/x86/intel/int3472/discrete_quirks.o` compiles.
- Both Linux patches pass `scripts/checkpatch.pl --strict` with no findings.
- All libcamera patches apply cleanly to the recorded libcamera base.
- A simple-pipeline, softisp-IPA libcamera build completes successfully.
- The available libcamera style checks report no content finding; the optional
  `reuse` and `clang-format` tools were unavailable on the test system.
- The YAML parses successfully.

## Hardware testing

### Current softisp candidate

The September 12 current-libcamera testing used the recorded libcamera base,
the three prepared patches, and the CPU softisp path at 1280x720. The live
preview retained the tuning file's improvement over the untuned green-yellow
cast, but remained darker and warmer than an Insta360 comparison camera showing
roughly the same scene. No test image was retained. This is a visual comparison,
not a calibrated color measurement, so the matrix remains a candidate for
controlled chart calibration rather than a general per-unit result.

After the owner reported that the current preview looked grainier and hazier,
same-scene A/B captures separated the exposure-stability patch from the image
quality regression. Disabling `relativeExposureTolerance` left the appearance
and uniform-wall adjacent-pixel RMS noise effectively unchanged (2.93 versus
2.97 on an 8-bit luma scale), while analogue gain remained near 7x. The
tolerance is therefore not the source of the grain or low contrast.

The current softisp defaults reached 6.84x to 7.10x analogue gain at the
33.315 ms frame-duration limit in this lighting. A supported tuning experiment
using `relativeLuminanceTarget: 0.12` and a 0.35 normal lower constraint reduced
gain to 4.82x and adjacent-pixel RMS noise to 2.63, but lowered the sampled wall
mean from 171 to 146. Applying `Contrast: 1.15` improved apparent separation
but amplified the same noise. Neither experiment was adopted: the appropriate
brightness/noise tradeoff needs controlled multi-lighting evaluation, and
contrast defaults belong to the softisp Adjust algorithm rather than the AGC
settling patch. No comparison image was retained.

### Original simple-IPA series

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

The current prepared tuning retains the matrix and removes the obsolete Adjust
and AGC keys from the original series. Automatic white balance remains enabled,
but neither the original checks nor the current same-scene comparison are a
calibration; daylight and other units have not been independently measured.
