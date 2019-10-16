# Flashing guide

### Table of Contents
* [Disclaimer](#disclaimer)
* [Unlocking the device](#unlocking-the-device)
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

## Downgrading firmware & TWRP<a name="downgrading-firmware-twrp"></a>

When using Sailfish OS the current port expects the phone to have Android 8 Oreo firmware, so most likely downgrading via TWRP will be required.

1. Fetch the files for latest O<sub>2</sub>OS 8.1 firmware ([OP5 / cheeseburger](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/cheeseburger/firmware/firmware_5.1.7_oneplus5.zip/download) | [OP5T / dumpling](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/dumpling/firmware/firmware_5.1.7_oneplus5t.zip/download)) and a TWRP 3.2.3 image ([OP5 / cheeseburger](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/cheeseburger/recovery/twrp-3.2.3-0-20180822-codeworkx-cheeseburger.img/download) | [OP5T / dumpling](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/dumpling/recovery/twrp-3.2.3-0-20180822-codeworkx-dumpling.img/download)).
2. Flash the firmware zip first and then TWRP image to Recovery partition.
3. First time flashers should also check `/data` for filesystem issues (make sure it's **unmounted** & formatted as **`ext4`** beforehand!):
```
ADB_SHELL # e2fsck /dev/block/bootdevice/by-name/userdata
```
4. Before rebooting back to recovery make sure to "Format data"!

## Flashing steps

1. Clear data & caches (factory reset)
2. Flash [the latest LineageOS 15.1 zip for your device from here](https://mega.nz/#F!W9MyDAJJ!riJ5okLw5CVZlqWoTVC_1g) (tested and known to work)
3. (Optional) Flash whatever else you normally have on the Android side (e.g. [OpenGApps](https://opengapps.org/), [Magisk](https://forum.xda-developers.com/apps/magisk/official-magisk-v7-universal-systemless-t3473445/), [disable dm_verity & force-encrypt](https://zackptg5.com/android.php#disverfe) etc)
4. Flash [your desired SFOS zip](https://mega.nz/#F!KhsWGYzT!nKLttGqwJg0DY-IArUlbdQ) (normally takes ~1 min 30 sec)
5. Reboot

## Skipping tutorial

Once booted for the first time Sailfish OS will always start off with a tutorial screen. Since you'll likely be flashing zips many times, this will become very annoying rather quickly. You can skip this by tapping each corner of the screen once starting from top-left going clockwise.

## Dual-booting with LineageOS

What makes SFOS unique as well is that it doesn't actually touch your `/system` partition (and `/vendor` once I figure stuff out :p), which makes it super easy to dual-boot!

The only limitation is that you'll be stuck on LOS 15.1 (Android 8.1 Oreo) unless you want to start flashing different ROMs, firmware & TWRP versions for when you boot SFOS rather than Android, which I really cannot recommend.

When you've flashed a Sailfish OS zip you can swap between the operating systems without needing wiping anything by simply flashing my [boot-switcher zip](https://git.io/fjPUq) within TWRP.
