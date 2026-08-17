# Metroid bug backlog

Last audited against accepted baseline and coherent live state: 2026-08-17

Accepted build: `23.0-20260808-UNOFFICIAL-metroid` (r21)

Live device: `23.0-20260815-UNOFFICIAL-metroid` (r35), coherent slot B; not accepted

Accepted OTA SHA-256:
`e26956f003ceea3923d847515e2943dc8bbf4505533cbae726d36bc167f968db`

This is the authoritative maintainer backlog. A confirmed issue has installed-
device or accepted-image evidence and a deterministic source/configuration cause.
A latent issue has a deterministic defect but no retained user-visible failure.
A test gap is not a bug claim.

Detailed runtime evidence is retained privately because raw device logs contain
sensitive identifiers. Source paths are relative to `lineage/`. Any proprietary
component mentioned below must be user-extracted or have explicit redistribution
permission; it must never be committed to this public repository.

## Status summary

| State | Issues |
|---|---|
| Active fixes | MTR-001, MTR-002, MTR-005, MTR-011, MTR-015, MTR-016, MTR-024 |
| Installed fixes needing focused acceptance | MTR-003, MTR-009, MTR-010, MTR-012, MTR-018, MTR-019, MTR-022, MTR-023, MTR-029 |
| Evidence incomplete | MTR-020 |
| External hardware/carrier/policy acceptance | MTR-027, real eSIM profile, OMAPI |
| Closed defects / recurring gates | MTR-004, MTR-006, MTR-007, MTR-008, MTR-013, MTR-014, MTR-017, MTR-021, MTR-026, MTR-028 |

Before editing any active issue, complete its evidence matrix: reproduce on the
installed build; compare the Nothing stock dump/configuration; inspect relevant
Nothing/Qualcomm kernel source and DTS; compare AOSP, Lineage, CLO and reference
devices; then identify the first deterministic divergence. One evidence-backed
change gets one focused validation cycle. Do not iterate by flashing guesses.

## P0: release and core-function blockers

### MTR-001: QTI radio extension services are rejected by VINTF

- Severity: critical
- Status: r35 APN checksum migration installed and validated; physical-SIM and
  carrier acceptance pending
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
- Public failure (XDA posts 24 and 29): active AT&T and Cox/Verizon physical SIMs
  can see/connect to a network, but data, voice, and text do not work. This proves
  a functional defect beyond Binder registration and is broader than IMS alone.
- First divergence: r28 omitted stock `QtiTelephony`, `QtiTelephonyService`, and
  `qcrilmsgtunnel` while retaining stock package maps, permissions, sysconfig,
  libraries, properties, and SELinux policy that reference them. Stock 260414,
  stock 260624, and Qualcomm references ship the complete package set.
- Successor source fix: restore the three stock-signed APKs and Lineage's
  `QtiTelephonyCompat`; assign all stock-signed QTI phone packages to
  `vendor_qtelephony` without relying on the ROM platform certificate. Focused
  package/policy builds and assembled `system_ext.img` pass.
- r29 install finding: four name-only seapp rules were invalid on Android 16 and
  invalidated the combined seapp table, so zygote could not assign system_server.
  After correcting that, PackageManager rejected stock-signed
  `QtiTelephonyService` because `MODIFY_AUDIO_ROUTING` lacked an explicit
  privileged-permission allowlist. r30 scopes a dedicated seinfo to the Nothing
  certificate plus four package names and adds only that required allowlist.
- r30 installed evidence: exact sealed OTA SHA-256
  `40fb1b4178836482e2f0f349a092541d1a1f5820c81d8e3503546b49411e08b4`
  boots repeatedly on successful slot A with encrypted data, Enforcing SELinux,
  one system_server start, QtiTelephony and IMS in `vendor_qtelephony`, registered
  QTI radio/IMS services, no relevant AVC/fatal, and empty crash/tombstone/pstore
  gates. No SIM is present, so this is startup evidence only.
- r34 APN migration divergence: stock, current source, and the installed
  `/product/etc/apns-conf.xml` contain carrier-ID `10028` `nrphone`, IMS,
  hotspot, and XCAP rows. The retained provider database has zero `10028` rows
  because r30 and r34 share `ro.build.id=BP2A.250805.005` and
  `TelephonyProvider.onCreate()` only invoked its existing checksum refresh when
  that build ID changed.
- Successor APN migration fix: `packages/providers/TelephonyProvider` commit
  `80ea349` invokes the existing updater when either the build ID or packaged
  APN checksum changes. The updater preserves user/carrier/DPC entries and
  replaces only unedited rows. Production and test APK builds pass.
- r35 installed result: the retained checksum changed from `2991848244` to
  `3646330062`; all four carrier-ID 10028 `nrphone`, `nrhotspot`, `ims`, and
  `xcap` rows materialized and persisted across reboot. This closes the stale
  database migration defect only; both SIM slots are absent, so carrier data,
  voice, SMS, and IMS remain blocked.
- Independent Cox data divergence: Lineage had no MCC 311/MNC 600 profiles while
  stock has seven Cox profiles. The successor adds the exact IMS, FOTA,
  default/MMS/DUN/SUPL profiles; generated APN schema and `product.img` pass.
- Evidence boundary: the public installer never required the generation-matched
  modem/MCFG input. Retained local no-SIM evidence shows emergency LTE camping
  with `subId=-1`, but cannot be attributed to the tester's inserted SIM.
- Private tester captures cover both card types. The longer physical-SIM record
  was collected immediately after a fresh wipe/flash of the newest XDA seed on
  2026-08-13. `Build.VERSION.INCREMENTAL` identifies that seed as r24; the initial
  August 11 log timestamps are the r24 build clock before current time sync, not
  stale retained logs. It supersedes the shorter boot-only record. A conventional
  removable card in slot 0 reaches USIM/ISIM `READY`,
  subscription creation, carrier-record load, LTE home registration, and outgoing
  non-IMS SMS. Both selected AT&T APN families are then rejected by the modem as
  `OEM_DCFAILCAUSE_4` (`0x1004`) before CID/interface assignment.
- A separate earlier capture contains a removable eUICC in slot 1 with an active
  carrier profile. Hardware eUICC/EID detection, USIM/ISIM readiness, subscription,
  LTE home registration, and incoming/outgoing non-IMS SMS pass. Profile refresh
  fails and the active subscription is incorrectly exposed as non-embedded. Its
  selected data profile receives the same immediate modem `0x1004` rejection.
  IMS is unavailable/unregistered in both captures.
- These results rule out card detection, subscription creation, LTE registration,
  SMS transport, and missing AT&T APNs as the shared first failure. Neither older
  ROM/modem generation is frozen r29, so the captures cannot accept or reject r29;
  the opaque OEM code does not justify a firmware change by itself.
- Evidence disposition: include `vendor/apn` commit `ed04060` in the next coherent
  candidate. Verify that carrier ID `10028` selects `nrphone` for initial attach
  and the first data call. If `0x1004` persists on `nrphone`, localize it against
  stock QMI/MCFG behavior rather than reopening UICC detection.
