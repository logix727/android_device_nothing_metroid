# LineageOS 23 device tree for Nothing Phone (3) (`metroid`)

Unofficial LineageOS 23 (Android 16) bring-up for the Nothing Phone (3), codename
`metroid`, based on Qualcomm SM8735.

## Status

**Alpha development. Maintainer-tested; not an official release.**

There is currently no supported public OTA or recovery bootstrap download. Do
not follow old mirrors, mix artifacts, or treat this repository as an official
LineageOS release. The latest accepted build is a maintainer-local candidate;
the connected target runs coherent r28 but is not accepted. r29 is
offline-verified and not installed; no carrier fix is claimed until its full
target-device matrix passes.

The current maintainer baseline has radio/IMS infrastructure, Power HAL,
framework thermal skin/headroom, corrected launch/security metadata, and native
eSIM provisioning UI with matching stock modem firmware. Historical physical-SIM
and removable-eUICC captures reach LTE registration and SMS but fail data at an
opaque modem response; r29 carries the next stock-aligned telephony correction.
Carrier/IMS, eSIM management, thermal/charging, camera, Bluetooth/audio, haptics,
and accessory coverage remain. See [`BUGS.md`](BUGS.md).

## Repo coverage

Copy `manifest/metroid.xml` to `.repo/local_manifests/metroid.xml` so Repo status,
manifest locks, and release audits include the device, kernel, and private vendor
repositories. Access to the private vendor repository is required for builds;
never publish its contents.

## Maintainer OTA updates

For an installed build with MindTheGapps, use
`scripts/apply-ota-adb.sh <audited-ota.zip>` from this directory. It invokes
normal-system update_engine so Lineage `backuptool_ab` preserves addon.d/GApps;
do not use recovery sideload for routine upgrades. Initial installation and
rollback remain recovery operations.

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

The current public branch contains the device revision used to freeze r29 and all
33 ordered public carry patches. Every declared pre-patch revision is reachable
from its public upstream, and the expected result trees match the maintained
checkout. A sanitized immutable r29 Repo manifest and source tag are still
required before claiming clean external reconstruction.

The following sequence reconstructs the older immutable r4 source lock. It is
retained as a provenance example, not the current candidate.

1. Initialize the historical immutable source candidate:

   ```bash
   repo init \
     -u https://github.com/logix727/android_device_nothing_metroid.git \
     -b refs/tags/lineage-23.0-20260806-source-r4 \
     -m manifest/lineage-23.0-20260806-base.xml
   repo sync -c
   device/nothing/metroid/patches/apply-series.sh "$PWD"
   ```

   The manifest pins that historical platform state. The application script
   verifies every resulting project tree. `manifest/metroid.xml` remains the
   moving development manifest and is not a release lock.
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

The accepted maintainer baseline is recorded in [`BASELINE.md`](BASELINE.md).
The exhaustive per-operation hardware status is recorded in
[`HARDWARE_ACCEPTANCE.md`](HARDWARE_ACCEPTANCE.md); service registration alone
does not satisfy that matrix.
The historical public reconstruction record is
[`release/20260806-source-lock.json`](release/20260806-source-lock.json). The
current frozen-candidate scope is
[`release/20260813-r29-candidate.json`](release/20260813-r29-candidate.json); it is
not a claim that r29 has passed target-device validation.

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
