# Metroid - Updated build audit / baseline tracker

This file is updated each revision. It records: the build artifact state, what
passed/failed/broken, source/revision evidence, image verification details, and the
next steps. Do not treat a service registration or binder presence as a
functional acceptance result.

================================================================
Latest recorded seed (historical, non-promotable)
================================================================
- Build label: r24 (historical public test seed; not a T4 candidate)
- ROM file: `lineage-23.0-20260811-UNOFFICIAL-metroid.zip`
- ROM SHA-256: `50143f9e8481cd0211def4aba5776246f46fa68c0a991fb8961be45608361e98`
- Build date UTC (from ramdisk build.prop): `Tue Aug 11 08:59:43 EDT 2026` (1786453183)
- Source tag / revision for device/nothing/metroid: `2301da8`
- Source revision for kernel/nothing/sm8735: `ce342da8315a`
- Source revisions verified against device branch logs: frameworks/av
  `113ccbf1...`, build/soong `b4bbdf59...`, packages/apps/Aperture
  `db454eb0...`
- Root vbmeta flag: `1` (hashtree disabled; verification enabled)
- Release status: RELEASE-BLOCKED / NON-PROMOTABLE. It predates the mandatory
  build-state provenance gate and lacks an independent payload-equivalence
  audit. The accepted release remains `releases/current/` ->
  `candidate_20260808_192539_leaudio-r21`
  (r21 build `23.0-20260808-UNOFFICIAL-metroid`, SHA-256
  `e26956f003ceea3923d847515e2943dc8bbf4505533cbae726d36bc167f968db`).
- r24 was produced incrementally over the r23 build. It was not install-clean,
  and no build-time source/artifact attestation binds it to the recorded source.
  Its stated delta is MTR-021 init service disables (`vendor.atfwd`, `chre`,
  `nt_key_monitor` disable gates; no executable shipped for the last two in this
  ROM build).

================================================================
Build artifact audit (r24) - partial; release gate failed
================================================================
- ROM ZIP hash verified (`sha256sum` matched `50143f9e...`).
- Payload-equivalence audit: NOT independently executed for r24; the r24
  JSON reports `hash-and-boot-image-only-per-maintainer; no payload-equivalence`
  run. The `releases/current` verified snapshot (`r21`) DID confirm 16/16 payload
  equivalence.
- AVB / signing: `META-INF/com/android/otacert` and `vbmeta-avb-info.txt` are
  present in the seed package, but no retained cryptographic whole-file/payload
  signature verification exists for r24. `system/vendor/init_boot` vbmeta kept at
  measured stock-chain SPL `2025-04-05`; `ro.build.version.security_patch` in
  boot ramdisk reports `2026-02-01`; `ro.vendor.build.security_patch` reports
  `2025-06-05`.
- Root vbmeta flags: `1` confirmed in seed metadata; NOT `2` (verification
  disabled) - correct.
- Build fingerprint / props match metroid build recipe: `ro.build.id=BP2A.250805.005`
  (Nothing stock A16 id), `ro.product.device=metroid`, `ro.product.name=lineage_metroid`.
- SELinux: enforcing (not explicitly verified in r24 live state; accepted r21
  baseline confirmed Enforcing).
- GApps companion: `MindTheGapps-16.0.0-arm64-20260409_073023.zip` (SHA-256
  `a6ff8b8c31f7ccd0a9f2fd651fa4438a8e39a5f63b95be246ea1f98982af2c28`).
  Must be sideloaded from NEW-slot recovery BEFORE first Android boot; not
  embedded in ROM.
- Modem: NOT in ROM. Matches accepted r21 baseline: exact stock A16 modem
  filesystem (`MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.126608.2.134544.2`) must be
  present on both modem slots before flashing. Mixed modem generations cause
  QCRIL/LPA EID failure (not a ROM bug).
- The r24 record reports a clean source tree, but it has no build-time manifest
  attestation and therefore cannot prove that the recorded commits produced the
  ZIP.

================================================================
Source-level delta comparison (r21 accepted -> r24 seed)
================================================================
Verified in `lineage/device/nothing/metroid` source and built artifacts:

