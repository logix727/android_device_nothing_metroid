#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)
from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)

namespace_imports = [
    'hardware/qcom-caf/sm8750',
    'hardware/qcom-caf/wlan',
    'vendor/qcom/opensource/commonsys/display',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/qcom/opensource/dataservices',
    'vendor/qcom/opensource/display',
    'device/nothing/metroid',
]

blob_fixups: blob_fixups_user_type = {
    'vendor/etc/init/android.hardware.biometrics.face-service.noth.rc': blob_fixup()
        .regex_replace('    disabled\n    disabled\n', '    disabled\n')
        .regex_replace(
            '    group camera system\n',
            '    group camera system\n'
            '    interface aidl android.hardware.biometrics.face.IFace/default\n',
        ),
    'vendor/etc/init/cnd.rc': blob_fixup()
        .regex_replace('    disabled\n', ''),
    'vendor/etc/init/qms.rc': blob_fixup()
        .regex_replace('    disabled\n', '')
        .regex_replace(
            '     class main\n',
            '     class main\n'
            '     user root\n',
        )
        .regex_replace('    user root\n    group root\n', ''),
    'vendor/etc/init/init.nt_logtool.rc': blob_fixup()
        .regex_replace(
            'service diag_gpslog_start ',
            'on post-fs-data\n'
            '    mkdir /data/vendor/diag_mdlog 0770 root system\n'
            '    restorecon_recursive /data/vendor/diag_mdlog\n\n'
            'service diag_gpslog_start ',
        ),
    'vendor/etc/init/hw/init.qcom.usb.rc': blob_fixup()
        .regex_replace('ncm\\.0', 'ncm.gs6'),
    'vendor/etc/init/hw/init.qcom.rc': blob_fixup()
        .regex_replace(
            '    exec u:r:vendor_qti_init_shell:s0 -- /vendor/bin/init\\.qti\\.can\\.sh\n',
            '',
        )
        .regex_replace(
            'service vendor\\.atfwd /vendor/bin/ATFWD-daemon\n'
            '    class late_start\n'
            '    user system\n'
            '    group system radio\n\n',
            '',
        )
        .regex_replace(
            'service esepmdaemon /system/vendor/bin/esepmdaemon\n'
            '    class core\n'
            '    user system\n'
            '    group nfc\n\n',
            '',
        )
        .regex_replace(
            'service chre /vendor/bin/chre\n'
            '    class late_start\n'
            '    user system\n'
            '    group system\n'
            '    socket chre seqpacket 0660 root system\n'
            '    shutdown critical\n\n'
            'on property:vendor\\.chre\\.enabled=0\n'
            '   stop chre\n\n',
            '',
        ),
    'vendor/etc/init/vendor.qti.hardware.perf2-hal-service.rc': blob_fixup()
        .regex_replace('    disabled\n    disabled\n', ''),
    'vendor/etc/init/vendor.qti.media.c2@1.0-service.rc': blob_fixup()
        .regex_replace('    disabled\n', ''),
    'vendor/etc/init/vendor.qti.media.c2audio@1.0-service.rc': blob_fixup()
        .regex_replace('    disabled\n', ''),
}

module = ExtractUtilsModule(
    'metroid',
    'nothing',
    blob_fixups=blob_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
