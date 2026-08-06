# Metroid bug backlog

Last audited: 2026-08-06

Installed build: `23.0-20260806-UNOFFICIAL-metroid`

Installed OTA SHA-256:
`22e98f31182daa6e0645af48d64b7f7617aedf8b180250815759171436b260df`

This is the authoritative maintainer backlog. A confirmed issue has installed-
device or accepted-image evidence and a deterministic source/configuration cause.
A latent issue has a deterministic defect but no retained user-visible failure.
A test gap is not a bug claim.

Detailed runtime evidence is retained privately because raw device logs contain
sensitive identifiers. Source paths are relative to `lineage/`. Any proprietary
component mentioned below must be user-extracted or have explicit redistribution
permission; it must never be committed to this public repository.

## P0: release and core-function blockers

### MTR-001: QTI radio extension services are rejected by VINTF

- Severity: critical
- Status: resolved for IMS/radio registration on r4; physical-SIM endurance
  acceptance pending
- Impact: IMS, IWLAN, QTI call-audio control, vendor radio configuration, SAP,
  and advanced UICC/data paths cannot register.
- Evidence (base): two-boot traces show servicemanager rejecting the listed QTI
  interfaces because they are absent from the device VINTF manifest.
- Source: `vendor/nothing/metroid/proprietary/vendor/etc/init/qcrilNrd.rc:5-46`
- Cause: `device.mk:264-271` installs only selected AOSP radio fragments; the
  exact stock standalone declarations for the served QTI interfaces were absent.
- Resolution (r4): standalone QTI fragments are installed; second-boot traces show
  `IQtiRadioConfig/default`, `IImsRadio/imsradio0/1`, and `IQtiRadioStable/slot1/2`
  resolving and registering via servicemanager with no registration denial, and
  `org.codeaurora.ims` binds them under `vendor_qtelephony`.
- Acceptance remaining: physical-SIM call, SMS, data, IMS, IWLAN, call-audio,
  DSDS, airplane-mode, and suspend tests.

### MTR-002: Android IMS implementation is absent

- Severity: critical
- Status: resolved on r4 (infrastructure); carrier-SIM feature validation pending
- Impact: VoLTE, VoWiFi, IMS SMS, supplementary services, IMS handover, and IMS
  emergency MMTEL cannot work.
- Evidence (base): the installed package/service audit finds no IMS implementation;
  `ImsResolver` reports no carrier or device MMTEL service.
- Source: `packages/services/Telephony/res/values/config.xml:237-241`
- Cause: no compatible `org.codeaurora.ims` package was installed and the default
  MMTEL package was not selected by a metroid Telephony overlay.
- Resolution (r4): the stock `org.codeaurora.ims` is installed as a
  system_ext/priv-app, runs under `vendor_qtelephony`, and `ImsResolver` binds
  MMTEL and EMERGENCY_MMTEL on both slots; `QImsService` receives
  `UNSOL_SRV_STATUS_UPDATE` for both subscriptions.
- Acceptance remaining: VoLTE/VoWiFi, IMS SMS, incoming/outgoing audio, and
  LTE/Wi-Fi handover with a carrier SIM.

### MTR-003: eSIM is advertised without an LPA or usable eUICC backend

- Severity: high
- Status: resolved on r4 by not advertising eUICC
- Impact: applications were presented an eUICC hardware feature for which no
  LPA/EuiccService or eUICC binder backend existed, so discovery, download,
  activation, deletion, and settings could not work.
- Evidence (base): `EuiccManager` was disabled, no `EuiccService` package was
  installed, and no eUICC binder service was present.
- Source: `proprietary-files.txt:6`
- Cause: `android.hardware.telephony.euicc` was advertised without a legally
  distributable LPA/EuiccService and its served declarations.
- Resolution (r4): the eUICC hardware feature is no longer advertised on the
  installed build, so apps no longer see eSIM as available. eSIM remains
  intentionally unavailable until a legally distributable LPA/UI with all
  dependencies and served declarations is packaged.
- Acceptance: when reintroduced, `EuiccManager.isEnabled()`, EID discovery,
  profile download, enable/disable, reboot persistence, deletion, and
  physical-SIM coexistence.

### MTR-004: Android Power HAL cannot register

- Severity: high
- Status: resolved on r4
- Impact: framework and SurfaceFlinger lacked the device power-mode, boost, and
  ADPF implementation.
