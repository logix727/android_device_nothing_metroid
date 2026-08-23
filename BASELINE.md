# Maintainer-local accepted baseline

This is private target-device acceptance evidence, not a redistribution claim.
The tested state combines a ROM OTA, separately sideloaded Google add-on, and
separately flashed matching stock modem firmware.

This records the accepted public r48 release. The current maintainer device runs
r49 (`1787430715`) on slot B as a locally accepted external-test candidate; r49
does not replace the public baseline until Tele2 and inserted-SIM2 gates pass.
The accepted public build runs
`23.0-20260821-UNOFFICIAL-metroid` (incremental `1787327311`) on successful slot
A from `releases/candidate_20260821_121653_317252161_candidate/`; OTA SHA-256
`5e79b012fb8063b09f4a3fde48b5241470c6b2fb55b0acf0d39bc334fd66d581`.
r48 is encrypted and Enforcing, preserves GApps and the active Dark Star eSIM,
and passes two boots, boot-loaded TIPC, automatic mode 26 and `ereseller`,
IPv4/IPv6 data, `NR_NSA`, IMS call, QCC domain/linker closure, empty pstore and
no QCC crash/AVC. SMS/MMS passed on the same unchanged carrier/radio stack before
the QCC-only r47 delta. Google certification remains externally blocked.

## ROM

- Version: `23.0-20260821-UNOFFICIAL-metroid`
- Build date UTC: `1787275251`
- OTA: `lineage-23.0-20260821-UNOFFICIAL-metroid.zip`
- OTA SHA-256: `5e79b012fb8063b09f4a3fde48b5241470c6b2fb55b0acf0d39bc334fd66d581`
- Verified snapshot: `releases/candidate_20260821_121653_317252161_candidate/`
- Accepted slot when recorded: A
- SELinux: Enforcing
- Data: encrypted
- Root vbmeta flags: `1` (hashtree disabled for recovery add-ons; verification
  remains enabled)
- Two boots: passed
- QCC crash/AVC: none across two boots
- Pstore: empty

## Required companion inputs

### Modem firmware

- Both `modem_a` and `modem_b` contain the complete stock A16 modem filesystem.
- Build: `MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.152387.2.170946.5`
- Source evidence: `references/upstream/dump_a16/modem/`
- Companion image SHA-256:
  `35f2476e03a3f3353c1db999b88a075ffd30ebb0f006e3498c96b1d6e27ed0a3`
- Construction was verified with `fsck.vfat` and an exact recursive content diff.
- Pre-change backups are private under `/tmp/opencode/metroid-modem-backup/`:
  - modem A: `2cc0c5a181dd01ab0aecda37ede38ad4c0ad1a8eabddbb5fe493d32a93c7ecc0`
  - modem B: `204392c542970337f28325ed0331de7484cf11bf8bc5cf51be0ba6db5b26522e`

### Google add-on

- Package: `MindTheGapps-16.0.0-arm64-20260409_073023.zip`
- SHA-256: `a6ff8b8c31f7ccd0a9f2fd651fa4438a8e39a5f63b95be246ea1f98982af2c28`
- Installed from r17's new-slot recovery after the ROM OTA and before Android boot.
- Base GMS, Play Store, Wellbeing, permission XML, default-permission XML, and
  sysconfig files are present. Google account state survived the upgrade.
- Recovery ROM sideload does not run addon.d on this A/B device. Repeat the GApps
  sideload after every ROM OTA or updated `/data/app` Google packages can survive
  without their base APK/policy and crash at boot.

## Verified deltas

- IMS/QTI radio services bind on both slots; MMTEL and emergency MMTEL register.
- Power HAL, QSPA, camera provider, GNSS, thermal skin/headroom, and `sltntc` run.
- Nothing charging-policy HAL uses the exact A16 binary/RC, registers as
  `vendor.noth.hardware.charge.ICharge/default`, runs in a dedicated Enforcing
  domain across two boots, and has no remaining charge-node AVCs.
- r20 was installed from Android through normal-system update_engine. Lineage
  `backuptool_ab` preserved MindTheGapps, addon.d, Google permission/sysconfig,
  GMS, and Play Store without recovery interaction.
- r21 restores the stock LE Audio profile family. BAP assistant, CSIP, HAP,
  LE call control, MCP, VCP, and LE Audio services start across two boots with
  ISO manager/HAL initialization and no Bluetooth AVC/crash.
- Launch API and boot-image SPL metadata are corrected.
- GNSS property and MediaCodec media-quality lookup defects remain fixed.
- eSIM: native `EuiccManager` is enabled across two boots; Google SIM Manager
  reaches **Set up an eSIM**, transfer chooser, and QR scanner using the standard
  framework path with no telephony compatibility carry.
- Matching A16 modem firmware fixed the prior generic EID failure caused by mixed
  modem/MCFG generations.

## Unverified / blocked

- Real eSIM activation-code download, enable/disable, reboot persistence, deletion,
  transfer, and physical-SIM coexistence.
- Physical SIM calls, SMS/MMS, data, IMS features, emergency UI, DSDS, and OMAPI.
- Controlled thermal severity/cooling/display behavior after the retained 48-49 C
  unplugged-use event.
- Aperture stabilization and full r35 finalized-video stability, LE Audio,
  haptic parity, NFC tag/payment/off-host, USB-C audio, physical-SIM operation,
  and long-duration suspend drain.

## Source revisions

Full accepted source state is sealed under the r48 verified snapshot. Primary
revisions:

| Project | Revision |
|---|---|
| `device/nothing/metroid` | `ece6095006051aa9feea39b6ed257808b0c04168` |
| `vendor/nothing/metroid` | `62a5802800e0e31a75a6bd5b56e798ef42c9e1ec` (private) |
| `kernel/nothing/sm8735` | `aeb23d327717f9f4820f1ba5b1436fd401089a36` |
| `bootable/recovery` | `e37118daa2ba496c6db14069bc304d412e470e61` |
| `packages/modules/adb` | `5468a11bced5023cff45c4d988994a30b684b732` |

Post-r48 workflow/record commits are not part of the accepted OTA until the exact
audited successor is installed and accepted.
