# Hardware acceptance matrix

This is the canonical inventory and functional acceptance ledger for Nothing
Phone (3) (`metroid`). `BASELINE.md` identifies the accepted release;
`BUGS.md` owns defects. This file answers whether each hardware operation has
actually been exercised.

## Status rules

| Status | Meaning |
|---|---|
| PASS | The real operation passed on the named build with retained evidence. |
| PARTIAL | A bounded subset passed; the row names the missing modes. |
| FAIL | A real operation has a reproduced defect. |
| BLOCKED | Required hardware, credentials, carrier service, or physical action is unavailable. |
| UNKNOWN | No functional result. Enumeration, a Binder service, or absence of a bug is not a pass. |
| N/A | The inventory shows that the device does not expose this hardware. |

Rows without a specific r21 result are not accepted-release claims. Live r28
observations are installed diagnostic evidence only until a complete release gate
passes.

## Tested configurations

| Name | Build / slot | State |
|---|---|---|
| Accepted baseline | r21 `23.0-20260808`, OTA `e26956f003ceea3923d847515e2943dc8bbf4505533cbae726d36bc167f968db`, slot A | Enforcing, encrypted, two boots, empty crash buffer; accepted |
| Latest live state | coherent r28 `23.0-20260813`, slot B | Enforcing and encrypted across two boots; NCM and bounded init cleanup pass; Play Store storefront blocked as Play Protect uncertified (MTR-027); not accepted |

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
| Aperture preview and ordinary stills | PARTIAL | PARTIAL | Repeat front/rear and every physical lens on installed system APK. |
| FHD30 video and flip | PARTIAL: temporary APK finalized 1920x1080/30, route `4 -> 1 -> 4` | PARTIAL: coherent-r28 probe finalized a short MP4 while applying 1x -> 3x zoom; provider stayed stable and no tombstone changed | Validate Aperture UI route/flip, audio, cadence and process restart. |
| FHD60 video and flip | PARTIAL: temporary APK finalized 1920x1080/60, route `0 -> 1 -> 0` | PARTIAL diagnostic: r22 `/product` APK routes `0 -> 1 -> 0` in mixed boot state | Repeat on a coherent candidate and finalize a fresh clip plus thermal/cadence run. |
| UHD30 video and flip | PARTIAL: temporary APK finalized 3840x2160/30, route `0 -> 1 -> 0` | PARTIAL diagnostic: r22 `/product` APK routes `0 -> 1 -> 0` and finalized a 3840x2160/30 H.264/AAC clip in mixed boot state; provider stayed PID 1377 and no tombstone changed | Repeat on a coherent candidate; long clip, zoom and thermal run. |
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
| AudioFX | FAIL: MTR-025 nonexistent keepalive binding | PARTIAL on r28: AudioFX process and operational session service survive playback/client restart with no observed crash or bind-failure loop; inert keepalive binding, audible effect and persistence remain unproven | Test exact keepalive binding, perceptible effect, persistence and reboot. |
| USB-C audio/headset buttons/mic | BLOCKED | BLOCKED | Compatible dongle/headset required. |
| Bluetooth A2DP/HFP/SCO | BLOCKED | BLOCKED | Headset required; include calls, microphone, volume and fallback. |
| LE Audio/LC3/HAP/BAP/Auracast | BLOCKED: services initialize only | BLOCKED | Compatible hearing/LE/broadcast hardware required. |
| Widevine DRM | UNKNOWN | PARTIAL: expected unlocked-bootloader L1 rejection; L3 needs network provisioning. ClearKey session plumbing passes | Provisioned L3 and protected playback. L1 is not an acceptance target while unlocked. |

## Haptics and physical controls

| Hardware / operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| RichTap/AW haptic device | PARTIAL: service/config initializes | PARTIAL | Perceived output, calibration and Nothing OS parity. |
| Standard effects/primitives | FAIL: effects absent, primitive durations zero, `TEXTURE_TICK` silent | FAIL | MTR-011 stock effect/primitive recovery. |
| Amplitude/composition | UNKNOWN | UNKNOWN | API and perceived-output sweep. |
| Power key | PARTIAL: normal use | PARTIAL | Short/long press, emergency gesture and reboot combinations. |
| Volume up/down | PARTIAL: input nodes exposed | PARTIAL | Media/call/camera/recovery behavior. |
| Essential Key | PARTIAL: GPIO 250 mapped to camera/torch handler | UNKNOWN | Short/long press, screen off/on and fallback behavior. |
| Headset jack button input | UNKNOWN | UNKNOWN | Requires USB-C audio accessory. |

