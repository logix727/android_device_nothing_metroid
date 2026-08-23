# Hardware acceptance matrix

This is the canonical inventory and functional acceptance ledger for Nothing
Phone (3) (`metroid`). `BASELINE.md` identifies the accepted release;
`BUGS.md` owns defects. This file answers whether each hardware operation has
actually been exercised.

## Status rules

| Status | Meaning |
|---|---|
| PASS | The real operation passed on the named build with retained evidence. |
| INHERITED | A named accepted parent passed and the child changed no owning source, dependency, firmware or companion input. |
| PARTIAL | A bounded subset passed; the row names the missing modes. |
| FAIL | A real operation has a reproduced defect. |
| BLOCKED | Required hardware, credentials, carrier service, or physical action is unavailable. |
| UNKNOWN | No functional result. Enumeration, a Binder service, or absence of a bug is not a pass. |
| N/A | The inventory shows that the device does not expose this hardware. |

Rows without a specific accepted result or a valid named `INHERITED` parent are
not accepted-release claims. r49 results below are installed diagnostic evidence
until external Tele2 and inserted-SIM2 gates pass.

## Tested configurations

| Name | Build / slot | State |
|---|---|---|
| Accepted baseline / live state | r48 `23.0-20260821`, OTA `5e79b012fb8063b09f4a3fde48b5241470c6b2fb55b0acf0d39bc334fd66d581`, slot A | Enforcing, encrypted, two boots, boot-loaded TIPC, active eSIM, automatic carrier data/NR_NSA, QCC clean; accepted |
| Installed external-test state | r49 `23.0-20260822`, OTA `aa58c5accbade7b491a595398cba028cf90b49f0dafcbcd87ad046f47866351e`, slot B | eSIM/physical-SIM2 mux round-trip and eSIM restoration pass; Tele2 calls and inserted SIM2 remain external gates |

Private live evidence is under `diagnostics/hardware_acceptance_20260809_r22/`
and `diagnostics/hardware_acceptance_20260811_coherent_r22_camera/`. Public
release evidence must be sanitized before publication.

## Display and touch

| Hardware / operation | Inventory | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|---|
| Built-in display output | 1260x2800 rounded OLED, centered punch-hole | PASS: normal UI and two accepted boots | PASS: Android UI and camera probes rendered | Dead pixels, uniformity, color accuracy, flicker and outdoor readability require visual checks. |
| Refresh modes | 60, 90 and 120 Hz exposed | PARTIAL: 60/120 paths observed | PARTIAL: all modes enumerate; active 60 Hz observed | Exercise mode changes, app overrides, AOD and sustained rendering; MTR-018 blocks UDFPS ordering acceptance. |
| HDR | HDR10, HLG and Dolby Vision types exposed; protected buffers supported | UNKNOWN | UNKNOWN | Play verified HDR content and measure mode, brightness and tone mapping. |
| Manual/automatic brightness | Goodix front ALS; stock lux/backlight maps | PARTIAL: manual UI use | PARTIAL: ALS registered but emitted no event in stationary 15 s probe | Light/dark transitions, sunlight/HBM, minimum brightness, AOD and thermal clamping. |
| Capacitive touch | FocalTech `fts_ts`, 10 slots, 1260x2800 range | PARTIAL: normal UI use | PARTIAL: ADB-driven UI does not validate the panel | Full-panel drawing, ten-point multitouch, edges, latency, wet/glove/pocket rejection. |
| Touch while charging | Touch charger flag controlled by charging HAL | UNKNOWN | UNKNOWN | Wired/wireless charging interaction and false-touch testing. |
| AOD / doze | Framework and UDFPS doze paths present | PARTIAL | PARTIAL | Long AOD, burn-in movement, notifications, proximity/pocket behavior and UDFPS. |

## Cameras

