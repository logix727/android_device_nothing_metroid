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

The framework patches carry the UDFPS coordinate override, two `system_server`
boot-safety fixes, and the metroid AudioFX keepalive binding. The AudioFX series
exports only a dedicated inert keepalive while its DSP service remains private;
the Settings series carries dependency-closed face-guidance fallback. The
recovery patch raises minui's input
device capacity so the PMIC power and volume-down keys are registered after
the phone's squeeze-sensor input nodes. The Soong patch restores the platform
security-patch property in the boot/init_boot ramdisk build properties.

The series includes every required framework, app, HAL, build, and recovery
patch. A candidate must not rely on an unlisted local commit. Do not apply it to
the recorded post-patch commits.

The vendor tree is proprietary and must not be published. Populate it from your
own stock dump with `extract-files.py`. Private extraction revisions remain in
the maintainer workspace and are not part of the public source lock.
