# Building guide

### Table of Contents
* [Build environments](#build-environments)
* [Syncing local repository](#syncing-local-repository)
* [Building HAL parts](#building-hal-parts)
* [Building SFOS packages](#building-sfos-packages)

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

## Syncing local repository

At this point the process of downloading source code for LineageOS and libhybris will start. At first this may take a while depending on your internet connection speed (with 200 mbit/s it'll take ~10 mins for reference):
```
HA_BUILD $ repo sync -c -j`nproc` --fetch-submodules --no-tags --no-clone-bundle
```

If this is your first time building, environment variables also need to be set up by executing:
```
HA_BUILD $ . build/envsetup.sh && breakfast cheeseburger && export USE_CCACHE=1
```

## Building HAL parts

Now we will build the required parts of LineageOS for HAL to function properly under SFOS. This usually takes around 30 minutes on 4 relatively fast CPU cores (i5-4690K) for the first time. To start the process, enter:
```
HA_BUILD $ make -j`nproc` hybris-hal
```

During the `hybris-hal` build process a `hybris-boot.img` boot image in `out/` will be generated. When kernel or Android side changes are done afterwards the image can be regenerated using a command:
```
HA_BUILD $ make -j`nproc` hybris-boot
```

In case a recovery boot image is needed, it can be built like so:
```
HA_BUILD $ make -j`nproc` hybris-recovery
```

If this was your first time building `hybris-hal`, see [building droidmedia & audioflingerglue](https://git.io/fj6j8) under the [initial building guide](INITIAL-BUILDING.md).

## Building SFOS packages

Coming *very* soon...
