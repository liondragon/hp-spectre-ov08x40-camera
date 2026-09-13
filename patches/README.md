# Patch Set

The currently prepared patches use these source bases:

- Linux local-install set: Ubuntu source package `7.0.0-31.31`, source-tar
  SHA-256
  `2b3931325008e95281f0747484b0832b07f1f8aa8a94677049b29a9bf4aabf09`.
- Linux crop-selection upstream patch: compile-tested separately against
  `fd923b32d7614047c8b2acecae3915ec94f7afab`.
- Linux INT3472 delay patch: an installable Ubuntu backport of Hans de Goede's
  accepted August 18, 2026 change, not the upstream submission artifact.
- libcamera sensor-properties v3: `87c7285663aaad7608fdc18d5216ec6811c685c7`
- libcamera softisp tuning: `87c7285663aaad7608fdc18d5216ec6811c685c7`
- libcamera configurable AGC settling-tolerance RFC: `87c7285663aaad7608fdc18d5216ec6811c685c7`

The two Linux files apply together to the Ubuntu source package above. The
crop-selection patch also remains a standalone upstream submission; the
INT3472 upstream change is already accepted and is kept here only in its local
Ubuntu-install form. The libcamera color tuning is independent of the
sensor-properties and common AGC
code changes. The latter two address distinct parts of the exposure-control
path and are both needed to eliminate the reproduced pulse on the tested
camera. The current tuning keeps the tested color matrix and existing Adjust,
target, and sensor-limit defaults; it enables the new 2% settling tolerance but
does not carry the obsolete custom controls from the original submitted series.

The files use mail-style patch format. Check each patch against the base listed
above before applying it. Do not submit the INT3472 backport upstream; the
equivalent maintainer-authored change has already been accepted.