- Evidence (base): `android.hardware.power.IPower/default` was absent and framework
  performance-hint diagnostics reported ADPF unsupported.
- Source: `device.mk:264-271`
- Cause: the stock-equivalent `android.hardware.power.IPower/default` declaration
  was not installed, although the vendor power process ran.
- Resolution (r4): a stock-matching Power AIDL VINTF fragment is installed and
  `android.hardware.power.IPower/default` registers on both boots.
- Acceptance remaining: Power AIDL VTS, interaction/launch/camera boosts,
  sustained ADPF sessions, WALT tracing, and suspend regression.

### MTR-005: framework thermal policy has no skin sensor or headroom

- Severity: high
- Status: confirmed
- Impact: framework thermal status, headroom, display mitigation, and scheduler
  consumers are blind to enclosure temperature. Kernel and proprietary thermal
  protection still operate, so this is not total thermal-protection loss.
- Evidence: framework thermal diagnostics expose no skin temperature and return
  `NaN` headroom while other device temperatures remain available.
- Source: `hardware/qcom-caf/thermal/thermalConfig.cpp:2487-2501`
- Cause: tuna maps skin to nonexistent `sys-therm-3`; the kernel exposes Nothing
  shell sensors instead.
- Fix direction: restore the compatible stock Thermal HAL or recover the exact
  shell sensor mapping and thresholds. Do not guess thresholds.
- Acceptance: live `TYPE_SKIN`, non-NaN headroom, controlled thermal-status and
  cooling transitions, display mitigation, and charging interaction.

### MTR-006: launch API metadata incorrectly identifies Android 16 hardware

- Severity: high
- Status: resolved on r4
- Impact: compatibility, VSR, permission, and security behavior could be selected
  for an Android 16-launch device instead of the stock Android 15 launch level.
- Evidence (base): installed properties reported first/board API level 36.
- Source: `lineage_metroid.mk`
- Cause: `PRODUCT_SHIPPING_API_LEVEL` was set to 36; stock evidence records API 35
  and board API `202404`.
- Resolution (r4): installed properties report `ro.product.first_api_level=35`,
  `ro.board.first_api_level=202404`, and `ro.product.device=metroid`.
- Acceptance: factory reset, permissions, setup, and broad application regression
  remain to be validated.

### MTR-007: security-patch metadata is stale and incomplete

- Severity: high
- Status: partially resolved on r4; boot-image SPL still blank
- Impact: consumers can misjudge the incorporated security-patch level.
- Evidence: installed properties report platform SPL `2026-02-01`;
  `ro.vendor.build.security_patch=2025-06-05`; `ro.bootimage.build.version.security_patch`
  is blank.
- Source: `build/soong/scripts/gen_build_prop.py:137-197`
- Cause: the Soong ramdisk `build.prop` generator emits common `bootimage`
  identity properties but omits the platform security-patch property. The boot
  and init_boot AVB descriptors independently and correctly retain the measured
  stock boot-chain SPL `2025-04-05`.
- Source fix: staged for the next build by emitting the platform SPL as
  `ro.bootimage.build.version.security_patch`. A focused ramdisk/boot/init_boot
  build produces runtime metadata `2026-02-01` while preserving both AVB SPL
  descriptors at `2025-04-05`. Not installed or runtime-accepted yet.
- Acceptance: patch provenance/CVE ledger plus consistent build properties and
  AVB rollback indexes.

### MTR-008: accepted release records and bootstrap artifacts are inconsistent

- Severity: high
- Status: resolved for r4 records; verify before each future release
- Impact: users and maintainers can select the wrong OTA, source lock, recovery
  image set, or checksum record.
- Evidence (base): maintainer release pointers still named the August 4 OTA while
  `BASELINE.md` named the August 5 candidate.
- Cause: `releases/current`, install documentation, lock files, source capture,
  and recovery bootstrap were not updated atomically.
- Resolution (r4): `releases/current` points to
  `candidate_20260806_144606_ims-policy-r4`; `docs/BASELINE.md` and the device
  `BASELINE.md` name the same ZIP/hash/source; the verified snapshot seals
  `VERIFICATION.txt`, `SHA256SUMS`, the repo-manifest lock, payload-derived
  bootstrap, and `source/*-state.txt`.
