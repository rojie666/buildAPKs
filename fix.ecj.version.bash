#!/bin/env bash
# Copyright 2017-2019 (c) all rights reserved 
# by S D Rausty https://sdrausty.github.io
#####################################################################
set -Eeuo pipefail
shopt -s nullglob globstar

_SDGTRPERROR_() { # Run on script error.
	local RV="$?"
	echo "$RV"
	printf "\\e[?25h\\n\\e[1;48;5;138mBuildAPKs downgrade.ecj.to.working.version.bash ERROR:  Generated script error %s near or at line number %s by \`%s\`!\\e[0m\\n" "${3:-VALUE}" "${1:-LINENO}" "${2:-BASH_COMMAND}"
	exit 179
}

_SDGTRPEXIT_() { # Run on exit.
	printf "\\e[?25h\\e[0m"
	set +Eeuo pipefail 
	exit
}

_SDGTRPSIGNAL_() { # Run on signal.
	local RV="$?"
	_WAKEUNLOCK_
	printf "\\e[?25h\\e[1;7;38;5;0mBuildAPKs %s WARNING:  Signal %s received!\\e[0m\\n" "downgrade.ecj.to.working.version.bash" "$RV"
 	exit 178 
}

_SDGTRPQUIT_() { # Run on quit.
	local RV="$?"
	printf "\\e[?25h\\e[1;7;38;5;0mBuildAPKs %s WARNING:  Quit signal %s received!\\e[0m\\n" "downgrade.ecj.to.working.version.bash" "$RV"
 	exit 177 
}

trap '_SDGTRPERROR_ $LINENO $BASH_COMMAND $?' ERR 
trap _SDGTRPEXIT_ EXIT
trap _SDGTRPSIGNAL_ HUP INT TERM 
trap _SDGTRPQUIT_ QUIT 

export RDR="$(cat $HOME/buildAPKs/var/conf/RDR)"   #  Set variable to contents of file.
cd "$RDR"
(git pull && git submodule update --init ./debs) || (echo ; echo "Internet disconnected: continuing...")
dpkg --purge ecj || dpkg --purge ecj4_6
dpkg --install "$RDR/debs/ecj4.6_4.6.2_all.deb"

#EOF