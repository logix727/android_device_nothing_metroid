# Official-readiness backlog

This tree remains an unofficial XDA test port. Hardware acceptance and public
source readiness are separate gates; neither implies LineageOS endorsement or
official build eligibility.

## Source blockers

- Replace personal or local carry dependencies with LineageOS-hosted forks or
  reviewed upstream changes. `lineage.dependencies` is not submission-ready.
- Publish a sanitized immutable r29 Repo manifest and source tag. Required public
  bases, ordered carries, device revision and kernel revision are already public;
  keep proprietary vendor source, signing material, raw logs and credentials
  private.
- Make the kernel and module build reproducible from the Android build graph or
  an accepted public prebuilt workflow. Resolve the two stock GPL NFC modules
  that currently lack matching published source.
- Remove build-broken escapes, duplicate output ownership, missing-module masks,
  and disabled dexpreopt by fixing each owning cause.
- Regenerate proprietary output from a curated `proprietary-files.txt`; remove
  manual sidecar copying and factory/diagnostic or source-buildable stock files.
- Maintain current platform, vendor, boot, and kernel security provenance and a
  CVE ledger.
- Define a lawful, reproducible A/B firmware installation path for both slots.

## Hardware blockers

- Close physical-SIM data, voice, SMS, IMS, emergency, DSDS, and handover on the
  frozen modem generation.
- Complete camera/video, UDFPS, audio, Bluetooth, Wi-Fi hotspot, USB/MTP,
  mandatory sensor, NFC/payment, suspend, and thermal/charging acceptance.
- Complete removable-eUICC profile management, OMAPI, and accessory rows when
  credentials or hardware are available; historical removable-eUICC active-profile
  LTE/SMS is only partial evidence.

## Submission gate

Do not request official review until a clean external checkout reproduces the
same source and kernel graph, redistribution and corresponding-source questions
are resolved, all applicable device-support requirements pass, and the exact
candidate is installed and accepted on target hardware.
