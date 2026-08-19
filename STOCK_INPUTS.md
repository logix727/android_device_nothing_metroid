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

The private comparison set is verified locally: official `260414 -> 260624` OTA
SHA-256 `9a745b155b0062e12b0150d694271d347964ff6dd1f48f49581b0617f83c18e3`,
all 41 extracted partition images match the published hash list, and NothingOSS
`sm8735/b/mr` is pinned at
`b2381b5e146c4e50dd5871d3254c83e2af227614`.

## Current radio comparison: B4.1 260814

The official incremental from `Metroid_B4.1-260624-1457` to
`Metroid_B4.1-260814-1733` was downloaded from Nothing's Google OTA endpoint:

- URL: `https://android.googleapis.com/packages/ota-api/package/2a52b639be641edff7fb07fac5d645503acd14bc.zip`
- OTA SHA-256:
  `3c537697c6d086045fb1d285f69579416f591d9df45dfc8e91f00a435bfa37a0`
- Nothing Archive commit: `278ba197ca20792ead72adc57e0268c4724928b4`
- Published partition-manifest SHA-256:
  `100416e302bd4aafb7a5c08821a79b544b2f53a36d4df87f687be8597cfdad27`
- Reconstruction: the archive `ota_extractor` applied the incremental to the
  exact verified 260624 41-partition base; all 41 outputs pass the published
  manifest.
- Modem build:
  `MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.152387.2.170946.5`
- Modem filesystem image SHA-256:
  `561be74df3f8c943706b04ff4fa5247ad90a71abc88d6ebf35302844c4d17270`
- Zero-padded 367001600-byte modem partition SHA-256:
  `35f2476e03a3f3353c1db999b88a075ffd30ebb0f006e3498c96b1d6e27ed0a3`

Core QCRIL/data/IMS binaries, database, Google/QTI LPA, data-status APK, DSP and
`multiimgqti` are unchanged. The current stock radio control set changes
QtiTelephony (`67935f1accf409ad96490ac67492b76c4b8a4ccd16f9cd6dadae20f920ddf92d`),
`nt-telephony-common.jar`
(`b760c04d504157593c87ca36cb847d3f04ca9e7f8f9246f43f4a6281909bec87`),
and ABI-compatible `libril-qc-radioconfig.so`
(`0bb964f7ac65a02939862c301ce4c64b2c5f121fb6c485cbb5ef84d99fe03572`).
These inputs are promoted atomically; the successor candidate requires the full
260814 firmware generation rather than a modem-only mix.

Firmware installation boundary: update both slots for `abl`, `aop`,
`aop_config`, `bluetooth`, `cpucp`, `cpucp_dtb`, `devcfg`, `dsp`,
`featenabler`, `hyp`, `imagefv`, `keymaster`, `modem`, `multiimgoem`,
`multiimgqti`, `qupfw`, `shrm`, `soccp_dcd`, `soccp_debug`, `tz`, `uefi`,
`uefisecapp`, `xbl`, `xbl_config`, and `xbl_ramdump`. Do not flash stock
`pvmfw`: it is ROM-owned and source-built with the candidate pKVM stack. Android
logical partitions, boot/vendor_boot/init_boot/recovery/dtbo, AVB partitions and
userdata likewise remain candidate-owned.
