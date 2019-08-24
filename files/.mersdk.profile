function hadk() { source $HOME/.hadk.env; echo "Env setup for $DEVICE"; }
export PS1="PLATFORM_SDK $PS1"
[ -d /etc/bash_completion.d ] && for i in /etc/bash_completion.d/*; do . $i; done
hadk

export HISTFILE="$HOME/.bash_history-sfossdk"
export RELEASE=`cat /etc/os-release | grep VERSION_ID | cut -d"=" -f2`

builder_script="rpm/dhd/helpers/build_packages.sh"

function gen_ks() {
	echo '$ HA_REPO="repo --name=adaptation-community-common-$DEVICE-@RELEASE@"' &&
	HA_REPO="repo --name=adaptation-community-common-$DEVICE-@RELEASE@" &&
	echo '$ HA_DEV="repo --name=adaptation-community-$DEVICE-@RELEASE@"' &&
	HA_DEV="repo --name=adaptation-community-$DEVICE-@RELEASE@" &&
	echo '$ KS="Jolla-@RELEASE@-$DEVICE-@ARCH@.ks"' &&
	KS="Jolla-@RELEASE@-$DEVICE-@ARCH@.ks" &&
	echo '$ sed "/$HA_REPO/i$HA_DEV --baseurl=file:\/\/$ANDROID_ROOT\/droid-local-repo\/$DEVICE" $ANDROID_ROOT/hybris/droid-configs/installroot/usr/share/kickstarts/$KS > $KS' &&
	sed "/$HA_REPO/i$HA_DEV --baseurl=file:\/\/$ANDROID_ROOT\/droid-local-repo\/$DEVICE" $ANDROID_ROOT/hybris/droid-configs/installroot/usr/share/kickstarts/$KS > $KS &&
	echo '$ hybris/droid-configs/droid-configs-device/helpers/process_patterns.sh' &&
	hybris/droid-configs/droid-configs-device/helpers/process_patterns.sh
}

function build_all_packages() {
	cd $ANDROID_ROOT

	echo "$ $builder_script $@"
	$builder_script $@ && gen_ks
}

function build_packages() {
	cd $ANDROID_ROOT

	if (( $# == 0 )); then
		build_packages -c
		return
	fi

	echo "$ $builder_script $@"
	$builder_script $@ || return
	
	[[ $@ == *"-c"* || $@ == *"--configs"* ]] && gen_ks
}

function run_mic_build() {
	if [ -z $UPDATES_CHECKED ]; then
		# Function to compare version strings
		vercomp() {
			[ "$1" = "$2" ] && return 0 # =
			[ "$1" = "`printf "$1\n$2" | sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | head -1`" ] && return 1 # <
			return 2 # >
		}

		# Fetch latest public release version
		local tmp=`curl -s https://en.wikipedia.org/wiki/Sailfish_OS | grep -B 2 "^<td>Public release$" | grep "^<td>v" | tail -1` # e.g. "<td>v3.0.3.10</td>"
		tmp=${tmp#*v} # e.g. "3.0.3.10</td>"
		local LATEST_RELEASE=${tmp::${#tmp}-5} # e.g. "3.0.3.10"
		local LATEST_TOOLING=`echo $LATEST_RELEASE | cut --complement -d"." -f4-` # e.g. "3.0.3"
		local CURRENT_TOOLING=`cat /etc/os-release | grep VERSION_ID | cut -d"=" -f2 | cut --complement -d"." -f4-` # e.g. "3.1.0"

		# Can we build latest w/ current tooling (e.g. '3.0.3' vs '3.1.0')
		vercomp "$LATEST_TOOLING" "$CURRENT_TOOLING"
		tmp=$?
		if (( $tmp == 0 )); then
			# TODO Check if installed tooling is latest available from http://releases.sailfishos.org/sdk/targets/
			RELEASE="$LATEST_RELEASE"
			echo ">> Targeting latest public release $LATEST_RELEASE."

		# Out-of-date version history => Use tooling release
		elif (( $tmp == 1 )); then
			echo ">> Targeting installed tooling release $RELEASE."

		# Can't build w/ current tooling => Check if tooling updates available
		else
			curl -s http://releases.sailfishos.org/sdk/targets/ | fgrep $LATEST_TOOLING &>/dev/null && echo ">> Build target updates available ($CURRENT_TOOLING.x => $LATEST_TOOLING.x)! Resources: http://releases.sailfishos.org/sdk/targets/ https://git.io/fjM1D"
			echo ">> Currently targeting installed tooling release $RELEASE."
		fi

		UPDATES_CHECKED=1
	fi

	local cmd="sudo mic create fs --arch=$PORT_ARCH --tokenmap=ARCH:$PORT_ARCH,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME --record-pkgs=name,url --outdir=sfe-$DEVICE-$RELEASE$EXTRA_NAME --pack-to=sfe-$DEVICE-$RELEASE$EXTRA_NAME.tar.bz2 $ANDROID_ROOT/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks"
	echo "$ $cmd"
	$cmd
}

alias ha_build="ubu-chroot -r $PLATFORM_SDK_ROOT/sdks/ubuntu"
alias habuild="ha_build"

alias build_all_pkgs="build_all_packages"
alias build_all="build_all_packages"
alias build_pkgs="build_packages"
alias build_droid_hal="build_packages -d"
alias build_hal="build_droid_hal"
alias build_device_configs="build_packages -c"
alias build_configs="build_device_configs"
alias build_cfgs="build_device_configs"

alias do_mic_build="run_mic_build"
alias mic_build="run_mic_build"
alias build_sfos="run_mic_build"
alias build_sailfish="run_mic_build"