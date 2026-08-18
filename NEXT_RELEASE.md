# Next release

Canonical issue backlog: [`BUGS.md`](BUGS.md).
Canonical accepted baseline: [`BASELINE.md`](BASELINE.md).
Canonical hardware matrix: [`HARDWARE_ACCEPTANCE.md`](HARDWARE_ACCEPTANCE.md).

## Accepted baseline and live state

r21 (`23.0-20260808-UNOFFICIAL-metroid`) remains the accepted baseline: encrypted
userdata, SELinux Enforcing, root vbmeta flag `1`, empty crash buffer, no new
tombstones, and two successful boots.

The live device is r35 (`23.0-20260815-UNOFFICIAL-metroid`) on successful slot B,
installed from the immutable snapshot
`releases/candidate_20260815_192053_709386797_candidate/`; OTA SHA-256
`d846533b49062d437d112fa3946be413471ab20b2ece9a3f601236e23cc6c7b6`.
It is encrypted and Enforcing, has snapshot state `none`, preserves GApps, and
passes two coherent boots with one system_server start and no new crash,
tombstone, or pstore record. QTI/IMS startup passes; the APN checksum migration
materialized all four carrier-ID 10028 rows and persisted across reboot. No
physical SIM is present, and camera/USB/UDFPS matrices are incomplete, so r21
remains the accepted baseline.

r35 also passes bounded installed checks for fresh UDFPS enrollment and four
unlocks with no HAL death, NCM local IPv4 transport with `usb0` excluded from
Ethernet, haptic one-shot/prebaked/primitive delivery to the driver, and one NFC
disable/enable cycle with a stable service PID. `vendor.gralloc.enable_logs=0`
is installed and camera preview exercised the provider without Mapper5,
GWP-ASan, or tombstone failure, but capture-intent automation did not produce a
trustworthy finalized still or video. These results do not close the remaining
functional matrices.

A 14-minute-26-second USB-powered screen-off no-SIM observation retained the
same boot ID, boot count, and system_server PID with an empty crash buffer, no
new tombstone or pstore record, and no interval fatal/SSR/modem-crash/panic/AVC
signature. This is a bounded idle-stability result, not unplugged deep suspend
or drain acceptance. The installed result is summarized in
`release/20260817-r35-installed.md`.

r36 is installed coherently on slot A in
`release/20260817-r36-candidate.json`. It contains the stock-backed framework IMS
capability gates, complete 3 Sweden carrier-ID 1691 APN family, and CND/DPM AIDL
manifest plus framework-matrix contracts. It does not claim to resolve the
separate pre-network `0x1004` data failure. Do not install it on the no-SIM
maintainer device merely to prove service registration; physical carrier
acceptance and the vendor-RIL/QMI comparison remain required. Two boots pass with
encrypted userdata, Enforcing SELinux, successful/bootable slot metadata, empty
snapshot state, no new crash/tombstone/pstore record, persistent GApps bases,
both restored CND/DPM services registered, all three IMS capability resources
true, and all four carrier-ID 1691 APNs materialized. See
`release/20260817-r36-installed.md`.

Installed acceptance reopened the source queue as MTR-030. Airplane mode
deterministically crashes `com.qti.phone` because the stock QTI APK resolves
`com.nothing.telephony.INothingTelephony$Stub` from stock's omitted
`nt-telephony-interface.jar` boot jar. The matched QTI APK/common jar are
byte-identical to stock and the matched interface jar supplies the exact ABI.
Carry only that jar and boot-classpath entry in the next R3 candidate; keep it
isolated from unrelated boot-chain work and require ten installed radio cycles.
Immutable snapshot: `releases/candidate_20260817_193603_796382843_candidate/`;
OTA SHA-256 `ca8390590270e325650057eac21d480d82c5453e2f96e57415ee0c7503cfb647`.
The install-clean build, source/companion provenance, all 16 payload-image
equivalence, signing/AVB, partition, VINTF, init, and duplicate audits pass.

