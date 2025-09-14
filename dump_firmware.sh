#!/bin/sh /etc/rc.common
# init script to extract Qualcomm MSM8916 firmware
# /etc/init.d/qcom-firmware

START=10

OUTDIR="/lib/firmware/qcom/msm8916"
FLAG="$OUTDIR/done.flag"
PARTS="modem persist fsg fsc sec dsp"

start() {
    if [ -f "$FLAG" ]; then
        echo "[*] Qualcomm firmware already extracted, skipping."
        return 0
    fi

    mkdir -p "$OUTDIR"

    echo "[*] Extracting Qualcomm firmware partitions..."
    for part in $PARTS; do
        DEV="/dev/disk/by-partlabel/$part"
        if [ -e "$DEV" ]; then
            echo "  - Dumping $part..."
            dd if="$DEV" of="$OUTDIR/$part.img" bs=1M status=none
        else
            echo "  ! Partition $part not found at $DEV"
        fi
    done

    echo "[*] Creating symbolic links..."
    for f in $OUTDIR/*.img; do
        base=$(basename "$f" .img)
        ln -sf "$f" "$OUTDIR/$base"
    done

    # Create the flag
    touch "$FLAG"
    echo "[+] Firmware successfully extracted to $OUTDIR (flag created)"
}
