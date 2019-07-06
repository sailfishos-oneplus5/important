# Flashing guide
This is the initial version of the flashing guide. It will most likely become way simpler once I figure out some stuff :)

### Table of Contents
* [Unlocking the device](#unlocking-the-device)
* [Verifying Treble support](#verifying-treble-support)
* [Downgrading firmware & TWRP](#downgrading-firmware-twrp)
* [Pre-flash actions](#pre-flash-actions)
* [Flashing ZIPs](#flashing-zips)
* [Post-flash actions](#post-flash-actions)
* [Post-boot actions](#post-boot-actions)

## Unlocking the device
Check out [this forum post](https://forums.oneplus.com/threads/guide-oneplus-5-how-to-unlock-bootloader-flash-twrp-root-nandroid-efs-backup-and-more.548216/), rooting can be ignored as the system will be wiped fully anyways afterwards.

## Verifying Treble support
When booted to TWRP you can verify Treble support via a simple command:
```
ADB_SHELL # [ ! -r /dev/block/bootdevice/by-name/vendor ] && echo "Treble support NOT present!"
ADB_SHELL #
```
If it doesn't return anything, move forward. In other cases you need to flash stock [O<sub>2</sub>OS 5.1.5](https://otafsg.h2os.com/patch/amazone2/GLO/OnePlus5Oxygen/OnePlus5Oxygen_23.J.38_GLO_038_1808082017/OnePlus5Oxygen_23_OTA_038_all_1808082017_ebb1d69f37.zip) and do an [OTA update to 5.1.6](http://otafsg1.h2os.com/patch/amazone2/GLO/OnePlus5Oxygen/OnePlus5Oxygen_23.J.39_GLO_039_1810091237/OnePlus5Oxygen_23_OTA_039_all_1810091237_160b.zip) from there.

Download one of the following TWRP images depending on your current Android version:
[Android 9.x](https://dl.twrp.me/cheeseburger/twrp-3.3.1-0-cheeseburger.img)
[Android 8.x](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/cheeseburger/recovery/twrp-3.2.1-0-20180414-codeworkx-cheeseburger.img/download)

Installing is done by simply executing `fastboot flash recovery /path/to/twrp.img`.

## Downgrading firmware & TWRP<a name="downgrading-firmware-twrp"></a>
When using Sailfish OS the current port expects the phone to have Android 8 firmware, so most likely downgrading via TWRP will be required.

1. Fetch the files for [latest OxygenOS 8.1 firmware](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/cheeseburger/firmware/firmware_5.1.7_oneplus5.zip/download) and the [TWRP](https://sourceforge.net/projects/cheeseburgerdumplings/files/15.1/cheeseburger/recovery/twrp-3.2.1-0-20180414-codeworkx-cheeseburger.img/download) build we'll be using.
2. Flash the firmware zip first and then TWRP image to Recovery partition.
3. Before rebooting back to recovery make sure to "Format data"!

## Pre-flash actions
Coming soon...

## Flashing ZIPs
Coming soon...

## Post-flash actions
Coming soon...

## Post-boot actions
Coming soon...
