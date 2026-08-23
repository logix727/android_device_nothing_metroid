# LineageOS 23 for Nothing Phone (3) (`metroid`)

## 2026-08-17 unofficial hardware-acceptance seed (r35)

- Exact OTA: `lineage-23.0-20260815-UNOFFICIAL-metroid.zip`, SHA-256
  `d846533b49062d437d112fa3946be413471ab20b2ece9a3f601236e23cc6c7b6`.
- Immutable snapshot:
  `releases/candidate_20260815_192053_709386797_candidate/`.
- Installed through update_engine with `kSuccess (0)` on automatically selected
  slot B. Snapshot state is `none`, userdata is encrypted, SELinux is Enforcing,
  and two coherent boots have one system_server and no new crash, tombstone or
  pstore record.
- APN migration, QTI/IMS startup, fresh UDFPS enrollment plus four unlocks, NCM
  local IPv4, and bounded haptic, NFC and camera-preview checks pass.
- Full physical-SIM/eSIM, remaining UDFPS repetition, camera finalization, USB
  adjacency, thermal/charging, AudioFX and face-flow acceptance remain open.
- Play Store package launch and certification are separate. Updated Phonesky
  initially had a stopped/unresolved launcher state; after package-state
  normalization it launched crash-free and Google selected the uncertified-device
  activity. MTR-027 remains `UNCERTIFIED-BLOCKED`; no identity, attestation,
  Google-package or AVB bypass is included.
- Tester instructions: `release/XDA_TESTER_20260817_R35.txt`.

## 2026-08-14 unofficial physical-SIM test candidate (r30)

- Exact OTA: `lineage-23.0-20260814-UNOFFICIAL-metroid.zip`, SHA-256
  `40fb1b4178836482e2f0f349a092541d1a1f5820c81d8e3503546b49411e08b4`.
- Immutable snapshot: `releases/candidate_20260814_141135_911532683_r30/`.
- r30 fixes r29's two installed boot blockers: Android 16 rejected the new
  name-only seapp rules, and stock-signed QtiTelephonyService lacked its required
  `MODIFY_AUDIO_ROUTING` privileged-permission allowlist.
- Installed through Android update_engine with `kSuccess (0)` on automatically
  selected slot A. Slot A is successful, snapshot state is `none`, userdata is
  encrypted, SELinux is Enforcing, and GApps/addon.d were preserved.
- Repeated boots pass with one system_server start, empty crash buffer, no new
  tombstone or pstore record, and no recurrence of either r29 fatal signature.
- QtiTelephony and org.codeaurora.ims run in `vendor_qtelephony`; QTI radio and
  IMS services register and the required audio permission is granted.
- No physical SIM is present in the maintainer target. Carrier data, voice, SMS,
  APN, IMS, VoLTE, VoWiFi, and DSDS remain external tester acceptance items.
- Post-release acceptance found two source defects for the next candidate:
  Ethernet IpClient also claims NCM `usb0` and clears its gateway (MTR-019), and
  enabled QTI mapper debug logging dereferences a freed buffer handle (MTR-029).
  r30 remains the exact XDA SIM test artifact, but camera stability and NCM local
  transport are not promoted as passing.
- r30 fingerprint enrollment fails despite correct UI/illumination. The stock
  Goodix shim is blocked by SELinux from `/proc/touchpanel/fod_mode`, and the
  existing UDFPS refresh vote still arrives after pointer-down. Stock-equivalent
  policy access and a metroid-only overlay-lifetime 120 Hz vote are built for the
  next candidate; no r30 fingerprint-function claim remains.
- r30 AudioFX real-session open/close, client-death cleanup and reboot persistence
  pass. Spanish/Japanese/Arabic face-education rendering passes without blank UI.
  r30 Aperture finalized FHD30/FHD60/UHD30 with correct routes, but MTR-029's
  sampled tombstone blocks camera stability acceptance despite successful retries.
- Tester instructions: `release/XDA_TESTER_20260814_R30.txt`.

## Post-r21 retained status

r21 remains the accepted baseline unchanged.