- New external capture (2026-08-14): the successor QTI package stack reaches
  physical-SIM USIM/ISIM readiness, subscription load, LTE home registration with
  voice/SMS/data service, and repeated successful non-IMS SMS submissions. The
  tester confirms those outbound messages reached the recipient, but replies were
  not received on the device. After mobile data is enabled, both selected AT&T
  default APNs (`nxtgenphone` and
  `wap.cingular`) receive immediate modem `OEM_DCFAILCAUSE_4` (`0x1004`) responses
  with no CID or interface. An outgoing circuit-switched call is accepted by the
  RIL, enters `DIALING`, then receives last-call cause 252, `Explicit network
  reject`. This confirms that the first data failure remains below Android APN
  selection and before interface assignment.
- First source divergence: the SIM resolves to carrier ID `1187` with specific
  carrier ID `10028` (`AT&T 5G SA`), but Lineage had no `10028` profiles. Android
  therefore fell back to generic `1187`, selected `nxtgenphone` as initial attach
  and default, and later retried legacy `wap.cingular`. Nothing stock defines the
  missing set as `nrphone` default, `ims`, `nrhotspot`, and `nrphone` XCAP.
- Source fix: `vendor/apn` commit `ed04060` adds that exact four-profile stock
  block to `US.xml`. XSD validation and the real `apns-conf.xml` Soong build pass,
  and generated output contains all four `10028` rows. A broader audit confirms
  source and output match at 419 US records and 86 carrier-ID records; unrelated
  legacy stock catalog entries were not imported.
- Fix boundary: this corrects initial-attach, default-data, IMS, hotspot, and XCAP
  selection for this SIM. It does not explain or close inbound SMS or modem call
  cause 252; those remain separate installed acceptance results.
- Capture boundary: the files do not contain an independently verifiable ROM build
  property, and they identify baseband
  `MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.150609.3.152387.2`, not r30's frozen
  `...1.126608.2.134544.2` generation. They therefore strengthen the external
  functional evidence but cannot accept or reject r30 on its required modem input.
- New external capture (2026-08-16, r35): a 3/Hallon SE physical SIM
  (240/02, carrier ID 1691, slot 2/PHONE1) on the installed r35 build shows the
  `3 SE` (`data.tre.se`, 2935) and `3 SE MMS` (2934) rows materialized and
  selected with the correct DNN and TrafficDescriptor. Registration flaps between
  `REG_DENIED_EM` on Telia SE 24001 EDGE/GSM and brief `REG_HOME` LTE 24002
  windows. Within a HOME/IN_SERVICE LTE 24002 window (B20, PCI 120, CS+PS in
  service), `SETUP_DATA_CALL` for `data.tre.se` still receives an immediate
  `OEM_DCFAILCAUSE_4` (`0x1004`, retry=-1, no CID). This is a second, unrelated
  carrier repeating the identical OEM cause while the device is home-registered
  with correct APN rows; it removes APN content, carrier-ID fallback, and
  registration state from the shared first failure and points at the modem/RIL
  data-path configuration. The OTA does not embed the modem, and no baseband
  version string is present in these captures, so the frozen
  `...1.126608.2.134544.2` generation cannot be confirmed from them.
- Evidence disposition: the checksum-migration and US `10028` APN fixes are
  validated as installed (rows materialize and persist), but they do not change
  the 0x1004 response on either carrier. Before any further data-path source
  edit, run the documented same-device stock control on the matching modem
  generation and compare stock QMI/MCFG behavior with QXDM/QMI-level capture.
- Acceptance: present UICC/subscription, calls, SMS, data, IMS, IWLAN, call-audio,
  DSDS, airplane-mode, and suspend tests on the documented modem generation.

### MTR-002: Android IMS implementation and carrier acceptance

- Severity: critical
- Status: r35 installed with IMS process/service startup validated; carrier IMS
  acceptance pending
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
- Functional tester result: the fresh-wipe r24 physical SIM and earlier
  removable-eUICC captures
  both have IMS unregistered while circuit-switched SMS works; data independently
  fails with modem `0x1004`. MMTEL binding is therefore infrastructure evidence
  only, not functional acceptance.
- r30 local result: `org.codeaurora.ims` remains stable in `vendor_qtelephony`,
  both vendor IMS-radio instances and QTI IMS factory/data/CM/UCE services
  register across repeated boots, with no SIM available for MMTEL acceptance.
- New external capture (2026-08-14): QImsService starts and briefly reports
  `VOLTE ims registered`, but framework registration remains
  `REGISTRATION_STATE_NOT_REGISTERED`, MMTEL voice/SMS capabilities remain false,
  outbound SMS uses the non-IMS RIL path, inbound SMS fails, and the attempted call
  uses the circuit-switched RIL path before modem rejection. Treat the vendor
  message as contradictory infrastructure telemetry, not IMS acceptance. The
  capture uses the mismatched
  `...1.150609.3.152387.2` baseband and does not independently identify the ROM
  build, so repeat on r30 with its frozen modem generation before source changes.
- First carrier-policy divergence: after the AT&T subscription resolves, framework
  logs `available = false` and sets `voLteFeatureOn = false` even though user
  enablement, TTY, and provisioning are true. Lineage's carrier-ID 1187 config
  does not set `carrier_volte_available_bool`, whose framework default is false.
  Nothing's validated stock CarrierConfig overlay enables VoLTE for both AT&T
  PLMNs used by this SIM (`310280` home and `310410` serving), then disables only
  VT and WFC in its carrier-ID 1187/10028 policy.
- Successor source fix: add a metroid-scoped CarrierConfig RRO reproducing the
  stock-effective AT&T policy: VoLTE available, VT/WFC unavailable, TTY over
  VoLTE disabled, enhanced-4G editing disabled, and stock APN filtering/IMS
  controls. The focused RRO and CarrierConfig test modules compile, and the built
  APK retains the expected raw MCC/MNC values.
- r31 offline result: immutable snapshot
  `releases/candidate_20260814_233610_118108082_candidate/`, OTA SHA-256
  `b702dc7b119e8e91180c49fc59c3f8b0bbc4c0c75ecbfe373ac8dd06cf70def3`,
  passes install-clean build, payload-equivalence, signing/AVB, partition,
  VINTF, init, source-state, and companion-input audits. The target-files contain
  both the four carrier-ID 10028 APNs and `CarrierConfigOverlayMetroid.apk`.
  Status remains built-not-installed.
- US parity follow-up: stock/APN audit found T-Mobile and Verizon core profiles
  already complete, but Lineage omitted 56 stock carrier-ID profiles across
  FirstNet, Cricket, Dish/Boost AT&T variants, Liberty, MVNx, Tracfone AT&T,
  Red Pocket, Consumer Cellular, Pure Talk, Airvoice, Ztar, and Kore. The source
  now restores those profiles, corrects AT&T SA/NSA IMS to use
  `network_type_bitmask`, and adds the missing NSA XCAP profile.
- Nothing stock also admits VoLTE by default while AOSP defaults it off. The
  metroid RRO now reproduces that admission only for US MCCs 310 through 316;
  carrier-specific WFC and VT policy remains unchanged. Schema validation,
  CarrierConfig module compilation, product-image generation, and generated
  per-carrier profile-count checks pass. Hardware behavior remains untested.