Source/image presence (installed status is stated separately):
- MTR-001 (QTI radio VINTF) - installed since r4; registers in source.
- MTR-002 (IMS `org.codeaurora.ims`) - installed since r4.
- MTR-003 (eSIM LPA/Euicc) - installed since r17; EuiccManager enabled.
- MTR-004 (Power HAL AIDL) - installed since r4.
- MTR-005 (thermal / `sltntc` + stock thermal HAL) - framework path fixed r7.
- MTR-006 (launch API `first_api_level=35`) - fixed r4.
- MTR-007 (security-patch metadata / `ro.bootimage.build.version.security_patch`)
  - fixed r5; verified in r24 ramdisk build.prop (`2026-02-01`). Note: boot/init
  AVB descriptors retain measured stock-chain SPL `2025-04-05` separately.
- MTR-009 (Nothing charge-policy HAL / `vendor.noth.hardware.charge.ICharge`)
  - installed r20; HAL binary matches A16 (`c8c3402a...`), VINTF fragment
  present, dedicated SELinux domain, no charge-node AVC across two boots.
- MTR-010 (LE Audio profile family enabled) - installed r21; properties true.
- MTR-012 (Aperture EIS hidden / routing fix) - installed r22.
- MTR-013 (media-quality lookup loop) - fixed r5.
- MTR-014 (GNSS property AVC / typed `set_prop`) - fixed r5.
- MTR-023 (face-enrollment locale-safe fallback) - `BUILT-NOT-INSTALLED` in r23
  (`packages/apps/Settings 89dfc1c`); present in the r24 Settings APK but not
  validated on a device.
- MTR-025 (AudioFX framework keepalive binding) - `BUILT-NOT-INSTALLED` in r23
  (`frameworks/base 9a8ec9477`, `packages/apps/AudioFX 1e3f198`); the AudioFX APK
  is present in the r24 image but has no installed functional acceptance.
- MTR-021 (init dangling services audit / disable gates): the r24 image applies
  property-based disable gates for `vendor.atfwd` and `chre`; `nt_key_monitor`
  does not appear in its target-files. Historical counts came from the superseded
  init classifier. Rerun the maintained classifier on a successor frozen
  candidate before drawing a release verdict.

Still active / open (NOT fixed in r24; confirmed via BUGS.md + HARDWARE_ACCEPTANCE):
- MTR-011 (haptics degraded): source unchanged; primitives report zero duration,
  `TEXTURE_TICK` silent. Not fixed in r24; requires stock effect/primitive
  recovery (not an init/config fix).
- MTR-015 (QCC location assistance): QCC vendor service absent; XTRA retries
  unavailable service. Not fixed.
- MTR-016 (sensor-extension service disabled): service not installed; requires
  proprietary framework (`system/framework/nt-services.jar`) integration before
  any restore - rejected for this build.
- MTR-018 (UDFPS refresh order race): not fixed; requires 120 Hz before LHBM.
- MTR-019 (USB NCM function name mismatch): `init.qcom.usb.rc` uses `ncm.0`,
  `UsbGadget.cpp` links `ncm.gs6`. Not changed.
- MTR-020 (CPUSS register address): published `tuna.dtsi` carries `0x178a0098`;
  `0x178b0098` is from `kera` (different SoC). No source change applied.
- MTR-024 (ST21 NFC `ENOTCONN` during power transitions): still open.
- MTR-026 (GMS Password Checkup crash on mixed-state boot): every observed
  operator-created r22-userspace/r21-`init_boot` boot reproduced four
  `ModuleInitializer` fatalities (`SERVICE_INVALID`). Repeated coherent-r22 boots
  on slot B are crash-clean. The r24 init-disable delta is unrelated to that first
  divergence; the next sealed successor needs the same coherent regression gate.
- MTR-027 (Play Protect certification/storefront): coherent r22 reaches Google's
  uncertified-device blocking activity. Earlier package/account/process retention
  did not test storefront entry. This is external Google certification policy,
  not a supported ROM-side spoofing target; see `PLAY_CERTIFICATION.md`.

Blocked / requires external input (NOT ROM bugs):
- Play Protect certification (MTR-027): the current unofficial custom build is
  blocked as uncertified. Formal certification is unavailable; Google's official
  private per-device registration path, if offered, cannot support a ROM-wide
  claim. Never collect or publish Android/GSF ID.
- Physical-SIM testing (MTR-001/MTR-002 acceptance remaining): requires active
  SIM + carrier. IMS infrastructure is installed but not validated with live
  subscriptions.
