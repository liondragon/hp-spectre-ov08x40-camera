# What the Fix Changes

## INT3472 power timing

On the affected system, the OVTI08F4 sensor failed to read its chip ID with
error `-121` when the existing 45 ms handshake delay was used. A 150 ms
machine-specific delay first demonstrated the timing problem. The accepted
upstream fix instead raises the INT3472 handshake delay to 200 ms for every
sensor that uses this power sequence.

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

Those properties include the documented 702 nm unit-cell size and supported
color-bar test patterns. Step-response testing measured two-frame exposure and
analogue-gain delays. The blanking controls retain the generic two-frame values.

## automatic exposure stability

The common mean-luminance AGC can continue making small alternating exposure
corrections near its target. Combined with delayed and quantized sensor
controls, those corrections produced a visible brightness pulse on this
camera. The prepared common AGC patch adds an optional relative exposure
tolerance, disabled by default, and the ov08x40 tuning enables it at 2%.
Exposure-compensation changes rebase the filtered exposure, while exposure and
constraint mode changes reset it, so explicit controls remain responsive.

Correct sensor delays and the settling tolerance are separate changes. Neither
eliminated the pulse alone in testing; together they held analogue gain steady
while retaining normal response to an exposure-compensation change.

## softisp tuning

The current softisp IPA uses the common AGC implementation and fixed Adjust
defaults. The tuning leaves exposure, gain, contrast, gamma, and target
luminance at those existing defaults, while enabling the measured 2% settling
tolerance. It enables automatic white balance and retains the tested 3050 K
color-correction matrix.

The original simple-IPA tuning series carried `contrast`, `gamma`,
`maxAnalogueGain`, and `maxExposureTimeMs` keys through proposed parser
changes. Current softisp does not parse those keys: its Adjust algorithm uses
runtime controls and common AGC derives hard limits from sensor controls. The
current tuning therefore cannot preserve the old 1.15 default contrast or 3x
gain ceiling merely by copying those fields.

This ownership split matters for follow-up work. Sensor-specific luminance and
constraint curves belong in the OV08X40 tuning. A configurable default contrast
belongs in the common softisp Adjust algorithm. Exposure settling remains in
common AGC, with per-sensor opt-in through tuning. Keeping those changes
separate avoids hiding image-quality policy inside the anti-oscillation fix.

On the target laptop, that matrix and automatic white balance substantially
reduced a green-yellow cast under 2700 K LED lighting. This is practical tuning
from one unit and lighting setup, not a laboratory calibration for every unit.

## Desktop routing

The desktop setup disables WirePlumber's raw V4L2 monitor and keeps the
libcamera monitor enabled. This prevents desktop apps from choosing the raw
sensor device instead of the processed libcamera stream.
