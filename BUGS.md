# Metroid bug backlog

Last audited: 2026-08-05

Installed build: `23.0-20260805-UNOFFICIAL-metroid`

Installed OTA SHA-256:
`d052d13c16f008f8ea80118f598f8fa7cefdcad6b1d6ef82590e63c7ec324c3c`

This is the authoritative maintainer backlog. A confirmed issue has installed-
device or accepted-image evidence and a deterministic source/configuration cause.
A latent issue has a deterministic defect but no retained user-visible failure.
A test gap is not a bug claim.

Evidence paths are workspace-relative. Source paths are relative to `lineage/`.

## P0: release and core-function blockers

### MTR-001: QTI radio extension services are rejected by VINTF

- Severity: critical
- Status: confirmed
- Impact: IMS, IWLAN, eSIM/LPA, QTI call-audio control, vendor radio
  configuration, SAP, and advanced UICC/data paths cannot register.
- Runtime: `diagnostics/ota_20260805_perf_walt/second-boot-dmesg.txt:6310-6377`
- Source: `vendor/nothing/metroid/proprietary/vendor/etc/init/qcrilNrd.rc:5-46`
- Cause: `device.mk:264-271` installs only selected AOSP radio fragments; the
  exact stock standalone declarations for the served QTI interfaces are absent.
- Fix direction: package only declarations for interfaces observed attempting
  registration. Do not import the aggregate stock manifest blindly.
- Acceptance: `check-vintf-all`; zero relevant registration denials across two
  boots and qcrild restart; physical-SIM call, SMS, data, IMS, IWLAN, call-audio,
  DSDS, airplane-mode, and suspend tests.
- Dependencies: root blocker for MTR-002 and MTR-003.

### MTR-002: Android IMS implementation is absent

- Severity: critical
- Status: confirmed
- Impact: VoLTE, VoWiFi, IMS SMS, supplementary services, IMS handover, and IMS
  emergency MMTEL cannot work.
- Runtime: `diagnostics/final_bug_audit_20260805/radio-private.txt:55-56` and
  `diagnostics/final_bug_audit_20260805/logcat-private.txt:1295-1317`
- Source: `packages/services/Telephony/res/values/config.xml:237-241`
- Cause: no compatible `org.codeaurora.ims` package is installed and the default
  MMTEL package is not selected by a metroid Telephony overlay.
- Fix direction: package the compatible stock IMS stack and dependencies, select
  it for MMTEL, and restore the served IMS radio declarations from MTR-001.
- Acceptance: both slots bind and register MMTEL; VoLTE/VoWiFi, IMS SMS,
  incoming/outgoing audio, and LTE/Wi-Fi handover pass with a carrier SIM.

### MTR-003: eSIM is advertised without an LPA or usable eUICC backend

- Severity: high
- Status: confirmed
- Impact: eSIM discovery, download, activation, deletion, and settings do not
  work even though applications see the eUICC hardware feature.
- Runtime: `diagnostics/final_bug_audit_20260805/radio-private.txt:26-30,56`
- Source: `proprietary-files.txt:6`
- Cause: no valid `EuiccService`/LPA is installed and qcrild LPA interfaces are
  rejected by MTR-001.
- Fix direction: either remove the eUICC feature until support exists, or package
  a legally distributable LPA/UI with all dependencies and served declarations.
- Acceptance: `EuiccManager.isEnabled()`, EID discovery, profile download,
  enable/disable, reboot persistence, deletion, and physical-SIM coexistence.

### MTR-004: Android Power HAL cannot register

- Severity: high
- Status: confirmed
- Impact: framework and SurfaceFlinger lack the device power-mode, boost, and
  ADPF implementation.
- Runtime: `diagnostics/final_bug_audit_20260805/power-thermal-private.txt:8-14`
- Source: `device.mk:264-271`
- Cause: the stock-equivalent `android.hardware.power.IPower/default` declaration
  is not installed, although the vendor power process runs.
- Fix direction: install a standalone stock-matching Power AIDL VINTF fragment.
- Acceptance: service registration, Power AIDL VTS, interaction/launch/camera
  boosts, sustained ADPF sessions, WALT tracing, and suspend regression.
- Note: independent of the accepted perf/WALT SELinux fix.

### MTR-005: framework thermal policy has no skin sensor or headroom

- Severity: high
- Status: confirmed
- Impact: framework thermal status, headroom, display mitigation, and scheduler
  consumers are blind to enclosure temperature. Kernel and proprietary thermal
  protection still operate, so this is not total thermal-protection loss.