- Live device: coherent r28 `23.0-20260813-UNOFFICIAL-metroid`, slot B,
  encrypted and SELinux Enforcing across two boots; installed but not accepted.
- r28 immutable snapshot:
  `releases/candidate_20260812_224028_708148776_candidate/`, SHA-256
  `6d1427449128bbd65e64841b2934ea91dae7f68ede51c2557830d827feddb9e9`.
- MTR-019 passes installed NCM enumeration, DHCP, DNS, IPv4, and HTTPS; reconnect,
  HAL-restart, standalone-NCM and adjacent-mode regressions remain. The bounded
  MTR-021 cleanup passes across both boots.
- MTR-023 and MTR-025 are installed but still require real locale/UI and
  playback/lifecycle acceptance.
- Public AT&T and Cox/Verizon physical-SIM reports establish a functional radio
  blocker: network visibility without data, voice, or text. The successor restores
  three omitted stock QTI telephony APKs plus `QtiTelephonyCompat`, stock-equivalent
  SELinux assignment, and seven missing Cox 311/600 APNs. Focused package, policy,
  APN, image and VINTF validation passes; carrier testing remains required.
- A sanitized fresh-wipe r24 capture covers a conventional physical SIM; an
  earlier capture covers a removable eUICC active profile. Both reach LTE
  registration and SMS, both fail data at modem response `0x1004`, and IMS remains
  unregistered. The eUICC capture also fails profile refresh/embedded metadata.
- That successor is offline-verified as r29 at
  `releases/candidate_20260813_115214_637118668_candidate/`, SHA-256
  `18759452f85d92f45a38a4e276eecb58a119b1d425f9e7a966d91ae5dd0202f8`.
  It has not been installed; no physical-SIM or IMS fix is claimed yet.
- Play Store remains redirected to Google's uncertified-device activity. Google's
  official custom-ROM registration may provide per-device storefront access but
  does not certify this ROM.

- Live device: coherent r22 `23.0-20260809-UNOFFICIAL-metroid`, slot B,
  encrypted and SELinux Enforcing; not accepted.
- MTR-026 historical conclusion: three coherent-r22 boots had empty crash
  buffers, so the four observed Password Checkup fatalities were attributed to
  an operator-created mixed r21-`init_boot`/r22-images diagnostic state. Later
  evidence corrected that conclusion: the retained r22 stability capture and
  coherent r50 both contain the same intermittent proprietary GMS private-API
  failure. See `BUGS.md`; promotion remains blocked with no eligible Lineage fix.
- MTR-027: Google blocks the Play Store storefront as Play Protect uncertified.
  This remains an external policy gate; no certification or bypass is claimed.
- r23 (`e262e83ee6ce1ddb7536ed9924db8382058b1bf2cf8c368896690b9a62456ca5`)
  was built install-clean but was not installed.
- r24 (`50143f9e8481cd0211def4aba5776246f46fa68c0a991fb8961be45608361e98`)
  is a non-promotable test seed, not an accepted candidate.
- r25 (`7d20dd544a8ea58d6bde3bac8f6ef3641ffd4a94f71c0fda16094ccc7f5ae23b`)
  is install-clean and offline-verified in
  `releases/candidate_20260812_164223_410891256_r25/`. It is not installed or
  accepted. It carries bounded MTR-019/MTR-021 fixes plus dependency-closed
  replacements for the rejected r23 MTR-023/MTR-025 implementations.

## 2026-08-08 maintainer-local candidate (r17, stock-backed eSIM)

Installed and accepted privately from
`releases/candidate_20260807_223220_esim-stockfw-r17/`.

ROM SHA-256:

`d5098df075e52e89ce61d35db2dbdecfd917b6bc1b899ce9b3d740d843c00243`

### Required companion inputs

- Exact stock A16 modem firmware on both modem slots, build
  `MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.126608.2.134544.2`.
- MindTheGapps Android 16 ARM64 add-on SHA-256
  `a6ff8b8c31f7ccd0a9f2fd651fa4438a8e39a5f63b95be246ea1f98982af2c28`,
  sideloaded from the new-slot recovery after the ROM OTA.
