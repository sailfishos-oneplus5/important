# Building guide

### Table of Contents
* [Build environments](#build-environments)
* [Syncing local repository](#syncing-local-repository)
* [Building HAL parts](#building-hal-parts)
* [Building SFOS packages & rootfs](#building-sfos-packages-rootfs)

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

At first this may take a while depending on your internet connection speed (with 200 mbit/s it'll take ~8 mins for reference):
```
HA_BUILD $ repo sync -c -j`nproc` --fetch-submodules --no-clone-bundle --no-tags
```

If this is your first time building, execute the following line to finalize the environment:
```
HA_BUILD $ hybris-patches/apply-patches.sh --mb && . build/envsetup.sh && breakfast $DEVICE
```

**NOTE:** It's possible and **required before syncing again** to use `repo sync -l` to reset your cloned repos to their pre-patch states, however at the cost of losing **any and all** local-only changes!

## Building HAL parts

Now we will build the required parts of LineageOS for HAL to function properly under SFOS. This usually takes around 9 minutes on 16 Zen 2 threads (R7 3700X) for the first time. To start the process, enter:
```
HA_BUILD $

rm -rf vendor/lineage/bootanimation/
mka hybris-hal
```

**NOTE:** If this was your first time building the droid HAL side, the following needs to be also executed for working camera, video playback & recording etc; this shouldn't take very long:
```
echo "MINIMEDIA_AUDIOPOLICYSERVICE_ENABLE := 1" > external/droidmedia/env.mk
mka droidmedia libbiometry_fp_api_32
hybris/mw/sailfish-fpd-community/rpm/copy-hal.sh
```

During the `hybris-hal` build process `hybris-*.img` boot images in `out/target/product/$DEVICE/` will be generated. When kernel and other Android side changes are done afterwards the image can be regenerated using:
```
HA_BUILD $ mka hybris-boot
```

## Building SFOS packages & rootfs<a name="building-sfos-packages-rootfs"></a>

Before beginning, run the following to avoid a few errors while building and pulling repo updates:
```
croot
cd external/libhybris
git checkout master
cd -
cd hybris/mw/sailfish-fpd-community
git checkout master
cd -
```

To pull updates and start (re)building all locally required SFOS packages & the rootfs, run the following command (full build takes ~20 minutes for me):
```
PLATFORM_SDK $ build_all_packages
```

For now here's also a temporary "fix" for `repo problem: nothing provides sailfish-fpd-community needed by pattern:jolla-configuration-...`:
```
croot
cp droid-local-repo/$DEVICE/sailfish-fpd-community/droid-*.rpm /tmp
bp -b hybris/mw/sailfish-fpd-community -s rpm/sailfish-fpd-community.spec
mv /tmp/droid-*.rpm droid-local-repo/$DEVICE/sailfish-fpd-community/
bp -vi
```

As the rootfs `mic` build command line is now included in `build_packages.sh` steps, this is all you need to get a rather tiny (~380 MB) flashable SFOS zip file! Look into the [flashing guide](FLASHING.md) on how to proceed afterwards.

When just droid configs have been modified, `build_device_configs` will be enough. Same goes for droid HAL stuff with `build_droid_hal` instead. Building with these commands instead will be substantially faster than rebuilding everything (which is unnecessary 99% of the time anyways).

The rootfs build can still be triggered manually too if required via `run_mic_build`. This makes sense if you've just modified `droid-configs` for example and have no need to rebuild all packages for no reason again :)