r31 is `OFFLINE-VERIFIED` and not installed. Its immutable snapshot is
`releases/candidate_20260814_233610_118108082_candidate/`; OTA SHA-256
`b702dc7b119e8e91180c49fc59c3f8b0bbc4c0c75ecbfe373ac8dd06cf70def3`.
It carries only the stock-backed AT&T 5G SA APN and VoLTE carrier-policy fixes
over the existing source state, plus the recurring MTR-028 install gate. The
install-clean build, payload equivalence, signing/AVB, partition, VINTF, init,
source-state, and companion-input audits pass. It remains
`BUILT-NOT-INSTALLED`; no data, call, SMS, or IMS fix is closed until this exact
artifact is installed with the frozen modem generation and passes the physical-
SIM matrix.

The next candidate supersedes r31 for US multi-carrier testing. Static stock
parity found no missing core T-Mobile or Verizon carrier-ID profiles, but found
56 missing or newer stock profiles for FirstNet, Cricket, Dish/Boost AT&T SIMs,
Liberty, MVNx, Tracfone AT&T, Red Pocket, Consumer Cellular, Pure Talk,
Airvoice, Ztar, and Kore. These are now restored without deleting narrower
legacy GID matches. AT&T SA/NSA IMS masks and NSA XCAP are corrected. The
CarrierConfig RRO also restores stock VoLTE admission for US MCCs 310-316 while
leaving WFC and VT carrier-specific. Focused schema, module, product-image, and
generated-output checks pass; no carrier is claimed working until physical SIM
acceptance.

r32 is now `OFFLINE-VERIFIED` and supersedes r31. Immutable snapshot:
`releases/candidate_20260815_005128_749949780_candidate/`; OTA SHA-256
`919fe65976707c55b509a4cc823eecc64abb26f02f506a44a24ee9a758579629`.
The install-clean build and source-state, companion-input, payload-equivalence,
signing/AVB, partition, VINTF, and init audits pass. It is not installed and no
US carrier has gained a hardware acceptance claim from these static results.

Post-r32 online verification compared the source against official Lineage
`android_vendor_apn` main at `05ceef76016fb07f5f22591247b07eb78fd4a092`.
The six current US deltas are now integrated: Google Fi data/MMS typing on both
T-Mobile identities, FreedomPop, Docomo Pacific, AirFire, Mosaic, and removal of
obsolete AT&T `lwaactivate`. AOSP/Lineage CarrierConfig and carrier-ID data have
no newer safe US delta for this branch. Stock and Lineage both intentionally
lack a `10028` asset, causing canonical AT&T `1187` selection before the metroid
vendor overlay. Therefore r32 remains preserved but is superseded for install by
the forthcoming r33 source state.

r33 is `OFFLINE-VERIFIED` and supersedes r32 for installation. Immutable
snapshot: `releases/candidate_20260815_091437_165511465_candidate/`; OTA SHA-256
`fb2c2c294a7dc2d76499fdce8018211d5bfbd3f7792fc0094561d0547187833b`.
All offline release gates pass. Remaining cellular gates are intrinsically live:
active modem MCFG selection, carrier account/IMS provisioning, IMEI/TAC acceptance,
registration, calls, SMS, data, emergency-domain behavior, and carrier handover.
Remaining eSIM gates are EID, SM-DP+ download, enable, reboot persistence,
disable/delete, and physical-SIM coexistence.

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

