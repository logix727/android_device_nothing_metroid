#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 logix727
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

SOURCE="${1:?usage: $0 /path/to/extracted/vendor_dlkm}"
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HERE/local-prebuilt-modules"
TMP="$(mktemp -d "$HERE/.local-prebuilt-modules.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

declare -A EXPECTED=(
    [stm_nfc_i2c.ko]=5f6ec24ab7a464169463f10d56e42d09e5f4cc360b5e7ec8261a515ad895f742
    [stm_st54se_gpio.ko]=334c9afd91859276bbdefae30f671a0b515d6656ccbded6121da4e7f587c741a
)

for module in "${!EXPECTED[@]}"; do
    mapfile -t matches < <(find "$SOURCE" -type f -name "$module" -print)
    [[ ${#matches[@]} -eq 1 ]] || {
        echo "expected one $module under $SOURCE, found ${#matches[@]}" >&2
        exit 1
    }
    source_file="${matches[0]}"
    actual="$(sha256sum "$source_file" | cut -d' ' -f1)"
    [[ "$actual" == "${EXPECTED[$module]}" ]] || {
        echo "$module hash mismatch: expected ${EXPECTED[$module]}, got $actual" >&2
        exit 1
    }
    install -m 0644 "$source_file" "$TMP/$module"
done

rm -rf "$DEST"
mv "$TMP" "$DEST"
trap - EXIT
echo "Verified local modules in $DEST"