- r32 offline result: immutable snapshot
  `releases/candidate_20260815_005128_749949780_candidate/`, OTA SHA-256
  `919fe65976707c55b509a4cc823eecc64abb26f02f506a44a24ee9a758579629`,
  passes install-clean build, source-state, companion-input, payload-equivalence,
  signing/AVB, partition, VINTF, and init audits. Status remains
  built-not-installed.
- Online verification against official Lineage APN main and AOSP/Lineage
  CarrierConfig/carrier-ID sources found and integrated the only safe current US
  drift: Google Fi, FreedomPop, Docomo Pacific, AirFire and Mosaic APN typing,
  plus obsolete AT&T activation-row removal. No current safe CarrierConfig or
  carrier-ID database delta remains for this branch.
- r33 offline result: immutable snapshot
  `releases/candidate_20260815_091437_165511465_candidate/`, OTA SHA-256
  `fb2c2c294a7dc2d76499fdce8018211d5bfbd3f7792fc0094561d0547187833b`,
  passes all offline release gates and supersedes r32. Status remains
  built-not-installed.
- Fix boundary: this removes Android's deterministic voice-MMTEL disable and,
  together with `vendor/apn` commit `ed04060`, supplies the stock `ims` and
  `nrphone` profiles. It does not prove carrier registration or explain the
  circuit-switched cause 252 and absent non-IMS inbound indication; those remain
  installed fallback-path acceptance results.
- New external capture (2026-08-16, r35, 3/Hallon SE 24002): QImsService
  repeatedly reports `ImsServiceSub ... registered = 2` (NOT_REGISTERED) with
  `restrictCause = 0` for both network modes 0 and 14; `ImsConfigImpl:
  onSubscriptionsChanged unable to process due to SubscriptionInfo is null`;
  `LteVopsSupportInfo` shows `mVopsSupport = 2` (VoLTE NOT_SUPPORTED) and
  `mEmcBearerSupport = 2` on the serving 24002 LTE cell. This matches the
  tester-reported IMS registration error codes 4001 and 4002 (not present in
  these three captures; they were observed at other times). The repeated
  `service not connected. Domain = PS` line also appears while registered, so it
  is not the first divergence. No IMS PDN is established, consistent with the
  cell declaring VoPS unsupported and the separate 0x1004 data failure.
- Acceptance remaining: establish a valid subscription first, then VoLTE/VoWiFi,
  IMS SMS, incoming/outgoing audio, and LTE/Wi-Fi handover.

### MTR-003: stock-backed eSIM provisioning

- Severity: high
- Status: installed on r17; provisioning UI accepted through QR scanner, real
  profile download/activation pending
- Impact: applications were presented an eUICC hardware feature for which no
  LPA/EuiccService or eUICC binder backend existed, so discovery, download,
  activation, deletion, and settings could not work.
- Evidence (base): `EuiccManager` was disabled, no `EuiccService` package was
  installed, and no eUICC binder service was present.
- Source: `proprietary-files.txt:6`
- Cause: `android.hardware.telephony.euicc` was advertised without a legally
  distributable LPA/EuiccService and its served declarations.
- Interim resolution (r4-r16): stop advertising eUICC until a complete stock
  application/transport path and matching modem firmware were available.
- r15 forensic result: the complete stock application/transport stack was
  integrated temporarily. Framework selected QTI automatically, routed the
  documented legacy card-ID path to built-in slot 1, loaded the stock JNI
  bridge, bound both `IUimLpa/UimLpa0` and `/UimLpa1`, and launched Google's
  profile UI. The modem then returned `UimLpaResult=1` with an empty EID.
- Root cause: QCRIL/LPA userspace matched stock, but both installed modem slots
  used firmware/MCFG generations different from the A16 stock dump. The mixed
  stack returned generic `UimLpaResult=1` and an empty EID.
- New stock evidence: metroid exposes live `IUimLpa/UimLpa0` and `/UimLpa1`
  modem services. Stock ships Google SIM Manager, a metroid partner APK, the
  eUICC feature in ODM, exact Google-certificate permission grants, and profile
  retention policy.
- Source integration: restore those two stock-signed APKs privately, advertise
  the stock ODM feature, and add Lineage `EuiccPolicy`. Focused package/product
  builds pass with preserved APK signatures.
- Firmware correction: both modem slots now contain the complete audited A16
  stock modem tree (`MPSS.DE.7.0-02698...126608.2.134544.2`), replacing mixed
  2025-08 and 2026-03 builds. Radio, IMS, LPA, and QSPA services remain healthy.
- r10/r11 evidence: Google SIM Manager and the corrected lowercase metroid slot
  map load, but `EuiccManager` remains disabled because AOSP radio slot status
  reports no eUICC/EID. Stock's self-contained Qualcomm LPA transport is required
  to bridge framework `EuiccService` calls to the live `IUimLpa/UimLpa0` and
  `/UimLpa1` services.
- Transport fix: package the stock QTI LPA APK with the current platform
  signature and stock `vendor_qtelephony` domain, enable the real product
  telephony wrapper, and provide a compatibility uses-library for Qualcomm's
  orphaned `uimlpalibrary.jar` declaration. Focused Soong/uses-library/signature
  validation passes; runtime acceptance remains.
- r14 evidence: QTI LPA loads its stock JNI bridge, binds both live modem LPA
  instances, registers callbacks with qcril, and connects `EuiccConnector`.
  AOSP still passes slot `-1` because RadioConfig exposes no card ID/EID.
- r17 resolution: with matching modem firmware and stock application/transport
  stack, `EuiccManager.isEnabled()` is true across two boots and Google SIM
  Manager reaches the native **Set up an eSIM** chooser and QR scanner without a
  platform telephony compatibility patch.
- Historical external result: an already-provisioned removable eUICC is detected
  with an EID and its active profile reaches LTE registration plus bidirectional
  SMS. This validates active-profile radio use, not native profile download: eUICC
  profile refresh fails and framework subscription metadata says non-embedded.
- Acceptance remaining: real activation-code download, profile enable/disable,
  reboot persistence, deletion, transfer, and physical-SIM coexistence. Never
  print or publish the device EID or activation credentials.

### MTR-004: Android Power HAL cannot register

- Severity: high
- Status: closed on r4
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
- Status: framework path resolved on installed r7; transition acceptance pending
- Impact: framework thermal status, headroom, display mitigation, and scheduler
  consumers are blind to enclosure temperature. Kernel and proprietary thermal
  protection still operate, so this is not total thermal-protection loss.
- Evidence: framework thermal diagnostics expose no skin temperature and return
  `NaN` headroom while other device temperatures remain available.
- Source: `hardware/qcom-caf/thermal/thermalConfig.cpp:2487-2501`
- Cause: the generic tuna HAL maps skin to nonexistent `sys-therm-3`. The build
  also omitted Nothing's `sltntc` fitting daemon and enable property, leaving
  kernel `shell_front`, `shell_frame`, `shell_back`, and `shell_max` at zero.
- Source fix: package the user-extracted stock `sltntc`, restore its stock enable
  property and measured SELinux domain, and select the hash-verified stock
  Thermal HAL, which contains Nothing's `shell_max` mapping and thresholds.
  Focused daemon/policy/HAL builds and `check-vintf-all` pass.