Physical modules are rear OV50H wide, rear S5KJN1 ultra-wide, rear S5KJN5
telephoto and front S5KJN1. Logical SAT exposes 0.6x, 1x and 3x lens points.

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| Camera2 maximum-JPEG capture, exposed IDs 0-4 | UNKNOWN | PARTIAL: coherent-r28 sweep captured fresh valid 12 MP JPEGs from all five IDs; provider PID 1381 stayed stable and the tombstone inventory did not change | Validate image content, focus, exposure and physical-ID mapping. |
| Aperture preview and ordinary stills | PARTIAL | PARTIAL on r35: preview exercised multi-camera processing with stable service PIDs and no Mapper5/GWP-ASan/tombstone; automated capture did not produce a trustworthy finalized still | Repeat front/rear and every physical lens on installed system APK and verify finalized files. |
| FHD30 video and flip | PARTIAL: temporary APK finalized 1920x1080/30, route `4 -> 1 -> 4` | PASS on r44: ten system-Aperture cycles finalize H.264/AAC 1920x1080/30 with route `4 -> 1 -> 4`; camera PIDs and crash gates remain stable | Visual content/focus/exposure and sustained thermal run. |
| FHD60 video and flip | PARTIAL: temporary APK finalized 1920x1080/60, route `0 -> 1 -> 0` | PASS on r44: ten system-Aperture cycles finalize true parsed 1920x1080/60 with route `0 -> 1 -> 0`; no Mapper5/GWP-ASan/fatal evidence | Visual cadence/content and sustained thermal run. |
| UHD30 video and flip | PARTIAL: temporary APK finalized 3840x2160/30, route `0 -> 1 -> 0` | PASS on r44: ten system-Aperture cycles finalize H.264/AAC 3840x2160/30 with route `0 -> 1 -> 0`; no crash/tombstone/pstore/AVC delta | Visual content and long zoom/thermal clip. |
| Stabilization/EIS | FAIL: intentionally disabled to avoid Morpho crash path | FAIL: feature remains disabled | MTR-012 walking/panning, crop, cadence and zoom matrix before enabling. |
| SAT zoom and lens transitions | UNKNOWN | PARTIAL: coherent-r22 Camera2 sweep passed 0.6x/1x/3x/10x | UI transitions, focus/exposure continuity and intermediate zoom. |
| Zoom while recording | UNKNOWN | PARTIAL: coherent-r22 1080p Camera2 clip applied 1x -> 3x without provider failure | FHD30/FHD60/UHD30 through Aperture across valid lenses. |
| Flash / torch / front screen flash | UNKNOWN | PARTIAL: coherent-r22 Camera2 torch increased frame luma | Still/video auto flash, front screen flash and thermal cutoff. |
| Third-party Camera2/WebRTC | UNKNOWN | PARTIAL: maintained Camera2 probe passes still capture | Video call, preview, recording and concurrent-client behavior. |

## Audio and media

| Hardware / operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| Bottom speaker / stereo playback | UNKNOWN | UNKNOWN | Audible left/right, distortion, volume curve and sustained playback. |
| Earpiece | BLOCKED | BLOCKED | Physical call and routed media test. |
| Built-in microphones | UNKNOWN | UNKNOWN | Front/rear/voice-capture recording, gain, noise suppression and stereo mapping. |
| Voice-call audio | BLOCKED | BLOCKED | SIM call: handset, speaker, mute and proximity routing. |
| Media encode/decode | PARTIAL: media-quality lookup fixed; camera AVC/AAC files finalized | PARTIAL | AVC/HEVC/AV1, protected playback, seek, rotation and repeated sessions. |
| AudioFX | FAIL: MTR-025 nonexistent keepalive binding | PASS on r30 for real-session lifecycle: QTI/NXP effect chains open and close, client death removes all sessions through framework UID observation, preferences persist across reboot, and post-reboot replay passes | Audible/perceptible effect still requires listening or loopback measurement. |
| USB-C audio/headset buttons/mic | BLOCKED | BLOCKED | Compatible dongle/headset required. |
| Bluetooth A2DP/HFP/SCO | BLOCKED | BLOCKED | Headset required; include calls, microphone, volume and fallback. |
| LE Audio/LC3/HAP/BAP/Auracast | BLOCKED: services initialize only | BLOCKED | Compatible hearing/LE/broadcast hardware required. |
| Widevine DRM | UNKNOWN | PARTIAL: expected unlocked-bootloader L1 rejection; L3 needs network provisioning. ClearKey session plumbing passes | Provisioned L3 and protected playback. L1 is not an acceptance target while unlocked. |

## Haptics and physical controls