r29 is rejected after installation. It was `OFFLINE-VERIFIED` in
`releases/candidate_20260813_115214_637118668_candidate/`; OTA SHA-256
`18759452f85d92f45a38a4e276eecb58a119b1d425f9e7a966d91ae5dd0202f8`.
It carried only the stock-aligned MTR-001/MTR-002 QTI telephony package and Cox
APN corrections plus the recurring MTR-028 install gate. All 16 payload images
match target-files, VINTF has no duplicate conflict, and the init audit has no
blocking finding, but installed diagnostics exposed two boot blockers: invalid
name-only Android 16 seapp rules and a missing QtiTelephonyService privileged
permission allowlist. r30 fixes both and is installed as described above.
Physical-SIM T5 still waits on external testers: both local slots are empty. The
exact frozen MindTheGapps archive has been restored from its official release and
independently matches the recorded size and SHA-256. Do not spend the device-write
budget on another no-SIM recovery install. The patched host ADB reached 100
percent during the r29 recovery transfer; r30 installed through update_engine.

An external 2026-08-14 physical-SIM capture now proves USIM/ISIM readiness, LTE
home registration, and outbound non-IMS SMS delivery to the recipient. Replies are
not received. Both selected AT&T default APNs receive the same immediate modem
`0x1004` rejection. A circuit-switched call reaches `DIALING` but is rejected with
modem cause 252. Framework IMS remains unregistered despite contradictory
QImsService telemetry. The capture identifies
baseband `...1.150609.3.152387.2`, not r30's required
`...1.126608.2.134544.2`, and contains no independent ROM build property, so it is
useful localization evidence but not r30 acceptance. Repeat only on the documented
ROM and modem pair before changing source or firmware.

The capture also exposes an actionable APN-source defect: CarrierResolver selects
specific carrier ID `10028` (`AT&T 5G SA`), but Lineage lacked its profiles and
fell back to generic `nxtgenphone` and legacy `wap.cingular`. `vendor/apn` commit
`ed04060` restores Nothing stock's exact `nrphone`, `ims`, `nrhotspot`, and XCAP
set. XSD and Soong `apns-conf.xml` builds pass. Calls and inbound SMS remain
separate acceptance results.

The same capture exposes a second stock-backed divergence after carrier config
loads: framework reports VoLTE `available=false` and disables voice MMTEL despite
provisioning and user enablement being true. `CarrierConfigOverlayMetroid`
restores the stock-effective AT&T carrier policy, but the exact r35
`framework-res.apk` still resolves `config_device_volte_available=false`.
Nothing stock sets the device VoLTE, VT, and WFC capability resources true and
then applies carrier policy. Restore those device resources so the existing
carrier RRO can take effect. Do not treat CS cause 252 or missing non-IMS inbound
SMS as closed.

The 3/Hallon capture also exposes a carrier-specific IMS defect: r35 has no
carrier-ID 1691 IMS or XCAP APN and makes no IMS-PDN attempt, while stock ships
both. `vendor/apn` commit `2573baa` adds those rows; its follow-up binds them to
carrier ID 1691 and restores stock's specific default/IA and iWLAN-MMS rows. AOSP
value `LteVopsSupportInfo=2` means supported, and IMS errors
4001/4002 are present in the supplied capture; prior contrary notes are corrected.

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
  Cox/Verizon data or IMS. A fresh-wipe r24 physical-SIM capture and an earlier
  removable-eUICC active-profile capture show LTE registration and SMS passing,
  but both data paths receive modem `0x1004`. The successor restores stock
  `QtiTelephony`, `QtiTelephonyService`, `qcrilmsgtunnel`, `QtiTelephonyCompat`,
  stock-equivalent SELinux domains, and seven missing Cox 311/600 APNs. Focused
  package, policy, APN-schema, image, and VINTF checks pass. The next source state
  additionally restores stock's framework IMS capability gates, Swedish
  carrier-ID 1691 IMS/XCAP rows, and two stock AIDL declarations requested by
  CND/DPM. None is claimed to resolve the separate pre-network `0x1004` response.
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
- MTR-025 lifecycle and reboot persistence pass on r30; only perceptible effect
  remains for listening or loopback measurement.
- Validate USB-C audio, HFP/SCO, A2DP fallback, volume coordination, and suspend.