- Resolution (r7): `sltntc` runs as `u:r:sltntc:s0`, shell zones update, stock
  Thermal HAL hashes match the stock dump, `TYPE_SKIN` reports live values,
  thresholds are 39/43/44/50/54/63 C, and headroom is non-NaN across two boots.
- Residual: proprietary thermal-engine logs dynamic shell-zone name errors and a
  missing FPS virtual sensor; controlled status/cooling/display/charging
  transitions remain unverified.
- Current disposition: no further source edit is justified. The remaining gate
  is one bounded unplugged thermal transition with headroom, cooling, display
  mitigation and recovery evidence; do not reproduce the prolonged heat event.
- Heat-event evidence: during normal unplugged use in a prior boot session,
  BatteryStats recorded 48 C for about 47 minutes, then 49 C for about 6 minutes
  before a manual reboot. Battery level fell 73% to 58% and charge counter fell
  3843 to 3076 mAh. There was no thermal shutdown, panic, watchdog, ANR, pstore
  record, or new tombstone, but retained framework thermal status was 0. The
  history also retained contradictory `+plugged +charging` state bits alongside
  `plug=none`; do not use those stale bits as evidence that a charger was present.
- Acceptance: live `TYPE_SKIN`, non-NaN headroom, controlled thermal-status and
  cooling transitions, display mitigation, and charging interaction.

### MTR-006: launch API metadata incorrectly identifies Android 16 hardware

- Severity: high
- Status: closed on r4
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
- Status: closed on installed r5
- Impact: consumers can misjudge the incorporated security-patch level.
- Evidence: installed r5 reports platform and boot-image SPL `2026-02-01` and
  vendor SPL `2025-06-05`; boot/init_boot AVB descriptors retain `2025-04-05`.
- Source: `build/soong/scripts/gen_build_prop.py:137-197`
- Cause: the Soong ramdisk `build.prop` generator emits common `bootimage`
  identity properties but omits the platform security-patch property. The boot
  and init_boot AVB descriptors independently and correctly retain the measured
  stock boot-chain SPL `2025-04-05`.
- Resolution (r5): emit the platform SPL as
  `ro.bootimage.build.version.security_patch`; verified across two installed
  boots while preserving both AVB SPL descriptors at `2025-04-05`.
- Acceptance: patch provenance/CVE ledger plus consistent build properties and
  AVB rollback indexes.

### MTR-008: accepted release records and bootstrap artifacts are inconsistent

- Severity: high
- Status: resolved for r17 records; recurring release gate
- Impact: users and maintainers can select the wrong OTA, source lock, recovery
  image set, or checksum record.
- Evidence (base): maintainer release pointers still named the August 4 OTA while
  `BASELINE.md` named the August 5 candidate.
- Cause: `releases/current`, install documentation, lock files, source capture,
  and recovery bootstrap were not updated atomically.
- Resolution (r17): `releases/current`, top-level/device baseline, release notes,
  ZIP/hash/source, separate modem-firmware requirement, and GApps add-on are
  reconciled. The verified snapshot seals
  `VERIFICATION.txt`, `SHA256SUMS`, the repo-manifest lock, payload-derived
  bootstrap, and `source/*-state.txt`.
- Acceptance: one consistency audit proves every canonical record names the same
  ZIP/hash/revisions and a clean checkout reproduces target-files.
- Update-path evidence: normal-system update_engine initially failed opening
  `vbmeta_vendor_a` because only root/system vbmeta devices had the stock
  `vendor_custom_ab_block_device` label. Applying stock's
  `vbmeta_vendor_[ab]` label made the same audited payload complete with
  `kSuccess`. The label is staged in source so future Updater/update_engine runs
  can preserve addon.d/GApps without recovery interaction.

## P1: confirmed subsystem defects

### MTR-009: Nothing charging-policy HAL is disabled and undeclared

- Severity: high
- Status: installed on r20; bounded hardware acceptance pending
- Impact: basic USB/wireless charging works, but Nothing current voting,
  shell-temperature derating, abnormal handling, and reverse-wireless policy are
  unavailable.
- Evidence: `vendor.noth.hardware.charge.ICharge/default` is absent while basic
  platform charging remains functional.
- Source: `vendor/nothing/metroid/proprietary/vendor/etc/init/vendor.noth.hardware.charge-service.rc:1-7`
- Cause: duplicate `disabled` directives and no active ICharge VINTF fragment.
- Stock/source audit: r17 also shipped an older executable
  (`73d0a05c...`) instead of the A16 stock binary (`c8c3402a...`). The AIDL
  library matches stock. The archived experiment was incomplete and was not
  cherry-picked.
- Source fix staged: restore the exact A16 executable and normal-boot RC, add the
  standalone stock VINTF fragment, and reconstruct the stock HAL domain/service
  with typed qcom-battery, charger-proc, USB/battery supply, thermal, and kmsg
  access. Generic proc/sysfs grants remain excluded pending measured AVCs.
- r18 first boot: HAL entered its dedicated domain but Binder registration was
  denied calling `servicemanager`, causing a five-second crash loop. The service
  was stopped immediately; r18 is diagnostic-only and not a release candidate.
  Add the standard `binder_use()` server grant before the next build.
- r19: Binder registration succeeds and the HAL remains running. First node
  access exposed only two denials: write to stock `/proc/touchpanel/TP_charger_flags`
  and traversal of generic `/sys/devices/virtual` before typed thermal nodes.
  Stage a dedicated touchpanel proc label and directory-only generic sysfs
  traversal; do not grant generic proc/sysfs file access.
- r20: exact stock service remains registered across two boots; dedicated
  touchpanel/charger/qcom-battery labels and directory-only thermal traversal
  produce no charge-HAL AVCs. USB charging reports expected current, voltage,
  battery health, and service state at 28 C. A five-minute screen-off wired/full
  trend cooled battery 29 to 28 C, held USB at 27 C and abnormal status 0, kept
  the same HAL PID, and produced no AVC/crash. Controlled unplug/reconnect,
  hot-battery derating, wireless, and reverse-charging acceptance remain.
- Acceptance: low-SOC USB PD/PPS and wireless curves, screen on/off, thermal
  derating, stop/resume, suspend, reverse charging, and abnormal temperatures.
- Dependency: validate together with MTR-005.

### MTR-010: LE Audio profile family is explicitly disabled

- Severity: high
- Status: installed on r21; real-hardware acceptance pending
- Impact: unicast, broadcast, VCP, CSIP, HAP, MCP, and CCP cannot start.
- Evidence: all eight installed LE Audio profile properties and the hearing-aid
  feature override are `false`.
- Source: `product.prop`, `vendor.prop`, `system_ext.prop`
- Root cause: consumed product properties set eight profiles false after the
  stock-matching vendor properties set them true. Product precedence disabled
  BAP unicast/broadcast, CCP, CSIP, HAP, MCP, and VCP before controller
  capability checks; no kernel, firmware, HAL, VINTF, or module deficiency was
  found.
- Source fix: remove the product false overrides, restore stock hearing-aid UI
  flag true, and restore stock LE Audio allow-list bypass false. Runtime
  controller capability checks remain authoritative. Existing devices retain
  both old `persist.*` values in `/data`; the device init migration resets them
  to stock on boot.
