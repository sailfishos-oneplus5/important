# Flashing guide
This is the initial version of the flashing guide. It will most likely become way simpler once I figure out some stuff :)

### Table of Contents
* [Unlocking the device](#unlocking-the-device)
* [Verifying Treble support](#verifying-treble-support)
* [Downgrading firmware & TWRP](#downgrading-firmware-twrp)
* [Pre-flash actions](#pre-flash-actions)
* [Flashing ZIPs](#flashing-zips)
* [Post-flash actions](#post-flash-actions)

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


## Pre-flash actions
Because tar is broken in TWRP's busybox for this device, we'll be working around that by just creating a temporary 12 GB [`swap file`](https://www.linux.com/news/all-about-linux-swap-space):
```
ADB_SHELL #

dd if=/dev/zero of=/sdcard/swapfile bs=1M count=12288
chmod 600 /sdcard/swapfile
mkswap /sdcard/swapfile
swapon /sdcard/swapfile
```
This file will have to be created/enabled each time before you flash the SFOS zip until I've found a better workaround.

## Flashing ZIPs
1. Flash [this LineageOS 15.1 zip](https://download.lineage.microg.org/cheeseburger/lineage-15.1-20190225-microG-cheeseburger.zip) (tested by me and known to work)
2. Flash your desired SFOS zip

## Post-flash actions
Once the zips have flashed successfully, the temporary swapfile can be safely removed:
```
ADB_SHELL #

swapoff /sdcard/swapfile
rm /sdcard/swapfile
```

There are 2 services (`time_daemon` and `qti`) which both are started by vendor init scripts that cannot be overridden by [sparse files](https://git.io/fji3Y) in [dcd](https://git.io/fji3O) (why?). They don't seem do anything useful under Sailfish, just spam logs like crazy and cause battery drain because they are being restarted every 5-10 seconds (fix?) and I recommend disabling them before booting like so:
```
ADB_SHELL #

umount /vendor
mount -o rw /vendor
sed -i "s/service qti.*/service qti \/vendor\/bin\/qti_HYBRIS_DISABLED/" /vendor/etc/init/hw/init.qcom.rc
sed -i "s/service time_daemon.*/service time_daemon \/vendor\/bin\/time_daemon_HYBRIS_DISABLED/" /vendor/etc/init/hw/init.qcom.rc
```
After all this I tend to clear caches and reboot to the new SFOS system :)
