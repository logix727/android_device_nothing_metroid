# Next release

## Blockers

- Face enrollment: Settings now passes its preview surface to the HAL instead of
  competing with it for front camera 1. A runtime APK test proved sole HAL camera
  ownership and exposed the next failure: missing graphics-allocator client
  policy. The stock-matching policy fix compiles; OTA validation remains.
- Camera: mode changes now reselect logical camera 4 for SAT capture and physical
  camera 0 for UHD/60 fps, and high-bandwidth modes can no longer jump to an
  unsupported physical lens. Focused build and device tests pass for photo/video
  routing, finalized FHD60, FHD30 SAT zoom while recording, and UHD30. FHD60 and
  UHD use main-camera digital zoom by design; broader app testing remains.
- Haptics: the stock HAL was denied its AW86927 RichTap node, calibration proc
  files and SFDC properties. Device-scoped labels and grants compile into the
  vendor image; strength/effect parity still needs OTA testing against stock.

## Community coverage

- Calls, SMS, mobile data, IMS, emergency UI, dual SIM and handover.
- Bluetooth LE Audio, USB-C audio, NFC HCE/secure element, wireless charging.
- Suspend drain, thermal throttling, HDR/video playback, camera third-party apps.

## Release gate

1. All modified projects committed on `lineage-23.0-metroid`.
2. Fresh install-clean `m bacon` using all available build resources.
3. VINTF, init, payload, AVB, signing and partition audits pass.
4. Target-slot boot, second boot, Enforcing, encryption and crash sweep pass.
5. Update `BASELINE.md`, release notes and SHA-256; then tag source.