- Real eSIM profile activation (MTR-003 remaining): requires carrier activation
  code + credentials. UI verified through QR scanner; download/enable/reboot/delete
  remain unverified.
- Physical SIM/eSIM coexistence, dual-SIM routing, VoLTE/VoWiFi.
- USB OTG / USB-C audio / headset buttons / DisplayPort / USB Ethernet (need
  accessories).
- NFC payment/off-host (needs real terminal + HCE applet); MTR-024 remains open.
- Hardware keystore / TEE / StrongBox.
- Real LC3 LE Audio accessories (service initialization verified; playback not
  tested with real buds).
- Full camera matrix: FHD30 video routing (r21 partial), zoom while recording,
  SAT intermediate zoom, EIS/stabilization (intentionally disabled), zoom
  transition, long-run thermal, front/rear/UHD30 combined cycle. Aperture FHD30
  routing (`4 -> 1 -> 4`) and FHD60/UHD30 (`0 -> 1 -> 0`) verified only with
  temporary/system APK in mixed-state diagnostics, NOT on a coherent clean build.
- Haptics full matrix (MTR-011): primitives/effects/composition/amplitude need
  real perceived-output testing; no ROM change available.
- Thermal/charging matrix (MTR-005): framework thermal path verified; controlled
  unplugged load, thermal severity, cooling/display derating, charging policy
  transitions, hot-battery, wireless/reverse charge all remain unverified. The
  retained 48-49 C event (r21 baseline retention) is a real event that requires
  measurement before any claim is made.
- Long-duration unplugged percentage drain / battery curve.
- Destructive release tests: factory reset / FBE / recovery decrypt-format / rollback.

================================================================
Hardware/software audit (r24 - what the source and built image say)
================================================================
Software / framework / init / system:
- Build fingerprint / version / date / device: matches metroid + A16 base; build
  date is Aug 11. The recorded source state is not bound to the artifact.
- `lineage-23.0-20260811-UNOFFICIAL-metroid` in `build.prop`.
- `product.prop` / `system.prop` carry device properties; `ro.hw_timeout_multiplier=4`
  preserved per device AGENTS.md invariant.
- Init service inventory (`init.qcom.rc` + device RCs): `vendor.atfwd` and
  `chre` have disable gates (`persist.vendor.radio.atfwd.start=false` and
  `vendor.chre.enabled=0`). `vendor.atfwd` binary (`ATFWD-daemon`) is present in
  `vendor/bin/`; `chre` binary (`chre`) is present in `vendor/bin/`. The audit
  result that called missing auto-started classes conditional is superseded. The
  corrected `triage_init_rc_missing.py` must pass on successor staging before
  freeze. `nt_key_monitor` is absent from the r24 target-files; image presence
  alone does not establish a clean normal-boot inventory.
- `vendor.qti.qspa-service.rc` is rebuilt from Qualcomm source module (not the
  old copied absent RC); `IQspa/default` VINTF fragment present.
- Power HAL VINTF fragment (`android.hardware.power.IPower/default`) present.
- QTI radio standalone fragments installed; IMS bindings verified in accepted
  r21; not re-tested in r24.
- AudioFX APK (`system_ext/priv-app/AudioFX/AudioFX.apk`, framework binding fix
  present) is in the r24 image, not installed or functionally accepted.
- Settings APK (`system_ext/priv-app/Settings/Settings.apk`, MTR-023 locale-safe
  face-enrollment guidance fallback) is in the r24 image, not installed or
  functionally accepted.

Image-level / payload-level verification (not independently executed for r24):
- The audited r21 snapshot (`releases/current/` -> `candidate_20260808_192539_leaudio-r21`)
  confirms: 16/16 payload equivalence, AVB chain verifies, payload-properties
  correct, payload-images match target-files, `VERIFICATION.txt`, `VBMETA_*`
  and `payload-equivalence.txt` all consistent.
- The r24 seed (`releases/xda_seed_20260811_r24/`) provides `SHA256SUMS`,
  `INSTALL.txt`, `XDA_TESTER_CHECKLIST.md`, `NOTICE.txt`, and the ROM ZIP
  (`lineage-23.0-20260811-UNOFFICIAL-metroid.zip`) with verified hash. It does
  NOT contain an independent payload-equivalence file; that remains the gap that
  cannot be filled retroactively under the provenance gate. Build a successor
  frozen candidate before any release claim can replace r21.
