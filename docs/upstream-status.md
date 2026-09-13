# Upstream Status

Last checked: September 12, 2026

| Work | Status |
| --- | --- |
| Ubuntu `linux` bug report | Submitted as [Launchpad bug #2163610](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2163610) |
| Red Hat Bugzilla test report | Added to [bug #2333331, comment 102](https://bugzilla.redhat.com/show_bug.cgi?id=2333331#c102) |
| libcamera ov08x40 sensor helper | Merged as `0a1cff8bba3d5ca871f6218ab32869f7c90bdc71` |
| libcamera ov08x40 sensor properties | Changes requested. A v3 using the documented 702 nm unit-cell size, pattern mode 2, and measured two-frame exposure and analogue-gain delays is prepared locally but not sent. [Oleg Mikheev's overlapping patch](https://patchwork.libcamera.org/patch/28148/) is also under review; it uses 700 nm and does not include the measured delays. Coordinate with that thread before sending another version. Original Message-ID `20260816204253.2845257-1-opensource@inspiredexperts.com` |
| libcamera simple IPA Adjust defaults | Superseded locally. Current softisp does not accept these tuning defaults; the replacement tuning uses its existing Adjust behavior. Original Message-ID `20260816204259.2845517-2-opensource@inspiredexperts.com` |
| libcamera simple IPA AGC limits | Superseded locally by the common AGC implementation and the sensor's reported physical limits. Original Message-ID `20260816204259.2845517-3-opensource@inspiredexperts.com` |
| libcamera ov08x40 tuning | A current softisp patch retaining the tested color matrix, using the existing Adjust and AGC defaults, and removing obsolete keys is prepared locally but not sent. It has a same-scene hardware comparison but not a full calibration. Original Message-ID `20260816204259.2845517-4-opensource@inspiredexperts.com` |
| libcamera configurable AGC settling tolerance | Prepared locally as the first patch in a two-patch RFC series and not sent. It adds a common tuning option that defaults to zero; the second patch enables 2% only for ov08x40. Exposure-compensation changes rebase the filtered exposure, while exposure and constraint mode changes reset it. The hardware reproducer shows that the configured tolerance and corrected sensor delay together eliminate the periodic exposure pulse while preserving response to larger changes. |
| Linux ov08x40 crop selection | No reply recorded. Message-ID `20260816204239.2844654-1-opensource@inspiredexperts.com` |
| Linux INT3472 handshake delay | Superseded by Hans de Goede's global 200 ms v2, which credits James with `Reported-by` and was applied to the media tree. Message-ID `20260818122821.165541-1-johannes.goede@oss.qualcomm.com` |

The libcamera tuning series cover letter has Message-ID
`20260816204259.2845517-1-opensource@inspiredexperts.com`.
