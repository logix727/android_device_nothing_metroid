# Maintainer-local installed baseline

This records private maintainer acceptance evidence. It is not by itself a
redistributable public release; the immutable release snapshot and manifest lock
under `releases/candidate_20260807_084022_gapps-avb-r9/` provide that.

## Build

- Version: `23.0-20260807-UNOFFICIAL-metroid`
- Build date UTC: `1786073721`
- OTA: `lineage-23.0-20260807-UNOFFICIAL-metroid.zip`
- SHA-256: `70a1406da079046b746cf952debfac00722fbdc994c481c74388db7ef5dc065c`
- Verified snapshot: `releases/candidate_20260807_084022_gapps-avb-r9/`
- Installed slot when recorded: `a`
- SELinux: Enforcing
- Data: encrypted
- Slot marked successful on the recorded boots: yes

## Acceptance deltas vs r4

- `org.codeaurora.ims` runs as `u:r:vendor_qtelephony:s0`; no IMS, radio, or
  vendor-property AVC denials across two clean boots.
- `IQtiRadioConfig/default`, `IImsRadio/imsradio0` and `imsradio1` resolve and
  bind; `ImsResolver` registers MMTEL and EMERGENCY_MMTEL on both slots and
  `QImsService` receives subscription service-status updates.
- Power HAL `android.hardware.power.IPower/default` registers.
- `ro.product.first_api_level=35`, `ro.board.first_api_level=202404`;
  platform and boot-image SPL `2026-02-01`; vendor `2025-06-05`.
- eUICC is no longer advertised and no LPA/EuiccService is installed, so no
  eSIM is presented to apps.
- GNSS HAL restart completes without the prior property-service AVC.
- Codec creation no longer performs the invalid `media_quality` VINTF lookup.
- Nothing's confined `sltntc` daemon updates all four shell zones. The stock
  Thermal HAL reports live `TYPE_SKIN`, stock 39/43/44/50/54/63 C thresholds,
  and non-NaN 0/10-second framework headroom across two boots.
- Lineage's recommended MindTheGapps Android 16 ARM64 add-on was installed in
  recovery before first boot from a separately verified ZIP (SHA-256
  `a6ff8b8c31f7ccd0a9f2fd651fa4438a8e39a5f63b95be246ea1f98982af2c28`).
  Play Store, GMS, GSF, and Google Setup Wizard persist across two boots.
- Root vbmeta remains signed and verifies all chain descriptors. Only AVB's
  hashtree-disabled bit is set (`Flags: 1`) so intentional recovery add-on writes
  survive; verification-disabled (`2`) is not set.
- Aperture stabilization UI and camera-flip changes are installed and compile-
  validated, but retained user package state prevented trustworthy UI/runtime
  acceptance; do not claim MTR-012 or MTR-022 closed yet.

## Source revisions

Full project-level revisions are sealed verbatim in the r9 snapshot under
`source/*-state.txt`. The primary metroid trees are pinned as follows:

| Project | Revision |
|---|---|
| `device/nothing/metroid` | `7a71f597d4e105ba70ee012ad48dc366f0fa4858` |
| `vendor/nothing/metroid` | `17d816d3234603bf545b2cc580a68c269dee1004` (private; not published) |
| `kernel/nothing/sm8735` | `ce342da8315a62e6144882faeddbdeccda544f9b` |
| `build/soong` | `b4bbdf5956a788ab60921bd71421b1c9be31a8f0` |
| `frameworks/av` | `113ccbf172d572086818456a41b62809c38a0ac0` |
| `packages/apps/Aperture` | `db454eb0525be0b59bee2c32030df3fd7d553eb5` |

Update this file only after a new audited OTA is installed and accepted.
