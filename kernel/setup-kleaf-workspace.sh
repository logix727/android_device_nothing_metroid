#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 logix727
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

DEVICE="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_ROOT="${1:?usage: $0 /path/to/kernel-workspace}"
WORKSPACE_ROOT="$(cd "$WORKSPACE_ROOT" && pwd)"

[[ -f "$WORKSPACE_ROOT/msm-kernel/bazel.WORKSPACE" ]] || {
    echo "missing pinned msm-kernel checkout under $WORKSPACE_ROOT" >&2
    exit 1
}

cp "$WORKSPACE_ROOT/msm-kernel/bazel.WORKSPACE" "$WORKSPACE_ROOT/WORKSPACE"
patch -d "$WORKSPACE_ROOT" -p0 < "$DEVICE/kernel/patches/workspace-dtc-version.patch"

if git -C "$WORKSPACE_ROOT/build/kernel" apply --reverse --check \
        "$DEVICE/kernel/patches/build-kernel-module-symvers.patch" >/dev/null 2>&1; then
    :
else
    git -C "$WORKSPACE_ROOT/build/kernel" apply --check \
        "$DEVICE/kernel/patches/build-kernel-module-symvers.patch"
    git -C "$WORKSPACE_ROOT/build/kernel" apply \
        "$DEVICE/kernel/patches/build-kernel-module-symvers.patch"
fi

: > "$WORKSPACE_ROOT/build/BUILD"
for name in msm_abl.bzl msm_common.bzl msm_dtc.bzl msm_kernel_16k_la.bzl \
        msm_kernel_extensions.bzl msm_kernel_la.bzl msm_kernel_le.bzl \
        msm_kernel_vm.bzl msm_platforms.bzl; do
    ln -sfn "../msm-kernel/$name" "$WORKSPACE_ROOT/build/$name"
done
ln -sfn "msm-kernel/vendor" "$WORKSPACE_ROOT/vendor"
printf '%s\n' 'msm-kernel/vendor' > "$WORKSPACE_ROOT/.bazelignore"

printf '%s\n' '#define DTC_VERSION "DTC 1.7.0"' \
    > "$WORKSPACE_ROOT/external/dtc/version_gen.h"
cp "$WORKSPACE_ROOT/external/dtc/version_gen.h" \
    "$WORKSPACE_ROOT/external/dtc/version_non_gen.h"
bison -b "$WORKSPACE_ROOT/external/dtc/dtc-parser" -d \
    "$WORKSPACE_ROOT/external/dtc/dtc-parser.y"
cp "$WORKSPACE_ROOT/external/dtc/dtc-parser.tab.h" \
    "$WORKSPACE_ROOT/external/dtc/dtc-parser.h"

cp "$DEVICE/kernel/vendor-module-targets.txt" \
    "$WORKSPACE_ROOT/vendor-module-targets.txt"

echo "Kleaf workspace prepared at $WORKSPACE_ROOT"