- r21: all eight effective properties are true across two boots; persisted
  hearing-aid is true and allow-list bypass false. BAP assistant, CSIP, HAP,
  LE call control, MCP, VCP, and LE Audio services start; ISO manager and LE
  Audio HAL client initialize with no Bluetooth crash or AVC.
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
- Evidence boundary: packaged stock policy/configuration defines effects and
  compositions, but the proprietary running HAL publishes none. Obtain exact
  stock runtime capabilities and operation output before changing HAL, XML,
  kernel or DTS; packaged assets and registration alone do not define a fix.
- r35 bounded result: one-shot, prebaked, and primitive shell requests reached
  the stable HAL and AW8693x kernel path. This proves output plumbing only; it
  does not establish advertised capability completeness, perceived parity, or a
  source fix.
- Fix direction: map framework effects/compositions onto a working vendor path,
  or advertise only real capabilities with explicit fallbacks.
- Acceptance: every advertised effect, primitive, composition, amplitude level,
  keyboard, launcher, biometric, charging, notification, and stock comparison.

### MTR-012: Aperture stabilization setting is a no-op on metroid

- Severity: high
- Status: installed source fix; runtime acceptance pending
- Impact: all Aperture video requests disable stabilization while the user-facing
  preference remains available.
- Source: `packages/apps/Aperture/app/src/main/java/org/lineageos/aperture/viewmodels/CameraViewModel.kt:1776-1785`
- Cause: a device conditional unconditionally forces stabilization off.
- Source fix: the setting is hidden on metroid while capture requests continue
  forcing stabilization off. Restore EIS only for a measured mode/camera matrix
  that avoids the known Morpho crash path.
- Bounded validation (2026-08-08): a temporary same-signature Aperture update
  finalized FHD30, FHD60, and UHD30 H.264/AAC files at the requested resolution
  and cadence. The provider remained PID 1395 with no camera crash or new
  tombstone. This verifies the disabled-EIS fallback only, not stabilization.
- Acceptance: walking/panning FHD30, FHD60, and UHD30 clips; request/result
  metadata, crop, cadence, zoom transitions, provider PID, and tombstones.

### MTR-013: media quality lookup loops and produces continuous AVCs

- Severity: medium
- Status: resolved on installed r5
- Impact: every codec session repeatedly looks up an absent service, logs
  `Media Quality Service not found`, and generates SELinux denials.
- Evidence: repeated codec tests log `Media Quality Service not found` and a
  matching servicemanager AVC for every lookup.
- Source: `frameworks/av/media/libstagefright/MediaCodec.cpp:2094-2104`
- Source fix: integrated AOSP change `I574e5ec8a790dbcfd81ab5789f088bc28c37773a`,
  which uses nonblocking framework `checkService` semantics instead of treating
  `media_quality` as a declared VINTF HAL. Do not add policy for the absent service.
- Resolution (r5): repeated codec creation produces no invalid `media_quality`
  VINTF lookup or associated servicemanager denial.
- Acceptance: repeated AVC/HEVC playback and recording with no lookup loop, AVC,
  or codec regression.

### MTR-014: GNSS cannot set its value-added-process property

- Severity: medium
- Status: resolved on installed r5
- Impact: core GNSS fixes work, but enhanced IZat/PPE/DRE process selection may
  remain disabled.
- Evidence: boot log records a property-service denial when the QTI GNSS domain
  sets `vendor.qti.izat.value_added_process`.
- Source: `sepolicy/vendor/enforcing.te:123-128`
- Cause: raw property-socket file access was granted instead of typed `set_prop`.
- Source fix: replace the ineffective raw property-socket file grant with the
  typed `set_prop(vendor_hal_gnss_qti, vendor_location_prop)` macro.
- Resolution (r5): GNSS HAL restart completes without the prior property-service
  AVC and the service re-registers.
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
- Evidence boundary: stock starts and declares the service, but Lineage lacks a
  proven legitimate consumer and the stock framework consumer may be proprietary.
  Verify consumer identity and binary/ABI equivalence before removing `disabled`
  or adding a stable-HAL fragment.
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
- Status: source fixes installed on r35; enrollment and four unlocks pass,
  repetition/cancellation acceptance pending
- Impact: LHBM authentication can fail if the panel begins at 60 Hz.
- Evidence: display/UDFPS traces record LHBM requests while the panel is still at
  60 Hz, followed by the 120 Hz vote.
- Source: `frameworks/base/packages/SystemUI/src/com/android/systemui/biometrics/UdfpsController.java:1059-1075`
- First divergence: SystemUI exposes the touch overlay without acquiring AOSP's
  existing pre-authentication max-refresh vote, then notifies the fingerprint HAL
  before its asynchronous per-touch display-mode request can take effect. Stock
  HAL/RC/VINTF and the metroid panel driver already agree; no kernel change is
  justified.
- r30 functional result: the enrollment UI, UDFPS overlay, illumination, and
  60-to-120 Hz touch vote appear, but repeated physical touches produce no
  enrollment progress and sensor-0 counters remain zero. The proprietary Nothing
  AIDL service, stock-identical `fingerprint.default.so`, `libgf_hal.so`, Goodix
  daemon, `/dev/goodix_fp`, QSEE buffers, and TEE handles are all active.
- First capture-path divergence: the stock Goodix shim opens
  `/proc/touchpanel/fod_mode` before sending physical finger-down. r30 logs
  `avc: denied { search }` from `hal_fingerprint_default` to the labeled
  `vendor_proc_touchpanel` directory, followed by `fod_mode_fd <0`; no Goodix
  capture/progress event follows. Stock compiled policy grants the exact directory
  and file permissions.
- Source fixes: restore stock-equivalent `vendor_proc_touchpanel` directory/file
  access for `hal_fingerprint_default`; add a default-off SystemUI overlay-lifetime
  max-refresh vote and enable it only for metroid before touch becomes reachable.
  SystemUI, device overlay, SELinux policy, and vendor image focused builds pass.
  Aggregate SystemUI test targets remain blocked by unrelated pre-existing test
  compile failures; production modules compile.
- r35 installed result: fresh enrollment completes and four captured fingerprint
  unlocks succeed with zero fingerprint HAL deaths. The screen credential was
  subsequently removed, invalidating enrollments as expected. Complete a fresh
  enrollment, 46 additional screen-on/AOD unlocks, and cancellation/retry before
  closure.
- Fix direction: hold the maximum-refresh vote for the overlay lifetime before
  accepting touch; an immediate asynchronous reorder alone may still race.
- Next-batch scope: install the stock-equivalent policy plus the default-off,
  metroid-enabled overlay-lifetime vote, balanced on every hide and failed-show
  path. Hold this R2 change
  until frozen r29 has an installed disposition.
- Acceptance: Smooth Display off; 50 screen-on/AOD unlocks and enrollment with
  120 Hz active before LHBM and zero `fps not equal 120`.

### MTR-019: USB NCM function name disagrees with gadget HAL

- Severity: medium
- Status: primary r35 NCM local transport passes; adjacent regressions pending
- Impact: NCM and NCM+ADB requests cannot link or enumerate.
- First divergence: stock-derived vendor init created `ncm.0` while the selected
  QTI gadget HAL links `ncm.gs6`.
