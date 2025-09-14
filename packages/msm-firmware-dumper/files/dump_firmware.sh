#!/bin/sh
# SPDX-License-Identifier: MIT
# Minimal Qualcomm firmware copier: modem + Wi‑Fi (cp, no ln)

set -eu

ab_get_slot() {
	if command -v qbootctl > /dev/null; then
		ab_slot_suffix=$(qbootctl -a | grep -o 'Active slot: _[ab]' | cut -d ":" -f2 | xargs) || :
	else
		ab_slot_suffix=$(grep -o 'androidboot\.slot_suffix=..' /proc/cmdline | cut -d "=" -f2) || :
	fi
	echo "${ab_slot_suffix:-}"
}

# Particiones a inspeccionar (RO)
SLOT="$(ab_get_slot)"
FW_PARTITIONS="
	apnhlos
	bluetooth${SLOT}
	dsp${SLOT}
	modem${SLOT}
	persist
	vendor${SLOT}
	RADIO
"
SUPER_PARTITIONS="super system"

# Directorios de trabajo y destino
BASEDIR="/run/msm-fw-min"
MNT="$BASEDIR/mnt"
DST_FW="/lib/firmware"
DST_WLAN_PRIMA="/lib/firmware/wlan/prima"

mkdir -p "$MNT" "$DST_FW" "$DST_WLAN_PRIMA"
mount -o mode=755,nodev,noexec,nosuid -t tmpfs none "$BASEDIR"

# Mapear dinámicas (si procede)
if command -v make-dynpart-mappings >/dev/null; then
	for part in /sys/block/mmcblk*/mmcblk*p* /sys/block/sd*/sd*; do
		[ -e "$part" ] || continue
		DEVNAME="$(sed -n 's/^DEVNAME=//p' "$part/uevent")"
		PARTNAME="$(sed -n 's/^PARTNAME=//p' "$part/uevent")"
		[ -n "$PARTNAME" ] || continue
		case " $SUPER_PARTITIONS " in
			*" $PARTNAME "*) 
				if make-dynpart-mappings "/dev/$DEVNAME"; then
					for dyn in /dev/mapper/*; do
						P="$(basename "$dyn")"
						case " $FW_PARTITIONS " in
							*" $P "*) mkdir -p "$MNT/$P"; mount -o ro,nodev,noexec,nosuid "$dyn" "$MNT/$P" 2>/dev/null || true ;;
						esac
					done
				fi
				break
			;;
		esac
	done
fi

# Montar por PARTNAME (RO)
for part in /sys/block/mmcblk*/mmcblk*p* /sys/block/sd*/sd*; do
	[ -e "$part" ] || continue
	DEVNAME="$(sed -n 's/^DEVNAME=//p' "$part/uevent")"
	PARTNAME="$(sed -n 's/^PARTNAME=//p' "$part/uevent")"
	[ -n "$PARTNAME" ] || continue
	case " $FW_PARTITIONS " in
		*" $PARTNAME "*) 
			mkdir -p "$MNT/$PARTNAME"
			mountpoint -q "$MNT/$PARTNAME" || mount -o ro,nodev,noexec,nosuid "/dev/$DEVNAME" "$MNT/$PARTNAME" 2>/dev/null || true
		;;
	esac
done

# Copiar módem (patrones habituales en particiones *image/* y *firmware/*)
copy_glob() {
	srcdir="$1"; shift
	[ -d "$srcdir" ] || return 0
	for pat in "$@"; do
		for f in "$srcdir"/$pat; do
			[ -f "$f" ] || continue
			cp -an "$f" "$DST_FW/$(basename "$f")" 2>/dev/null || true
		done
	done
}

for d in "$MNT"/*/image "$MNT"/*/firmware; do
	copy_glob "$d" \
		"mba.mbn" \
		"modem.*" \
		"wcnss.*" \
		"modem_pr/mcfg/configs/mcfg_sw/generic/common/default/default/mcfg_sw.mbn"
done

# Copiar Wi‑Fi NV desde persist
if [ -f "$MNT/persist/WCNSS_qcom_wlan_nv.bin" ]; then
	cp -an "$MNT/persist/WCNSS_qcom_wlan_nv.bin" "$DST_WLAN_PRIMA/WCNSS_qcom_wlan_nv.bin" 2>/dev/null || true
fi

# Opcional: conservar wcnss_mac_addr para uso posterior por init
if [ -f "$MNT/persist/wcnss_mac_addr" ]; then
	mkdir -p "$DST_FW/persist"
	cp -an "$MNT/persist/wcnss_mac_addr" "$DST_FW/persist/wcnss_mac_addr" 2>/dev/null || true
fi

# Limpiar montajes
for m in "$MNT"/*; do
	[ -d "$m" ] || continue
	umount "$m" 2>/dev/null || true
done

exit 0
