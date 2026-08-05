# Locally extracted kernel modules

Two GPL modules loaded by the stock `vendor_dlkm` image do not currently have
matching published source:

| Module | Purpose | Expected SHA-256 |
|---|---|---|
| `stm_nfc_i2c.ko` | ST NFC controller | `5f6ec24ab7a464169463f10d56e42d09e5f4cc360b5e7ec8261a515ad895f742` |
| `stm_st54se_gpio.ko` | ST54 secure-element GPIO | `334c9afd91859276bbdefae30f671a0b515d6656ccbded6121da4e7f587c741a` |

Both expected files came from the `vendor_dlkm` partition of Nothing OS
`Metroid_B4.0-250917-1218` and report the stock 6.6.87 Android 15 KMI. This public
repository does not redistribute those binaries. Extract them from your own
copy of that documented stock image:

```bash
kernel/extract-unpublished-modules.sh /path/to/extracted/vendor_dlkm
```

The script verifies both hashes and writes them to the ignored
`kernel/local-prebuilt-modules/` directory consumed by
`stage_kernel_artifacts.sh`.

Redistributors remain responsible for satisfying all applicable license and
corresponding-source obligations. Local extraction is for private build and test
use; it does not by itself authorize public OTA redistribution. If matching
source is published, build these modules from source and remove the
local-extraction path.