- The `lineage/` build output (`lineage/out/target/product/metroid/`) confirms
  `system/build.prop`, `vendor/build.prop`, and `ramdisk/system/etc/ramdisk/build.prop`
  contain the correct dates/properties; the boot image (`boot.img`) is built.
  The r24 public JSON reports a successful `m bacon`; it is not a build-state
  attestation and does not satisfy T4.

Hardware verification (live installed evidence):
- Live evidence in this workspace covers the r21 accepted baseline, historical
  mixed-state r22 diagnostics, and coherent-r22 slot-B crash/camera checks. There is no
  `hardware_acceptance_20260811_r24` or equivalent private live-evidence folder
  for the r24 seed. Do not create it now; use a sealed successor.
- The `lineage/device/nothing/metroid/HARDWARE_ACCEPTANCE.md` matrix (updated at
  commit `2301da8`) distinguishes r21 verified rows from r22 diagnostic rows. The
  r24 seed has no promotable live state. Any existing tester result remains
  diagnostic evidence; installed acceptance for shipping must use a successor
  audited candidate.

================================================================
Next steps / required actions (before any new release claim can be made)
================================================================
1. Preserve any existing r24 tester result as diagnostic, non-promotable
   evidence. Do not make an r24 release claim.
2. Freeze a successor candidate with a committed record containing companion
   hashes and the affected-test union. Use the full candidate-wrapper invocation
   in `VALIDATION_WORKFLOW.md`, then run `/candidate-gate` and `/release-seal`.
3. After explicit install approval, validate the exact sealed successor:
   - Two clean boots on the successor (with r21 init_boot NOT present, clean slot A or B,
     not mixed-state).
   - MTR-026 crash hygiene: zero `PasswordCheckup.ZERO_PARTY_API SERVICE_INVALID`
     fatalities on both clean boots.
   - MTR-027 certification/storefront: open Play Store and record either the
     exact blocking headline or, if accessible, the Settings certification text.
     Then require storefront entry plus small and >200 MB installs. "Play Protect
     ON," package presence, or account retention is not a pass. If the
     uncertified block appears, report `UNCERTIFIED-BLOCKED`; do not expose an
     Android/GSF ID or attempt a spoofing bypass.
   - eSIM profile: real activation code download + enable/reboot/delete; EID
     presence verified in `About phone`.
   - Physical SIM: live calls, SMS, MMS, LTE/5G data, VoLTE (`*#*#4636#*#*` IMS
     registration line), VoWiFi, dual-SIM routing, airplane toggle, hot-swap.
   - NFC: repeated toggle + real terminal payment; no ENOTCONN regression.
   - AudioFX: bind succeeds, effect applied, no bind-failure loop.
   - Regression: face unlock, two boots, Wi-Fi 7 MLO, haptics, camera 3 lenses.
4. Source / build verification for the successor:
   - Independent payload-equivalence audit (`16/16` images verified).
   - `check-vintf-all` verified in successor source (not just r21 snapshot).
   - `triage_init_rc_missing.py --summary` confirms the classified shipped-init
     inventory after the r24 delta; future candidates use `/candidate-gate`
     before `/release-seal`.
   - `repo status` clean; `patches/series.conf` carries documented.
5. If installed validation and every release gate pass:
   - Promote the already sealed successor snapshot with `VERIFICATION.txt`,
     `SHA256SUMS`, payload equivalence, source state, and VINTF audit.
   - Update `lineage/device/nothing/metroid/BASELINE.md` with the new OTA hash,
      exact successor source revisions,
     GApps version/hash, modem version/hash, slot (A or B), VINTF state,
      SELinux Enforcing, encryption state, crash buffer empty, new tombstones
      none, and the new `live_state` description (coherent successor, not
     mixed-state r22 system / r21 init_boot).
   - Only after that: publish updated public release notes.

