#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <lineage OTA zip>" >&2
  exit 2
fi

ota="$(realpath "$1")"
[[ -f "$ota" ]]
command -v adb >/dev/null
command -v unzip >/dev/null
command -v sha256sum >/dev/null

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

zip_hash="$(sha256sum "$ota" | cut -d' ' -f1)"
unzip -p "$ota" payload.bin > "$tmp/payload.bin"
unzip -p "$ota" payload_properties.txt > "$tmp/payload_properties.txt"
payload_size="$(stat -c %s "$tmp/payload.bin")"
property_size="$(awk -F= '$1 == "FILE_SIZE" { print $2 }' "$tmp/payload_properties.txt")"
[[ "$payload_size" == "$property_size" ]]

adb wait-for-device
adb root >/dev/null
adb wait-for-device

source_slot="$(adb shell getprop ro.boot.slot_suffix | tr -d '\r')"
[[ "$source_slot" == "_a" || "$source_slot" == "_b" ]]
adb shell 'test "$(getprop sys.boot_completed)" = 1; test "$(getenforce)" = Enforcing'
adb shell 'test -x /system/addon.d/30-gapps.sh; test -f /product/etc/permissions/privapp-permissions-google-product.xml; test -f /product/etc/sysconfig/google.xml'
adb shell 'service check android.os.UpdateEngineService | grep -q found'

lineage_root="$(realpath ../../..)"
client="${UPDATE_ENGINE_CLIENT:-$lineage_root/out/target/product/metroid/system/bin/update_engine_client}"
if [[ ! -x "$client" ]]; then
  "$lineage_root/../build_los23.sh" update_engine_client
fi
[[ -x "$client" ]]
adb push "$client" /data/local/tmp/update_engine_client >/dev/null
adb shell 'chmod 0755 /data/local/tmp/update_engine_client; /data/local/tmp/update_engine_client --reset_status; mkdir -p /data/ota_package; chown system:cache /data/ota_package; chmod 0770 /data/ota_package; restorecon -RF /data/ota_package'
adb shell '/system/bin/snapshotctl dump | grep -q "Update state: none"'

adb push "$tmp/payload.bin" /data/ota_package/payload.bin >/dev/null
adb push "$tmp/payload_properties.txt" /data/ota_package/payload_properties.txt >/dev/null
adb shell 'chown system:cache /data/ota_package/payload.bin /data/ota_package/payload_properties.txt; chmod 0640 /data/ota_package/payload.bin /data/ota_package/payload_properties.txt; restorecon /data/ota_package/payload.bin /data/ota_package/payload_properties.txt'

echo "Applying $ota"
echo "OTA SHA-256: $zip_hash"
adb shell 'headers=$(cat /data/ota_package/payload_properties.txt); /data/local/tmp/update_engine_client --update --follow --payload=file:///data/ota_package/payload.bin --size='"$payload_size"' --headers="$headers"' | tee "$tmp/update-engine.log"
grep -q 'onPayloadApplicationComplete(ErrorCode::kSuccess (0))' "$tmp/update-engine.log"

adb shell reboot
adb wait-for-device
adb root >/dev/null
adb wait-for-device
adb shell 'while [ "$(getprop sys.boot_completed)" != 1 ]; do sleep 2; done'

target_slot="$(adb shell getprop ro.boot.slot_suffix | tr -d '\r')"
[[ "$target_slot" != "$source_slot" ]]
adb shell 'test "$(getenforce)" = Enforcing; test "$(getprop ro.crypto.state)" = encrypted; test -x /system/addon.d/30-gapps.sh; test -f /product/etc/permissions/privapp-permissions-google-product.xml; test -f /product/etc/sysconfig/google.xml; pm path com.google.android.gms >/dev/null; pm path com.android.vending >/dev/null; test -z "$(logcat -b crash -d)"'
adb shell 'rm -f /data/ota_package/payload.bin /data/ota_package/payload_properties.txt /data/local/tmp/update_engine_client; input keyevent 223'

echo "Update accepted on $target_slot"
