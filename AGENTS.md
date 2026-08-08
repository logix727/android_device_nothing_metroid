# Nothing Phone (3) LineageOS maintainer contract

Maintain `metroid` as a long-lived LineageOS device, not a one-off bring-up.
Start every task from `BASELINE.md` and `NEXT_RELEASE.md`.

## Installed baseline

- Build: `23.0-20260808-UNOFFICIAL-metroid`
- OTA SHA-256:
  `8a7ed31caa2415c9de8f84eb5c0411ffe497a94a313103d86bfef9cf11b5911f`
- Artifact: `releases/candidate_20260808_175755_charge-updater-r20/`; not a public
  release. `org.codeaurora.ims` runs as `vendor_qtelephony` with MMTEL bound on
  both slots and no IMS/radio AVCs across two boots.
- Last recorded state: slot B, boot complete across two boots, SELinux Enforcing,
  encrypted data, slot marked successful. Both modem slots use the matching A16
  stock modem build and MindTheGapps was separately sideloaded from new-slot
  recovery. See `BASELINE.md` before changing either companion input.
- Never describe a newer source change as working until it is built, audited,
  installed, and tested.

## Hard invariants

- Never publish proprietary vendor blobs or private release/AVB keys.
- Never declare an unserved stable HAL. Run `m check-vintf-all` after VINTF work.
- Keep `ro.hw_timeout_multiplier=4` in `/system/build.prop`.
- Preserve the 231-line installed `init.target.rc` with `OPUS_NTLOG_KEEP` and no
  `OPUS-USB-BRINGUP` block unless measured evidence justifies replacement.
- Preserve early ADB and dynamic USB gadget operation; test ADB, MTP, tethering,
  cable reconnect, late HAL start, and HAL restart after USB changes.
- Physical UDFPS geometry is `(630,2539,r=107)`. Decorative enrollment/UI
  resources may move; touch/LHBM geometry must not be guessed.
- Root vbmeta may set only AVB's hashtree-disabled bit (`1`) when required for
  official recovery add-ons. Never set verification-disabled (`2`); signed
  vbmeta chains and rollback verification must remain active.
- Vendor remains ext4; vendor_boot page size remains `0x1000`.
- Do not manually force an OTA target slot. Use coherent recovery sideloads.
- Product/package changes require install-clean staging because removed RC/VINTF
  files can survive incremental builds.
- Keep the screen off outside short display/camera/biometric test windows.

## Bug workflow

1. Reproduce the exact user-visible operation.
2. Save a pre-test baseline: build, slot, service PID, crash/tombstone timestamps,
   relevant settings/properties, and hardware state.
3. Capture logcat, dmesg, AVCs, tombstones, dumpsys, and source/image hashes.
4. Compare current source with AOSP/Lineage upstream and Nothing stock evidence.
5. Identify the first deterministic failure, not downstream symptoms.
6. Implement the smallest maintainable fix in the owning subsystem.
7. Run focused compile/static tests.
8. Prefer reversible APK/runtime tests before OTA cycles when possible.
9. Build one install-clean OTA, audit it, request approval, install, and test two
   boots plus the full affected regression matrix.
10. Update tests, `NEXT_RELEASE.md`, and eventually `BASELINE.md`.

## Subsystem expectations

### Camera

- Test real preview, still capture, finalized video, front screen flash, all
  physical lenses, logical SAT zoom, zoom while recording, FHD60, UHD30, and
  third-party Camera2 clients.
- Watch provider PID and new tombstones. Morpho/EIS crashes must not be hidden by
  merely proving that cameras enumerate.

### Biometrics

- Test enrollment and authentication, not only HAL registration.
- Fingerprint testing includes both enrollment stages, lockscreen UI, touch/LHBM,
  charging indication clearance, ripple behavior, and repeated unlocks.
- Face testing includes property/data initialization, camera session creation,
  enrollment progress, authentication, and failure recovery.

### Haptics

- Verify the running binary hash, RC, VINTF, loaded RichTap/AW/ICS libraries,
  SFDC/calibration, standard effects, composed effects, amplitude, and perceived
  output against Nothing OS. A registered stock service is not sufficient.

### Radio/connectivity

- Physical-SIM testing must cover calls, SMS, data, IMS, emergency UI, dual SIM,
  handover, airplane mode, and suspend/resume. Do not infer success from qcrild.

### Updates and boot

- Test recovery sideload, target-slot activation, encrypted userdata retention,
  first boot, second boot, snapshot merge, SELinux, system_server start count,
  crash buffers, AVB, and update-engine status.

## Source and upstream

- Persistent work uses `lineage-23.0` branches with focused commits.
- Prefer upstreamable fixes. Add device conditionals only for real hardware/vendor
  behavior; avoid global platform hacks.
- Before duplicating a fix, search current Lineage/AOSP/CLO and relevant device
  trees. Document why upstream behavior is insufficient.
- Keep `repo status` clean. Do not release detached commits or undocumented
  untracked inputs.
- The ordered temporary carry set is `patches/series.conf`.
- Private vendor source is reproduced from stock extraction and private commits;
  never add blobs to the public device repository.

## Release gate

Before sideloading or publishing:

1. `repo status` is clean and every modified project has a named commit.
2. Focused builds/tests pass.
3. Install-clean `m bacon` succeeds.
4. Init-service, VINTF, vendor-image, payload-equivalence, AVB, signing, partition,
   and artifact checks are inspected, not merely executed.
5. Exact ZIP SHA-256 and source revisions are recorded.
6. User approves sideload/flash.
7. Target boot, second boot, Enforcing, encryption, crash sweep, and affected
   hardware acceptance pass.
8. Release notes distinguish verified, unverified, and broken behavior.

## Current priorities

1. Radio VINTF, IMS, and eSIM integration.
2. Power HAL and framework thermal policy.
3. Release reproducibility, metadata, and public artifact consistency.
4. Camera stabilization/routing and haptic parity.
5. Physical-SIM and accessory acceptance.

Do not start from archived plans or handoffs; they describe superseded states.
