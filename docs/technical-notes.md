# What the Fix Changes

## INT3472 power timing

On the affected system, the OVTI08F4 sensor failed to read its chip ID with
error `-121` when the existing 45 ms handshake delay was used. Increasing the
delay to 150 ms allowed it to probe.

The patch does not raise the delay for every OVTI08F4 camera. It adds a quirk
field and applies 150 ms only when DMI identifies the HP Spectre x360
14-eu0xxx family.

## ov08x40 crop selection

libcamera asks raw camera sensors for their native size, crop bounds and active
crop. The driver did not answer those requests.

The kernel patch records the crop for each mode, initializes the try crop when
the subdevice opens, and implements `get_selection`. This removes the rectangle
ioctl errors seen during camera setup.

## libcamera sensor support

The ov08x40 sensor helper was merged upstream in libcamera commit
`0a1cff8bba3d5ca871f6218ab32869f7c90bdc71`. This repository only adds the
remaining static sensor properties.

Those properties include a 700 nm unit-cell size, the supported color-bar test
pattern, and two-frame delays. The unit-cell size comes from OmniVision's OV08X
product information. The delays are experimental and need wider hardware
validation.

## Simple IPA tuning

The simple IPA already has Adjust and AGC algorithms, but it could not read
these defaults and limits from YAML. The patches add optional values for:

- gamma, contrast and saturation;
- the AGC histogram target;
- maximum analogue gain;
- maximum exposure time.

When those keys are missing, existing tuning files keep the old behaviour.

The included ov08x40 values are:

```text
Maximum exposure: 33 ms
Maximum analogue gain: 3.0
AGC target: 2.3
Contrast: 1.15
Gamma: 2.2
```

On the target laptop, the color-correction matrix and automatic white balance
substantially reduced a green-yellow cast under 2700 K LED lighting. The values
are practical webcam tuning, not calibrated tuning for every unit.

## Desktop routing

The desktop setup disables WirePlumber's raw V4L2 monitor and keeps the
libcamera monitor enabled. This prevents desktop apps from choosing the raw
sensor device instead of the processed libcamera stream.
