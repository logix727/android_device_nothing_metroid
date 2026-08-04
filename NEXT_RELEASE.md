# Next release

## Blockers

- Face enrollment and authentication pass on the installed candidate with no HAL
  death or biometric error. Settings passes its preview surface to the HAL and
  the stock-matching graphics-allocator policy is active. The base Settings face
  guidance strings were empty; metroid now supplies the missing safety and setup
  text. The text overlay is focused-build validated but not yet in an OTA.
- Camera: mode changes now reselect logical camera 4 for SAT capture and physical
  camera 0 for UHD/60 fps, and high-bandwidth modes can no longer jump to an
  unsupported physical lens. Focused build and device tests pass for photo/video
  routing, finalized FHD60, FHD30 SAT zoom while recording, and UHD30. FHD60 and
  UHD use main-camera digital zoom by design; broader app testing remains.
- Haptics: the stock HAL was denied its AW86927 RichTap node, calibration proc
  files and SFDC properties. Device-scoped labels and grants are active on the
  installed candidate; calibration completes and perceived output is stronger.
  Full effect parity against stock remains.

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
