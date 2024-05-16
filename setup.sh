#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

. scripts/osx.sh
. scripts/utils.sh

cleanup() {
	err "Last command failed"
	info "Finishing..."
}

wait_input() {
	read -p -r "Press enter to continue: "
}

main() {
	

	info "################################################################################"
	info "MACOS Configuration"
	info "################################################################################"
	setup_osx
	success "Finished configuring MacOS defaults. NOTE: A restart is needed"


	success "Done"

	info "System needs to restart. Restart?"

	select yn in "y" "n"; do
		case $yn in
		y)
			sudo shutdown -r now
			break
			;;
		n) exit ;;
		esac
	done
}

trap cleanup SIGINT SIGTERM ERR EXIT

main
