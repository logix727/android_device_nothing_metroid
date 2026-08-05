# Next release

Canonical issue backlog: [`BUGS.md`](BUGS.md).

## Blockers

- Face enrollment and authentication pass on the installed candidate with no HAL
  death or biometric error. Settings passes its preview surface to the HAL and
  the stock-matching graphics-allocator policy is active. The base Settings face
  guidance strings were empty; metroid now supplies the missing safety and setup
  text. The text overlay is installed; final visual confirmation remains.
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
  the screen is off. The installed overlay starts disconnected PNO with zero
  framework failures; saved-AP reconnection remains blocked by AP availability.
- NFC: restore the stock CPLC helper domain and property labels, and remove the
  forced completion value that masked clean-state bootstrap failure. A property-
  clean boot regenerates all values before HAL startup; toggle and credit-card
  polling pass. Android advertises HCE/HCE-F, host routing is enabled, and the
  routing table is active. An actual payment transaction still needs a wallet
  app and reader/terminal.
- UICC secure element: declare stock ROW `SIM1` and `SIM2` instances served by
  qcrild. Both services register on the installed candidate; physical-SIM OMAPI
  testing remains. JPN-only `eSE1` is intentionally not declared.
- Performance: restore the stock perf HAL's access to `/proc/sys/walt` after the
  device tree relabeled those controls. The installed candidate passes two boots,
  cold app launches, UI gestures, camera startup and CPU load with readable WALT
  controls, no perf AVC, and both perf/QHDC services alive.
- Wi-Fi 7: OpenWrt MLD testing passes WPA3-SAE H2E, GCMP-256, 6 GHz/320 MHz
  EHT association, about 839 Mbps down and 660 Mbps up over TCP, five-minute
  screen-off retention, and screen-off PNO reassociation in about 5.6 seconds.
  Android reports one active affiliated link, so simultaneous multi-link traffic
  is not yet proven.
- Face guidance is present and confirmed in English. Base Settings still contains
  explicit empty localized values, so non-English guidance needs a locale-safe
  fallback before broad release.
- No-SIM regression testing passes speaker playback, microphone capture, Bluetooth
  stack restart, USB gadget reset/ADB at 480 Mbps, sensors, haptic effects,
  five-minute forced Doze with Wi-Fi retained, and a two-minute CPU thermal load.
  Unplugged auto-suspend also passes with no framework wake lock or display/power
  suspend blocker held. The 34-minute window began at 100%, so it does not provide
  a useful long-duration percentage-drain figure.
- GNSS: open-source GPSTest receives raw measurements and continuous GPS locations;
  the indoor test fixed on five satellites with about 53-second mean TTFF.
- Wireless charging: battery history records an actual `plug=wireless` charging
  transition. USB and wireless power supplies report independently.

## Community coverage

- Calls, SMS, mobile data, IMS, emergency UI, dual SIM and handover.
- Bluetooth LE Audio, USB-C audio, NFC payment/secure-element applets.
- Long-duration suspend drain, thermal throttling, HDR/video playback, camera
  third-party apps.

## Release gate

1. All modified projects committed on `lineage-23.0-metroid`.
2. Fresh install-clean `m bacon` using all available build resources.
3. VINTF, init, payload, AVB, signing and partition audits pass.
4. Target-slot boot, second boot, Enforcing, encryption and crash sweep pass.
5. Update `BASELINE.md`, release notes and SHA-256; then tag source.
