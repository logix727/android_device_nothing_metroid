# Installation status

There is currently no supported public LineageOS 23 OTA or recovery bootstrap
bundle for Nothing Phone (3) (`metroid`). These instructions intentionally do not
provide flashing commands until a complete matched release is published.

## Release requirements

A future installable release must provide, from one audited build:

- the full A/B OTA ZIP and SHA-256;
- a recovery bootstrap bundle and checksums;
- source tag and complete public manifest lock;
- firmware baseline and rollback requirements;
- verified clean-install and update instructions;
- explicit working, broken, and untested behavior.

Never use an OTA with recovery, boot, DTBO, or AVB images from another build.
Never disable AVB verification or manually force the OTA target slot.

## Before testing a future release

- Unlocking and factory reset erase internal storage.
- Keep a complete stock restore package and tested recovery procedure.
- Back up all data.
- Verify every downloaded hash against the signed release record.
- Stop at the first failed command instead of flashing unrelated partitions.

Historical instructions under `release/` are retained only as development
records and are not current installation guidance.

## Automated upgrades versus first installs

- Existing coherent Lineage installations should use the normal Android
  `update_engine` path (`scripts/apply-ota-adb.sh` or Lineage Updater). This is
  host-driven and preserves GApps through `addon.d-v2/backuptool_ab` without
  recovery UI.
- First install, rollback, or any ROM sideload performed from recovery still
  requires rebooting into the newly selected slot's recovery before installing
  GApps. Upstream `sideload-auto-reboot` installs one package and boots Android;
  it cannot safely chain ROM plus GApps.
- Unsigned third-party GApps require recovery signature confirmation. Do not
  bypass verification or embed a maintainer ADB key in public recovery.
- A fully autonomous recovery flow requires a dedicated trusted add-on key and a
  versioned noninteractive rescue/install protocol. Until then, recovery installs
  are assisted and normal upgrades are the autonomous path.

## Bug reports

Include the exact OTA SHA-256, firmware, install type, reproduction steps, and
sanitized logs in any maintainer report. Never publish credentials, subscriber
identifiers, network details, precise location, or private keys.
