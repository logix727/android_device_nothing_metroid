# Maintainer-local installed baseline

This is private target-device acceptance evidence, not a redistribution claim.
The tested state combines a ROM OTA, separately sideloaded Google add-on, and
separately flashed matching stock modem firmware.

## ROM

- Version: `23.0-20260808-UNOFFICIAL-metroid`
- Build date UTC: `1786152646`
- OTA: `lineage-23.0-20260808-UNOFFICIAL-metroid.zip`
- OTA SHA-256: `d5098df075e52e89ce61d35db2dbdecfd917b6bc1b899ce9b3d740d843c00243`
- Verified snapshot: `releases/candidate_20260807_223220_esim-stockfw-r17/`
- Installed slot: A
- SELinux: Enforcing
- Data: encrypted
- Root vbmeta flags: `1` (hashtree disabled for recovery add-ons; verification
  remains enabled)
- Two boots: passed
- Crash buffer: empty
- New tombstones: none; retained 19:44 tombstone was maintainer-induced before r17

## Required companion inputs

### Modem firmware

- Both `modem_a` and `modem_b` contain the complete stock A16 modem filesystem.
- Build: `MPSS.DE.7.0-02698-PAKALA_GEN_PACK-1.126608.2.134544.2`
- Source evidence: `references/upstream/dump_a16/modem/`
- Constructed VFAT image SHA-256:
  `d53a062a749e83d5854ab17a5aa5680d27c7b1e1970ee7112e71036b1d7b2a5f`
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
- Aperture stabilization/routing, LE Audio, haptic parity, NFC payment/off-host,
  USB-C audio, and long-duration suspend drain.

## Source revisions

Full source state is sealed under the r17 snapshot. Primary revisions:

| Project | Revision |
|---|---|
| `device/nothing/metroid` | `d5d23f4ade652d376be4f5832bc3c8086ecf1b27` |
| `vendor/nothing/metroid` | `71ac13e56db7e88faf6775ba5726283cf1aba731` (private) |
| `kernel/nothing/sm8735` | `ce342da8315a62e6144882faeddbdeccda544f9b` |
| `build/soong` | `b4bbdf5956a788ab60921bd71421b1c9be31a8f0` |
| `frameworks/av` | `113ccbf172d572086818456a41b62809c38a0ac0` |
| `packages/apps/Aperture` | `db454eb0525be0b59bee2c32030df3fd7d553eb5` |

Post-r17 record commits are not part of the installed OTA. Update this baseline
only after another audited OTA and all required companion inputs are accepted.
