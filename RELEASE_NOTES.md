# LineageOS 23 for Nothing Phone (3) (`metroid`)

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

ADB intentionally scales normal sideload progress by 47 because recovery usually
requests the package bytes about twice for verification and installation. A
successful A/B sideload may therefore stop near 47 percent and print
`adb: failed to read command: Success`; use recovery's final status, not the host
percentage, as the result.

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
