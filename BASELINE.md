# Maintainer-local installed baseline

This records private maintainer acceptance evidence. It is not by itself a
redistributable public release; the immutable release snapshot and manifest lock
under `releases/candidate_20260806_194556_xda-thermal-r7/` provide that.

## Build

- Version: `23.0-20260806-UNOFFICIAL-metroid`
- Build date UTC: `1786058391`
- OTA: `lineage-23.0-20260806-UNOFFICIAL-metroid.zip`
- SHA-256: `74d738f1ba6b8f7f4534f82a6b0e004dbebdc3f4b90f09cccef48d534cdf1bb0`
- Verified snapshot: `releases/candidate_20260806_194556_xda-thermal-r7/`
- Installed slot when recorded: `b`
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
- Aperture stabilization UI and camera-flip changes are installed and compile-
  validated, but retained user package state prevented trustworthy UI/runtime
  acceptance; do not claim MTR-012 or MTR-022 closed yet.

## Source revisions

Full project-level revisions are sealed verbatim in the r7 snapshot under
`source/*-state.txt`. The primary metroid trees are pinned as follows:

| Project | Revision |
|---|---|
| `device/nothing/metroid` | `99887340b88cf6d30ed29acd408cc909c97042ac` |
| `vendor/nothing/metroid` | `17d816d3234603bf545b2cc580a68c269dee1004` (private; not published) |
| `kernel/nothing/sm8735` | `ce342da8315a62e6144882faeddbdeccda544f9b` |
| `build/soong` | `b4bbdf5956a788ab60921bd71421b1c9be31a8f0` |
| `frameworks/av` | `113ccbf172d572086818456a41b62809c38a0ac0` |
| `packages/apps/Aperture` | `db454eb0525be0b59bee2c32030df3fd7d553eb5` |

Update this file only after a new audited OTA is installed and accepted.
