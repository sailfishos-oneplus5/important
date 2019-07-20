# Initial building guide

### Table of Contents
* [Starting from ground zero](#starting-from-ground-zero)
* [Setup the Platform SDK](#setup-the-platform-sdk)
* [Adding SFOS build target](#adding-sfos-build-target)
* [Setup the HABUILD SDK](#setup-the-habuild-sdk)
* [Cleaning up](#cleaning-up)
* [Initializing local repo](#initializing-local-repo)
* [Fixing build_packages](#fixing-build_packages)
* [Building extra packages](#building-extra-packages)

## Starting from ground zero

When starting out, the ideal situation would be creating another user just for building to keep the environment consistent:
```
HOST $

sudo useradd porter -s /bin/bash -m -G wheel -c "SFOS Builder"
sudo passwd porter
su porter
cd
```

To make the host environment suitable for building you'll need the following changes made:

1. [Append these lines to your `~/.bashrc`](files/.bashrc)
2. [Create a `~/.hadk.env` with the following content](files/.hadk.env)
3. [Create a `~/.mersdkubu.profile` with the following content](files/.mersdkubu.profile)
4. [Create a `~/.mersdk.profile` with the following content](files/.mersdk.profile)
5. Get the `repo` command:
```
HOST $

mkdir ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
```

## Setup the Platform SDK

Here's where the magic magic happens in terms of building Sailfish OS itself. To set it up we need to create some initial directories for the SUSE based Platform SDK chroot and extract it:
```
HOST $

sudo mkdir -p $PLATFORM_SDK_ROOT/{targets,toolings,sdks/sfossdk}
sudo ln -s /srv/mer/sdks/sfossdk/srv/mer/sdks/ubuntu/ /srv/mer/sdks/ubuntu
cd && curl -k -O http://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2
sudo tar --numeric-owner -p -xjf Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 -C $PLATFORM_SDK_ROOT/sdks/sfossdk
mkdir -p $ANDROID_ROOT
sfossdk
```

After entering the Platform SDK prompt, we need to fetch the HADK Android tools for utils such as mkbootimg:
```
PLATFORM_SDK $

sudo zypper ref
sudo zypper --non-interactive in android-tools-hadk
```
**NOTE:** Repository errors for `adaptation0` can be safely ignored here and in the future.

## Adding SFOS build target

In the Platform SDK we use Scratchbox to build packages for the target device architecture. Releases for the SDK targets can be found [here](http://releases.sailfishos.org/sdk/targets/) if another version is desired. To set it up, the following set of commands should be run:
```
PLATFORM_SDK $ cd && sdk-manage target install $VENDOR-$DEVICE-$PORT_ARCH http://releases.sailfishos.org/sdk/targets/Sailfish_OS-$RELEASE-Sailfish_SDK_Target-$PORT_ARCH.tar.7z --tooling SailfishOS-$RELEASE --tooling-url http://releases.sailfishos.org/sdk/targets/Sailfish_OS-$RELEASE-Sailfish_SDK_Tooling-i486.tar.7z
```

To verify that the install succeeded, executing `sdk-assistant list` should yield something like this:
```
PLATFORM_SDK $ sdk-assistant list
SailfishOS-3.0.3.9
`-oneplus-cheeseburger-armv7hl
```

## Setup the HABUILD SDK

Next we'll pull down & extract the Ubuntu 14.04 chroot environment where LineageOS HAL parts shall be built:
```
PLATFORM_SDK $

TARBALL=ubuntu-trusty-20180613-android-rootfs.tar.bz2
cd && curl -O https://releases.sailfishos.org/ubu/$TARBALL
UBUNTU_CHROOT=$PLATFORM_SDK_ROOT/sdks/ubuntu
sudo mkdir -p $UBUNTU_CHROOT
sudo tar --numeric-owner -xjf $TARBALL -C $UBUNTU_CHROOT
sudo sed -i "s/\tlocalhost/\t$(</parentroot/etc/hostname)/g" $UBUNTU_CHROOT/etc/hosts
cd $ANDROID_ROOT
curl -L https://git.io/fjPTL > installer-sparse.zip
unzip installer-sparse.zip -d installer-sparse/
rm installer-sparse.zip
habuild
```

When pulling down large amounts of source code it is a good idea to configure git as to not limit our available resources and cause other issues:
```
HA_BUILD $

git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## Cleaning up

Once you can enter both PLATFORM_SDK and HA_BUILD environments, you can safely delete the leftover chroot filesystem archives from your home directory:
```
HA_BUILD $ cd && rm Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 ubuntu-trusty-*-android-rootfs.tar.bz2
```

## Initializing local repo

When everything is ready to go we can finally init the local source repository:
```
HA_BUILD $

cd $ANDROID_ROOT
repo init -u git://github.com/mer-hybris/android.git -b hybris-15.1 --depth 1
git clone https://github.com/sailfishos-oneplus5/local_manifests -b hybris-15.1 .repo/local_manifests/
```

Now that the repo is initialized you can start [syncing the local repository](BUILDING.md#syncing-local-repository) as per the [regular porting guide](BUILDING.md) as it will be identical from here on out unless otherwise stated.

## Fixing build_packages

Upstream [`ofono-ril-binder-plugin`](https://git.io/fjMeu) since the start of July 2019 now requires a newer version of [`libgrilio`](https://git.merproject.org/mer-core/libgrilio) which isn't yet provided by default. We'll build this newer version manually:
```
PLATFORM_SDK $

rpm/dhd/helpers/build_packages.sh -d
git clone https://git.merproject.org/mer-core/libgrilio hybris/mw/libgrilio/
rpm/dhd/helpers/build_packages.sh -b hybris/mw/libgrilio
```

Another issue is [`ofono-configs`](https://git.io/fjik8) (which are provided by [sparse files](https://git.io/fjKXf) in [dcd](https://git.io/fjiIU)). Thankfully it's a simple fix:
```
PLATFORM_SDK $

rpm/dhd/helpers/build_packages.sh -c
sb2 -t $VENDOR-$DEVICE-$PORT_ARCH -R -m sdk-install zypper in bluez5-obexd droid-config-cheeseburger droid-config-cheeseburger-bluez5 kf5bluezqt-bluez5 libcommhistory-qt5 libcontacts-qt5 libical obex-capability obexd-calldata-provider obexd-contentfilter-helper qt5-qtpim-versit qtcontacts-sqlite-qt5
```

## Building extra packages

These extra packages are responsible for fixing video recording, working call audio and device specific features such as notification slider & display off gestures. They aren't built by default, so that's why we'll be building them next (on my machine this process took ~10 mins total):
```
HA_BUILD $

gettargetarch > lunch_arch
make -j`nproc` $(external/droidmedia/detect_build_targets.sh $PORT_ARCH)
make -j`nproc` $(external/audioflingerglue/detect_build_targets.sh $PORT_ARCH)
exit

PLATFORM_SDK $

DROIDMEDIA_VERSION=0.20190719.0
rpm/dhd/helpers/pack_source_droidmedia-localbuild.sh $DROIDMEDIA_VERSION
mkdir -p hybris/mw/droidmedia-localbuild/rpm
cp rpm/dhd/helpers/droidmedia-localbuild.spec hybris/mw/droidmedia-localbuild/rpm/droidmedia.spec
sed -ie "s/0.0.0/$DROIDMEDIA_VERSION/" hybris/mw/droidmedia-localbuild/rpm/droidmedia.spec
mv hybris/mw/droidmedia-$DROIDMEDIA_VERSION.tgz hybris/mw/droidmedia-localbuild
rpm/dhd/helpers/build_packages.sh --build=hybris/mw/droidmedia-localbuild
rpm/dhd/helpers/build_packages.sh --droid-hal --mw=https://github.com/sailfishos/gst-droid.git

AUDIOFLINGERGLUE_VERSION=0.0.12
rpm/dhd/helpers/pack_source_audioflingerglue-localbuild.sh $AUDIOFLINGERGLUE_VERSION
mkdir -p hybris/mw/audioflingerglue-localbuild/rpm
cp rpm/dhd/helpers/audioflingerglue-localbuild.spec hybris/mw/audioflingerglue-localbuild/rpm/audioflingerglue.spec
sed -ie "s/0.0.0/$AUDIOFLINGERGLUE_VERSION/" hybris/mw/audioflingerglue-localbuild/rpm/audioflingerglue.spec
mv hybris/mw/audioflingerglue-$AUDIOFLINGERGLUE_VERSION.tgz hybris/mw/audioflingerglue-localbuild
rpm/dhd/helpers/build_packages.sh --build=hybris/mw/audioflingerglue-localbuild
rpm/dhd/helpers/build_packages.sh --droid-hal --mw=https://github.com/mer-hybris/pulseaudio-modules-droid-glue.git

git clone https://github.com/sailfishos-oneplus5/triambience hybris/mw/triambience-localbuild/
rpm/dhd/helpers/build_packages.sh --build=hybris/mw/triambience-localbuild

git clone https://github.com/sailfishos-oneplus5/onyx-triambience-settings-plugin hybris/mw/onyx-triambience-settings-plugin-localbuild/
rpm/dhd/helpers/build_packages.sh --build=hybris/mw/onyx-triambience-settings-plugin-localbuild

rpm/dhd/helpers/build_packages.sh -c
```
**NOTE:** Please substitute [DROIDMEDIA_VERSION](https://git.io/fjMe2) and [AUDIOFLINGERGLUE_VERSION](https://git.io/fjMeg) values with their latest versions if they are different different.

Once you're done you can check out [building the SFOS rootfs](BUILDING.md#building-the-sfos-rootfs) over on the [regular building guide](BUILDING.md).
