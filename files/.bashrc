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
