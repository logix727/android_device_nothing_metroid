# Lean validation workflow

This workflow minimizes full Android builds and target-device writes without
weakening the two maintainer rules:

1. An issue is closed only after its exact shipped fix is installed and the real
   operation passes on `metroid`.
2. Nothing ships without a confirmed first deterministic divergence backed by an
   installed/stock/kernel/upstream/reference evidence matrix.

Everything before the final candidate should remove uncertainty as cheaply as
possible. Do not use an OTA to answer a question that source, image inspection,
a host test, or a reversible target test can answer.

## Separate verdicts

Track issue state independently from candidate state.

| Issue state | Meaning |
|---|---|
| `EVIDENCE` | Reproduction or evidence matrix is incomplete. |
| `READY` | First divergence is confirmed and the minimal fix is defined. |
| `BUILT-NOT-INSTALLED` | Focused checks pass; fix is waiting for a candidate. |
| `INSTALLED-UNTESTED` | Exact fix is installed, but its real operation is not accepted. |
| `CLOSED` | Exact installed fix passed its functional and regression matrix. |
| `BLOCKED` | Hardware, credentials, carrier, policy, or a physical action is unavailable. |
| `DIAGNOSTIC` | Instrumentation answered a causal question but is not shippable. |

| Candidate state | Meaning |
|---|---|
| `PLANNED` | Eligible issue set is being assembled. |
| `FROZEN` | Commits, companion inputs, and test union are fixed. |
| `OFFLINE-VERIFIED` | Install-clean build and artifact audits pass. |
| `INSTALLED` | Exact audited artifact is coherently installed. |
| `ACCEPTED` | Release gates and required hardware tests pass. |
| `REJECTED` | A release gate failed; the artifact is not promoted. |

A coherent rejected candidate may still close an independent issue whose exact
operation passed. A mixed-state boot, temporary APK, or instrumented kernel may
never promote a candidate.

## Classify work first

| Work class | Default action | Build or install cost |
|---|---|---|
| Active source defect | Confirm divergence, fix, focused-check, then batch. | One eventual candidate. |
| Acceptance-only | Run the missing operation on the coherent installed build. | No build or install. |
| Built but uninstalled | Hold for the next eligible frozen batch. | No extra candidate. |
| External blocker | Keep a ready test recipe and report `BLOCKED`. | No build or install. |
| Diagnostic question | Use read-only evidence or one reversible probe. | No release candidate. |
| Test gap | Add an acceptance row; do not invent a defect. | No source change. |

An acceptance-only failure becomes an active source defect. Start a new evidence
matrix before editing.

## Validation tiers

| Tier | Gate | Expected cost |
|---|---|---|
| T0 Evidence | Reproduce, capture pre-state, compare installed/stock/kernel/upstream/reference, state first divergence. | No source build. |
| T1 Focused | Unit, host, lint, parser, targeted `atest`, and affected module compile. | Incremental build only. |
| T2 Reversible | Standalone probe or same-signature APK/runtime trial with proven cleanup. | No partition write. |
| T3 Staged image | Regenerate required packaging and inspect target staging, VINTF, init, ELF, SELinux, and image membership. | No phone write. |
| T4 Candidate | Freeze source and companion files, run the candidate wrapper with their paths, then payload/AVB/signing/provenance audits. | One full build. |
| T5 Installed | Under standing authorization, install the exact audited OTA, boot twice, run invariant smoke plus affected matrices. | One planned install. |

Passing T2 reduces uncertainty but does not close a shipped fix. The final code
must still be present in the T5 artifact.

## Risk classes

Use the highest applicable class.

| Risk | Typical changes | Policy |
|---|---|---|
| R0 | Documentation, evidence, parsers, maintainer tooling. | T0/T1 only; no candidate. |
| R1 | Leaf APK or resource change with a safe same-signature trial. | T1, preferably T2, then defer install to a batch. |
| R2 | SystemUI/framework integration, native HAL, SELinux, overlay/property, package inventory, non-core init. | T1 and T3, then one coherent batch candidate. |
| R3 | Kernel/DT/vendor_boot, boot classpath or core system_server, VINTF, critical init, AVB/partition/update/FBE/firmware. | Dedicated review; do not combine unrelated R3 causes without explicit justification. |

An atomic fix spanning projects, such as binary plus RC plus VINTF plus SELinux,
remains one root-cause group. Multiple projects are not a reason to split it.

## Change-triggered gates

