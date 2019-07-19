# Building guide

### Table of Contents
* [Build environments](#build-environments)
* [Syncing local repository](#syncing-local-repository)
* [Building HAL parts](#building-hal-parts)
* [Building SFOS packages](#building-sfos-packages)
* [Building the SFOS rootfs](#building-the-sfos-rootfs)

## Build environments

After initial setup you will have the `PLATFORM_SDK` and `HA_BUILD` environments ready to build the required parts. To enter `HA_BUILD` env you first need to go through `PLATFORM_SDK`.

How to enter `PLATFORM_SDK`:
```
HOST $ sfossdk
PLATFORM_SDK $
```

How to enter `HA_BUILD`:
```
PLATFORM_SDK $ habuild
HA_BUILD $
```

Leaving an environment can be achieved by simply entering `exit` or pressing `CTRL + D`
```
HA_BUILD $ exit
PLATFORM_SDK $
```

## Syncing local repository

At this point the process of downloading source code for LineageOS and libhybris will start. This will also be done when updating source code repos.

At first this may take a while depending on your internet connection speed (with 200 mbit/s it'll take ~10 mins for reference):
```
HA_BUILD $ repo sync -c -j`nproc` --fetch-submodules --no-tags --no-clone-bundle && rm -rf vendor/lineage/bootanimation/
```

If this is your first time building, execute the following line to finalize the environment:
```
HA_BUILD $ . build/envsetup.sh && breakfast cheeseburger && export USE_CCACHE=1
```

## Building HAL parts

Now we will build the required parts of LineageOS for HAL to function properly under SFOS. This usually takes around 25 minutes on 4 relatively fast CPU cores (i5-4690K) for the first time. To start the process, enter:
```
HA_BUILD $ mka hybris-hal
```

During the `hybris-hal` build process a `hybris-boot.img` boot image in `out/target/product/cheeseburger/` will be generated. When kernel and other Android side changes are done afterwards the image can be regenerated using:
```
HA_BUILD $ mka hybris-boot
```

In case a recovery boot image is needed, it can be built like so:
```
HA_BUILD $ mka hybris-recovery
```

## Building SFOS packages

When building for the first time you need to execute a few commands to fix some issues. See [fixing build_packages](INITIAL-BUILDING.md#fixing-build_packages) under the [initial building guide](INITIAL-BUILDING.md) and come back here afterwards.

Sailfish OS packages will need to be built many times during development. To selectively build / rebuild **everything**, run the following command (full build takes ~15 minutes for me):
```
PLATFORM_SDK $ rpm/dhd/helpers/build_packages.sh
```

**NOTE:** If this was your first time running build_packages, see [building extra packages](INITIAL-BUILDING.md#building-extra-packages) under the [initial building guide](INITIAL-BUILDING.md).

When just droid configs have been modified, `rpm/dhd/helpers/build_packages.sh -c` will be enough. Same goes for droid HAL stuff, but with `-d` flag instead. Building with these flags set will be substantially faster than rebuilding everything.

After building droid configs, you should always regenerate the kickstart file as follows:
```
PLATFORM_SDK $

HA_REPO="repo --name=adaptation-community-common-$DEVICE-@RELEASE@"
HA_DEV="repo --name=adaptation-community-$DEVICE-@RELEASE@"
KS="Jolla-@RELEASE@-$DEVICE-@ARCH@.ks"
sed "/$HA_REPO/i$HA_DEV --baseurl=file:\/\/$ANDROID_ROOT\/droid-local-repo\/$DEVICE" $ANDROID_ROOT/hybris/droid-configs/installroot/usr/share/kickstarts/$KS > $KS
```

## Building the SFOS rootfs

This is the final step in building stuff. Please define `RELEASE` as latest public build from the [version history](https://en.wikipedia.org/wiki/Sailfish_OS#Version_history). At the time of writing this would have been `3.0.3.10`. The `mic` build process averages ~7 minutes for me.

After this you should have a flashable Sailfish OS zip in `sfe-cheeseburger-*/`:
```
PLATFORM_SDK $

RELEASE=3.0.3.10
hybris/droid-configs/droid-configs-device/helpers/process_patterns.sh
sudo mic create fs --arch=$PORT_ARCH --tokenmap=ARCH:$PORT_ARCH,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME --record-pkgs=name,url --outdir=sfe-$DEVICE-$RELEASE$EXTRA_NAME --pack-to=sfe-$DEVICE-$RELEASE$EXTRA_NAME.tar.bz2 $ANDROID_ROOT/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks
```
Hooray! You've now successfully fully built all of the Sailfish OS source code into a rather tiny (~350 MB) flashable zip file! Look into the [flashing guide](FLASHING.md) on how to proceed.
