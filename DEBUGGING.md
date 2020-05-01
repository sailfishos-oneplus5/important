# Debugging guide

### Table of Contents
* [Device reboots to fastboot](#device-reboots-to-fastboot)
* [Can't get past setup / lockscreen](#cant-get-past-setup-lockscreen)
* [Getting telnet](#getting-telnet)
* [Debugging via SSH](#debugging-via-ssh)
* [Stracing binaries](#stracing-binaries)
* [Gathering logs](#gathering-logs)
* [Transferring logs](#transferring-logs)

## Device reboots to fastboot

For me this has happened when flashing the wrong LineageOS 16.0 zip. Double-check that the zip I've mentioned in the [flashing guide](FLASHING.md#flashing-steps) matches yours unless you know what you are doing!

## Can't get past setup / lockscreen<a name="cant-get-past-setup-lockscreen"></a>

In my experience this usually happens when you **DON'T** flash the LineageOS 16.0 zip before SFOS zip (e.g. after testing everything & wiping all but `/system`). Please make sure you followed the [flashing guide](FLASHING.md) fully!

I've also noticed some other e.g. `unofficial` LineageOS builds causing this behavior as well.

## Getting telnet

You can think of `telnet` as a replacement for the [ADB](https://developer.android.com/studio/command-line/adb) shell. On the host a telnet session can be started by typing:
```
HOST $ telnet 192.168.2.15 2323
```

**NOTE:** This only works on local debugging builds!

## Debugging via SSH

Remote debugging is possible via SSH on a local Wi-Fi network. It should be running by default on developer mode, but you'll need some setup:
```
TELNET # passwd nemo
```

Once a password has been set for the regular user `nemo`, you need to get the IP address of the device:
```
TELNET # ip a | grep wlan0
23: wlan0: <BROADCAST,MULTICAST,DYNAMIC,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 3000
    inet 192.168.1.105/24 brd 192.168.1.255 scope global wlan0
```
**NOTE:** The `WLAN IP address` can also be seen on the device UI in `Settings` > `Developer tools`.

In this case the device's IP is `192.168.1.105` and I can SSH in like so:
```
HOST $ ssh nemo@192.168.1.105
nemo@192.168.1.105's password: 
Last login: Sun Jul  7 12:16:15 2019
,---
| Sailfish OS 3.3.0.16 (Rokua)
'---
[nemo@Sailfish ~]$
```

To gain root access via SSH the following needs to be used (in some regards the command works like `sudo`):
```
[nemo@Sailfish ~]$ devel-su
Password:
[root@Sailfish nemo]#
```
**NOTE:** Prompts below starting with `#` are meant to be run as `root` and similarly ones starting with `$` are meant to be run as the user `nemo`!

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
HOST $ scp nemo@192.168.1.105:/sdcard/*.log .
nemo@192.168.1.105's password: 
dmesg.log                                                    100% 2003KB  14.0MB/s   00:00
journalctl.log                                               100%  905KB  11.6MB/s   00:00
logcat.log                                                   100%  491KB   9.6MB/s   00:00
```
and also via most of the GUI Linux file managers (Windows requires [an explorer extension](http://swish-sftp.org/) or [a seperate client](https://winscp.net/eng/index.php)).

**NOTE:** The SSH scp command can also be used over the telnet `192.168.2.15` IP when connected locally!

If nothing else works you can boot the device to TWRP and get the logs from there in whichever way you prefer.
