# Patch Set

The currently prepared patches use these upstream bases:

- Linux crop-selection patch: `dac3e89a2c90c2feeb471e1f22a2512ad424b792`
- Linux INT3472 delay patch: Hans de Goede's accepted v2 from August 18,
  2026; it has also been backported and build-tested against Ubuntu 7.0.14.
- libcamera sensor-properties v2: `87c7285663aaad7608fdc18d5216ec6811c685c7`
- Original libcamera tuning series: `b8910c9a4961b992a6c5bbe836e2cd1c30626e31`

The Linux patches are separate changes for separate maintainer groups. The
libcamera sensor-properties patch is independent. The remaining three
simple-IPA files record the original submitted series in this order:

1. Adjust defaults
2. AGC limits
3. ov08x40 tuning

Do not submit or apply that original three-patch IPA series to current
libcamera unchanged. The simple IPA has moved to `softisp`, its AGC now uses
the common implementation, and the tuning needs fresh measurements against
that implementation.

The files use mail-style patch format. `scripts/apply-patches.sh` remains
appropriate for the recorded historical source bases; current upstream work
should be checked patch-by-patch against the base listed above.
