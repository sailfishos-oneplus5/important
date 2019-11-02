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
HA_BUILD $ repo sync -c -j`nproc` --fetch-submodules --no-clone-bundle --no-tags
```

If this is your first time building, execute the following line to finalize the environment:
```
HA_BUILD $ hybris-patches/apply-patches.sh --mb && . build/envsetup.sh && breakfast $DEVICE && export USE_CCACHE=1
```

It's possible and **required before syncing again** to use `repo sync -l` to reset your cloned repos to their pre-patch states, however at the cost of losing **any and all** local-only changes!

## Building HAL parts

Now we will build the required parts of LineageOS for HAL to function properly under SFOS. This usually takes around 9 minutes on 16 Zen 2 threads (R7 3700X) for the first time. To start the process, enter:
```
HA_BUILD $ mka hybris-hal
```

**NOTE:** If this was your first time building the droid HAL side, the following needs to be also executed for working camera, video playback & recording etc; this shouldn't take very long:
```
echo "MINIMEDIA_AUDIOPOLICYSERVICE_ENABLE := 1" > external/droidmedia/env.mk
sed "s/Werror/Werror -Wno-unused-parameter/" -i frameworks/av/services/camera/libcameraservice/Android.mk
mka droidmedia
mka audioflingerglue
```

During the `hybris-hal` build process `hybris-*.img` boot images in `out/target/product/$DEVICE/` will be generated. When kernel and other Android side changes are done afterwards the image can be regenerated using:
```
HA_BUILD $ mka hybris-boot
```

## Building SFOS packages

Most likely Sailfish OS packages will need to be built many times during development. To selectively build / rebuild **everything**, run the following command (full build takes ~15 minutes for me):
```
PLATFORM_SDK $ build_all_packages
```

When just droid configs have been modified, `build_device_configs` will be enough. Same goes for droid HAL stuff with `build_droid_hal` instead. Building with these commands instead will be substantially faster than rebuilding everything (which is unnecessary 99% of the time anyways).

If instead you'd like to refresh your existing local copies by pulling updates and rebuilding, you can simply use the `-p` flag e.g. use `build_all_packages -p` to update & rebuild everything.

## Building the SFOS rootfs

This is the final step in building stuff. By default the latest public release will be build from the [version history](https://en.wikipedia.org/wiki/Sailfish_OS#Version_history). Any other public build (with the proper tooling installed) can be built by defining `RELEASE=x.y.z`. The `mic` build process averages ~7 minutes for me.

After this you should have a flashable Sailfish OS & boot switcher zips in `sfe-$DEVICE-*/`:
```
PLATFORM_SDK $ run_mic_build
```

Hooray! You've now successfully fully built all of the Sailfish OS source code into a rather tiny (~340 MB) flashable zip file! Look into the [flashing guide](FLASHING.md) on how to proceed.
