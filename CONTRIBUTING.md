# Contributing

GitHub issues and pull requests are accepted for this unofficial maintainer fork.
Contributions should target `lineage-23.0-metroid` and address a measured device
problem or an item in `BUGS.md`. Changes intended for LineageOS upstream must
follow the official CLA, Gerrit, `Change-Id`, authorship, and review process.

## Before submitting

- Reproduce the real operation; service registration alone is not acceptance.
- Compare current Lineage/AOSP behavior, stock evidence, and relevant devices.
- Keep the fix in the owning subsystem and avoid unrelated cleanup.
- Run focused builds/tests and `m check-vintf-all` after VINTF changes.
- Do not commit proprietary blobs, stock modules, firmware, signing keys, build
  output, logs, user data, credentials, or unsanitized diagnostics.
- Preserve actual authorship and provenance. Use a verified or GitHub noreply
  email and sign off commits when possible.
- Use a concise subject and wrap commit-message bodies near 80 columns.
- Original Android contributions should use Apache-2.0/SPDX conventions;
  kernel work must preserve applicable GPL notices.

## Reports and pull requests

State the build/source revision, firmware baseline, exact reproduction, expected
and actual behavior, tests run, and remaining risks. Sanitize serials, MACs,
network names, coordinates, phone/subscriber identifiers, account data, and keys.

Changes that affect installation or a release claim require a coherent audited
OTA and target-device acceptance before documentation may call them working.

Participation in this fork follows the LineageOS Code of Conduct:
https://github.com/LineageOS/charter/blob/main/code-of-conduct.md.
