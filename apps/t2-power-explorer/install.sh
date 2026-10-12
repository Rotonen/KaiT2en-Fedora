#!/usr/bin/env bash
set -euo pipefail

APP_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$APP_DIR/../../scripts/fedora/lib.sh"
require_root
install_kait2en_fonts
require_fedora
require_command dnf make sudo
register_cargo_workspace_cleanup

dnf install -y cargo gcc gtk4-devel libadwaita-devel

target_user=${SUDO_USER:-}
[[ -n "$target_user" && "$target_user" != root ]] ||
	fail "t2-power-explorer must be built for the user who invoked sudo"
build_cargo_project t2-power-explorer "$target_user"
stage_cargo_project t2-power-explorer
activate_cargo_project t2-power-explorer
clean_cargo_project t2-power-explorer "$target_user"
info "t2-power-explorer installed"
