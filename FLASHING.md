# Flashing guide

### Table of Contents
* [Disclaimer](#disclaimer)
* [Unlocking the device](#unlocking-the-device)
* [Verifying Treble support](#verifying-treble-support)
* [Downgrading firmware & TWRP](#downgrading-firmware-twrp)
* [Flashing steps](#flashing-steps)
* [Skipping tutorial](#skipping-tutorial)
* [Dual-booting with LineageOS](#dual-booting-with-lineageos)

## Disclaimer

```cpp
#include "disclaimer.h"
/*
 * I am NOT responsible for you getting fired because the alarm app failed or if you destroy your device.
 * Please do some research if you have any concerns about features included in this port.
 * Same security standards as for official Sailfish OS devices may not apply here.
 * Everything is served on an as-is basis and YOU are choosing to do these modifications.
 */
 ```

**WARNING:** All current data on the device WILL be erased, so be sure to make full data & NANDroid backups before proceeding!

## Unlocking the device

Check out [this forum post](https://forums.oneplus.com/threads/guide-oneplus-5-how-to-unlock-bootloader-flash-twrp-root-nandroid-efs-backup-and-more.548216/), rooting can be ignored as the system will be wiped fully anyways afterwards.

## Verifying Treble support

When booted to TWRP you can verify Treble support via a simple command:
```
ADB_SHELL # [ -r /dev/block/bootdevice/by-name/vendor ] || echo "Treble support NOT present!"
```
If it doesn't return anything, move forward. In other cases you need to flash stock [O<sub>2</sub>OS 5.1.5](https://otafsg.h2os.com/patch/amazone2/GLO/OnePlus5Oxygen/OnePlus5Oxygen_23.J.38_GLO_038_1808082017/OnePlus5Oxygen_23_OTA_038_all_1808082017_ebb1d69f37.zip) and do an [OTA update to 5.1.6](http://otafsg1.h2os.com/patch/amazone2/GLO/OnePlus5Oxygen/OnePlus5Oxygen_23.J.39_GLO_039_1810091237/OnePlus5Oxygen_23_OTA_039_all_1810091237_160b.zip) from there.

## Downgrading firmware & TWRP<a name="downgrading-firmware-twrp"></a>

When using Sailfish OS the current port expects the phone to have Android 8 firmware, so most likely downgrading via TWRP will be required.

1. Fetch the files for [latest O<sub>2</sub>OS 8.1 firmware](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/cheeseburger/firmware/firmware_5.1.7_oneplus5.zip/download) and the [TWRP image](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/cheeseburger/recovery/twrp-3.2.1-0-20180414-codeworkx-cheeseburger.img/download) we'll be using.
2. Flash the firmware zip first and then TWRP image to Recovery partition.
3. First time flashers should also check `/data` for filesystem issues (make sure it's formatted as `ext4` beforehand!):
```
ADB_SHELL #

umount /dev/block/bootdevice/by-name/userdata
e2fsck /dev/block/bootdevice/by-name/userdata
```
4. Before rebooting back to recovery make sure to "Format data"!

## Flashing steps

1. Flash [this LineageOS 15.1 zip](https://download.lineage.microg.org/cheeseburger/lineage-15.1-20190225-microG-cheeseburger.zip) (tested by me and known to work)
2. Flash your desired SFOS zip (normally takes ~1 min 30 sec)
3. (Optional) clear caches
4. Reboot

## Skipping tutorial

Once booted for the first time Sailfish OS will always start off with a tutorial screen. Since you'll likely be flashing zips many times, this will become very annoying rather quickly. You can skip this by tapping each corner of the screen once starting from top-left going clockwise.

## Dual-booting with LineageOS

What makes SFOS unique as well is that it doesn't actually touch your `/system` partition (and `/vendor` once I figure stuff out :p), which makes it super easy to dual-boot!

The only limitation is that you'll be stuck on LOS 15.1 (Android 8.1 Oreo) unless you want to start flashing different ROMs for when you boot SFOS than Android, which I really cannot recommend.

If you want [full regular GApps](https://opengapps.org/) instead of [MicroG](https://microg.org/), you probably want to flash a different **recent** LOS zip than what I [mention on this guide](#flashing-zips) (I haven't personally tested this but it should work as well).

When you've flashed a Sailfish OS zip you can swap between the operating systems without needing wiping anything by simply flashing my [boot-switcher zip](https://git.io/fjPUq) within TWRP.