## Biometrics

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| Face enrollment/authentication, English | PASS | UNKNOWN | Re-run enrollment, auth and failure recovery. |
| Face guidance, non-English | FAIL: MTR-023 blank guidance | FAIL | Latin, CJK and RTL locale-safe fallback. |
| UDFPS enrollment | UNKNOWN | UNKNOWN | Fresh two-stage enrollment and cancellation/retry. |
| UDFPS screen-on unlock | UNKNOWN | UNKNOWN | 50 unlocks, geometry, ripple and failed attempts. |
| UDFPS AOD unlock | UNKNOWN | UNKNOWN | 50 unlocks and proximity/pocket cases. |
| UDFPS refresh/LHBM ordering | FAIL: MTR-018 race | FAIL | Require 120 Hz before pointer/LHBM notification. |
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
| QCC assisted location | FAIL: MTR-015 incomplete stack | FAIL | Restore coherent stack or remove clients; compare TTFF. |
| Physical SIM detection | BLOCKED | PASS on fresh-wipe r24 XDA capture: slot-0 card, USIM/ISIM and subscription load; no SIM is present in the maintainer target | Repeat on r29 with matching modem firmware and capture slot recovery. |
| Removable eUICC active profile | BLOCKED | PARTIAL/FAIL on historical early build: eUICC/EID, subscription, LTE and bidirectional SMS pass; profile refresh/embedded metadata and data fail | Repeat active-profile, management and coexistence tests on r29. |
| Cellular voice/SMS/MMS/data | BLOCKED | PARTIAL/FAIL on fresh-wipe r24 physical SIM and an earlier removable eUICC: LTE and SMS pass, but independent data profiles receive modem `0x1004`; r29 remains uninstalled | Test data, SMS/MMS and calls on r29 with matching modem firmware. |
| VoLTE/VoWiFi/emergency/DSDS | BLOCKED | FAIL/PARTIAL on r28; stock QTI phone services are built for successor | Validate MMTEL registration, calls, SMS, two SIMs and handover. |
| eSIM UI/QR path | PASS through QR scanner | PARTIAL: external removable eUICC proves active-profile use, not native download; profile refresh fails | Real profile credentials: download, enable, reboot, delete and transfer. |
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
| NFC adapter and tag polling | PASS: toggle/tag evidence | PARTIAL: adapter on; no tag | MTR-024 100-toggle loop, tag transactions and suspend. |
| NFC HCE/payment/off-host | PARTIAL: HCE capability only | PARTIAL: services enumerate only | External reader/payment, UICC/eSE and charger transitions. |
| UWB | N/A: no UWB feature/HAL or metroid-specific fitted-device evidence | N/A | Reopen only with authoritative hardware evidence. |

## USB and external I/O

| Operation | r21 | Live r22 | Remaining acceptance |
|---|---|---|---|
| USB ADB transport | PASS | PASS: 16 MiB push/pull hashes matched | Cable reconnect, host variation, late HAL start and HAL restart. |
| MTP/PTP | UNKNOWN | UNKNOWN | File transfer, large files, reconnect and locked state. |
| RNDIS tethering | UNKNOWN | UNKNOWN | IPv4/IPv6 transport and reconnect. |
| NCM / NCM+ADB | FAIL: MTR-019 function-name mismatch | PARTIAL/PASS on r28: `05c6:908c`, `cdc_ncm`, DHCP/DNS, IPv4 and HTTPS through `usb0`; standalone NCM enumerates, then plain ADB restores after gadget reset | Cable reconnect, HAL restart, standalone traffic, MTP/PTP/RNDIS and host variation remain. |
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
| Recovery sideload/rollback | PARTIAL | PARTIAL: successful installs may show near 47% host progress by upstream design; no retained incomplete install | MTR-028 requires recovery final status, automatic target slot, update/merge state, two coherent boots and encrypted-data retention; rejected-slot rollback remains untested. |
| Short deep suspend | PASS on prior accepted evidence | INCONCLUSIVE: powered ADB 180 s gate recorded `success 0 -> 0`; no kernel failure and no framework wakelock | Repeat unplugged with ADB disconnected and compare suspend/SoC counters. |
| Long idle drain | UNKNOWN | UNKNOWN | 8-hour unplugged screen-off test with subsystem wake accounting. |
| CPUSS residency accounting | FAIL: MTR-020 wrong register | FAIL | Correct from stock evidence and verify across suspend. |
| Crash/tombstone health | PASS: empty crash buffer, no new tombstone | PASS diagnostic: three coherent-r22 boots produced zero GMS fatalities and no new tombstone; MTR-026 cleared | Repeat on the next promotable installed candidate. |
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

1. Preserve the cleared MTR-026 crash gate and externally blocked MTR-027
   certification gate on every promotable successor candidate.
2. Run the safety-critical unplugged thermal/charging matrix and unplugged suspend.
3. Complete installed-system Aperture routing, lens, zoom, flash and EIS acceptance.
4. Localize physical-SIM UICC/subscription failure, then fix UDFPS ordering,
   haptic capability advertising, NFC transition errors and CPUSS accounting.
5. Execute physical SIM/eSIM, Bluetooth/USB audio, PD/PPS, wireless/reverse
   charging, NFC payment/off-host and external-I/O rows when hardware is available.