- Runtime: `diagnostics/final_bug_audit_20260805/power-thermal-private.txt:25-115`
- Source: `hardware/qcom-caf/thermal/thermalConfig.cpp:2487-2501`
- Cause: tuna maps skin to nonexistent `sys-therm-3`; the kernel exposes Nothing
  shell sensors instead.
- Fix direction: restore the compatible stock Thermal HAL or recover the exact
  shell sensor mapping and thresholds. Do not guess thresholds.
- Acceptance: live `TYPE_SKIN`, non-NaN headroom, controlled thermal-status and
  cooling transitions, display mitigation, and charging interaction.

### MTR-006: launch API metadata incorrectly identifies Android 16 hardware

- Severity: high
- Status: confirmed configuration defect
- Impact: compatibility, VSR, permission, and security behavior can be selected
  for an Android 16-launch device instead of the stock Android 15 launch level.
- Runtime: `diagnostics/final_bug_audit_20260805/security-metadata.txt:1-3`
- Source: `lineage_metroid.mk:25`
- Cause: `PRODUCT_SHIPPING_API_LEVEL := 36`; stock evidence records API 35 and
  board API `202404`.
- Fix direction: restore stock-matching first/board API metadata.
- Acceptance: install-clean build, VINTF and CTS-focused checks, factory reset,
  permissions, setup, and broad application regression.

### MTR-007: security-patch metadata is stale and incomplete

- Severity: high
- Status: confirmed
- Impact: the August build reports platform SPL `2026-02-01`, while vendor and
  boot SPL values are blank. Stock baseline evidence is newer.
- Runtime: `diagnostics/final_bug_audit_20260805/security-metadata.txt:4-6`
- Source: `vendor/lineage/release/flag_values/bp2a/RELEASE_PLATFORM_SECURITY_PATCH.textproto:1-4`
- Fix direction: integrate available fixes and declare honest platform, vendor,
  boot, and rollback-index levels; never advance metadata beyond incorporated code.
- Acceptance: patch provenance/CVE ledger plus consistent build properties and
  AVB rollback indexes.

### MTR-008: accepted release records and bootstrap artifacts are inconsistent

- Severity: high
- Status: confirmed maintainer/release defect
- Impact: users and maintainers can select the wrong OTA, source lock, recovery
  image set, or checksum record; the accepted build is not reproducible from a
  complete pinned manifest.
- Evidence: `releases/current/VERIFICATION.txt:2-6` still names the August 4 OTA,
  while `BASELINE.md:5-10` names the accepted August 5 OTA.
- Cause: `releases/current`, install documentation, lock files, source capture,
  and recovery bootstrap were not updated atomically.
- Fix direction: generate one immutable payload-derived bootstrap bundle; align
  current artifact, hashes, lock, manifest, install guide, and reachable commits.
- Acceptance: one consistency audit proves every canonical record names the same
  ZIP/hash/revisions and a clean checkout reproduces target-files.

## P1: confirmed subsystem defects

### MTR-009: Nothing charging-policy HAL is disabled and undeclared

- Severity: high
- Status: confirmed
- Impact: basic USB/wireless charging works, but Nothing current voting,
  shell-temperature derating, abnormal handling, and reverse-wireless policy are
  unavailable.
- Runtime: `diagnostics/final_bug_audit_20260805/service-health.txt:2`
- Source: `vendor/nothing/metroid/proprietary/vendor/etc/init/vendor.noth.hardware.charge-service.rc:1-7`
- Cause: duplicate `disabled` directives and no active ICharge VINTF fragment.
- Fix direction: verify the intended stock binary, then restore the stock RC and
  standalone fragment.
- Acceptance: low-SOC USB PD/PPS and wireless curves, screen on/off, thermal
  derating, stop/resume, suspend, reverse charging, and abnormal temperatures.
- Dependency: validate together with MTR-005.

### MTR-010: LE Audio profile family is explicitly disabled

- Severity: high
- Status: confirmed configuration defect
- Impact: unicast, broadcast, VCP, CSIP, HAP, MCP, and CCP cannot start.
- Runtime: `diagnostics/final_bug_audit_20260805/bluetooth-profile-properties.txt:1-9`
- Source: `product.prop:12-29`
- Cause: effective product properties disable the profile family despite stock
  enabling it and the audio policy containing LC3 routes.
