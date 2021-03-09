# ...
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=1000
export HISTCONTROL=ignoreboth
export PATH=$HOME/bin:$PATH
export PLATFORM_SDK_ROOT="/srv/mer"
export ANDROID_ROOT="$HOME/Sailfish/src"
shopt -s histappend
alias sfossdk="$PLATFORM_SDK_ROOT/sdks/sfossdk/mer-sdk-chroot"
