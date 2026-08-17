# MTR-027 Play Protect certification evidence

Audited: 2026-08-17. This record is sanitized: it contains no account name,
Android/GSF ID, device serial, or registration credential.

## Result

The coherent r22 installation reaches Google's **This device isn't Play Protect
certified** blocking activity instead of the Play Store storefront. This is a
confirmed user-visible block, but the retained evidence does not show an r22 ROM
regression or a corrupt Google add-on.

The first local divergence from the stock software path predates r22: the
installed build has a custom Lineage fingerprint, `userdebug` identity and AVB
chain; root vbmeta uses the hashtree-disabled flag `1`; and the bootloader
reports an orange/unlocked verified-boot state. Google's support documentation
lists an unlocked bootloader and a modified Android OS among the common
certification-failure reasons. The exact server-side rule or rollout that
selected this device is not observable locally.

The r35 investigation separates an earlier package-launch failure from this
certification result. The updated Phonesky 52.6.26 package was installed and
enabled but had `stopped=true`, and the launcher intent did not resolve. After
the package/component state was normalized, the launcher resolved without a
crash and Google selected `UncertifiedDeviceActivity`. The setter of the stopped
state is not established and the same update was previously observed running, so
there is no eligible ROM source fix for that state. Track a recurrence from an
untouched coherent install as an evidence gap, not as MTR-027 certification.

## Evidence matrix

| Layer | Installed / retained evidence | Stock, upstream, or reference evidence | Finding |
|---|---|---|---|
| User operation | A sanitized 2026-08-11 capture on coherent r22, slot B, shows Google's uncertified-device activity and no storefront. The earliest retained policy event is `uncertified_device` at 2026-08-08 22:48:32.730 in `diagnostics/hardware_acceptance_20260809_r22/suspend/30_logcat_window.txt:7812`. The consolidated record is `diagnostics/mtr027_play_certification_20260811_r22.txt`. | Google documents the same outcome as a certification failure, separate from Play Protect malware scanning. | Confirmed storefront block. |
| ROM identity | r17, r20, r21, and r22 use `Nothing/lineage_metroid/metroid:16/BP2A.250805.005/eng.logix:userdebug/release-keys`. Live and target-files evidence report `ro.debuggable=0`; the build type is still `userdebug`. | The Nothing A16 dump uses `user/release-keys` stock partition identities. | Custom fingerprint/build type is an early divergence; `ro.debuggable` is not. |
| Boot trust | Live r22 reports `ro.boot.verifiedbootstate=orange` and an unlocked bootloader. The ROM uses its custom AVB chain; verification remains enabled, while root vbmeta uses hashtree-disabled flag `1`. | Google lists an unlocked bootloader and modified OS as common certification failures. No retained stock runtime capture proves a particular stock verified-boot color. | Custom AVB/root trust state and unlocked/orange boot are policy-relevant divergences, not evidence of a broken AVB implementation. |
| r21 to r22 source delta | `build/make` and `vendor/lineage` revisions are identical. The functional application delta is Aperture camera routing; device-tree changes are release records/carry metadata plus that camera carry. GMS policy/config files compared between target-files are identical. | No Google package or certification-policy source delta exists in the r21-to-r22 ROM change. | No supported r22 certification regression was found. |
| Google add-on | Live base GmsCore, Phonesky, and permission XML hashes match the pinned MindTheGapps archive. GmsCore and Play Store are installed as updated system apps and their processes can remain alive. | Lineage documents MindTheGapps as a separately installed, unsupported proprietary add-on. | Package presence, process health, and account retention do not prove certification or storefront access. |
| Package chronology | Base Phonesky is 45.7.17. The active 52.6.26 update records `lastUpdateTime=2026-08-08 10:35:37`, before both r21 and r22 builds and before the retained policy event. | Stock Phonesky 47.3.29 and 48.9.30 and MindTheGapps Phonesky 45.7.17 all contain `com.google.android.gms.gmscompliance.ui.UncertifiedDeviceActivity`. | The activity is normal Google package content, not evidence of APK corruption. The update cannot establish a new r21-to-r22 ROM divergence. |
| Historical acceptance | Coherent-r22 crash evidence proves GMS/package/account retention and zero Password Checkup fatalities. No retained r21/r22 capture proves successful storefront entry or a certified status before the block. | A functional gate must exercise the storefront and an install, not only resolve the package or Binder services. | Earlier "intact" and "policy pass" wording was overstated. |
| Kernel / hardware | No kernel crash, AVC, missing service, package-signature failure, or transport failure precedes the blocking activity. | Certification is a Google compatibility/licensing and server-policy decision. | No kernel or device-source fix is indicated. |
| r35 package launch | Updated Phonesky 52.6.26 was installed/enabled but stopped and initially had no resolvable launcher. Normalizing package/component state restored a crash-free launch. | Stock requests `com.android.vending` with `stopped=false`; the same update had previously run on Lineage. | Separate package-state evidence gap; not a certification result and not yet a ROM defect. |
| r35 certification | A valid launcher request selects `com.google.android.gms.gmscompliance.ui.UncertifiedDeviceActivity`. | Google's documented certification policy remains server-controlled. | Confirms `UNCERTIFIED-BLOCKED` after package launch is restored. |

