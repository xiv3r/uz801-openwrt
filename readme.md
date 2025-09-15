## WRT for uz801
These are my attempts at building the os... my end goal is to build a working modern openwrt, but first I will start from immortalwrt from lkiuyu and the from official immortalwrt.

### lkiuyu/immortalwrt
- Modem Working
  - No Rx/Tx displayed in luci interface (?)
- Wifi Working
- USB gadget working (NCM, RNDIS, MASS, ACM tested!)
---
### TODO:
- ~~Use `msm-firmware-loader` instead of bundling firmware.~~
  - There is no easy way to load the partitions before kernel looks for them...
- Recover GHA build pipeline
- Use built dtb from openstick-builder?
  - use linux's dts?
- modemmanager not showing rxtx
---
### Stuff
- The `msm8916-yiming-uz801v3.dtb` file is a prebuilt dtb extracted from one of the many OpenStick-Builder project living in Github.