### WP4: Camera, biometrics, and haptics

- MTR-022 r30 system-Aperture acceptance passed FHD30/FHD60/UHD30 routing,
  finalized files, process restart, provider stability, and tombstone monitoring.
  Audited r22 is now running coherently on slot B. Its crash gate is clear, and
  retained coherent-r22 camera evidence covers all five camera IDs, SAT
  0.6x/1x/3x/10x zoom, torch, zoom while recording, and system-APK
  FHD30/FHD60/UHD30 evidence. Complete the remaining cadence, long-run,
  front-screen-flash, stabilization, and UI acceptance rows. MTR-029 now blocks
  camera stability promotion until stock `vendor.gralloc.enable_logs=0` is
  installed and the ten-cycle matrix is clean. MTR-012 still requires
  measured stabilization, crop, cadence, zoom-transition, and motion acceptance.
- MTR-018's source fixes are installed on r35. Fresh enrollment and four unlocks
  pass with no fingerprint HAL death. Complete the remaining 46 screen-on/AOD
  unlocks plus cancellation/retry with Smooth Display off before closure.
- MTR-011: recover actual stock effect/primitive mappings before advertising or
  changing any haptic capability.
- MTR-023 Spanish/Japanese/Arabic education rendering passes; complete the normal
  accessibility, parental-consent, enrollment and authentication flows.

### WP5: Connectivity, suspend, and cleanup

- MTR-019's Connectivity RRO is installed on r35. NCM assigns
  `10.205.201.184/24`, the host receives `10.205.201.209/24`, bidirectional local
  ping passes, and Ethernet excludes `usb0`. Complete IPv6/upstream, reconnect,
  HAL-restart, MTP and RNDIS regressions. The bounded MTR-021 cleanup remains closed.
  MTR-015 QCC remains a separate atomic
  feature decision; MTR-016 sensor extension and MTR-024 ST21 remain active.
  MTR-020 returns to
  evidence collection because current and latest NothingOSS tuna both use the
  existing register; do not transfer the `kera` address.
- Group RC/VINTF changes by subsystem, but retain one first-failure cause and one
  acceptance matrix per issue.

## Next execution order

1. Focused-build and stage the stock-backed framework capability, Swedish IMS APN,
   and CND/DPM VINTF corrections. Keep them separate from the unresolved data
   cause in status and validation.
2. Localize `0x1004` before another data-path edit. Use an exact r35/modem/MCFG
   identity, one boot-inclusive vendor-RIL-verbose attempt, then a same-device
   stock control and QMI/QXDM comparison if the local reason remains opaque.
   Determine whether QMI WDS Start Network Interface is emitted and retain its
   extended result. Do not change kernel, IPA, modem, MCFG, or APNs speculatively.
3. On the eventual coherent candidate, confirm effective device and carrier IMS
   gates, carrier-ID APNs, default and IMS PDNs, inbound/outbound SMS, calls, data,
   DSDS, airplane mode, and suspend on the documented modem generation.
4. Complete r35 UDFPS repetitions, camera finalization, and USB adjacent-mode
   regressions, then complete MTR-023 and perceptible AudioFX acceptance.
5. Preserve MTR-026 as a cleared recurring crash gate. For MTR-027, first record
   whether Phonesky is stopped and launcher-resolvable; r35 required package-state
   normalization before a crash-free launch reached Google's uncertified-device
   activity. Keep certification externally blocked. Test official per-device
   registration only as storefront access, never as ROM certification.
6. Validate the patched host ADB's 0-to-100 unique-transfer display on the next
   already-planned recovery sideload; record recovery's result independently.
7. Complete installed-system Aperture acceptance from the canonical hardware matrix.
8. Complete WP1 thermal/charging because the 49 C unplugged event is the highest
   safety-relevant unresolved evidence.
9. Execute remaining WP2-WP5 work in dependency order, using stock/kernel/upstream
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
