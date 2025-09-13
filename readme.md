TODO:
- Remove dependecy with any external repo (non other than immportal ones) i.e: openstick and use local packages
- Use usbgadget and usbgadget-ncm (from open/immortal wrt repos) and a newly created usbgadget-rndis instead of gc and adb
- try to use msm-firmware-loader...

## lkiuyu/immortalwrt
- Using msm-loader:
  - Working if manually enabled, as it seems that asks for wifi driver before persist is mounted.
    ```
    echo start > /sys/class/remoteproc/remoteproc0/state
    echo start > /sys/class/remoteproc/remoteproc1/state
    ```
- Revert back to bundling the drivers...