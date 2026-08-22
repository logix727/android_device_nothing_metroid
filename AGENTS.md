# Nothing Phone (3) LineageOS maintainer contract

Maintain `metroid` as a long-lived LineageOS device, not a one-off bring-up.
Start every task from `BASELINE.md` and `NEXT_RELEASE.md`.

## Installed baseline

- Build: `23.0-20260821-UNOFFICIAL-metroid` (r48, incremental `1787327311`)
- OTA SHA-256:
  `5e79b012fb8063b09f4a3fde48b5241470c6b2fb55b0acf0d39bc334fd66d581`
- Artifact: `releases/candidate_20260821_121653_317252161_candidate/`; accepted
  private XDA test seed, not an official release.
- Accepted r48 state: slot A, two boots, SELinux Enforcing, encrypted data,
  boot-loaded TIPC, active Dark Star eSIM, automatic carrier data/NR_NSA, QCC
  closure and empty pstore. Both modem slots use the required B4.1 260814 build
  `...1.152387.2.170946.5`; MindTheGapps is a separate companion input.
- Never describe a newer source change as working until it is built, audited,
  installed, and tested.

## Hard invariants

- Never publish proprietary vendor blobs or private release/AVB keys.
- Public distribution is limited to device, kernel, required source forks, and
  sanitized provenance. ROM binaries are approved `UNOFFICIAL` XDA test seeds
  only; the private vendor repository remains private forever.
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
9. Build one install-clean OTA, audit it, install under standing authorization, and test two
   boots plus the full affected regression matrix.
10. Update tests, `NEXT_RELEASE.md`, and eventually `BASELINE.md`.

Use precise status claims: evidence may establish `CONFIRMED`; a successful
coherent build may establish `BUILT-NOT-INSTALLED`; only the exact audited
candidate installed on the target and passing the real operation plus affected
regressions may be called working, fixed, or tested.

## Fast closure strategy

- Keep an acceptance queue and a source queue. Acceptance-only rows run on the
  coherent live build and consume no build. Source work starts only after a
  confirmed first divergence and is batched by dependency and subsystem.
- Launch independent read-only evidence matrices concurrently. The maintainer
  reviews their first divergences, rejects hypotheses, then serializes the
  smallest source edits per Git project.
- Run the cheapest affected T1 check after each commit. Run T3 once at the merged
  batch head. Build one install-clean frozen candidate, not one OTA per bug.
- Keep one safety reserve. A failed candidate is captured and rejected before any
  successor edit; never patch installed images or create mixed generations.

## Boot-safety review

Treat boot image composition, kernel/DT, vendor_boot, init_boot, critical init,
VINTF, SELinux domains used before boot completion, AVB, partitions, firmware,
FBE, update_engine, and package removals as boot-critical.

Before a boot-critical change joins a candidate:

1. State the exact first divergence and why a non-boot-critical fix is insufficient.
2. Diff stock, accepted r48, and proposed staged images.
3. Prove boot image membership, init imports/services, ELF dependencies, VINTF,
   SELinux, AVB descriptors/flags/rollback indexes, page size, and partition type.
4. Define recovery and rollback using already verified artifacts; do not rely on
   the candidate being able to boot.
5. Keep unrelated R1/R2 work out unless the change is one atomic dependency.
6. Stop on any unexplained missing executable/import, new boot AVC, crash/pstore,
   slot/merge anomaly, encryption change, or invariant mismatch.

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
- Before source replacement, extraction, ref movement, sync, or handoff, record
  project status and create a verified checkpoint containing intended tracked and
  untracked work. Never use checkout/restore/reset/clean to manufacture a clean
  tree.
- Keep public forks current with focused reviewed commits and source tags. The
  standing owner authorization covers pushes, releases, and repository-policy
  changes; published history is not rewritten. XDA posting remains owner-only.

## Device and root testing

- Confirm serial, installed build hash, slot, boot state, encryption, SELinux,
  battery/thermal state, and available restore path before testing.
- Standing owner authorization covers rooted diagnostics and mutation, remounts,
  file pushes, property/settings changes, package/service/profile operations,
  partition access, reboot, slot change, sideload, flash, firmware, and intentional
  wipe/format. Do not ask again. Capture pre/post state and keep raw logs private.
- Stop on unexpected target identity, heat/hardware danger, unplanned data loss,
  crash/slot/AVB/encryption/boot behavior, or loss of the verified recovery path.
  Intentional flashing and wiping are not stop conditions.
- Workers may analyze existing evidence only. The maintainer performs approved
  device commands and validates the resulting evidence personally.

## Release gate

Before sideloading, distributing a candidate, or making a functional claim:

1. `repo status` is clean and every modified project has a named commit.
2. Focused builds/tests pass.
3. Install-clean `m bacon` succeeds.
4. Init-service, VINTF, vendor-image, payload-equivalence, AVB, signing, partition,
   and artifact checks are inspected, not merely executed.
5. Exact ZIP SHA-256 and source revisions are recorded.
6. Verify the exact sideload/flash and target device under standing authorization.
7. Target boot, second boot, Enforcing, encryption, crash sweep, and affected
   hardware acceptance pass.
8. Release notes distinguish verified, unverified, and broken behavior.
9. Non-XDA publication uses standing authorization, is labeled `UNOFFICIAL`
   testing, and excludes proprietary source, private inputs, credentials, and raw
   logs. Only the owner publishes to XDA.

## Current priorities

1. Preserve accepted r48 source/artifact identity and complete acceptance-only
   UDFPS, camera, USB, face, AudioFX and thermal rows before another device write.
2. Reject physical-SIM/carrier evidence unless ROM and both modem slots pass the
   checked-in r48 preflight. Do not edit APNs or radio source from mismatched
   firmware logs.
3. Keep MTR-027 externally blocked: distinguish package launch from Google's
   certification decision and do not spoof identity, attestation or AVB.
4. Keep MTR-011/MTR-016 evidence-bound; MTR-020 and MTR-024 currently have no
   eligible source edit.
5. Execute physical-SIM, eSIM, OMAPI, LE Audio, and accessory matrices when the
   required hardware or credentials are available.
6. Replace temporary carry patches with reviewed public forks/upstream changes,
   eliminate build-broken escapes and undocumented kernel staging, and keep all
   official-readiness blockers explicit.
7. Maintain public source provenance and private vendor separation; XDA builds
   remain explicitly unofficial until all required rows are accepted.

Do not start from archived plans or handoffs; they describe superseded states.