- Source fix: extraction changes the configfs instance to `ncm.gs6`; fresh staged
  vendor output contains the nine matching paths and no `ncm.0`.
- r25 installed result: CDC NCM plus ADB enumerates as `05c6:908c`, the host
  `cdc_ncm` driver creates a 425 Mbps link, raw IPv4/IPv6 transport passes with
  zero packet loss, and ADB round-trip hashes match. Android Tethering cannot
  start `IpServer` because `config_tether_ncm_regexs` is empty and `usb0` is not
  classified as NCM.
- r26 correction: a metroid Tethering RRO maps `usb\\d` as NCM.
- r26 installed result: the RRO is active and classifies `usb0`, but the USB
  configured broadcast still arrives before the interface exists. Android B
  ignores the later interface-added event, so `IpServer` is never retried.
- Successor correction: Connectivity retries NCM serving when a matching late
  interface appears while NCM is already configured; focused Tethering tests and
  `TetheringNext` build pass.
- r27 installed result: the retry still misclassifies `usb0` because it matches
  both generic USB and NCM regexes and generic USB is checked first. NCM transport
  remains partial; do not promote r27 as closing MTR-019.
- Final source fix: when the active function is NCM, use the NCM matcher directly
  for configured and late-interface paths. Focused overlap/race tests pass. No
  further OTA is allowed in this release train.
- r28 installed result: `05c6:908c` NCM enumerates with Linux `cdc_ncm`; despite
  overlapping generic USB and NCM regexes, Tethering adds `IpServer` for `usb0`,
  assigns `10.20.247.25/24`, serves DHCP/DNS, and starts offload. The host receives
  `10.20.247.37/24`; phone-gateway, public IPv4, DNS, and HTTPS 204 checks pass.
- r30 regression result: NCM+ADB enumerates as `05c6:908c`, Linux loads `cdc_ncm`,
  the host receives DHCP, and a 16 MiB ADB push/pull matches all hashes. Tethering
  assigns `10.20.183.224/24`, but EthernetTracker also claims `usb0`; client
  IpClient then disables IPv6 and clears all addresses, removing the gateway.
  Host ARP cannot resolve the phone. No Wi-Fi/SIM upstream exists after the clean
  wipe, but null upstream does not justify clearing the downstream address.
- r30 source correction: a metroid ServiceConnectivityResources RRO excludes only
  `usb0` from Ethernet's `(usb|eth)\d+` matcher while preserving `usb1+` and
  `ethN`. The compiled overlay targets the correct overlayable and retains the
  expected regex. Installed acceptance waits for the next coherent candidate.
- r35 installed result: NCM is active as gadget function `0x400`; the phone owns
  `10.205.201.184/24`, the host owns `10.205.201.209/24`, and bidirectional local
  ping passes. Ethernet's installed matcher is `(?!usb0$)(usb|eth)\\d+`, so it
  no longer claims `usb0`. Plain charging plus ADB was restored and `usb0` is
  down. IPv6/upstream, reconnect, HAL restart, MTP and RNDIS remain pending.
- Additional r28 result: standalone `ncm` again enumerates as `05c6:908c` and
  creates the host CDC interface. The timed autonomous return to ADB exposed a
  host udev/test-harness permission issue; manual gadget reset restored plain ADB
  as `18d1:4e11`, with both USB HALs running. Do not count reconnect/HAL restart
  complete from this attempt.
- Acceptance: NCM/NCM+ADB host enumeration, DHCP/DNS, IPv4/IPv6 traffic, cable
  reconnect, HAL restart, and ADB/MTP/RNDIS regressions.

### MTR-020: CPUSS sleep-residency counters are absent

- Severity: medium
- Status: evidence incomplete; prior proposed cause disproved
- Impact: suspend works, but CPU/cluster low-power residency accounting is absent.
- Evidence: the CPUSS sleep-stats driver fails to map the configured register and
  exposes no residency counters.
- Source: `kernel/nothing/sm8735/arch/arm64/boot/dts/vendor/qcom/tuna.dtsi:1790-1802`
- Stock comparison: NothingOSS tuna uses `0x178a0098` in both B4.1 `260414` and
  `260624`. The previously proposed `0x178b0098` belongs to `kera`, a different
  SoC/device, and must not be copied into metroid.
- Live localization (2026-08-12): coherent r22 exposes the exact stock-matching
  DT node and all ten resources, and both CPUSS modules are loaded, but
  `17800054.cpuss-sleep-stats` remains unbound with no debugfs tree. Historical
  boots report `-22`; the driver collapses any secure SCM configuration-register
  read failure to that value, so the first failing address is still unknown.
- Next action: use a separately reviewed non-promotable diagnostic kernel to log
  the first failing SCM read, then compare equivalent stock runtime behavior.
  Do not change a register address or include this question in r25.
- Acceptance: successful probe and counters increasing over repeated suspend.

### MTR-021: inherited init inventory contains dangling services and invalid work

- Severity: medium
- Status: bounded cleanup closed on installed r28
- Impact: normal boot attempts missing executables and imports, obscuring real
  failures and advertising unavailable QSPA, CHRE, QCC, factory, and helper paths.
- Evidence: a static normal-boot audit finds inherited RC entries whose
  executables or imports are absent from the accepted images.
- Source: `rootdir/etc/init.qcom.rc:506-517` and inherited vendor RC inventory.
- Fix direction: remove unreachable declarations or restore complete features;
  do not duplicate MTR-001, MTR-015, or MTR-016 as separate symptoms.
- Acceptance: zero unapproved normal-boot references to missing executables or
  imports across static audit and two boots.
- Source fix staged: replace the copied `vendor.qti.qspa-service.rc` that pointed
  to an absent executable with Qualcomm's source-built module, which owns the
  stock-matching RC and `IQspa/default` VINTF fragment. Focused build and VINTF
  validation pass; r17 registers `IQspa/default` across two boots. The r25
  extraction now drops five RC-only feature fragments and strips stale CAN,
  standalone ATFWD, eSE and CHRE declarations rather than importing incomplete or
  privacy-sensitive stock stacks. Fresh install-clean staging audits 265 RC
  files, 376 services and 81 direct execs with zero boot-harm, zero unconditional
  dangles and zero unknowns; VINTF compatibility and duplicate checks pass.
- r25 installed result: the bounded targets are absent, but normal class starts
  still attempt six missing services: `ptt_socket_app`, `vendor.perfservice`,
  `nqnfcinfo`, `qvop-daemon`, `qseeproxydaemon`, and `wifi_qos_daemon`.
  Therefore MTR-021 remains open and r25 is rejected for full promotion.
- r26 correction: remove only those six service stanzas while preserving unrelated
  RC actions; the classifier now treats `nonencrypted` as unconditional reachability.
- r28 installed result: two coherent boots have no service state or log attempt for
  `ptt_socket_app`, `vendor.perfservice`, `nqnfcinfo`, `qvop-daemon`,
  `qseeproxydaemon`, or `wifi_qos_daemon`; the staged audit remains at zero
  boot-harm, unconditional-dangle, and unknown findings.