- Neither companion input is embedded in the ROM ZIP.

### Verified

- Install-clean signed A/B OTA; 16/16 payload equivalence, VINTF compatible,
  signed AVB chain, root flag `1`, encrypted userdata, Enforcing, two boots,
  empty crash buffer, and no new tombstones.
- Matching modem firmware resolves the mixed QCRIL/MCFG generation that caused
  the QTI LPA generic EID failure.
- Native `EuiccManager` is enabled using Google's standard EuiccService. Profile
  UI reaches **Set up an eSIM**, device-transfer chooser, and QR scanner without
  a platform telephony compatibility patch.
- QSPA, Power HAL, IMS radio 0/1, thermal skin/headroom, GNSS, camera provider,
  Play Store/GMS policy, and account retention pass across two boots.

### Unverified / tester focus

- A real private eSIM activation code: download, enable/disable, reboot, delete,
  transfer, and coexistence with physical SIM.
- Physical SIM calls, SMS/MMS, data, VoLTE/VoWiFi, emergency UI, DSDS, and OMAPI.
- Thermal status/cooling/display behavior under controlled unplugged load. A prior
  normal-use session retained battery temperatures of 48-49 C before a manual
  reboot; it was not charging and did not thermally shut down.
- Aperture EIS/routing, LE Audio, haptics, NFC payment/off-host, USB-C audio, and
  long-duration suspend.
- Public OTA/modem distribution remains blocked pending proprietary clearance.

## Recovery sideload progress

Stock ADB scales normal sideload progress by 47 because recovery may reread package
bytes for verification and installation. The metroid host carry replaces that
estimate with unique package-block coverage, so transfer reaches 100 percent after
every ZIP byte has been served once and repeated reads do not inflate it. Focused
tests and the full 103-test host suite pass; real recovery sideload acceptance is
pending. The message `adb: failed to read command: Success` remains a separate
missing-terminal-token condition, not an install verdict. MTR-028 still requires
recovery's final status, automatically selected target slot, update/snapshot state,
slot success, and two coherent boots before accepting or rejecting installation.

## 2026-08-06 maintainer-local candidate (r7, thermal skin)

Installed and tested privately from
`releases/candidate_20260806_194556_xda-thermal-r7/`.

SHA-256:

`74d738f1ba6b8f7f4534f82a6b0e004dbebdc3f4b90f09cccef48d534cdf1bb0`

### Verified

- Install-clean signed A/B OTA, 16/16 payload equivalence, VINTF compatible,
  AVB flags `0`, encrypted userdata, slot B, two boots, no snapshot merge,
  empty crash buffer, and no new tombstones.
- Stock-hash `sltntc` runs confined, automatically owns and updates the shell
  thermal node, and exposes front/frame/back/max enclosure temperatures.
- Stock-hash Thermal HAL reports live `TYPE_SKIN`, thresholds
  39/43/44/50/54/63 C, and non-NaN framework headroom on both boots.
- r5 boot-SPL, GNSS property, MediaCodec, radio, power, and core-service fixes
  remain intact.

### Unverified / residual

- Controlled thermal severity, cooling, display mitigation, charging derating,
  and long-duration load/suspend transitions.
- Proprietary thermal-engine logs dynamic shell-zone name errors and a missing
  FPS virtual sensor despite the framework path working.
- Public OTA upload remains blocked by proprietary redistribution clearance.

## 2026-08-06 maintainer-local candidate (r5, focused fixes)

Installed and tested privately from the immutable snapshot
`releases/candidate_20260806_172928_xda-focused-fixes-r5/`. Public OTA upload is
blocked until proprietary IMS redistribution clearance is established.

SHA-256:

`16174926b2bda7a74853f52a821bbb9e8405e8ed3bc11035e96b541a8a2cb8f7`

### Verified

- Install-clean signed A/B OTA; all 16 payload images match target-files.
- `check-vintf-all` compatible; AVB chain verifies with root flags `0`.
- Recovery sideload selected slot B; encrypted userdata retained; two boots,
  Enforcing SELinux/verity, slot success, no pending snapshot merge, empty crash
  buffer, and no new tombstones.
