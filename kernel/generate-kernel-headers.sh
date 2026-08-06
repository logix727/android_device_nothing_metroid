#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DEVICE="$(dirname "$HERE")"
KERNEL="${1:-$DEVICE/../../../kernel/nothing/sm8735}"
OUTPUT="${2:-$DEVICE/prebuilt/kernel-headers.tar.gz}"
EXPECTED_KERNEL="ce342da8315a62e6144882faeddbdeccda544f9b"

[[ "$(git -C "$KERNEL" rev-parse HEAD)" == "$EXPECTED_KERNEL" ]] || {
    echo "Kernel must be at $EXPECTED_KERNEL" >&2
    exit 1
}

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

copy_pair() {
    local source="$1" component="$2" nested="$3"
    local base="$stage/usr/techpack/$component/include"
    install -Dm0644 "$KERNEL/$source" "$base/$nested"
    install -Dm0644 "$KERNEL/$source" "$base/${nested#*/}"
}

copy_pair vendor/qcom/opensource/video-driver/include/uapi/vidc/media/v4l2_vidc_extensions.h vidc vidc/media/v4l2_vidc_extensions.h
copy_pair vendor/qcom/opensource/graphics-kernel/include/uapi/linux/msm_kgsl.h linux linux/msm_kgsl.h
copy_pair vendor/qcom/opensource/spu-kernel/include/uapi/linux/spss_utils.h linux linux/spss_utils.h
copy_pair vendor/qcom/opensource/spu-kernel/include/uapi/linux/spcom.h linux linux/spcom.h

for path in media/mmm_color_fmt.h media/msm_sde_rotator.h media/Kbuild \
    drm/msm_drm_pp.h drm/msm_drm_aiqe.h drm/sde_drm.h drm/Kbuild \
    hdcp/msm_hdmi_hdcp_mgr.h hdcp/Kbuild Kbuild; do
    copy_pair "vendor/qcom/opensource/display-drivers/include/uapi/display/$path" \
        display "display/$path"
done

copy_pair vendor/qcom/opensource/dsp-kernel/include/uapi/misc/fastrpc.h misc misc/fastrpc.h

for path in linux/msm_audio_calibration.h linux/msm_audio.h \
    sound/audio_effects.h sound/audio_slimslave.h sound/msmcal-hwdep.h \
    sound/wcd-dsp-glink.h sound/lsm_params.h sound/devdep_params.h \
    sound/voice_params.h; do
    copy_pair "vendor/qcom/opensource/audio-kernel/include/uapi/audio/$path" \
        audio "audio/$path"
done

copy_pair vendor/qcom/opensource/synx-kernel/include/uapi/synx/media/synx_header.h synx synx/media/synx_header.h
copy_pair vendor/qcom/opensource/eva-kernel/include/uapi/eva/media/msm_eva_private.h eva eva/media/msm_eva_private.h

for name in cam_isp_ife.h cam_icp.h cam_cre.h cam_defs.h cam_isp_tfe.h \
    cam_req_mgr.h cam_sensor.h cam_isp_sfe.h cam_sync.h cam_lrme.h cam_isp.h \
    cam_jpeg.h cam_ope.h cam_tfe.h cam_custom.h cam_isp_vfe.h cam_cpas.h \
    cam_fd.h; do
    copy_pair "vendor/qcom/opensource/camera-kernel/include/uapi/camera/media/$name" \
        camera "camera/media/$name"
done

mkdir -p "$(dirname "$OUTPUT")"
tar --sort=name --format=gnu --owner=0 --group=0 --numeric-owner \
    --mtime='@0' --mode='u=rwX,go=rX' -C "$stage" -cf - usr \
    | gzip -n -9 > "$OUTPUT"

echo "$(sha256sum "$OUTPUT" | cut -d' ' -f1)  $OUTPUT"
