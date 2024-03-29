# Debugging guide

### Table of Contents
* [Notice about default user](#notice-about-default-user)
* [Device reboots to fastboot](#device-reboots-to-fastboot)
* [Can't get past setup / lockscreen](#cant-get-past-setup-lockscreen)
* [Getting telnet](#getting-telnet)
* [Debugging via SSH](#debugging-via-ssh)
* [Stracing binaries](#stracing-binaries)
* [Gathering logs](#gathering-logs)
* [Transferring logs](#transferring-logs)

## Notice about default user

Since Sailfish OS 3.4.0 (Pallas-Yllästunturi) the installation default user has become `defaultuser` where in all previous versions it has been `nemo`.

In case you upgraded to/past this version from a previous build where the user was still `nemo`, your user is still `nemo` and it should be used in all cases where `defaultuser` is now mentioned in this guide.

## Device reboots to fastboot

For me this has happened when flashing the wrong LineageOS 16.0 zip. Double-check that the zip I've mentioned in the [flashing guide](FLASHING.md#flashing-steps) matches yours unless you know what you are doing!

## Can't get past setup / lockscreen<a name="cant-get-past-setup-lockscreen"></a>

In my experience this usually happens when you **DON'T** flash the LineageOS 16.0 zip before SFOS zip (e.g. after testing everything & wiping all but `/system`). Please make sure you followed the [flashing guide](FLASHING.md) fully!

I've also noticed some other e.g. `unofficial` LineageOS builds causing this behavior as well.

## Getting telnet

You can think of `telnet` as a replacement for the [ADB](https://developer.android.com/studio/command-line/adb) shell. On the host (assuming the device is connected via USB using developer mode) a telnet session can be started by typing:
```
HOST $ telnet 192.168.2.15 2323
```

**NOTE:** On production builds `telnet` connections are blocked by default using the file `/init_disable_telnet`! Remove this and reboot if you intend to bring up `telnetd` on the device during init.

Starting the `telnet` daemon temporarily from the device is also possible using the following:
```
DEVICE # busybox-static telnetd -b 192.168.2.15:2323 -l /bin/sh &
```

If the connection still doesn't work you may have to manually assign an IP address for the device from your host like so:
```
HOST #

ip address                     # find device interface name to use below, example: enp40s0f3u4u1
DEV="enp40s0f3u4u1"
ip address add 192.168.2.20 dev $DEV
ip route add 192.168.2.15 dev $DEV
```

## Debugging via SSH

Remote debugging is possible via SSH on a local Wi-Fi network. It should be running by default on developer mode, but you'll need some setup:
```
TELNET # passwd defaultuser
```

Once a password has been set for the regular user `defaultuser`, you need to get the IP address of the device:
```
TELNET # ip a | grep wlan0
23: wlan0: <BROADCAST,MULTICAST,DYNAMIC,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 3000
    inet 192.168.1.105/24 brd 192.168.1.255 scope global wlan0
```
**NOTE:** The `WLAN IP address` can also be seen on the device UI in `Settings` > `Developer tools`.

In this case the device's IP is `192.168.1.105` and I can SSH in like so:
```
HOST $ ssh defaultuser@192.168.1.105
defaultuser@192.168.1.105's password: 
Last login: Fri Nov 20 21:36:06 2020
,---
| Sailfish OS 4.0.1.48 (Koli)
'---
[defaultuser@Sailfish ~]$
```

To gain root access via SSH the following needs to be used (in some regards the command works like `sudo`):
```
[defaultuser@Sailfish ~]$ devel-su
Password:
[root@Sailfish defaultuser]#
```
**NOTE:** Prompts below starting with `#` are meant to be run as `root` and similarly ones starting with `$` are meant to be run as the user `defaultuser`!

## Stracing binaries

Using the `strace` command can be beneficial e.g. when dealing with segfaulting or otherwise failing executables. It will print out all system calls and signals the binary attempts to do while running and specifically helps to find missing symlinks & other files.

If a specific command, say `ls /`, fails, a simple strace dump can be made via:
```
DEVICE $ strace -f -o /sdcard/strace.log ls /
```

When an already running process e.g. `ofonod` is say stuck in a loop, it can be straced like so:
```
DEVICE $ strace -f -o /sdcard/strace.log -p `pgrep ofonod | head -1`
```

Same applies for processes with known PIDs:
```
DEVICE $ strace -f -o /sdcard/strace.log -p 3714
```

## Gathering logs

In terms of content `journalctl` is the most important as it has pretty much everything you'd want in a log:
```
DEVICE # journalctl -b > /sdcard/journalctl.log
```

What it doesn't contain is the Android HAL side logs. They can be read via `logcat` as per usual:
```
DEVICE # logcat > /sdcard/logcat.log
```
**NOTE:** You WILL have to press `CTRL` + `C` when done!

Another one that could be potentially useful when dealing with kernel related issues is `dmesg`:
```
DEVICE # dmesg > /sdcard/dmesg.log
```

## Transferring logs

Starting from Android 9 Pie based ports, you can now just enable & use MTP like normal! If needed use the symlink to `/sdcard` named `android_storage` in the user folder.

If SSH access was enabled previously the logs can also be transferred via the command line:
```
HOST $ scp defaultuser@192.168.1.105:/sdcard/*.log .
defaultuser@192.168.1.105's password: 
dmesg.log                                                    100% 2003KB  14.0MB/s   00:00
journalctl.log                                               100%  905KB  11.6MB/s   00:00
logcat.log                                                   100%  491KB   9.6MB/s   00:00
```
and also via most of the GUI Linux file managers (Windows requires [an explorer extension](http://swish-sftp.org/) or [a seperate client](https://winscp.net/eng/index.php)).

**NOTE:** The SSH scp command can also be used over the telnet `192.168.2.15` IP when connected locally!

If nothing else works you can boot the device to TWRP and get the logs from there in whichever way you prefer.