| Hardware / operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| RichTap/AW haptic device | PARTIAL: service/config initializes | PARTIAL on r35: one-shot command reached stable HAL and AW8693x driver | Perceived output, calibration and Nothing OS parity. |
| Standard effects/primitives | FAIL: effects absent, primitive durations zero, `TEXTURE_TICK` silent | PARTIAL on r35: bounded prebaked and primitive commands reached HAL/kernel; capability completeness remains unresolved | MTR-011 stock effect/primitive recovery and perceived-output sweep. |
| Amplitude/composition | UNKNOWN | UNKNOWN | API and perceived-output sweep. |
| Power key | PARTIAL: normal use | PARTIAL | Short/long press, emergency gesture and reboot combinations. |
| Volume up/down | PARTIAL: input nodes exposed | PARTIAL | Media/call/camera/recovery behavior. |
| Essential Key | PARTIAL: GPIO 250 mapped to camera/torch handler | UNKNOWN | Short/long press, screen off/on and fallback behavior. |
| Headset jack button input | UNKNOWN | UNKNOWN | Requires USB-C audio accessory. |

## Biometrics

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| Face enrollment/authentication, English | PASS | UNKNOWN | Re-run enrollment, auth and failure recovery. |
| Face guidance, non-English | FAIL: MTR-023 blank guidance | PARTIAL/PASS on r30: exact fallback wiring is installed; Spanish, Japanese and Arabic education UI renders without blank title/actions and Arabic mirrors action order; locale restoration passes | Scroll all safety/accessibility guidance, parental consent, and complete real enrollment/authentication. |
| UDFPS enrollment | UNKNOWN | PASS on r35: fresh enrollment completed with the policy and refresh-vote fixes installed; zero HAL deaths | Repeat after credential removal and exercise cancellation/retry. |
| UDFPS screen-on unlock | UNKNOWN | PARTIAL on r35: four captured fingerprint unlocks passed; credential removal later invalidated enrollment as expected | Fresh enrollment and 46 more screen-on/AOD unlocks, geometry, ripple and failed attempts. |
| UDFPS AOD unlock | UNKNOWN | UNKNOWN | 50 unlocks and proximity/pocket cases. |
| UDFPS refresh/LHBM ordering | FAIL: MTR-018 race | PARTIAL on r35: overlay-lifetime vote is installed and bounded enrollment/unlock succeeds | Retain ordering trace across the full 50-unlock matrix with Smooth Display off. |
| UDFPS while charging | UNKNOWN | UNKNOWN | Indication clearance, wired/wireless transitions and unlock. |

## Sensors

The physical sensor inventory is STMicro `lsm6dsv` IMU, MEMSIC `mmc56x3x`
magnetometer, Goodix `GLS6851C` front light/proximity, and STK `stk6a2x`
rear-light/flicker. Fused and Nothing-specific rows are software/QSH outputs.
No pressure/barometer sensor is exposed.

| Sensor / operation | Live r22 result | Remaining acceptance |
|---|---|---|
| Accelerometer, calibrated/uncalibrated | PARTIAL: delivered stationary samples | Axis/orientation, range, rate, batching and wake behavior. |
| Gyroscope, calibrated/uncalibrated | PARTIAL: delivered samples | Axis, range, rate and bias under motion. |
| Magnetometer, calibrated/uncalibrated | PARTIAL: delivered samples | Compass accuracy and calibration under rotation. |
| Front ambient light | PARTIAL: registered; no event in 15 s stationary window | Controlled lux sweep and auto-brightness response. |
| Rear ambient light | PARTIAL: delivered event | Controlled lux and camera/display consumer behavior. |
| Rear flicker | PARTIAL: delivered event | Known-frequency lighting accuracy. |
| Proximity, wake/non-wake | PARTIAL: both delivered far-state events | Near/far transitions, calls, pocket and AOD. |
| Gravity / linear acceleration | PARTIAL: delivered events | Motion accuracy. |
| Rotation/orientation/game/geomagnetic vectors | PARTIAL: rotation, game, geomagnetic and legacy orientation emitted; Nothing device-orientation did not | Physical rotation matrix and device-orientation transitions. |
| Step counters | PARTIAL: wake/non-wake counters delivered initial values | Walked count accuracy and reboot persistence. |
| Step detectors | UNKNOWN: trigger-only | Physical walking and wake delivery. |
| Significant motion | UNKNOWN: trigger-only | Motion trigger and one-shot re-arm. |
| Tilt / tilt-to-wake | UNKNOWN: trigger-only | Physical tilt, screen wake and pocket suppression. |
| Stationary / motion detect | UNKNOWN: trigger-only | Timed stationary/motion transitions and wake. |
| Screen-upward | PARTIAL: delivered state | Physical face-up/down transitions. |
| Pocket mode | PARTIAL: delivered state | Pocket insertion/removal and false positives. |
| Device posture | PARTIAL: delivered state | Full orientation/posture transitions. |
| Matrix rejection | PARTIAL: delivered state | Edge/grip rejection under touch load. |
| Horizon motion / finger-display detect | UNKNOWN: trigger-only | Physical trigger and UDFPS/display integration. |
| Ambient-light-scene | PARTIAL: registered; no stationary-window event | Controlled front-light scene changes. |
| Sensor batching/flush/direct channels | UNKNOWN | Per-sensor latency, flush and suspend delivery. |
| Nothing sensor-extension API | FAIL: MTR-016 service is disabled and undeclared | Identify real consumers and restore only with stock evidence. |
| End-to-end UI rotation | UNKNOWN | Portrait/landscape transitions, camera/media apps and lockscreen. |

