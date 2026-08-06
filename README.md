# LineageOS 23 device tree for Nothing Phone (3) (`metroid`)

Unofficial LineageOS 23 (Android 16) bring-up for the Nothing Phone (3), codename
`metroid`, based on Qualcomm SM8735.

## Status

**Alpha development. Not release-ready.**

There is currently no supported public OTA or recovery bootstrap download. Do
not follow old mirrors, mix artifacts, or treat this repository as an official
LineageOS release. The latest accepted build is a maintainer-local candidate;
its source and artifact lock is not yet completely public or reproducible.

Current runtime blockers include cellular IMS/eSIM integration, Power HAL
registration, framework thermal mapping, launch/security metadata, and release
record consistency. See [`BUGS.md`](BUGS.md) for the evidence-ranked backlog.

## Repository scope

This repository contains:

- the public device configuration;
- source patches temporarily carried for other Android projects;
- recovery-installer source;
- documented Google GKI artifacts permitted for GKI devices.

It does not contain Android userspace vendor blobs, private signing/AVB keys,
modem firmware, or bootloader firmware. Proprietary Android files must be
extracted from firmware owned by the builder.

Two stock GPL NFC kernel modules currently lack matching published source. They
are intentionally not redistributed here. Builders must extract the exact
documented files from their own stock image; see
[`kernel/prebuilt-modules/README.md`](kernel/prebuilt-modules/README.md).

## Building

This is a pinned public-source reconstruction recipe. Proprietary inputs remain
builder-supplied and are verified separately.

1. Initialize the immutable source candidate:

   ```bash
   repo init \
     -u https://github.com/logix727/android_device_nothing_metroid.git \
     -b refs/tags/lineage-23.0-20260806-source-r4 \
     -m manifest/lineage-23.0-20260806-base.xml
   repo sync -c
   device/nothing/metroid/patches/apply-series.sh "$PWD"
   ```

   The manifest pins all platform projects to public pre-patch revisions. The
   application script verifies every resulting project tree. `manifest/metroid.xml`
   remains the moving development manifest and is not a release lock.
2. Extract proprietary userspace files from your own documented B4.1 stock dump:

   ```bash
   ./device/nothing/metroid/extract-files.py /path/to/stock/dump
   ```

   Exact stock inputs and hashes are recorded in [`STOCK_INPUTS.md`](STOCK_INPUTS.md).

3. Extract the two locally required NFC modules as documented in
   `kernel/prebuilt-modules/README.md`.
4. Build the kernel workspace and stage the generated device inputs:

   ```bash
   mkdir /path/to/kernelws
   cd /path/to/kernelws
   repo init \
     -u https://github.com/logix727/android_device_nothing_metroid.git \
     -b lineage-23.0 \
     -m kernel/manifest/metroid-kleaf.xml
   repo sync -c
   /path/to/lineage/device/nothing/metroid/kernel/setup-kleaf-workspace.sh "$PWD"
   build/kernel/kleaf/bazel.sh build --noenable_bzlmod \
     --//vendor/qcom/opensource/camera-kernel:project_name=sun \
     --target_pattern_file="$PWD/vendor-module-targets.txt"
   cd /path/to/lineage
   device/nothing/metroid/kernel/stage_kernel_artifacts.sh /path/to/kernelws
   ```

   The pinned manifest records every public source/tool base revision. The setup
   script applies the four reviewed kernel carry patches from `kernel/patches/`
   before creating the portable workspace. Host requirements include `repo`, `git`, `python3`, `bash`,
   `perl`, `rsync`, `find`, `flex`, `bison`, `patch`, and standard GNU utilities.

5. Build Android:

   ```bash
   source build/envsetup.sh
   lunch lineage_metroid-bp2a-userdebug
   m bacon
   ```

   Public source builds use AOSP's non-secret AVB test key. A release maintainer
   supplies a private signing path with `METROID_AVB_KEY_PATH`; private keys must
   never be committed or shared.

The installed maintainer baseline is recorded in [`BASELINE.md`](BASELINE.md).
The current public reconstruction record is
[`release/20260806-source-lock.json`](release/20260806-source-lock.json); it is a
source candidate, not a claim that a matching OTA has passed device validation.

The Android local manifest and `lineage.dependencies` use the maintainer kernel fork
while this bring-up remains unofficial. An official submission must use
LineageOS-hosted dependencies and the active release branch conventions.

## Safety

- No public build is presently endorsed for installation.
- Never disable AVB verification or set root vbmeta disable flags.
- Never mix recovery, boot, AVB, or OTA artifacts from different builds.
- Do not manually force an A/B OTA target slot.
- Keep a complete stock restore path before testing any future release.

## Reporting bugs

This source mirror does not use GitHub Issues. Before reporting a problem to the
maintainer, reproduce it on the documented source and firmware baseline with
unsupported kernels, root modules, and add-ons removed. Reports must include the
exact build hash, clean reproduction steps, and sanitized logs. Remove account,
network, location, radio/subscriber, and device identifiers before sharing logs.

## Licensing and provenance

Original contributions are licensed as described in [`LICENSE`](LICENSE).
Third-party and stock-derived material retains its original license and is
documented in [`NOTICE`](NOTICE). No license grant in this repository overrides
third-party terms or corresponding-source obligations.

## Credits

LineageOS, AOSP, Qualcomm CAF, Nothing, and reference-device maintainers.

Upstream contributions must follow the LineageOS charter and Gerrit process:
https://github.com/LineageOS/charter and
https://wiki.lineageos.org/how-to/submitting-patches/.

Unofficial. No warranty. You are responsible for your device.
