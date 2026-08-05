# LineageOS 23 for Nothing Phone (3) (`metroid`)

## 2026-08-05 tester build

This is an **unofficial prerelease for testers**, not an official LineageOS
build.

SHA-256:

`33ccd784a7ccffb6dff927470afec941887ea2d1d21d91d84930e6f7485457a7`

### Verified

- Install-clean Virtual A/B recovery sideload, target-slot activation, three
  boots, encrypted userdata retention, Enforcing SELinux and one system_server
  start per boot.
- Payload equivalence for all 16 partitions, AVB, signing, VINTF and partition
  audits.
- Wi-Fi hardware PNO starts while disconnected with zero framework failures.
- NFC clean-state CPLC bootstrap regenerates all derived properties before the
  NFC HAL starts; NFC disable/enable and credit-card polling work.
- ROW UICC secure-element `SIM1` and `SIM2` services register; JPN-only `eSE1`
  remains intentionally absent.
- Face enrollment/authentication, camera routing/zoom, fingerprint, haptics and
  core audio/camera/biometric HAL regression checks pass.

### Known issues / tester focus

- eSIM is unavailable because no LPA/EuiccService is installed; default eUICC
  card discovery also remains unverified.
- Physical-SIM calls, SMS, data, IMS, emergency UI and UICC OMAPI require testing.
- Saved-network PNO reconnection needs an available configured AP; PNO startup
  itself is verified.
- NFC payment/HCE and secure-element applets are not verified. ST21 logs `-107`
  transport errors during transitions despite successful initialization/tag use.
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
