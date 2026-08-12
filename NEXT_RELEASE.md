# Next release

Canonical issue backlog: [`BUGS.md`](BUGS.md).
Canonical accepted baseline: [`BASELINE.md`](BASELINE.md).
Canonical hardware matrix: [`HARDWARE_ACCEPTANCE.md`](HARDWARE_ACCEPTANCE.md).

## Accepted baseline and live state

r21 (`23.0-20260808-UNOFFICIAL-metroid`) remains the accepted baseline: encrypted
userdata, SELinux Enforcing, root vbmeta flag `1`, empty crash buffer, no new
tombstones, and two successful boots.

The live device is coherent r22 on slot B, encrypted and Enforcing. Three
retained coherent-r22 boots cleared the MTR-026 crash-hygiene gate: zero GMS
Password Checkup fatalities, no new tombstone, preserved account, and healthy
GMS/Play Store processes. Google separately blocks the storefront as Play
Protect uncertified (MTR-027). r23 was built but not installed; r24 is a
non-promotable test seed.

The tested configuration has three independently verified inputs:

1. ROM OTA: `releases/candidate_20260808_192539_leaudio-r21/`, SHA-256
   `e26956f003ceea3923d847515e2943dc8bbf4505533cbae726d36bc167f968db`.
2. MindTheGapps Android 16 ARM64 add-on, SHA-256
   `a6ff8b8c31f7ccd0a9f2fd651fa4438a8e39a5f63b95be246ea1f98982af2c28`,
   sideloaded from the new-slot recovery after the ROM OTA.
3. Stock A16 modem filesystem on both modem slots, build
   `MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.126608.2.134544.2`, reconstructed from
   `references/upstream/dump_a16/modem/` and verified byte-for-byte after image
   construction. The modem image is not part of the ROM OTA.

## Required workflow

Every bug starts with one evidence matrix before edits:

| Evidence | Required question |
|---|---|
| Installed/live evidence | What exact user operation fails, and what is the first failing log/state? Distinguish accepted r21 from coherent live r22. |
| Nothing stock dump | Which APK/blob/config/property/RC/VINTF behavior differs? |
| Kernel source/DTS | Is the hardware node, IRQ, GPIO, thermal zone, power path, or driver behavior correct? |
| AOSP/Lineage/CLO | Is this upstream behavior, a known fix, or a device-specific gap? |
| Reference devices | How do same-generation Qualcomm/Nothing devices implement it? |

Only after the first deterministic divergence is identified: make the smallest
owning-subsystem change, run focused tests, build one install-clean OTA, audit,
install, and execute the affected hardware matrix. Do not iterate by flashing
guesses.

## Work packages

### WP0: Release and source integrity

- Keep device, kernel, and private vendor registered in `.repo/local_manifests`.
- Regenerate source/carry locks from clean trees; include every local carry.
- Preserve ROM, modem, and GApps as separate tested inputs in release records.
- After every recovery ROM update, reboot to the new-slot recovery and sideload
  MindTheGapps before Android boots; A/B recovery sideload does not run addon.d.
- Prefer normal-system Lineage Updater/update_engine for upgrades. Stock-label
  `vbmeta_vendor_[ab]` so update_engine can write the full payload and invoke
  Lineage `backuptool_ab`, preserving GApps without recovery. Recovery remains
  the initial-install and rollback path.

### WP1: Thermal and charging policy

- MTR-005: reproduce controlled unplugged load while logging live skin, battery,
  framework severity, cooling devices, display mitigation, and process CPU/GPU.
- MTR-009 fix installed: exact A16 binary/RC, mandatory compatibility entry,
  standalone VINTF, typed SELinux policy, two boots, and no charge AVCs. Complete
  the remaining unplug/reconnect, hot-battery, wireless, and reverse-charge matrix.
- Acceptance: no sustained 48-49 C event without framework/UI severity; USB PD/PPS,
  wireless, screen on/off, hot-battery stop/resume, suspend, reverse charging.

### WP2: Physical SIM, IMS, eSIM, and OMAPI

- MTR-001/MTR-002: insert a physical SIM and test calls, SMS/MMS, data, APNs,
  VoLTE/VoWiFi, emergency UI, DSDS, handover, airplane mode, and suspend.
- MTR-003: use a private activation code to test download, enable/disable, reboot,
  deletion, transfer, and physical-SIM coexistence. Never retain EID/credentials.
- Preserve the exact A16 modem firmware on both slots; do not mix QCRIL userspace
  with another modem/MCFG generation.

### WP3: Bluetooth and audio

- MTR-010 fix installed: eight false profile gates were removed and stock
  hearing-aid/allow-list values restored. Accepted r21 starts all profile
  services across two boots; test real LC3/Auracast hardware.
- MTR-025: align MusicFX service discovery with installed AudioFX.
- Validate USB-C audio, HFP/SCO, A2DP fallback, volume coordination, and suspend.

### WP4: Camera, biometrics, and haptics

- MTR-022 temporary-APK acceptance passed for FHD30/FHD60/UHD30 routing,
  finalized files, process restart, provider stability, and tombstone monitoring.
  Audited r22 is now running coherently on slot B. Its crash gate is clear, and
  retained coherent-r22 camera evidence covers all five camera IDs, SAT
  0.6x/1x/3x/10x zoom, torch, zoom while recording, and system-APK
  FHD30/FHD60/UHD30 evidence. Complete the remaining cadence, long-run,
  front-screen-flash, stabilization, and UI acceptance rows. MTR-012 still requires
  measured stabilization, crop, cadence, zoom-transition, and motion acceptance.
- MTR-018: compare UDFPS refresh/LHBM ordering with stock and upstream, then run
  50 screen-on/AOD unlocks and enrollment at Smooth Display off.
- MTR-011: recover actual stock effect/primitive mappings before advertising or
  changing any haptic capability.
- MTR-023: locale-safe face-enrollment guidance.

### WP5: Connectivity, suspend, and cleanup

- MTR-015 QCC, MTR-016 sensor extension, MTR-019 USB NCM, MTR-020 CPUSS residency,
  MTR-021 remaining dangling init inventory, and MTR-024 ST21 transition errors.
- Group RC/VINTF changes by subsystem, but retain one first-failure cause and one
  acceptance matrix per issue.

## Next execution order

1. Preserve MTR-026 as a cleared recurring crash gate and MTR-027 as an external
   uncertified-policy gate; re-run both on the next promotable installed candidate.
2. Complete installed-system Aperture acceptance from the canonical hardware matrix.
3. Complete WP1 thermal/charging because the 49 C unplugged event is the highest
   safety-relevant unresolved evidence.
4. Execute WP2 when a physical SIM and private eSIM activation code are available.
5. Execute WP3-WP5 in dependency order, using stock/kernel/upstream evidence first.

## Release gate

1. `repo status` plus explicit device/kernel/vendor checks are clean.
2. Every local carry is committed, reproducible, and represented in the source lock.
3. Fresh install-clean `m bacon` succeeds.
4. VINTF, init, payload, AVB, signing, partition, modem, and artifact audits pass.
5. ROM/GApps/modem hashes and source revisions are recorded separately.
6. Target boot, second boot, slot success, snapshot state, Enforcing, encryption,
   crash/tombstone sweep, and affected real hardware acceptance pass.
7. GitHub records distinguish verified, unverified, externally blocked, and broken.
