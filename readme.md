## WRT for uz801
These are my attempts at building the os... my end goal is to build a working modern openwrt, but first I will start from immortalwrt from lkiuyu and the from official immortalwrt.

### lkiuyu/immortalwrt
- Using `msm-firmware-loader`:
  - Working if manually enabled, as it seems that asks for wifi driver before persist is mounted.
    ```shell
      echo start > /sys/class/remoteproc/remoteproc0/state
      echo start > /sys/class/remoteproc/remoteproc1/state
    ```
  - https://gitlab.postmarketos.org/postmarketOS/msm-firmware-loader/
  - Investigate if this can be replicated in wrt:
    ```
      #!/sbin/openrc-run

      name="MSM Firmware Loader"
      description="Load firmware that is located on dedicated partitions of qcom devices"

      depend() { # <-----------------
        need sysfs devfs
        before udev
      }

      start() {
        ebegin "Starting msm-firmware-loader"
        # This script must be executed before udev, block other services until it's done.
        /usr/sbin/msm-firmware-loader.sh
        eend $?
      }
    ```
- Revert back to bundling the firmwares...

#### TODO:
- Modem does not register...
- ~~Use `msm-firmware-loader` instead of bundling firmware.~~
  - There is no easy way to load the partitions before kernel looks for them... so dumps instead of ln `msm-firmware-dumper` and then restart...
- msm8916-usb-gadget: attach console to tty?
- _**ucify**_ the uz801-tweaks... see `usb0` network setup!
- Recover GHA build pipeline
- Use built dtb from openstick-builder?
- create dependency script (instead of dockerfile) to reuse in multiple dockerfiles and GHA

---
### Stuff
- The `msm8916-yiming-uz801v3.dtb` file is a prebuilt dtb extracted from one of the many OpenStick-Builder project living in Github.