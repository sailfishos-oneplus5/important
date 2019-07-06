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