- Fix direction: enable supported profiles in the product property layer and
  handle any persisted hearing-aid flag migration.
- Acceptance: real LC3 earbuds for playback, microphone, calls, volume/set
  coordination, broadcast, reconnect, suspend, and A2DP fallback.

### MTR-011: standard Android haptic capabilities are degraded

- Severity: medium
- Status: confirmed
- Impact: applications receive fallback pulses or no output for standard effects
  even though the proprietary RichTap path initializes.
- Runtime: `diagnostics/final_bug_audit_20260805/bluetooth-haptics-private.txt:53-69`
  and `diagnostics/post_ota_sweep_20260805_0026/camera-biometrics-haptics.txt:23741`
- Source: `vendor/qcom/opensource/vibrator/aidl/HapticsPolicy.xml:43-55`
- Cause: no prebaked effects are advertised and all primitives report zero
  duration; `TEXTURE_TICK` is dropped as unsupported.
- Fix direction: map framework effects/compositions onto a working vendor path,
  or advertise only real capabilities with explicit fallbacks.
- Acceptance: every advertised effect, primitive, composition, amplitude level,
  keyboard, launcher, biometric, charging, notification, and stock comparison.

### MTR-012: Aperture stabilization setting is a no-op on metroid

- Severity: high
- Status: confirmed
- Impact: all Aperture video requests disable stabilization while the user-facing
  preference remains available.
- Source: `packages/apps/Aperture/app/src/main/java/org/lineageos/aperture/viewmodels/CameraViewModel.kt:1776-1785`
- Cause: a device conditional unconditionally forces stabilization off.
- Fix direction: hide the setting immediately; restore EIS only for a measured
  mode/camera matrix that avoids the known Morpho crash path.
- Acceptance: walking/panning FHD30, FHD60, and UHD30 clips; request/result
  metadata, crop, cadence, zoom transitions, provider PID, and tombstones.

### MTR-013: media quality lookup loops and produces continuous AVCs

- Severity: medium
- Status: confirmed
- Impact: every codec session repeatedly looks up an absent service, logs
  `Media Quality Service not found`, and generates SELinux denials.
- Runtime: `diagnostics/final_bug_audit_20260805/logcat-private.txt:12945-22617`
  and `diagnostics/final_bug_audit_20260805/dmesg-private.txt:3032-10485`
- Source: `frameworks/av/media/libstagefright/MediaCodec.cpp:2094-2104`
- Fix direction: resolve upstream by gating the lookup when the handheld service
  is absent and using correct system-service semantics. Do not add policy for a
  nonexistent service.
- Acceptance: repeated AVC/HEVC playback and recording with no lookup loop, AVC,
  or codec regression.

### MTR-014: GNSS cannot set its value-added-process property

- Severity: medium
- Status: confirmed policy defect
- Impact: core GNSS fixes work, but enhanced IZat/PPE/DRE process selection may
  remain disabled.
- Runtime: `diagnostics/final_bug_audit_20260805/logcat-private.txt:196`
- Source: `sepolicy/vendor/enforcing.te:123-128`
- Cause: raw property-socket file access was granted instead of typed `set_prop`.
- Fix direction: trace the exact property and grant only
  `set_prop(vendor_hal_gnss_qti, vendor_location_prop)` if stock confirms it.
- Acceptance: no property AVC, expected property populated, cold TTFF, raw
  measurements, restart, airplane mode, and screen-off GNSS.

### MTR-015: QCC location assistance stack is incomplete

- Severity: medium
- Status: confirmed integration defect
- Impact: GNSS fixes work, but assistance/correction behavior can degrade during
  cold starts or network transitions; XTRA retries an unavailable QCC service.
- Runtime: `diagnostics/final_bug_audit_20260805/service-health.txt:5,8`
- Source: `vendor/nothing/metroid/proprietary/vendor/etc/init/init.qccvendor.rc:17-21`
- Fix direction: restore the coherent vendor/system QCC stack and declarations,
  or remove the clients and dangling RCs together.
- Acceptance: no retry loop; cold/warm TTFF and raw measurements with network
  on/off and screen-off GNSS.

### MTR-016: OEM sensor-extension service is disabled and undeclared

- Severity: medium
- Status: confirmed integration defect
- Impact: normal SSC sensors work, but Nothing-specific sensor/display/UDFPS
  coordination APIs are unavailable.
