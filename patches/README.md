# Patch Set

The patches are based on these upstream commits:

- Linux: `dac3e89a2c90c2feeb471e1f22a2512ad424b792`
- libcamera: `b8910c9a4961b992a6c5bbe836e2cd1c30626e31`

The Linux patches are separate changes for separate maintainer groups. The
libcamera sensor-properties patch is independent. The three simple-IPA patches
form a series in this order:

1. Adjust defaults
2. AGC limits
3. ov08x40 tuning

The files use mail-style patch format and can be checked or applied with
`scripts/apply-patches.sh`.
