# Upstream Status

Last checked: September 12, 2026

| Work | Status |
| --- | --- |
| Ubuntu `linux` bug report | Submitted as [Launchpad bug #2163610](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2163610) |
| Red Hat Bugzilla test report | Added to [bug #2333331, comment 102](https://bugzilla.redhat.com/show_bug.cgi?id=2333331#c102) |
| libcamera ov08x40 sensor helper | Merged as `0a1cff8bba3d5ca871f6218ab32869f7c90bdc71` |
| libcamera ov08x40 sensor properties | Changes requested. A v2 using the documented 702 nm unit-cell size, pattern mode 2, and default control delays is prepared locally but not sent. Original Message-ID `20260816204253.2845257-1-opensource@inspiredexperts.com` |
| libcamera simple IPA Adjust defaults | Jacopo Mondi added `Acked-by`; Kieran Bingham asked whether this should use a common implementation. Original Message-ID `20260816204259.2845517-2-opensource@inspiredexperts.com` |
| libcamera simple IPA AGC limits | Needs redesign rather than a mechanical rebase because the simple IPA now uses the common AGC implementation. Original Message-ID `20260816204259.2845517-3-opensource@inspiredexperts.com` |
| libcamera ov08x40 tuning | Waiting for the Adjust and AGC decisions and new hardware measurements against the current softisp IPA. Original Message-ID `20260816204259.2845517-4-opensource@inspiredexperts.com` |
| Linux ov08x40 crop selection | No reply recorded. Message-ID `20260816204239.2844654-1-opensource@inspiredexperts.com` |
| Linux INT3472 handshake delay | Superseded by Hans de Goede's global 200 ms v2, which credits James with `Reported-by` and was applied to the media tree. Message-ID `20260818122821.165541-1-johannes.goede@oss.qualcomm.com` |

The libcamera tuning series cover letter has Message-ID
`20260816204259.2845517-1-opensource@inspiredexperts.com`.
