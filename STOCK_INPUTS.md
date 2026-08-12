# Stock input matrix

Proprietary files are not distributed by this repository. Builders must obtain
the documented firmware lawfully and run the checked-in extraction scripts.

| Input | Source build | Verification |
|---|---|---|
| Android userspace blobs | `Metroid_B4.1-260414-1846` | Extracted `product.img` SHA-256 `801e2c0842c36005c51c4828e8cc632481c6a617c5c10f97b1a29c07eb49ca89`; `system.img` `a70315b5bd038273543eca42d71bf19d67bf5eb5fd410aa85a54dfa95aade639`; `system_ext.img` `24cface356a55a67b84c5564a1070490ca61e8002a779c55f7260752a9ecb7cf` |
| Google GKI and system DLKM | `Metroid_B4.0-250917-1218` | Exact Android CI builds and hashes in `kernel/gki/README.md` |
| Local NFC modules | `Metroid_B4.0-250917-1218` | Per-module SHA-256 values in `kernel/prebuilt-modules/README.md` |

The split is intentional. The device userspace extraction was updated to the
B4.1 stock baseline, while the accepted kernel configuration retains the GKI
and NFC module set validated with Nothing's B4.0 kernel ABI. Both NFC modules
report the Android 15 KMI generation expected by the retained GKI. A future
kernel transition must replace this matrix atomically rather than mixing
unrecorded artifacts.

Public firmware hash lists are available from the Nothing Archive release
records for `Metroid_B4.1-260624-1457` (which links the B4.1 full OTA chain) and
`Metroid_B4.0-250917-1218`. Those third-party records are provenance evidence,
not redistribution permission.

`Metroid_B4.1-260624-1457` is the newest indexed stock evidence as of 2026-08-12.
It is not yet a validated build input. Acquire and compare it in a separate
immutable private reference tree; do not overwrite the accepted `260414`
userspace extraction or atomically change userspace, firmware, GKI, and module
inputs without a reviewed compatibility transition.