- Boot-image SPL is now `2026-02-01`; boot/init_boot AVB SPL remains the measured
  stock-chain level `2025-04-05`.
- GNSS HAL restart has no prior property-service denial.
- Codec creation has no invalid `media_quality` VINTF lookup.
- Power, camera provider, GNSS, IMS radio 0/1, and system_server remain alive.

### Unverified / tester focus

- Physical-SIM calls, SMS, data, VoLTE/VoWiFi, emergency UI, DSDS, and OMAPI.
- Aperture stabilization control and front/back video routing are installed but
  not runtime-accepted on retained userdata due stale package-manager component
  state from a pre-OTA APK override test.
- LE Audio, USB-C audio, NFC payment/off-host SE, full haptic parity, thermal skin
  policy, charging policy, and long-duration suspend drain.
- eSIM remains intentionally unavailable; no LPA/EuiccService is installed.
- Unlocked bootloader means no Widevine L1, strong Play Integrity, or HDCP trust.

## 2026-08-06 maintainer-local candidate (r4, IMS policy)

This build was installed and tested privately by the maintainer. It is not yet
published as a supported download. Source and artifact are reproducible from the
immutable snapshot `releases/candidate_20260806_144606_ims-policy-r4/`.

SHA-256:

`22e98f31182daa6e0645af48d64b7f7617aedf8b180250815759171436b260df`

### Verified

- Install-clean Virtual A/B recovery sideload to slot A, two boots, slot marked
  successful, encrypted userdata retention, Enforcing SELinux, one
  `system_server` start per boot, empty crash buffer.
- Payload equivalence for all 16 partitions, AVB chain, signing, declared VINTF
  (`check-vintf-all` compatible), and partition audits.
- IMS/SELinux fix landed: `org.codeaurora.ims` runs as `vendor_qtelephony`;
  `IQtiRadioConfig/default`, `IImsRadio/imsradio0/1` and `IQtiRadioStable/slot1/2`
  resolve and bind; `ImsResolver` registers MMTEL and EMERGENCY_MMTEL on both
  slots; subscription service-status updates received. No IMS/radio/vendor-property
  AVC denials across two boots.
- Power HAL `android.hardware.power.IPower/default` registers.
- Launch metadata corrected: `ro.product.first_api_level=35`,
  `ro.board.first_api_level=202404`.
- Wi-Fi 7 (6 GHz/320 MHz, MLO/SAE) connected and transporting, Bluetooth ON, NFC
  service registers, camera provider, vibrator HAL and sensors register; charge
  at 100% with AC+USB powered and sane battery health.

### Known issues / tester focus for this candidate

- eSIM: on r4 the eUICC hardware feature is no longer advertised and no
  LPA/EuiccService is installed, so no eSIM is available. Reintroduction requires
  a legally distributable LPA.
- Physical-SIM calls, SMS, data, IMS features, emergency UI and OMAPI are NOT yet
  tested on r4 (no active subscription on the test device); these remain the
  critical open validation.
- Recovery sideload does not stage `care_map.pb`, so `update_verifier` skips its
  additional cared-block read. This matches upstream A/B recovery behavior and
  is not a metroid release blocker; AVB still protects mounted partitions.
- Platform security patch `2026-02-01`, vendor `2025-06-05`; boot-image SPL still
  blank (MTR-007).
- NFC payment/secure-element and wireless-charging-property-drain figures are not
  fully quantified; fingerprint and full haptic parity remain outstanding.
- Unlocked bootloader means no Widevine L1, strong Play Integrity or HDCP trust.

## 2026-08-05 maintainer-local candidate

This build was installed and tested privately by the maintainer. It was not
published as a supported download and is not a reproducible public release.

SHA-256:

`d052d13c16f008f8ea80118f598f8fa7cefdcad6b1d6ef82590e63c7ec324c3c`

### Verified

