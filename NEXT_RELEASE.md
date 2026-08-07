# Next release

Canonical issue backlog: [`BUGS.md`](BUGS.md).
Canonical baseline: [`BASELINE.md`](BASELINE.md).

## Installed baseline (r9, `23.0-20260807-UNOFFICIAL-metroid`)

- `org.codeaurora.ims` runs as `vendor_qtelephony`; IMS radio/radio-config and
  qti-radio-stable services resolve and bind; MMTEL and EMERGENCY_MMTEL register
  on both slots; no IMS/radio/vendor-property AVCs across two boots.
- Power HAL `android.hardware.power.IPower/default` registers.
- `ro.product.first_api_level=35`, `ro.board.first_api_level=202404`.
- eUICC is not advertised on r9 (no LPA/EuiccService installed).
- Slot A, Enforcing, encrypted, slot marked successful, empty crash buffer after
  two boots; no pending snapshot merge.
- Boot-image SPL is populated; GNSS property and media-quality lookup fixes pass
  focused runtime tests.
- Live framework skin temperature, stock thresholds, and non-NaN headroom pass
  across two boots with the stock Thermal HAL and confined `sltntc` daemon.
- Official MindTheGapps recovery add-on flow passes; Play Store/GMS/GSF/Google
  Setup Wizard persist across two boots. Google files remain a separate add-on,
  not part of the ROM artifact or public source.

## Blocker priorities (in order)

1. Physical-SIM calls, SMS, data and IMS features; emergency UI; and OMAPI
   acceptance — requires a carrier SIM in the device, currently blocked by
   subscription availability.
2. Redistribution clearance for the proprietary IMS package before any public
   OTA sharing; keep the vendor repo unpublished.
3. Aperture stabilization UI and flip-routing acceptance on clean package state;
   retained user package overrides prevented a trustworthy r5 UI test.
4. Release-reproducibility and record-consistency audits for every future release.

## Already-landed this cycle (preserve, do not regress)

- Radio/IMS VINTF fragments and device scoping that put `org.codeaurora.ims` under
  `vendor_qtelephony` (base r4 seapp/overlay/VINTF work).
- Standalone Power HAL VINTF fragment and stock-matching launch-API metadata.
- Soong ramdisk property generation now emits the platform SPL as
  `ro.bootimage.build.version.security_patch`; installed r5 reports `2026-02-01`
  and preserves measured boot-chain AVB SPL `2025-04-05` (MTR-007).
- GNSS uses a typed property grant; MediaCodec uses the upstream optional
  framework-service lookup; Aperture hides its metroid stabilization no-op and
  preserves high-bandwidth routing across camera flips. GNSS and MediaCodec pass
  runtime tests; Aperture changes remain runtime-unverified (MTR-012/013/014/022).
- Nothing's stock `sltntc` producer, policy, enable property, and stock Thermal
  HAL provide live `shell_max`, framework skin thresholds, and headroom across
  two installed boots (MTR-005 framework path resolved).
- `system`, `product`, and `system_ext` use writable ext4 with measured add-on
  reserves so Lineage's recommended Android 16 ARM64 MindTheGapps installer can
  mount and populate them. Root vbmeta keeps signature/chain verification but
  sets only AVB's hashtree-disabled bit so intentional recovery add-on writes
  survive boot. Installed and accepted across two r9 boots.

## Community coverage still to test

- Calls, SMS, mobile data, IMS, emergency UI, dual SIM and handover.
- Bluetooth LE Audio, USB-C audio, NFC payment/secure-element applets.
- Long-duration suspend drain, thermal throttling, HDR/video, camera third-party
  apps, factory-reset Setup Wizard/FBE/default-state.

## Release gate

1. All modified projects committed on `lineage-23.0` (device/kernel) with the
   private vendor reproduced from stock extraction only.
2. Fresh install-clean `m bacon` using all available build resources.
3. VINTF, init, payload, AVB, signing and partition audits pass.
4. Target-slot boot, snapshot state, slot success, second boot, Enforcing,
   encryption and crash sweep pass.
5. Update `BASELINE.md`, release notes and SHA-256; then tag source.