## Classification

- Confirmed: Google blocks the Play Store storefront on the current coherent
  custom build as uncertified.
- Confirmed: the first retained local divergence from stock is custom build/AVB
  identity, root flag `1`, and unlocked/orange boot state; it predates the r22
  camera delta.
- Not proven: Google's exact server-side trigger, rollout timing, or the current
  per-device registration status.
- Not proven: that r21 ever entered the storefront or reported certified.
- Maintainer disposition: expected external Google certification enforcement,
  tracked as a P0 release/claim blocker. It is not a proven ROM runtime defect.

## Supported outcomes

1. Formal Google certification/licensing for the exact build is the only
   release-wide way to call the ROM Play Protect certified; it is not currently
   available to this unofficial port.
2. Restoring the original manufacturer-signed stock OS is Google's general
   supported user remediation. Relock only with Nothing's documented stock
   procedure and a complete stock chain.
3. Google's official custom-ROM device-registration path, if offered, is a
   private per-device user action. It may restore access, but it does not certify
   this ROM and cannot support a general release claim.
4. Running LineageOS without Google apps, or using another lawful app source,
   avoids this optional companion dependency; it does not fix Play certification.
5. Until one of the above changes the measured result, release notes must say
   **Play Store blocked / Play Protect not certified** rather than "working."

## Prohibited workarounds

- Do not spoof a certified stock fingerprint, build identity, boot state, or
  attestation result.
- Do not patch GmsCore/Phonesky, disable certification or integrity checks, or
  pin an old Google package as a bypass.
- Do not disable AVB verification or relock a bootloader around custom images.
- Do not collect, publish, or place Android ID/GSF ID, account details, or
  registration credentials in logs, issues, release records, or source.

## Validation gate

For every candidate promoted with a Google add-on test claim:

1. Boot one coherent slot twice with exact ROM and add-on hashes recorded.
2. Record only build identity, boot state, and Google package versions.
3. Resolve and open the Play Store launcher.
4. If the launcher is absent or unresolved, label `PACKAGE-LAUNCH-BLOCKED` and
   record installed/enabled/stopped/suspended state before using Settings -> Apps
   -> Google Play Store -> Open/Enable once, then relaunch. Do not clear data or
   remove updates.
5. If Google's blocking activity appears, record its exact headline without any
   device identifier and label `UNCERTIFIED-BLOCKED`.
6. Otherwise open `profile > Settings > About`, record the exact Play Protect
   certification text, and confirm the real storefront is visible.
7. Install/update one small app and one app larger than 200 MB.
8. Reboot and repeat storefront entry; sweep GMS fatalities and tombstones.
9. Label the result `PACKAGE-LAUNCH-BLOCKED`, `CERTIFIED`,
   `REGISTERED-DEVICE ACCESS`, `UNCERTIFIED-BLOCKED`, or `NOT TESTED`.
   Per-device registration must never be reported as ROM certification.

Package presence, account retention, Play Protect scanning being enabled, or a
running GMS process is not a pass. MTR-027 remains externally blocked until the
exact candidate has a legitimate release-wide certification path; a release may
instead proceed only with the limitation stated accurately and Play Store
removed from its working/acceptance claims.

## Public references

- Google, **Check & fix Play Protect certification status**:
  `https://support.google.com/googleplay/answer/7165974`
- Google official custom-ROM registration entry point:
  `https://www.google.com/android/uncertified/`
- LineageOS, **Google Apps**: `https://wiki.lineageos.org/gapps/`