## Location, cellular and secure element

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| GNSS live fix and raw measurements | PASS: retained indoor fix/raw evidence | Infrastructure only observed | Cold/warm TTFF, outdoor accuracy, screen-off, airplane mode and restart loops. |
| QCC assisted location | FAIL: MTR-015 incomplete stack | PASS infrastructure on r47: QCC runs in `vendor_qcc_app`, both AIDL services and XTRA remain alive with no linker/JNI/AVC/crash | Outdoor cold/warm TTFF remains acceptance-only. |
| Physical SIM detection | BLOCKED | PASS on external captures: slot-0 card, USIM/ISIM, subscription load and LTE home registration; both r35 slots are physically absent | Repeat on installed r35 with matching modem firmware and explicit build identity; latest external capture used mismatched baseband `...1.150609.3.152387.2`. |
| Removable eUICC active profile | BLOCKED | r44 diagnostic PASS: native slot-1 US Mobile Dark Star profile downloads, enables, registers LTE HOME and survives airplane reattach; eUICC APDU/discovery path passes | Prove the same path on the next coherent candidate without live radio-module intervention; then test profile disable/enable, reboot and deletion. |
| Cellular voice/SMS/MMS/data | BLOCKED | r44 diagnostic PASS for LTE HOME, bidirectional SMS, one 14-second VoLTE call, a firewalled 28-byte TX/28-byte RX IPv4 probe, and a 166-byte self-MMS with successful outbound and inbound provider rows. | Install the automatic APN/TIPC/default-RAT candidate and repeat without manual APN/module/ATEL steps; add IPv6/DNS and an external MMS peer. |
| US multi-carrier SIMs | BLOCKED | Dark Star diagnostic pass after selecting carrier-ID 2575 `ereseller`, live-loading matching TIPC and restoring stock mode 26 after replacement initialized GSM-only. QTI basic 5G, Android `NR_NSA`, and SystemUI 5G display pass; allocated NR bearer unproven. | Prove zero-touch Dark Star on the next candidate; test other networks independently only when required credentials are available. |
| VoLTE/VoWiFi/emergency/DSDS | BLOCKED | r44 diagnostic VoLTE pass: framework selected `ImsPhone`, the Dark Star call reached ACTIVE in about one second and ended cleanly. IMS SMS timed out once and correctly fell back to CS; inbound SMS passed after ATEL-ready recovery. | Repeat from an untouched boot on the next candidate; test inbound call/audio, IMS SMS, emergency UI, Wi-Fi Calling and DSDS separately. |
| eSIM UI/QR path | PARTIAL | Real Dark Star profile download/enable/reboot passes; disable/delete fails because the eUICC returns GSMA `catBusy` after LPA retries | MTR-031: compare same profile/card on official Nothing OS; do not repeat destructive erase attempts. |
| SIM2/eSIM hardware mux | Slot 1 supports physical SIM2 or eSIM, not both | r49 PASS locally for both QTI requests and rebooted mode transitions; same eSIM profile restores intact | Inserted physical-SIM2 subscription/data/SMS/call test remains external. |
| OMAPI/UICC secure element | BLOCKED | BLOCKED | Physical SIM/reader and applet. |

