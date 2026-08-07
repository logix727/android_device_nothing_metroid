# Required source patches

Maintainer candidates use topic commits outside this device repository. Until
the corresponding maintained forks exist, sync the immutable pre-patch
revisions recorded in `series.conf`, then apply and verify the complete series:

```bash
device/nothing/metroid/patches/apply-series.sh "$PWD"
```

The script refuses dirty repositories and wrong starting revisions. After each
project is patched, it verifies the resulting Git tree against `series.conf`.
Commit IDs created by `git am` may vary with committer metadata; the result tree
is the reproducibility contract.

The framework patch carries the UDFPS coordinate override and two
`system_server` boot-safety fixes. The recovery patch raises minui's input
device capacity so the PMIC power and volume-down keys are registered after
the phone's squeeze-sensor input nodes. The Soong patch restores the platform
security-patch property in the boot/init_boot ramdisk build properties. The
telephony patch supports property-gated legacy eUICC transports and service
selection without changing devices that use standard card-ID discovery.

The series includes every required framework, app, HAL, build, and recovery
patch. Do not apply it to the recorded post-patch commits.

The vendor tree is proprietary and must not be published. Populate it from your
own stock dump with `extract-files.py`. Private extraction revisions remain in
the maintainer workspace and are not part of the public source lock.