### MTR-022: Aperture camera flip bypasses metroid video routing

- Severity: medium
- Status: coherent r22 runtime evidence retained; accepted-release promotion pending
- Impact: a front-to-back flip can reopen logical camera 4 while UHD or 60 fps is
  selected instead of the required physical main camera.
- Source: `packages/apps/Aperture/app/src/main/java/org/lineageos/aperture/viewmodels/CameraViewModel.kt:1255-1278`
- Source fix: video-mode flips route the selected facing through the same metroid
  selector used by normal quality/mode changes, using persisted video preferences
  rather than the front camera's temporary fallback configuration.
- Validation (2026-08-08): FHD30 returned `4 -> 1 -> 4`; FHD60 and UHD30 returned
  `0 -> 1 -> 0`. Finalized files were 1920x1080 at 30/60 fps and 3840x2160 at
  30 fps. UHD30 restored camera 0 after process restart. The provider remained
  PID 1395 with no camera crash or new tombstone.
- Live diagnostic validation (2026-08-09): the `/product` APK hash matches the
  audited r22 build, but slot A uses r21 `init_boot`. FHD60 returned `0 -> 1 -> 0`;
  UHD30 returned `0 -> 1 -> 0` and
  finalized a 6.63-second H.264/AAC 3840x2160/30 file. The provider remained PID
  1377 and no tombstone changed.
- OTA result: audited r22 SHA-256
  `e603ada70f0c717836475481622a826d9b09bee26ce53b5a208747dc7fdba9b5`
  booted coherent slot B, completed snapshot merge, remained Enforcing and
  encrypted, and preserved GApps. Later coherent-r22 camera evidence passed all
  five IDs, SAT zoom, torch, zoom while recording, and retained system-APK video
  checks without a new crash or tombstone. r22 remains unaccepted.
- Acceptance: front/back/front transitions at FHD30, FHD60, and UHD30 before
  recording and after process restart; verify camera ID and finalized files.

### MTR-023: face-enrollment guidance is blank outside English

- Severity: medium
- Status: r30 static and education-UI fallback accepted; full enrollment,
  accessibility, and parental-consent acceptance pending
- Impact: safety, education, and accessibility guidance supplied by the device
  overlay disappears under locales that ship explicit empty Settings strings.
- Source: device English overlay at
  `overlay/packages/apps/Settings/res/values/strings.xml:3-18`; representative
  empty locale values at `packages/apps/Settings/res-product/values-es/strings.xml:58-65`.
- Fix direction: implement a locale-safe upstream fallback or real translations.
  Do not label English text as translated content.
- r23/r24 disposition: rejected implementation. Commit `89dfc1c` covered only
  selected dynamic Java consumers and missed static headings, accessibility text,
  and parental-consent resources.
- r25 replacement: one shared resolver preserves non-empty localized text and
  falls back to truthful English without changing locale or layout direction;
  all dynamic, static, accessibility, and parental-consent consumers are covered.
  Settings and focused framework builds pass. `SettingsUnitTests` is currently
  blocked by unrelated pre-existing `SaveAndFinishWorkerTest` signature errors.
- r28 disposition: exact replacement is installed coherently across two boots;
  representative Latin, CJK, RTL, accessibility, and parental-consent UI remains
  to be exercised.
- French acceptance attempt: the installed Settings APK contains the complete
  fallback implementation and default English text while French resources are
  explicitly empty. Launching face enrollment under a temporary Settings-only
  French locale correctly reached the credential gate, but this target has no
  screen lock; no credential was created. The locale override was restored and
  visible enrollment guidance remains unaccepted.
- r30 result: the installed Settings APK matches the sealed candidate and contains
  12 shared-resolver call sites. Spanish, Japanese, and Arabic education UI renders
  non-empty localized titles/actions; Arabic mirrors the action order for RTL.
  The Settings-only locale override was restored. Direct root launch proves
  rendering but does not replace normal credential/enrollment acceptance.
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
- Evidence boundary: the retained `-107` immediately receives a valid response
  and success callback in the same screen-state transaction. Current and latest
  NothingOSS DTS are identical and matching driver source is unpublished. Do not
  guess delays, retries, GPIOs, IRQ polarity, I2C address or firmware.
- r35 bounded result: one disable/enable cycle returned to `mState=on` with the
  same NFC service PID. Transitional ST21 reads/writes again returned `-107`, so
  the cycle neither reproduces a user-visible failure nor clears the issue.
- Fix direction: reproduce against synchronized Lineage/stock transition traces.
- Acceptance: 100 toggles plus tag, HCE, payment, suspend, and charger-transition
  loops with no user-visible failure or recurring transport error.

### MTR-025: AudioFX framework binding targets a nonexistent service

- Severity: medium
- Status: r30 real-session lifecycle and reboot persistence accepted; perceptible
  effect remains pending
- Impact: audio sessions repeatedly fail to bind the MusicFX keepalive service;
  effect lifecycle and persistence may be unreliable.
- Evidence: repeated audio sessions fail to bind the framework-selected MusicFX
  keepalive component because that service is not installed.
- Source: framework binding at
  `frameworks/base/services/core/java/com/android/server/audio/MusicFxHelper.java:64-67,103-118`
  does not match the installed `packages/apps/AudioFX/AndroidManifest.xml:67-88`.
- Fix direction: align package/service discovery with the installed AudioFX
  implementation instead of repeatedly binding a nonexistent component.
- r23/r24 disposition: rejected implementation. The old carry exported the
  operational DSP/session-owning `AudioFxService` under the normal
  `MODIFY_AUDIO_SETTINGS` permission and bound it as an AOSP keepalive.
- r25 replacement: `AudioFxService` remains private; a dedicated inert exported
  `KeepAliveService` owns no DSP/session state, and framework tests assert the
  exact component. FrameworksServicesTests and AudioFX builds pass; merged
  manifest inspection confirms only the inert service is exported.
- r28 disposition: exact replacement is installed coherently across two boots;
  a normal media probe creates and restarts playback while AudioFX and its private
  session service remain alive without an observed crash or bind-failure loop.
  The framework's exact inert keepalive binding, perceptible effect, client-death
  cleanup, and reboot persistence remain to be accepted.
- r30 result: the maintained probe created real AudioTrack sessions. With AudioFX
  in its normal non-stopped persistent state, framework receiver discovery and
  UID/session tracking pass; QTI/NXP Equalizer, BassBoost, Virtualizer, and Preset
  Reverb chains attach to the exact sessions. Explicit CLOSE removes all effects.
  Force-stopping the probe triggers `MSG_EFFECT_CLIENT_GONE`, closes all sessions,
  and removes the chain. Speaker preferences remain byte-identical across reboot,
  and a post-reboot session/death cycle passes. The probe was removed and media
  volume restored. AudioFX's persistent procState means inert keepalive binding is
  correctly unnecessary in this live state; audible change remains unmeasured.
- Acceptance: effect open/close, playback, client death, reboot persistence, and
  no bind failures.

### MTR-026: GMS Password Checkup mixed-state crash gate

- Severity: high release gate
- Status: cleared on coherent r22; recurring candidate gate
- Evidence: four GMS Password Checkup fatalities occurred only when r22
  system/vendor/product were booted with r21 slot-A `init_boot`.