## Wi-Fi, Bluetooth, NFC and UWB

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| Wi-Fi 2.4/5 GHz | PARTIAL | UNKNOWN: enabled but disconnected during probe | Association, throughput, roaming, captive portal and suspend. |
| Wi-Fi 7 6 GHz/320 MHz | PASS: retained association/transport evidence | UNKNOWN | MLO, failover, throughput and long run. |
| Screen-off retention / PNO | PASS: bounded retention and reassociation | INCONCLUSIVE: disconnected during powered ADB idle test | Long unplugged run and repeated PNO. |
| Hotspot/tethering | UNKNOWN | UNKNOWN | 2.4/5/6 GHz clients, upstream handoff and coexistence. |
| Wi-Fi Direct | UNKNOWN | UNKNOWN | Discovery, group owner/client, transfer and coexistence. |
| Bluetooth adapter and profiles | PARTIAL: classic/LE infrastructure starts | PARTIAL: enabled; no accessory | Pairing, reconnect, HID, PAN, BLE scan/advertise/GATT. |
| NFC adapter and tag polling | PASS: toggle/tag evidence | PARTIAL/PASS on r44: 100 disable/enable cycles reach OFF/ON and retain the NFC PID with no crash/tombstone/pstore/AVC; transient ST21 `-107` remains; no tag | Tag transactions, synchronized stock transition trace and suspend/charger loops. |
| NFC HCE/payment/off-host | PARTIAL: HCE capability only | PARTIAL: services enumerate only | External reader/payment, UICC/eSE and charger transitions. |
| UWB | N/A: no UWB feature/HAL or metroid-specific fitted-device evidence | N/A | Reopen only with authoritative hardware evidence. |

## USB and external I/O

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| USB ADB transport | PASS | PASS: 16 MiB push/pull hashes matched | Cable reconnect, host variation, late HAL start and HAL restart. |
| MTP/PTP | UNKNOWN | PASS on r44 for MTP+ADB: 64 MiB GIO push/pull hashes match | Locked-state exposure, PTP and physical reconnect. |
| RNDIS tethering | UNKNOWN | FAIL on r44: correct `05c6:9024`/`rndis_host`, phone address and TetheredState form, but host DHCP and static local transport fail | Capture RNDIS IPA/GSI lifecycle and DHCP packets before source edits. |
| NCM / NCM+ADB | FAIL: MTR-019 function-name mismatch | PASS on r44 for NCM+ADB: `05c6:908c`, `cdc_ncm`, DHCP, bidirectional IPv4, host-to-phone IPv6, ADB integrity and Ethernet exclusion pass | Upstream unavailable; phone-to-host IPv6 tooling, physical reconnect and pending HAL-death fix acceptance. |
| USB OTG/host | BLOCKED | BLOCKED | Storage, HID and powered accessory required. |
| USB Ethernet/accessory networking | BLOCKED | BLOCKED | Compatible adapter; DHCP, IPv4/IPv6, suspend and unplug. |
| DisplayPort/video output | BLOCKED | BLOCKED | Compatible adapter/display required; fitted support is not yet proven. |
| USB PD/PPS | UNKNOWN | UNKNOWN | Charger/analyzer matrix, negotiation, thermal derating. |

## Battery, charging, thermal and performance

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| Battery gauge/basic wired charge | PARTIAL: bounded charge trend | PARTIAL: USB online, 100%, Full | Full discharge/charge curve, gauge accuracy and reconnect. |
| Charging-policy HAL | PARTIAL: runs Enforcing with no charge-node AVC | PARTIAL | Actual policy response, unplug/reconnect and service restart. |
| Wireless charging | PARTIAL: basic detection retained | UNKNOWN | Alignment, rates, full cycle, suspend and thermal behavior. |
| Reverse wireless charging | UNKNOWN | UNKNOWN | Enable, receiver power, timeout, low-battery and thermal cutoff. |
| Hot-battery stop/resume | UNKNOWN | UNKNOWN | Controlled safe heating/cooling matrix. |
| Thermal skin/headroom | PARTIAL: telemetry available | PARTIAL | MTR-005 controlled load, severity, cooling, display and charging mitigation. |
| CPU/performance policy | PARTIAL: WALT/performance stack available | PARTIAL | Sustained CPU load, scheduling, throttling and ADPF/boost behavior. |
| GPU compute | UNKNOWN | PARTIAL diagnostic: Adreno 825 Vulkan submission and 1024/1024 verified dwords | Repeat on a promotable candidate; GLES, sustained load, throttling and recovery. |

