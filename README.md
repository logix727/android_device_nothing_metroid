# Android Device Tree for Nothing Phone (3) (metroid)

This repository contains the LineageOS device tree for Nothing Phone (3), codename `metroid`.

## Scope

- Device configuration and product makefiles
- Recovery-related configuration
- Board and partition metadata
- Device-specific support files required during build

This repository is intended to be used alongside the full Android/Lineage source tree.

## Repository Layout

- `BoardConfig.mk` and `device.mk`: core board and product definitions
- `AndroidProducts.mk`, `twrp_metroid.mk`: product targets
- `recovery.fstab`: recovery partition mappings
- `bootctrl/`, `gpt-utils/`: device-specific helpers

## Build Prerequisites

You need a synced Android/Lineage source checkout and the usual build dependencies for your target branch.

## Typical Build Usage

From the Android source root:

```bash
source build/envsetup.sh
lunch twrp_metroid-eng
mka recoveryimage
```

Adjust the target based on your branch and product naming.

## Notes

- This project is actively developed and may be work-in-progress.
- Keep proprietary blobs and firmware handling in their appropriate vendor repositories/workflows.

## Contributing

Issues and pull requests are welcome for:

- Build fixes
- Recovery/device bring-up improvements
- Cleanup and maintainability updates

Please include logs when reporting build or boot problems.