- Runtime: `diagnostics/final_bug_audit_20260805/service-health.txt:3`
- Source: `vendor/nothing/metroid/proprietary/vendor/etc/init/vendor.noth.hardware.sensor.sensor_extension-service.rc:1-7`
- Fix direction: restore only after identifying actual framework consumers and
  validating the intended stock binary and standalone fragment.
- Acceptance: extension API, pocket/posture/orientation, UDFPS/display
  coordination, batching, wake-up delivery, suspend, and HAL restart.

### MTR-017: post-OTA care-map verification did not run

- Severity: high
- Status: confirmed release-path defect
- Impact: the target slot was accepted without the intended first-boot block
  verification pass. AVB still protects mounted partitions.
- Runtime: `diagnostics/ota_20260805_perf_walt/first-boot-dmesg.txt:4914-4917`
  and `first-boot-logcat.txt:14850`
- Cause: `/data/ota_package/care_map.pb` was absent after recovery sideload.
- Fix direction: trace recovery/update-engine handoff and require care-map
  presence before accepting a candidate.
- Acceptance: `VerifyPartitions()` completes before slot success; authorized
  corruption testing proves rejection/fallback.

## P2: latent defects and cleanup

### MTR-018: UDFPS refresh vote occurs after pointer-down notification

- Severity: high
- Status: latent deterministic race
- Impact: LHBM authentication can fail if the panel begins at 60 Hz.
- Runtime evidence: `diagnostics/post_ota_sweep_20260805_0026/sensors-display-input.txt:556,1139-1141,1993`
- Source: `frameworks/base/packages/SystemUI/src/com/android/systemui/biometrics/UdfpsController.java:1059-1075`
- Fix direction: hold the maximum-refresh vote for the overlay lifetime before
  accepting touch; an immediate asynchronous reorder alone may still race.
- Acceptance: Smooth Display off; 50 screen-on/AOD unlocks and enrollment with
  120 Hz active before LHBM and zero `fps not equal 120`.

### MTR-019: USB NCM function name disagrees with gadget HAL

- Severity: medium
- Status: latent deterministic defect
- Impact: NCM and NCM+ADB requests cannot link or enumerate.
- Source: vendor init creates `ncm.0` at
  `vendor/nothing/metroid/proprietary/vendor/etc/init/hw/init.qcom.usb.rc:78-86`,
  while `vendor/qcom/opensource/usb/hal/UsbGadget.cpp:225-226` links `ncm.gs6`.
- Fix direction: align the device configfs function or make the HAL instance
  device-configurable.
- Acceptance: NCM/NCM+ADB host enumeration, DHCP/DNS, IPv4/IPv6 traffic, cable
  reconnect, HAL restart, and ADB/MTP/RNDIS regressions.

### MTR-020: CPUSS sleep-residency counter uses a non-stock register address

- Severity: medium
- Status: confirmed observability defect
- Impact: suspend works, but CPU/cluster low-power residency accounting is absent.
- Runtime: `diagnostics/ota_20260805_perf_walt/second-boot-dmesg.txt:2446`
- Source: `kernel/nothing/sm8735/arch/arm64/boot/dts/vendor/qcom/tuna.dtsi:1790-1802`
- Fix direction: reconcile active `0x178a0098` with stock `0x178b0098` after
  restoring reproducible kernel staging.
- Acceptance: successful probe and counters increasing over repeated suspend.

### MTR-021: inherited init inventory contains dangling services and invalid work

- Severity: medium
- Status: confirmed cleanup/integration defect
- Impact: normal boot attempts missing executables and imports, obscuring real
  failures and advertising unavailable QSPA, CHRE, QCC, factory, and helper paths.
- Runtime: `diagnostics/post_ota_sweep_20260805_0026/init-service-static-audit.txt:21-91`
- Source: `rootdir/etc/init.qcom.rc:506-517` and inherited vendor RC inventory.
- Fix direction: remove unreachable declarations or restore complete features;
  do not duplicate MTR-001, MTR-015, or MTR-016 as separate symptoms.
- Acceptance: zero unapproved normal-boot references to missing executables or
  imports across static audit and two boots.

### MTR-022: Aperture camera flip bypasses metroid video routing

- Severity: medium
- Status: latent deterministic defect
- Impact: a front-to-back flip can reopen logical camera 4 while UHD or 60 fps is
  selected instead of the required physical main camera.