- Coherent result: three retained coherent-r22 boots on slot B produced zero GMS
  fatalities, no new tombstone or Dropbox crash, preserved the Google account,
  and kept GMS and Play Store processes healthy.
- First deterministic divergence: operator-created boot-chain skew, not a
  coherent ROM, GApps, or preserved-data defect.
- Acceptance: repeat the two-boot crash-hygiene gate on every promotable
  successor candidate.

### MTR-027: Google Play Protect uncertified-device policy

- Severity: external distribution/policy gate
- Status: externally blocked; not a proven ROM defect
- Evidence: coherent r22 on slot B displays `This device isn't Play Protect
  certified` and blocks access to the Play Store storefront.
- r28 result: GMS and Phonesky are installed, running, network-capable, and
  crash-clean, but launching Phonesky deterministically selects
  `com.google.android.gms.gmscompliance.ui.UncertifiedDeviceActivity` again.
- r35 split result: updated Phonesky 52.6.26 was installed and enabled but had
  `stopped=true`, so no launcher resolved. After normal package/component-state
  normalization, launch was crash-free and Google selected the same uncertified
  activity. The stopped-state setter remains unknown and is a separate evidence
  gap, not a certification result or an eligible ROM fix.
- First local divergence from stock: custom Lineage build/AVB identity, root
  vbmeta flag `1`, and orange/unlocked verified-boot state. The exact Google
  server-side decision and private registration status are not locally observable.
- Policy: retain `UNCERTIFIED-BLOCKED`; do not spoof fingerprints, attestation,
  package state, boot state, or AVB, and do not present private device
  registration as ROM certification.
- Lawful access path: Google's official custom-ROM registration page may grant
  storefront access to this one device. Record that only as `REGISTERED-DEVICE
  ACCESS`; it does not certify the ROM or imply any Play Integrity verdict.
- Acceptance: record package launch state first. Use `PACKAGE-LAUNCH-BLOCKED` for
  an absent/unresolved launcher and `UNCERTIFIED-BLOCKED` only after a valid
  launch reaches Google's policy activity. Do not clear data or remove updates
  as part of the initial test.

### MTR-028: recovery ADB sideload progress does not report install completion

- Severity: P0 recurring release gate
- Status: misleading 47-percent host display fixed in source; real sideload
  acceptance pending; install outcome must still be correlated
- User-visible symptom: host progress commonly stops near 47 percent and may
  print `adb: failed to read command: Success`, making a completed transfer look
  incomplete.
- First deterministic divergence: recovery reads the ZIP on demand through FUSE,
  while host ADB estimates progress as bytes served times 47 divided by package
  size. Roughly one package-length therefore displays near 47 percent. The EOF
  warning means the host did not receive the final eight-byte terminal token; it
  does not establish recovery success or failure.
- Classification: upstream host UX defect, not an incomplete-install defect.
  Retained installs through r28 completed target-slot activation and coherent
  boots despite near-47-percent output.
- Host source fix: `packages/modules/adb` now counts first-time coverage of each
  requested package block. Repeated verification/installation reads do not
  inflate progress; out-of-order requests remain monotonic; and the partial final
  block reaches exactly 100 percent. The display no longer uses the 47 multiplier
  or approximate marker. Linux and Windows host ADB builds pass, including
  103/103 host tests and focused duplicate/out-of-order/partial-block coverage.
- Scope: this reports transfer coverage only. It does not claim recovery install
  progress and does not alter normal-sideload result semantics.
- Gate: record exact ZIP SHA-256, host output, recovery final status, automatically
  selected target slot, update/snapshot state, slot success, encrypted userdata,
  Enforcing SELinux, and first and second coherent boots. A transfer that never
  enters sideload is `NOT STARTED`; host completion without recovery final status
  is `OUTCOME UNCORRELATED`; only an explicit recovery/update failure, failed
  merge/slot, rollback, or failed coherent boot is `INSTALL FAILED/INCOMPLETE`.
- r28 result: host display stopped at 47 percent without a terminal token, while
  recovery's additional-packages prompt established ROM success and the exact
  GApps sideload returned `Total xfer: 1.00x`. The target then booted coherently
  twice on slot B. Validate the patched host on the next already-planned sideload.
  Keep a separate upstream minadbd terminal-token improvement open; do not
  mislabel byte-serving progress as install progress.
- r29/r30 result: the patched host transfer reached 100 percent during the r29
  recovery sideload. The exact sealed r30 OTA then installed through Android
  update_engine with `kSuccess (0)`, automatically activated slot A, preserved
  GApps, reached snapshot state `none`, marked slot A successful, and booted
  coherently more than twice.

### MTR-029: QTI Mapper5 debug logging reads freed buffer handles

- Severity: high
- Status: property fix installed on r35; preview stability passes, finalized
  ten-cycle acceptance pending
- Impact: sampled GWP-ASan detection can terminate Aperture while Codec2 submits
  camera video buffers, leaving a native tombstone despite otherwise successful
  FHD/UHD recording.
- Evidence: r30 Aperture tombstone at 2026-08-14 15:13 reports a use-after-free
  56 bytes into a handle in `QtiMapper5::freeBuffer`, followed by
  `GetHdrMetadataFromGralloc4Handle`, `C2NodeImpl::submitBuffer`, and
  `GraphicBufferSource`. Later retries finalized FHD30, FHD60, and UHD30, so the
  crash is sampled and is not cleared by successful reruns.
- First divergence: metroid sets `vendor.gralloc.enable_logs=1` while Nothing
  stock sets `0`. `QtiMapper5::freeBuffer` calls `snap_helper_->Free(buffer)` and
  then the enabled debug log dereferences `QTI_HANDLE_CONST(buffer)->id`.
  Installed mapper/gralloc binaries are stock-identical; no Aperture, Codec2,
  camera HAL, kernel, or blob replacement is justified.
- Source fix: restore stock `vendor.gralloc.enable_logs=0`; retain the source
  upstreaming opportunity to capture the ID before `Free` or avoid the post-free
  dereference.
- r35 installed result: the property is `0`; Aperture preview and multi-camera
  processing ran with stable camera-service PIDs and no Mapper5/GWP-ASan crash or
  new tombstone. Intent automation did not create a trustworthy finalized still
  or clip, so this bounded result does not satisfy the ten-cycle acceptance gate.
- Acceptance: two coherent boots, property `0`, ten ordered FHD30/FHD60/UHD30
  Aperture cycles with rear/front/rear routing and finalized H.264/AAC clips,
  stable camera services, and no new crash, tombstone, AVC, or pstore record.

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
11. The exhaustive operation-level inventory and latest measured status live in
    `HARDWARE_ACCEPTANCE.md`; unlisted service presence is not acceptance.

## Closed in accepted baseline

- Wi-Fi 7 6 GHz/320 MHz association, transport, screen-off retention, and PNO
  reassociation.
- NFC clean-state bootstrap, toggle, card polling, and HCE routing capability.
- Face enrollment/authentication and English guidance.
- GNSS raw measurements and indoor satellite fix.
- Perf HAL WALT access without the prior AVC.
- Wireless charging detection and short unplugged auto-suspend with blockers
  released.
