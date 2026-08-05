# LineageOS 23 for Nothing Phone (3) (`metroid`)

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
  partition audits. Runtime testing later found undeclared vendor services and a
  missing post-OTA care-map verification pass; see `BUGS.md`.
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