- Source: `packages/apps/Aperture/app/src/main/java/org/lineageos/aperture/viewmodels/CameraViewModel.kt:1255-1278`
- Fix direction: route the selected back camera through the same metroid video
  camera selector used by normal quality/mode changes.
- Acceptance: front/back/front transitions at FHD30, FHD60, and UHD30 before
  recording and after process restart; verify camera ID and finalized files.

### MTR-023: face-enrollment guidance is blank outside English

- Severity: medium
- Status: confirmed resource defect
- Impact: safety, education, and accessibility guidance supplied by the device
  overlay disappears under locales that ship explicit empty Settings strings.
- Source: device English overlay at
  `overlay/packages/apps/Settings/res/values/strings.xml:3-18`; representative
  empty locale values at `packages/apps/Settings/res-product/values-es/strings.xml:58-65`.
- Fix direction: implement a locale-safe upstream fallback or real translations.
  Do not label English text as translated content.
- Acceptance: complete enrollment in representative Latin, CJK, and RTL locales;
  all actionable safety/accessibility guidance is visible and appropriate.

### MTR-024: ST21 NFC transport repeatedly returns `ENOTCONN`

- Severity: medium
- Status: probable runtime defect
- Impact: tag polling and initialization pass, but payment, HCE, and off-host
  reliability remain at risk during NFC power transitions.
- Runtime: `diagnostics/ota_20260805_pno-nfc-uicc/nfc-toggle-valid-logcat.txt:2443-2455,2801-2822`
- Cause: unresolved; the unpublished driver appears stock-identical, so timing,
  GPIO, power, and IRQ behavior must be compared before changing code.
- Fix direction: reproduce against synchronized Lineage/stock transition traces.
- Acceptance: 100 toggles plus tag, HCE, payment, suspend, and charger-transition
  loops with no user-visible failure or recurring transport error.

### MTR-025: AudioFX framework binding targets a nonexistent service

- Severity: medium
- Status: confirmed integration defect
- Impact: audio sessions repeatedly fail to bind the MusicFX keepalive service;
  effect lifecycle and persistence may be unreliable.
- Runtime: `diagnostics/ota_20260805_perf_walt/perf-functional-logcat.txt:6125,6225,6272`
- Source: framework binding at
  `frameworks/base/services/core/java/com/android/server/audio/MusicFxHelper.java:64-67,103-118`
  does not match the installed `packages/apps/AudioFX/AndroidManifest.xml:67-88`.
- Fix direction: align package/service discovery with the installed AudioFX
  implementation instead of repeatedly binding a nonexistent component.
- Acceptance: effect open/close, playback, client death, reboot persistence, and
  no bind failures.

## Acceptance gaps

These are not active bug claims:

1. Physical SIM: calls, SMS/MMS, data, APNs, SIM PIN/PUK, IMS, emergency test
   routing, slot switching, DSDS, handover, airplane mode, and suspend.
2. UICC OMAPI: physical readers, channels, APDUs, access rules, removal, and DSDS.
3. Fingerprint: fresh two-stage enrollment and at least 20 successful screen-on
   and AOD unlocks on the final geometry.
4. Bluetooth: Classic A2DP/HFP/SCO, HID, PAN, BLE scan/advertise/GATT, and real LE
   Audio accessories after MTR-010.
5. USB: MTP file operations, RNDIS/NCM tethering, USB-C playback/microphone/buttons.
6. NFC: `HostApduService`, external reader, authorized payment-terminal
   transaction, off-host routing, and physical-SIM secure element.
7. Wi-Fi: controlled roaming, simultaneous multi-link MLO with AP-side proof,
   independent link failover, and long-run PNO cycles.
8. Camera/display: third-party Camera2/WebRTC, EIS matrix, front/back UHD/60 flip,
   HDR playback, refresh/brightness/touch interaction matrix.
9. Power: long-duration unplugged percentage drain, reverse wireless charging,
   and full charge-current/thermal curves.
10. Destructive release tests: factory reset, Setup Wizard/FBE defaults, recovery
    decrypt/format-data, rollback/corruption handling, and protected DRM playback.

## Closed in installed baseline

- Wi-Fi 7 6 GHz/320 MHz association, transport, screen-off retention, and PNO
  reassociation.
- NFC clean-state bootstrap, toggle, card polling, and HCE routing capability.
- Face enrollment/authentication and English guidance.
- GNSS raw measurements and indoor satellite fix.
- Perf HAL WALT access without the prior AVC.
- Wireless charging detection and short unplugged auto-suspend with blockers
  released.
