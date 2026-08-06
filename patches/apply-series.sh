#!/usr/bin/env bash
set -euo pipefail

DEVICE="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_ROOT="${1:-$(cd "$DEVICE/../../.." && pwd)}"

while IFS='|' read -r project base expected_tree patch_glob; do
    [[ -n "$project" && "$project" != \#* ]] || continue
    repo="$ANDROID_ROOT/$project"
    [[ -d "$repo/.git" ]] || {
        echo "Missing Git repository: $project" >&2
        exit 1
    }
    [[ -z "$(git -C "$repo" status --porcelain)" ]] || {
        echo "Dirty repository: $project" >&2
        exit 1
    }
    actual_base="$(git -C "$repo" rev-parse HEAD)"
    [[ "$actual_base" == "$base" ]] || {
        echo "$project is at $actual_base, expected pre-patch base $base" >&2
        exit 1
    }
    mapfile -t patches < <(compgen -G "$DEVICE/$patch_glob" | LC_ALL=C sort)
    [[ ${#patches[@]} -gt 0 ]] || {
        echo "No patches matched for $project: $patch_glob" >&2
        exit 1
    }
    git -C "$repo" am "${patches[@]}"
    actual_tree="$(git -C "$repo" rev-parse HEAD^{tree})"
    [[ "$actual_tree" == "$expected_tree" ]] || {
        echo "$project result tree $actual_tree, expected $expected_tree" >&2
        exit 1
    }
done < "$DEVICE/patches/series.conf"
