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
- Wi-Fi: enable stock-matching hardware PNO so saved networks can reconnect while
  the screen is off. The focused overlay build contains the expected resource;
  repeated disconnect/reconnect testing remains for the next OTA.
- NFC: restore the stock CPLC helper domain and property labels, and remove the
  forced completion value that masked clean-state bootstrap failure. SELinux and
  vendor-image builds pass; clean-state bootstrap and tag testing remain.
- UICC secure element: declare stock ROW `SIM1` and `SIM2` instances served by
  qcrild. VINTF compatibility and duplicate-instance checks pass; physical-SIM
  OMAPI testing remains. JPN-only `eSE1` is intentionally not declared.

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
