# Pinned Google GKI

This directory contains the redistributed Google GKI artifacts. The 311 buildable
`vendor_dlkm` modules, base DTB, and `dtbo.img` are generated from the published
Nothing kernel source by `../stage_kernel_artifacts.sh`. Two additional stock NFC
modules must be extracted locally and are not redistributed by this repository.

The LineageOS charter permits this explicitly:

> GKI devices MAY use either a source-built kernel or a prebuilt GKI image from Google, but MUST
> build all feasible modules from source.
> — `LineageOS/charter`, `device-support-requirements.md`, §Kernel

## Contents

| file | provenance |
|---|---|
| `Image` | `6.6.102-android15-8-gab8eb70a71b8-ab14350911-4k`, built by `kleaf@build-host` 2025-10-29. Google GKI build `ab14350911`. Shipped by Nothing on Nothing OS `Metroid_B4.0-250917-1218`. |
| `system_dlkm/` | 96 GKI modules from Google GKI build `ab13768703`, vermagic `6.6.87-android15-8-gc2569c3b141c-ab13768703-4k`. Also as shipped by Nothing. |

Exact public corresponding-source records:

| Artifact set | Android CI build | Immutable `kernel/common` source | Build configuration |
|---|---|---|---|
| `Image` | [`14350911/kernel_aarch64`](https://ci.android.com/builds/submitted/14350911/kernel_aarch64/latest) | [`ab8eb70a71b8906e3ceac53d2b10f027f8774bcb`](https://android.googlesource.com/kernel/common/+/ab8eb70a71b8906e3ceac53d2b10f027f8774bcb) | [`build.config.gki.aarch64`](https://android.googlesource.com/kernel/common/+/ab8eb70a71b8906e3ceac53d2b10f027f8774bcb/build.config.gki.aarch64) |
| `system_dlkm` | [`13768703/kernel_aarch64`](https://ci.android.com/builds/submitted/13768703/kernel_aarch64/latest) | [`c2569c3b141cb39a6c2bca63c62697589fe86dc4`](https://android.googlesource.com/kernel/common/+/c2569c3b141cb39a6c2bca63c62697589fe86dc4) | [`build.config.gki.aarch64`](https://android.googlesource.com/kernel/common/+/c2569c3b141cb39a6c2bca63c62697589fe86dc4/build.config.gki.aarch64) |

Both source revisions specify Clang `r510928` in `build.config.constants`.

`Image` SHA-256:
`a56ce8776a134b6ebf5bf0cfc67aabd56fabc41a961790dc16ee4770733770bc`.
The sorted SHA-256 inventory of `Image`, `system_dlkm/*.ko`, and
`system_dlkm/modules.*` hashes to
`6e520a008b0ca8b9e6eca7a13962f87d18d31a6135b05d9a1e2337a5619813d7`.

These identifiers document the exact checked-in set; they do not replace any
license or corresponding-source obligations.

Note the `Image` and `system_dlkm` come from *different* Google GKI builds (6.6.102 vs 6.6.87).
That is how the device shipped, and it works because GKI enforces the KMI generation
(`android15-8`), which both share — not the point release.

## Why system_dlkm is not built from source

GKI modules belong to the GKI release, not to this device. Our own `//common:kernel_aarch64`
build is `android15-6.6` HEAD (6.6.142) and its `gki_defconfig` does not even match Google's —
it has no `CONFIG_TLS`, so it cannot produce the `tls.ko` this device loads. Pairing our GKI
modules with Google's `vmlinux` would be strictly worse than shipping the matched set.

## Switching to a fully source-built kernel

The Kleaf workspace already builds `//common:kernel_aarch64` and `//msm-kernel:sun_perf_dist`
end to end, so shipping our own `Image` + `system_dlkm` is a config change, not new work. It was
deliberately not done: it would move the device off the 6.6.102 GKI its firmware was validated
against, for no compliance gain. If you do switch, rebuild `vendor_dlkm` in the same pass so all
three stay consistent.
