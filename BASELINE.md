# Maintainer-local installed baseline

This records private maintainer acceptance evidence. It is not by itself a
reproducible public release; the immutable release snapshot and manifest lock
under `releases/candidate_20260806_144606_ims-policy-r4/` provide that.

## Build

- Version: `23.0-20260806-UNOFFICIAL-metroid`
- Build date UTC: `1786033287`
- OTA: `lineage-23.0-20260806-UNOFFICIAL-metroid.zip`
- SHA-256: `22e98f31182daa6e0645af48d64b7f7617aedf8b180250815759171436b260df`
- Verified snapshot: `releases/candidate_20260806_144606_ims-policy-r4/`
- Installed slot when recorded: `a`
- SELinux: Enforcing
- Data: encrypted
- Slot marked successful on the recorded boots: yes

## IMS/SELinux acceptance deltas vs the prior baseline

- `org.codeaurora.ims` runs as `u:r:vendor_qtelephony:s0`; no IMS, radio, or
  vendor-property AVC denials across two clean boots.
- `IQtiRadioConfig/default`, `IImsRadio/imsradio0` and `imsradio1` resolve and
  bind; `ImsResolver` registers MMTEL and EMERGENCY_MMTEL on both slots and
  `QImsService` receives subscription service-status updates.
- Power HAL `android.hardware.power.IPower/default` registers.
- `ro.product.first_api_level=35`, `ro.board.first_api_level=202404`;
  `ro.vendor.build.security_patch=2025-06-05`; platform `2026-02-01`.
- eUICC is no longer advertised and no LPA/EuiccService is installed, so no
  eSIM is presented to apps.

## Source revisions

Full project-level revisions are sealed verbatim in the r4 snapshot under
`source/*-state.txt`. The primary metroid trees are pinned as follows:

| Project | Revision |
|---|---|
| `device/nothing/metroid` | `db3aead85743d8e38335708b73334b93555da147` |
| `vendor/nothing/metroid` | `4414182c43414406038a477d6a1162a535b9a28a` (private; not published) |
| `kernel/nothing/sm8735` | `ce342da8315a62e6144882faeddbdeccda544f9b` |

Update this file only after a new audited OTA is installed and accepted.