| Change type | Required before candidate freeze | Installed acceptance |
|---|---|---|
| Leaf APK | Module tests/build, merged manifest and signature check, optional reversible update. | Real app operation, process restart, reboot persistence, crash/AVC sweep. |
| Framework/SystemUI | Focused framework tests and a client/UI probe where possible. | Real API/UI operation, adjacent clients, system_server/SystemUI stability. |
| Vendor/RC/VINTF | Fresh Kati/staging as needed, `check-vintf-all`, VINTF server/duplicate, init, ELF, and policy audits. | Actual HAL operation, restart/recovery, client behavior, no AVC/crash. |
| Kernel/DT/vendor_boot | Reproducible kernel build, DT/config/image composition, AVB and page-size checks. | Probe/counters, dmesg/pstore, suspend/resume, affected hardware, second boot. |
| OTA/partition/AVB | Target-files and payload equivalence, signing, partition and metadata audit. | Update from supported baseline, slot success, merge, second boot, userdata retention. |

Use `TEST_MAPPING`, targeted `atest`, and Tradefed filters when suitable tests
exist. Cuttlefish may reject generic framework/app regressions but cannot accept
Nothing camera, biometric, haptic, modem, NFC, charging, thermal, suspend, panel,
or other proprietary hardware behavior.

## Build policy

1. Use incremental affected-module builds during T1.
2. Regenerate Kati/Soong packaging when product, package, RC, VINTF, overlay, or
   property inputs require it.
3. After a removal or rename, clean or regenerate the affected staging output
   before T3 so stale files cannot create a false pass.
4. Run `CANDIDATE_RECORD=<committed-release-record>
   METROID_GAPPS_PATH=<archive> METROID_MODEM_IMAGE_PATH=<image>
   METROID_OTA_CERT_PATH=<releasekey.x509.pem> ../build_los23.sh candidate` only
   after the batch is `FROZEN`; it performs `installclean` then `bacon`, verifies
   companion inputs and trust anchors, and emits the immutable build-state
   attestation consumed by the release audit.
5. Use a full output-tree clean only when build-system changes or measured stale
   output require it. Do not use full cleans as ritual.
6. Any source, patch-series, signing-input, or companion-input change after T4
   invalidates the candidate and its audit.

New committed candidate records use `schema_version: 3`,
`record_type: "frozen-candidate"`, `status: "frozen"`, a non-empty `issues`
array of `MTR-XXX` IDs, an immutable `validation_parent`, the planner-derived
`classified_test_suites`, per-issue functional acceptance, separately labeled
optional scheduled acceptance, and `companion_inputs` entries for `gapps`
(`file`, `sha256`) and `modem` (`build`, `sha256`). Historical records remain
unchanged evidence. The build wrapper rejects missing, uncommitted, dirty, or
malformed records and any suite mismatch. Companion
paths are local/private inputs: the record stores only identity and SHA-256.
The signing-key selection file is also tracked and sealed by hash; private key
material remains local and is represented only by its pinned public key or
certificate digest. `OFFLINE-VERIFIED` means the immutable source/artifact and
offline technical gates passed. It does not prove issue eligibility, installed
behavior, or release acceptance.

## Default flash budget

- One planned coherent OTA install per release train.
- One safety reserve for recovery or one corrected candidate.
- Zero raw partition flashes and zero manual slot changes during normal closure.
- A diagnostic OTA requires a written causal question, is non-promotable, and
  reserves a second write to restore a coherent state.
- A third device write ends the train. Reassess the evidence and freeze a new
  plan instead of continuing flash-driven debugging.
- Modem/firmware, erasure, format-data, rollback, and bootloader operations are
  covered by standing owner authorization. Keep them separate, checkpointed,
  explicitly targeted events.

Prefer normal-system `update_engine`. Recovery installation must keep ROM, GApps,
and modem as separate recorded inputs and follow the documented new-slot GApps
sequence.

## Batch eligibility

A fix may join a candidate only when all of these are true:

- First divergence and owning subsystem are explicit.
- Exact commits and dependencies are known.
- T1 passes; T2 passes when safe and useful; T3 has no unexplained finding.
- No diagnostic instrumentation remains.
- The real installed acceptance operation is defined and executable, or the row
  is explicitly external/non-gating.
- Source projects are committed and clean, carry patches are reproducible, and
  companion inputs are frozen.
- The change does not invalidate an open accepted row.

Do not batch competing hypotheses, unresolved stock/kernel contradictions, or
unrelated R3 root causes merely to save one build.

## Candidate test selection

Every installed candidate gets one small invariant suite:

1. Exact ZIP hash/build/slot and companion inputs match the frozen record.
2. MTR-028 recovery final status, automatic target-slot selection, update
   completion, slot success, snapshot merge, first boot, and second boot. Host
   progress near 47 percent or its terminal-token warning is not an install result.
3. Encrypted userdata, SELinux Enforcing, one system_server, clean crash buffer,
   no new tombstone/pstore, and no boot-critical AVC. A named external companion
   failure remains visible and rejects promotion; it is not waived or converted
   into a ROM source defect without a confirmed divergence.
