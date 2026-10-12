#!/usr/bin/env bash
# Compatibility entry point: this installs only the AVE component.
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"
require_root
require_repo_root
require_fedora
register_cargo_workspace_cleanup

install_ave() {
	local target_user="${SUDO_USER:-}"
	[[ -n "$target_user" && "$target_user" != root ]] || fail "t2-ave must be built by the invoking user"
	build_cargo_project t2-ave "$target_user"
	stage_cargo_project t2-ave SYSTEMD_UNIT_DIR=/etc/systemd/system
	python3 "$REPO_ROOT/packaging/lifecycle/kait2en-lifecycle.py" t2-ave record-source
	activate_cargo_project t2-ave SYSTEMD_UNIT_DIR=/etc/systemd/system
	clean_cargo_project t2-ave "$target_user"
}
run_step "build and install t2-ave" install_ave