## Storage, security, boot and suspend

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| UFS `/data` read/write integrity | UNKNOWN | PARTIAL diagnostic: encrypted `/data` 64 MiB write/copy hashes matched | Repeat on a promotable candidate; capacity, fsck, trim, fill, random I/O and power loss. |
| File-based encryption | PASS | PASS | Recovery decrypt/format-data and fresh-install defaults. |
| SELinux | PASS: Enforcing | PASS: Enforcing | AVC review per affected operation. |
| AVB/signing/payload integrity | PASS offline/runtime boot | PASS offline and boots | Deliberate corruption/rollback behavior is destructive and untested. |
| Normal-system OTA/GApps preservation | PASS through r21 | PARTIAL: r22 applied, merged, preserved GApps and passed three coherent crash-clean boots | Repeat on the next promotable candidate. |
| Recovery sideload/rollback | PARTIAL | r47 installs successfully but legacy host still reports the recovery reboot boundary as 47%; r45 retained a real interrupted-transfer failure | r48 must prove v2 host exit 0 on success and nonzero on deliberate install failure, plus automatic target slot, two boots and encrypted-data retention. |
| Short deep suspend | PASS on prior accepted evidence | INCONCLUSIVE on r35: 14m26s USB-powered screen-off no-SIM idle retained boot/system_server and clean crash/tombstone/pstore/fatal/SSR gates, but powered ADB cannot prove deep suspend | Repeat unplugged with ADB disconnected and compare suspend/SoC counters. |
| Long idle drain | UNKNOWN | UNKNOWN | 8-hour unplugged screen-off test with subsystem wake accounting. |
| CPUSS residency accounting | N/A: optional Qualcomm debugfs interface, not a functional compatibility requirement | No stock-vs-Lineage divergence established | Reopen only if matching stock runtime proves counters bind and advance. |
| Crash/tombstone health | PASS: empty crash buffer, no new tombstone | FAIL on coherent r50: no new native tombstone or pstore, but proprietary GMS repeatedly crashes on Password Checkup `SERVICE_INVALID` with both updated and pinned-base GMS; MTR-026 has no eligible Lineage fix | Require two controlled boots with a clean crash buffer; reject promotion if MTR-026 repeats. |
| Hardware keystore / TEE / StrongBox | UNKNOWN | UNKNOWN | Key generation, attestation, authentication binding, reboot persistence and deletion. |
| Removable storage | N/A: no removable-storage slot exposed | N/A | None. USB OTG storage is covered separately. |
| SIM tray mechanics/hotplug | BLOCKED | BLOCKED | Physical SIM insertion/removal and tray-slot mapping. |

## Glyph and lights

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| Glyph hardware/segments | UNKNOWN | UNKNOWN | Segment map, brightness, composer, notifications and concurrent patterns. |
| Notification/charging Glyph behavior | UNKNOWN | UNKNOWN | Wired/wireless/full/error states and DND. |
| Rear camera flash/torch | UNKNOWN | UNKNOWN | Brightness, timeout, Essential Key and camera interaction. |
| Screen/indicator behavior | PARTIAL | PARTIAL | Charging, low battery, notifications and accessibility patterns. |

## Immediate closure order

1. Keep MTR-026 as a blocking Google add-on compatibility gate and MTR-027 as an
   externally blocked certification gate; require a clean crash buffer on every
   promotable successor candidate.
2. Run the safety-critical unplugged thermal/charging matrix and unplugged suspend.
3. Complete installed-system Aperture routing, lens, zoom, flash and EIS acceptance.
4. Localize physical-SIM UICC/subscription failure, then fix UDFPS ordering,
   haptic capability advertising, NFC transition errors and CPUSS accounting.
5. Execute physical SIM/eSIM, Bluetooth/USB audio, PD/PPS, wireless/reverse
   charging, NFC payment/off-host and external-I/O rows when hardware is available.
