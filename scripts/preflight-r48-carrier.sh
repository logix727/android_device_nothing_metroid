#!/usr/bin/env bash
set -euo pipefail

EXPECTED_INCREMENTAL=1787327311
EXPECTED_BASEBAND=7.0-02698-PAKALA_GEN_PACK-1.152387.2.170946.5

if [[ -z ${ADB:-} ]]; then
    ADB=$(command -v adb || true)
fi
[[ -n ${ADB:-} && -x $ADB ]] || {
    echo "FAIL: adb was not found; set ADB=/path/to/adb" >&2
    exit 2
}

adb() {
    "$ADB" "$@"
}

prop() {
    adb shell getprop "$1" | tr -d '\r'
}

normalize_baseband() {
    local value=${1//[[:space:]]/}
    printf '%s' "${value#MPSS.DE.}"
}

[[ $(adb get-state 2>/dev/null || true) == device ]] || {
    echo "FAIL: connect and authorize the booted phone over ADB" >&2
    exit 3
}

incremental=$(prop ro.build.version.incremental)
baseband=$(prop gsm.version.baseband)
slot=$(prop ro.boot.slot_suffix)
boot_completed=$(prop sys.boot_completed)
default_network=$(prop ro.telephony.default_network)
sim_state=$(prop gsm.sim.state)
crypto=$(prop ro.crypto.state)
selinux=$(adb shell getenforce | tr -d '\r')
tipc=$(adb shell 'grep -cw tipc /proc/modules 2>/dev/null || true' | tr -d '\r')
IFS=, read -r baseband_0 baseband_1 baseband_extra <<<"$baseband"
baseband_0=$(normalize_baseband "${baseband_0:-}")
baseband_1=$(normalize_baseband "${baseband_1:-}")

failed=0
check() {
    local label=$1 actual=$2 expected=$3
    if [[ $actual == "$expected" ]]; then
        printf 'PASS: %s=%s\n' "$label" "$actual"
    else
        printf 'FAIL: %s=%s expected=%s\n' "$label" "$actual" "$expected" >&2
        failed=1
    fi
}

check incremental "$incremental" "$EXPECTED_INCREMENTAL"
check baseband_slot_0 "$baseband_0" "$EXPECTED_BASEBAND"
check baseband_slot_1 "$baseband_1" "$EXPECTED_BASEBAND"
if [[ -n ${baseband_extra:-} ]]; then
    echo "FAIL: unexpected extra baseband entries: $baseband" >&2
    failed=1
fi
check boot_completed "$boot_completed" 1
check default_network "$default_network" 26,26
check tipc_loaded "$tipc" 1
check crypto "$crypto" encrypted
check selinux "$selinux" Enforcing
printf 'INFO: slot=%s sim_state=%s raw_baseband=%s\n' "$slot" "$sim_state" "$baseband"

if ((failed)); then
    cat >&2 <<'EOF'
REFUSED: this device is not eligible for r48 carrier testing.
The Lineage OTA does not install Nothing firmware. If the baseband is wrong,
return to official Nothing OS and install the complete B4.1 260814 update before
reinstalling r48. Do not flash only modem.
EOF
    exit 4
fi

echo "READY: r48 ROM and required firmware match; carrier testing may proceed."