- Acceptance: one consistency audit proves every canonical record names the same
  ZIP/hash/revisions and a clean checkout reproduces target-files.

## P1: confirmed subsystem defects

### MTR-009: Nothing charging-policy HAL is disabled and undeclared

- Severity: high
- Status: confirmed
- Impact: basic USB/wireless charging works, but Nothing current voting,
  shell-temperature derating, abnormal handling, and reverse-wireless policy are
  unavailable.
- Evidence: `vendor.noth.hardware.charge.ICharge/default` is absent while basic
  platform charging remains functional.
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
- Evidence: all eight installed LE Audio profile properties and the hearing-aid
  feature override are `false`.
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
- Evidence: the Vibrator AIDL service advertises no prebaked effects and
  zero-duration primitives; `TEXTURE_TICK` produces no output.
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
- Evidence: repeated codec tests log `Media Quality Service not found` and a
  matching servicemanager AVC for every lookup.
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
- Evidence: boot log records a property-service denial when the QTI GNSS domain
  sets `vendor.qti.izat.value_added_process`.
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
- Evidence: the QCC vendor service is absent while the location process remains
  alive and repeatedly attempts the integration path.
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
- Evidence: `vendor.noth.hardware.sensor.sensor_extension.ISensorExtension/default`
  is absent on the installed build.
- Source: `vendor/nothing/metroid/proprietary/vendor/etc/init/vendor.noth.hardware.sensor.sensor_extension-service.rc:1-7`
- Fix direction: restore only after identifying actual framework consumers and
  validating the intended stock binary and standalone fragment.
- Acceptance: extension API, pocket/posture/orientation, UDFPS/display
  coordination, batching, wake-up delivery, suspend, and HAL restart.

## Reclassified reports

### MTR-017: recovery sideload does not stage the care map

- Severity: none
- Status: closed; expected upstream recovery-sideload behavior, not a metroid
  defect or release blocker
- Impact: `update_verifier` skips its additional cared-block read after recovery
  sideload. AVB still verifies mounted partitions.
- Evidence: r4 first-boot logs state `/data/ota_package/care_map.pb` does not
  exist and skip partition verification; `update_verifier` logs "Deferred marking
  slot 0 as booted successfully." The slot is subsequently marked successful.
- Cause: upstream A/B recovery sideload streams the OTA through FUSE and passes
  only `payload.bin` and `payload_properties.txt` to `update_engine_sideload`.
  It has no care-map staging path. `/data/ota_package` also uses the required
  userdata encryption policy. The rooted userspace `update_device.py` test tool
  stages `care_map.pb`; recovery does not.
- Resolution: do not add a device-specific recovery write into encrypted
  userdata. Gate recovery-sideload releases on payload/AVB audits, target-slot
  activation, snapshot state, slot success, and two clean boots. Use a normal
  userspace updater path when explicit care-map verification is required.

## P2: latent defects and cleanup

### MTR-018: UDFPS refresh vote occurs after pointer-down notification

- Severity: high
- Status: latent deterministic race
- Impact: LHBM authentication can fail if the panel begins at 60 Hz.
- Evidence: display/UDFPS traces record LHBM requests while the panel is still at
  60 Hz, followed by the 120 Hz vote.
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
- Evidence: the CPUSS sleep-stats driver fails to map the configured register and
  exposes no residency counters.
- Source: `kernel/nothing/sm8735/arch/arm64/boot/dts/vendor/qcom/tuna.dtsi:1790-1802`
- Fix direction: reconcile active `0x178a0098` with stock `0x178b0098` after
  restoring reproducible kernel staging.
- Acceptance: successful probe and counters increasing over repeated suspend.

### MTR-021: inherited init inventory contains dangling services and invalid work

- Severity: medium
- Status: confirmed cleanup/integration defect
- Impact: normal boot attempts missing executables and imports, obscuring real
  failures and advertising unavailable QSPA, CHRE, QCC, factory, and helper paths.
- Evidence: a static normal-boot audit finds inherited RC entries whose
  executables or imports are absent from the accepted images.
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
- Evidence: repeated NFC power-transition traces return `-107` (`ENOTCONN`) from
  the ST21 transport despite successful initialization and tag polling.
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
- Evidence: repeated audio sessions fail to bind the framework-selected MusicFX
  keepalive component because that service is not installed.
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
