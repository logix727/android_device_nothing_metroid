# Next release

Canonical issue backlog: [`BUGS.md`](BUGS.md).
Canonical accepted baseline: [`BASELINE.md`](BASELINE.md).
Canonical hardware matrix: [`HARDWARE_ACCEPTANCE.md`](HARDWARE_ACCEPTANCE.md).

## Accepted baseline and live state

r21 (`23.0-20260808-UNOFFICIAL-metroid`) remains the accepted baseline: encrypted
userdata, SELinux Enforcing, root vbmeta flag `1`, empty crash buffer, no new
tombstones, and two successful boots.

The live device is coherent r28 (`23.0-20260813-UNOFFICIAL-metroid`) on slot B,
encrypted and Enforcing. Two boots passed crash, tombstone, pstore, init-cleanup,
GApps, and core invariant gates. Installed NCM DHCP/DNS/IPv4/HTTPS testing passes
MTR-019's primary operation; reconnect/HAL and adjacent-mode regressions remain.
r28 is not promoted because MTR-023/MTR-025 still need real UI/audio
acceptance and public physical-SIM operation is now a confirmed blocker. Google
separately blocks the storefront as Play Protect uncertified (MTR-027).

r25 was installed from the `OFFLINE-VERIFIED` immutable snapshot:
`releases/candidate_20260812_164223_410891256_r25/`; OTA SHA-256
`7d20dd544a8ea58d6bde3bac8f6ef3641ffd4a94f71c0fda16094ccc7f5ae23b`.
All 16 payload images match target-files and release signing/AVB/partition/VINTF
gates pass. It is installed but rejected, not accepted.

Post-install disposition: r25 booted coherently twice on slot A, merged, remained
Enforcing/encrypted, preserved GApps, and added no native tombstone. It is rejected
for full promotion because MTR-021 still has six runtime class-start dangles and
MTR-019 lacks the NCM tethering interface regex. r26 is the one reserved corrected
candidate; no unrelated fixes join it.

r26 installed coherently twice on slot B and closes the six runtime init dangles.
Its NCM RRO is active, but installed testing exposed a framework race: USB
configured precedes `usb0`, and Android B ignores the later interface event.
The final successor adds only the tested Connectivity retry carry.

r27 installed coherently twice on slot A with no init regression, but NCM still
fails before `IpServer`: `usb0` matches both generic USB and NCM regexes and the
generic type wins. The final source-only correction prefers NCM classification
while NCM is active. The release train has reached its third-write stop rule; do
not install another candidate until a new train is reviewed.

r28 began a new reviewed train and was installed from the `OFFLINE-VERIFIED`
immutable snapshot `releases/candidate_20260812_224028_708148776_candidate/`;
OTA SHA-256
`6d1427449128bbd65e64841b2934ea91dae7f68ede51c2557830d827feddb9e9`.
It passes MTR-019's primary installed operation and closes the bounded MTR-021
cleanup on the installed target. It is installed but not accepted.

r29 is `OFFLINE-VERIFIED` in
`releases/candidate_20260813_115214_637118668_candidate/`; OTA SHA-256
`18759452f85d92f45a38a4e276eecb58a119b1d425f9e7a966d91ae5dd0202f8`.
It carries only the stock-aligned MTR-001/MTR-002 QTI telephony package and Cox
APN corrections plus the recurring MTR-028 install gate. All 16 payload images
match target-files, VINTF has no duplicate conflict, and the init audit has no
blocking finding. It is not installed or functionally accepted.
T5 currently waits only for physical SIM insertion: both slots are empty. The
exact frozen MindTheGapps archive has been restored from its official release and
independently matches the recorded size and SHA-256. Do not spend the device-write
budget on a no-SIM installation. The patched host ADB is built for MTR-028.

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

- MTR-001/MTR-002: XDA testers reproduce network visibility with no AT&T or
  Cox/Verizon data or IMS. Sanitized captures now cover both a conventional
  physical SIM and a removable eUICC active profile: LTE registration and SMS
  pass, but both data paths receive modem `0x1004`. The successor restores stock
  `QtiTelephony`, `QtiTelephonyService`, `qcrilmsgtunnel`, `QtiTelephonyCompat`,
  stock-equivalent SELinux domains, and seven missing Cox 311/600 APNs. Focused
  package, policy, APN-schema, image, and VINTF checks pass. Install and exercise
  present-UICC, subscription, data, SMS, calls, and IMS on the documented modem
  generation.
- MTR-003: the external removable-eUICC capture proves active-profile LTE/SMS but
  fails profile refresh and embedded metadata. Use a private activation code to
  test native download, enable/disable, reboot, deletion, transfer, and physical-
  SIM coexistence. Never retain EID/credentials.
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

- MTR-019's primary NCM operation passes and the bounded MTR-021 init cleanup is
  closed on installed r28. MTR-015 QCC remains a separate atomic
  feature decision; MTR-016 sensor extension and MTR-024 ST21 remain active.
  MTR-020 returns to
  evidence collection because current and latest NothingOSS tuna both use the
  existing register; do not transfer the `kera` address.
- Group RC/VINTF changes by subsystem, but retain one first-failure cause and one
  acceptance matrix per issue.

## Next execution order

1. Provide an active physical SIM or eUICC test path, then use both sanitized
   historical results to skip the now-proven card, subscription, registration and
   APN-selection paths: install r29 on the documented modem generation, verify its
   QTI/IMS processes, and test the first data call. If the historical modem-side
   `0x1004` rejection persists, compare stock QMI/MCFG behavior before any further
   source or firmware change.
2. Complete r28 MTR-023 face-locale and MTR-025 AudioFX acceptance.
3. Preserve MTR-026 as a cleared recurring crash gate and MTR-027 as an external
   uncertified-policy gate. Test Google's official per-device registration only
   as storefront access, never as ROM certification.
4. Validate the patched host ADB's 0-to-100 unique-transfer display on the next
   already-planned recovery sideload; record recovery's result independently.
5. Complete installed-system Aperture acceptance from the canonical hardware matrix.
6. Complete WP1 thermal/charging because the 49 C unplugged event is the highest
   safety-relevant unresolved evidence.
7. Execute remaining WP2-WP5 work in dependency order, using stock/kernel/upstream
   evidence first.

## Release gate

Frozen r25 record: `release/20260812-r25-candidate.json`. Its modem companion is
the official B4.0 `251117` transport image; a 656-file recursive SHA-256
comparison proves its filesystem content is identical to the accepted A16 modem
tree already installed on both slots. r25 does not change or embed modem firmware.

1. `repo status` plus explicit device/kernel/vendor checks are clean.
2. Every local carry is committed, reproducible, and represented in the source lock.
3. Fresh install-clean `m bacon` succeeds.
4. VINTF, init, payload, AVB, signing, partition, modem, and artifact audits pass.
5. ROM/GApps/modem hashes and source revisions are recorded separately.
6. MTR-028 records recovery's final status independently of host percentage and
   correlates the automatically selected target slot, update and snapshot state.
7. Target boot, second boot, slot success, snapshot state, Enforcing, encryption,
   crash/tombstone sweep, and affected real hardware acceptance pass.
8. GitHub records distinguish verified, unverified, externally blocked, and broken.