4. Display/touch/unlock sanity and enough ADB control to retain the evidence.

Wi-Fi transport, ADB transfer hashes, speaker playback, camera capture,
battery/charging and suspend are not universal release rituals. Run them only
when selected by the change-impact policy, when an unexplained invariant failure
could involve them, or at a scheduled compatibility-baseline milestone.

### Acceptance inheritance

An accepted hardware result is inherited by a child candidate without repeating
the physical operation when all of these are true:

1. The installed parent and exact accepted operation/evidence are immutable and
   named in the candidate record.
2. The planner selects no suite for that subsystem and no changed path owns or
   feeds its framework, app, HAL, vendor binary/config, kernel/DT/module, SELinux,
   firmware, or companion input.
3. The candidate is not a broad platform compatibility baseline and has no
   unexplained boot, crash, tombstone, pstore, AVC, service, or hardware-state
   regression that could invalidate the result.
4. The release record labels the result `INHERITED` and names the parent build;
   it must not claim the operation was freshly exercised.

Inheritance is transitive only through accepted installed records. A diagnostic,
rejected, uninstalled, mismatched-firmware, or partially tested build cannot be
an inheritance parent. Any source-vector or companion uncertainty fails closed
to a fresh operation.

Then run the union of matrices affected by the candidate. Do not rerun every
hardware row for every narrow change. Run the full available hardware matrix at
scheduled compatibility-baseline milestones, after a broad upstream/platform
rebase, for an R3 change with broad blast radius, or after an unexplained
invariant failure. Routine releases use invariant smoke plus change-affected
rows and preserve prior acceptance for demonstrably unaffected operations.

The maintained change-impact planner derives those affected matrices from the
sealed installed parent's Repo manifest and the proposed target manifest. Future
candidate records use stable `classified_test_suites`; handwritten test prose,
mutable `current`/`latest` links, and unrelated scheduled acceptance cannot widen
or narrow the derived union. Audio, camera, Bluetooth, USB, charging, suspend,
Wi-Fi and other matrices run only when their source vector changed, their issue
is included, an unexplained failure implicates them, or the planner marks a broad
compatibility baseline.

Run the planner-selected focused targets and static gates once with
`tools/maintenance/run_validation_plan.py`. Its manifest-bound receipt is a
required candidate input. The candidate wrapper verifies and seals that receipt,
then performs one `installclean` build; it does not repeat focused module builds
after cleaning output.

Google add-on package/process survival, storefront access, Play Protect
certification, and Play Integrity are separate results. Follow MTR-027 and never
convert a blocked policy result into a ROM pass.

## Stop and go rules

- Stop before editing if the first divergence is not confirmed.
- Stop before T4 if a focused or staged gate fails or the worktree is not frozen.
- Stop before T5 if artifact identity, payload equivalence, AVB/signing, or source
  provenance is uncertain.
- Do not ask again for OTA, flash, slot, firmware, erasure, wipe, or format
  operations. Standing owner authorization applies; verify the target and stop on
  unexpected safety, boot, encryption, identity, or unplanned-data conditions.
- On an installed failure, capture the first failure immediately. Do not fold in
  another fix until the candidate disposition and affected issues are recorded.
- Quarantine only a reproduced flaky test with an owner, issue, expiry, and
  non-blocking result. Never silently ignore it.

## Parallelism

- Run one read-only evidence agent per issue concurrently.
- Serialize writers within each Git project.
- Keep separate commits for separate causes in a shared project.
- Build the shared project once at the merged, committed batch head.
- Freeze the integration manifest before T4; no concurrent Android source edits
  are allowed during candidate build or audit.

## Maintained commands

- `/plan-validation` classifies changed paths, risk, tiers, and required gates.
- `/static-gate` runs T3 staged-image checks only; it never creates a release.
- `/candidate-gate` audits a frozen candidate without sealing a release snapshot.
- `/release-seal` creates the immutable audited snapshot after candidate checks.
- `/bughunt MTR-XXX` builds one read-only evidence matrix.

## Primary references

- AOSP `TEST_MAPPING`: `https://source.android.com/docs/core/tests/development/test-mapping`
- AOSP `atest`: `https://source.android.com/docs/core/tests/development/atest`
- Trade Federation: `https://source.android.com/docs/core/tests/tradefed`
- CTS: `https://source.android.com/docs/compatibility/cts`
- VTS: `https://source.android.com/docs/core/tests/vts`
- Cuttlefish: `https://source.android.com/docs/devices/cuttlefish`
- OTA tools: `https://source.android.com/docs/core/ota/tools`
- Virtual A/B: `https://source.android.com/docs/core/ota/virtual_ab`
- Android build guidance: `https://source.android.com/docs/setup/build/building`
- Linux KUnit: `https://www.kernel.org/doc/html/latest/dev-tools/kunit/index.html`
