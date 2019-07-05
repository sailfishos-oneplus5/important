# Initial building guide

### Table of Contents
* [Starting from ground zero](#starting-from-ground-zero)
* [Setting up the Platform SDK](#setting-up-the-platform-sdk)

## Starting from ground zero

When starting out, the ideal situation would be creating another user just for building and to keep the environment consistent:
```
HOST $ sudo useradd porter -s /bin/bash -m -G wheel -c "SFOS Builder"
HOST $ sudo passwd porter
HOST $ su porter
```
To finalize the host environment for building you'll need the following changes made:

Append to `~/.bashrc`:
```bash
# ...
shopt -s histappend
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
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


### Setting up the Platform SDK

Coming *very* soon...
