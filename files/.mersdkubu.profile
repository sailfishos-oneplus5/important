function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
export PS1="HABUILD_SDK [\${DEVICE}] $PS1"
hadk

function sdk_prompt() { echo "$1: enter PLATFORM_SDK first by pressing CTRL + D & try again!"; }
alias zypper="sdk_prompt zypper"
alias sb2="sdk_prompt sb2"

export HISTFILE="$HOME/.bash_history-habuild"

if [ -f build/envsetup.sh ]; then
    echo "$ source build/envsetup.sh"
    source build/envsetup.sh
    echo "$ breakfast $DEVICE"
    breakfast $DEVICE
    echo "$ export USE_CCACHE=1"
    export USE_CCACHE=1
fi
