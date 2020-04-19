hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
export PS1="HABUILD_SDK [\${DEVICE}] $PS1"
export HISTFILE="$HOME/.bash_history-habuild"
export TOP="$ANDROID_ROOT"
hadk

sdk_prompt() { echo "$1: enter PLATFORM_SDK first by pressing CTRL + D & try again!"; }
alias zypper="sdk_prompt zypper"
alias sb2="sdk_prompt sb2"
alias sfossdk="exit"
alias sfos_sdk="exit"
alias platform_sdk="exit"
alias plat_sdk="exit"
alias platformsdk="exit"
alias platsdk="exit"
[[ ! -x `command -v croot` ]] && alias croot="cd '$ANDROID_ROOT'"

if [ -f build/envsetup.sh ]; then
	echo "$ source build/envsetup.sh"
	source build/envsetup.sh
	echo "$ breakfast $DEVICE"
	breakfast $DEVICE
	echo "$ export USE_CCACHE=1"
	export USE_CCACHE=1
fi
