# Contributing

Thanks for helping improve the Nothing Phone (3) (`metroid`) device tree.

## Before You Open A PR

- Keep changes focused and minimal.
- Include a clear commit message describing what and why.
- If relevant, include recovery/build logs and exact reproduction steps.
- Do not commit generated artifacts (`out/`, images, archives, payload dumps).

## Pull Request Checklist

- [ ] The change is specific to this device tree.
- [ ] Build/recovery impact is explained.
- [ ] Risky changes include testing notes.
- [ ] New files follow existing structure and naming style.

## Commit Style

Use short prefixes where practical:

- `build:` build system and makefile updates
- `recovery:` recovery-specific changes
- `sepolicy:` policy-related updates
- `docs:` documentation updates

Example:

`recovery: fix fstab flag for userdata mount`
