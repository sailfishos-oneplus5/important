# Initial building guide

### Table of Contents
* [Starting from ground zero](#starting-from-ground-zero)
* [Setup the Platform SDK](#setup-the-platform-sdk)
* [Setup the HABUILD SDK](#setup-the-habuild-sdk)
* [Initializing local repo](#initializing-local-repo)

## Starting from ground zero

When starting out, the ideal situation would be creating another user just for building to keep the environment consistent:
```
HOST $ sudo useradd porter -s /bin/bash -m -G wheel -c "SFOS Builder"
HOST $ sudo passwd porter
HOST $ su porter
HOST $ cd
```

To finalize the host environment for building you'll need the following changes made:

Append to `~/.bashrc`:
```bash
# ...
shopt -s histappend
export HISTSIZE=1000
export HISTCONTROL=ignoreboth
export PATH=$HOME/.local/bin:$HOME/bin:$PATH
export PLATFORM_SDK_ROOT="/srv/mer"
export ANDROID_ROOT="$HOME/Sailfish/src"
alias sfossdk="$PLATFORM_SDK_ROOT/sdks/sfossdk/mer-sdk-chroot"
if [ ! -d /parentroot ]; then
    export HISTFILE="$HOME/.bash_history"
else
    env="sfossdk"
    [ -d /parentroot/parentroot ] && env="habuild"
    [ "$env" = "sfossdk" ] && alias habuild="ubu-chroot -r $PLATFORM_SDK_ROOT/sdks/ubuntu"
    export HISTFILE="$HOME/.bash_history-$env"
fi
```

Create `~/.hadk.env`:
```bash
export PLATFORM_SDK_ROOT="/srv/mer"
export ANDROID_ROOT="$HOME/Sailfish/src"
export VENDOR="oneplus"
export DEVICE="cheeseburger"
export PORT_ARCH="armv7hl"

echo "$ export LANG=C LC_ALL=POSIX"
export LANG=C LC_ALL=POSIX
echo "$ cd \$ANDROID_ROOT"
cd $ANDROID_ROOT
```

Create `~/.mersdkubu.profile`:
```bash
function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
export PS1="HABUILD_SDK [\${DEVICE}] $PS1"
hadk

if [ -f build/envsetup.sh ]; then
    echo "$ source build/envsetup.sh"
    source build/envsetup.sh
    echo "$ breakfast cheeseburger"
    breakfast cheeseburger
    echo "$ export USE_CCACHE=1"
    export USE_CCACHE=1
fi
```

Create `~/.mersdk.profile`:
```bash
PS1="PlatformSDK $PS1"
[ -d /etc/bash_completion.d ] && for i in /etc/bash_completion.d/*; do . $i; done

function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
hadk
```
Installing `repo`:
```
HOST $ mkdir ~/bin
HOST $ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
HOST $ chmod a+x ~/bin/repo
```


### Setup the Platform SDK

Here's where the magic magic happens in terms of building Sailfish OS itself. To set it up we need to create some initial directories for the SUSE based Platform SDK chroot and extract it:
```
HOST $ sudo mkdir -p "$PLATFORM_SDK_ROOT/{targets,toolings}" "$PLATFORM_SDK_ROOT/sdks/sfossdk"
HOST $ cd && curl -k -O http://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2
HOST $ sudo tar --numeric-owner -p -xjf Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 -C $PLATFORM_SDK_ROOT/sdks/sfossdk
HOST $ mkdir -p "$ANDROID_ROOT"
HOST $ sfossdk
```

After entering the Platform SDK prompt, we need to fetch the HADK Android tools for utils such as mkbootimg:
```
PLATFORM_SDK $ sudo zypper ref
PLATFORM_SDK $ sudo zypper --non-interactive in android-tools-hadk
```

### Setup the HABUILD SDK

Next we'll pull down & extract the Ubuntu 14.04 chroot environment where LineageOS HAL parts shall be built:
```
PLATFORM_SDK $ TARBALL=ubuntu-trusty-20180613-android-rootfs.tar.bz2
PLATFORM_SDK $ curl -O https://releases.sailfishos.org/ubu/$TARBALL
PLATFORM_SDK $ UBUNTU_CHROOT=$PLATFORM_SDK_ROOT/sdks/ubuntu
PLATFORM_SDK $ sudo mkdir -p $UBUNTU_CHROOT
PLATFORM_SDK $ sudo tar --numeric-owner -xjf $TARBALL -C $UBUNTU_CHROOT
PLATFORM_SDK $ sudo sed -i "s/\tlocalhost/\t$(</parentroot/etc/hostname)/g" $UBUNTU_CHROOT/etc/hosts
PLATFORM_SDK $ habuild
```

When pulling down large amounts of source code using it is a good idea to configure git as to not limit our available resources and cause other issues:
```
HA_BUILD $ git config --global user.name "Your Name"
HA_BUILD $ git config --global user.email "your@email.com"
```

### Initializing local repo

When everything is ready to go let's finally init the local source repository:
```
HA_BUILD $ cd $ANDROID_ROOT
HA_BUILD $ repo init -u git://github.com/mer-hybris/android.git -b hybris-15.1 --depth 1
HA_BUILD $ cd .repo/
HA_BUILD $ git clone https://github.com/sailfishos-oneplus5/local_manifests.git -b hybris-15.1
HA_BUILD $ sed -i "/hybris-boot/d" manifest.xml
HA_BUILD $ exit
```

Now that the repo is initialized you can start following the [regular porting guide](BUILDING.md) as it will be identical from here on out unless otherwise stated.