================================================================
Quick reference fields (update each revision - copy this section to the top after confirmation)
================================================================
| Field | Value (r24 seed, Aug 11 2026) |
|---|---|
| ROM label | r24 (historical public test seed; non-promotable) |
| ROM file | `lineage-23.0-20260811-UNOFFICIAL-metroid.zip` |
| ROM SHA-256 | `50143f9e8481cd0211def4aba5776246f46fa68c0a991fb8961be45608361e98` |
| Source device rev | `2301da8` (device/nothing/metroid) |
| Source kernel rev | `ce342da8315a` (kernel/nothing/sm8735) |
| Build date UTC | 1786453183 (Tue Aug 11 08:59:43 EDT 2026) |
| Root vbmeta flag | 1 |
| Release claim | NO - release gate failed; diagnostic seed only. |
| Accepted baseline | r21 (`candidate_20260808_192539_leaudio-r21` / `e26956f...`) |
| GApps add-on | `MindTheGapps-16.0.0-arm64-20260409_073023.zip` (`a6ff...`) |
| Modem required | A16 `MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.126608.2.134544.2` on both slots |
| Source provenance | UNBOUND - no build-time manifest/artifact attestation |
| Payload equivalence | NOT independently audited for r24 (only r21 snapshot has `16/16`) |
| AVB chain | Verified offline (r21); r24 has no retained complete signature/payload audit |
| GMS fatality (MTR-026) | Re-run on the next sealed successor; r22 mixed-state diagnosis reproduced 4 fatalities |
| Play certification (MTR-027) | `UNCERTIFIED-BLOCKED` on coherent r22; no legitimate ROM-side bypass and no prior r21 storefront pass retained |
| Thermal/charging (MTR-005 / MTR-009) | Framework thermal path verified (r7); charge HAL verified (r20); full matrix remains open |
| Haptics (MTR-011) | NOT fixed in any source revision through r24 |
| AudioFX (MTR-025) | `BUILT-NOT-INSTALLED`; APK present r24; live acceptance open |
| Face locale (MTR-023) | `BUILT-NOT-INSTALLED`; APK present r24 |
| Init audit (MTR-021) | r24 applies disable gates (`atfwd`, `chre`); `nt_key_monitor` binary absent |
| Testing focus | GMS / eSIM profile / SIM / NFC / audio-effect / regression / clean two boots |

================================================================
Notes about previous revisions (retained for tracking; do not reuse as current instructions)
================================================================
- r21 (`candidate_20260808_192539_leaudio-r21`, `e26956f...`): ACCEPTED baseline.
  Enforcing SELinux, encrypted `/data`, two boots, clean crash buffer.
  LE Audio profiles restored, charging-policy HAL installed, GNSS/media fixes.
- r22 (`candidate_20260808_223438_camera-r22`): NOT accepted as release.
  Audited r22 booted coherent slot B, snapshot merge completed, preserved GApps,
  and is crash-clean across repeated coherent boots. Google blocks its Play Store
  storefront as uncertified. Manual slot-A reactivation created a mixed state
  (r22 system/vendor/product + r21 `init_boot`) that reproduced four GMS Password
  Checkup fatalities.
- r23 (`candidate_20260810_201016_audiofx-face-r23`, `e262e83e...`): full install-clean
  build carrying incomplete/unsafe MTR-023 and MTR-025 implementations. It was
  not flashed and both implementations are rejected; r25 replaces them.
- r24 (`releases/xda_seed_20260811_r24/`, `50143f9e...`): incremental over r23; delta
  MTR-021 init disables (atfwd/chre/nt_key_monitor). Historical public test seed;
  no verified live state, payload equivalence, or build-state provenance. It is
  non-promotable.

================================================================
File provenance / verification notes (do NOT commit secrets or proprietary keys)
================================================================
- ROM hash: verified locally (`sha256sum` matched SHA256SUMS).
- GApps hash: verified locally.
- Source commit references (`2301da8`, `ce342da8315a`, `9ab75995e` etc.) are from
  the public local manifest; they match `lineage/metroid` release notes.
- The `releases/current` symlink still points to `candidate_20260808_192539_leaudio-r21`
  (r21); r24 must never replace it. Only a sealed, accepted successor may do so.
- Private vendor source (`vendor/nothing/metroid`) is maintained separately and is
  not published; this audit references only public device-tree changes.
- Stock modem backups (`/tmp/opencode/metroid-modem-backup/`) are private; no
  modem file hash is included here.
- No private signing/AVB keys are recorded here. The r24 key material and
  signatures were not fully verified by the retained audit evidence.