- Install-clean Virtual A/B recovery sideload, target-slot activation, three
  boots, encrypted userdata retention, Enforcing SELinux and one system_server
  start per boot.
- Payload equivalence for all 16 partitions, AVB, signing, declared VINTF, and
  partition audits. Runtime testing later found undeclared vendor services. The
  absent recovery-sideload care-map pass was subsequently confirmed as expected
  upstream behavior; see `BUGS.md`.
- Wi-Fi hardware PNO starts while disconnected with zero framework failures.
- NFC clean-state CPLC bootstrap regenerates all derived properties before the
  NFC HAL starts; NFC disable/enable and credit-card polling work.
- ROW UICC secure-element `SIM1` and `SIM2` services register; JPN-only `eSE1`
  remains intentionally absent.
- Face enrollment/authentication and selected camera/audio/biometric regression
  checks pass. Fingerprint fresh-enrollment acceptance remains incomplete, and
  standard Android haptic effects remain degraded.
- Perf HAL access to device-labeled WALT controls is restored and runtime-tested
  across app launch, UI, camera and CPU-load operations without AVCs or crashes.
- OpenWrt Wi-Fi 7 MLD testing passes 6 GHz/320 MHz EHT association, sustained
  TCP transport, screen-off retention and PNO reassociation.
- Open-source GPSTest receives raw GNSS measurements and continuous GPS fixes;
  an indoor run fixed on five satellites.
- Unplugged auto-suspend releases framework wake locks and display/power suspend
  blockers. Battery history also confirms a real wireless-charging transition.
- NFC advertises HCE/HCE-F with host routing and an active routing table.

### Known issues / tester focus

- eSIM is unavailable because no LPA/EuiccService is installed; default eUICC
  card discovery also remains unverified.
- Physical-SIM calls, SMS, data, IMS, emergency UI and UICC OMAPI require testing.
- Screen-off PNO reassociation passed against the tested AP; broader saved-network
  and controlled-roaming coverage remains untested.
- Cellular IMS/eSIM, Power HAL registration, framework skin thermal reporting,
  launch API metadata, and security-patch metadata remain release blockers.
- NFC payment and secure-element applets are not transaction-tested. ST21 logs
  `-107` transport errors during transitions despite successful initialization,
  tag use, and HCE capability checks.
- Long-duration unplugged percentage drain is not quantified; the focused
  suspend window began at 100% and was too short for a meaningful percentage.
- Factory-reset Setup Wizard/FBE/default-state validation has not been run.
- Unlocked bootloader means no Widevine L1, strong Play Integrity or HDCP trust.

## 2026-08-04 tester build

This is an **unofficial prerelease for testers**, not a daily-driver or official
LineageOS build.

SHA-256:

`74c012f8ef5a5cce1a860442be06bc412c43e11881c2f5f004559cec9c6c4869`

### Verified

- Full Virtual A/B recovery sideload and target-slot boot.
- Enforcing SELinux, encrypted `/data`, stable `system_server`.
- Payload-to-target-files equivalence for all 16 partitions and full AVB graph.
- Display, touch, Wi-Fi, Bluetooth, NFC, GNSS, audio, USB and sensors register.
- Fingerprint enrollment artwork and lockscreen indication placement corrected.
- Camera photo/video, front screen flash, physical rear lenses, logical SAT
  `0.6x/1x/3x` and FHD60 work in controlled tests.
- Nothing stock vibrator service, RC, RichTap/AW dependencies and SFDC are loaded.

### Known issues / tester focus

- Face unlock enrollment still fails and needs logs.
- Camera zoom/lens behavior is improved but still needs broad app/mode testing.
- Haptics remain noticeably weaker than Nothing OS despite the stock stack.
- UHD/4K routing was enabled in this build and needs device validation.
- Cellular calls, SMS, mobile data, IMS and emergency calling require SIM testing.
- Unlocked bootloader means no Widevine L1, strong Play Integrity or HDCP trust.

Report the exact ZIP hash, firmware, install type, reproduction steps, `logcat`,
`dmesg` and new tombstones. See [`INSTALL.md`](INSTALL.md).
