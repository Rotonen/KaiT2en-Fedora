#!/usr/bin/env bash

set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/target/release" "$tmp_dir/bin" "$tmp_dir/host/run/t2-touchid" \
	"$tmp_dir/host/var/lib/flatpak/overrides"
command_log="$tmp_dir/commands.log"
touch "$command_log"
export COMMAND_LOG="$command_log"

for command in systemctl gtk-update-icon-cache flatpak udevadm restorecon; do
	cat >"$tmp_dir/bin/$command" <<'EOF'
#!/usr/bin/env bash
printf '%s %s\n' "${0##*/}" "$*" >>"$COMMAND_LOG"
if [[ "${1:-}" == is-enabled ]]; then
	unit=${2:-}
	[[ "$unit" == --quiet ]] && unit=${3:-}
	[[ "${ENABLED_UNIT:-}" == "$unit" ]]
	exit
fi
if [[ "${1:-}" == list-unit-files ]]; then
	exit 1
fi
EOF
	chmod 0755 "$tmp_dir/bin/$command"
done

export PATH="$tmp_dir/bin:$PATH"
export ENABLED_UNIT=kait2en-dgpu-off.service

projects=(
	t2-dgpu-control
	t2-fancontrol-gtk
	t2-force-click
	t2-hybrid-gpu-control
	t2-power-explorer
	t2-smc-control
	kait2en-touchbar
	t2-zonepower-gtk
	t2-ave
	t2-journal
	t2-touchid
)
binaries=(
	t2-dgpu-control
	t2-fancontrol-gtk
	t2-force-click
	t2-hybrid-gpu-control
	t2-power-explorer
	t2-smc-control
	kait2en-touchbar
	t2-zonepower-gtk
	t2remote
	t2journal
	t2-touchid
)

for binary in "${binaries[@]}"; do
	printf '#!/usr/bin/env bash\n' >"$tmp_dir/target/release/$binary"
	chmod 0755 "$tmp_dir/target/release/$binary"
done

run_make() {
	local project=$1
	shift
	make --no-print-directory --silent -C "$repo_root" \
		PROJECT="$project" \
		TARGET_DIR="$tmp_dir/target" \
		DESTDIR="$tmp_dir/stage" \
		BINDIR=/usr/local/bin \
		LIBEXECDIR=/usr/local/libexec \
		DATADIR=/usr/local/share \
		SYSCONFDIR=/etc \
		SYSTEMD_UNIT_DIR=/usr/local/lib/systemd/system \
		SYSTEMD_OVERRIDE_DIR="$tmp_dir/host/etc/systemd/system" \
		SYSTEMD_VENDOR_DIR="$tmp_dir/host/usr/lib/systemd/system" \
		RUNDIR="$tmp_dir/host/run" \
		FLATPAK_OVERRIDES="$tmp_dir/host/var/lib/flatpak/overrides/global" \
		SYSTEMCTL="$tmp_dir/bin/systemctl" \
		GTK_UPDATE_ICON_CACHE="$tmp_dir/bin/gtk-update-icon-cache" \
		UDEVADM="$tmp_dir/bin/udevadm" \
		FLATPAK="$tmp_dir/bin/flatpak" \
		RESTORECON="$tmp_dir/bin/restorecon" \
		"$@"
}

for i in "${!projects[@]}"; do
	project=${projects[$i]}
	binary=${binaries[$i]}
	if [[ "$project" == t2-touchid ]]; then
		run_make "$project" DATADIR=/usr/share SYSTEMD_UNIT_DIR=/etc/systemd/system install
	else
		run_make "$project" install
	fi
	[[ -x "$tmp_dir/stage/usr/local/bin/$binary" ]]
done

stage_paths=(
	/usr/local/libexec/t2-dgpu-control-helper
	/usr/local/share/applications/org.t2fancontrol.gtk.desktop
	/usr/local/lib/systemd/system/t2-force-click.service
	/etc/environment.d/90-kait2en-gsk-renderer.conf
	/usr/local/libexec/t2-power-explorer-status
	/usr/local/share/applications/org.t2smccontrol.gtk.desktop
	/usr/local/lib/systemd/user/kait2en-touchbar.service
	/usr/local/lib/udev/rules.d/99-zz-kait2en-touchbar.rules
	/usr/local/lib/systemd/system/t2-zonepowerd.service
	/usr/local/libexec/t2-services/sleep.d/t2-ave
	/usr/local/bin/t2journal
)
for path in "${stage_paths[@]}"; do
	[[ -f "$tmp_dir/stage$path" ]]
done
[[ -f "$tmp_dir/stage/usr/local/lib/systemd/system/kait2en-t2-remote.service" ]]
grep -Fq 'ExecStart=/usr/local/bin/t2remote' \
	"$tmp_dir/stage/usr/local/lib/systemd/system/kait2en-t2-remote.service"
[[ -f "$tmp_dir/stage/etc/systemd/system/kait2en-t2-touchid.service" ]]
[[ -f "$tmp_dir/stage/usr/share/dbus-1/system.d/org.kait2en.TouchId.conf" ]]
[[ -f "$tmp_dir/stage/etc/systemd/system/fprintd.service.d/kait2en-t2-touchid.conf" ]]
[[ -f "$tmp_dir/stage/etc/kait2en/touchbar.toml" ]]
[[ -f "$tmp_dir/stage/etc/kait2en/t2-touchid.conf" ]]
[[ ! -s "$command_log" ]]
printf 'preserved touchbar config\n' >"$tmp_dir/stage/etc/kait2en/touchbar.toml"
printf 'preserved touchid config\n' >"$tmp_dir/stage/etc/kait2en/t2-touchid.conf"
run_make kait2en-touchbar install
run_make t2-touchid DATADIR=/usr/share SYSTEMD_UNIT_DIR=/etc/systemd/system install
grep -Fq 'preserved touchbar config' "$tmp_dir/stage/etc/kait2en/touchbar.toml"
grep -Fq 'preserved touchid config' "$tmp_dir/stage/etc/kait2en/t2-touchid.conf"
[[ ! -s "$command_log" ]]
if run_make t2-fancontrol-gtk activate >/dev/null 2>&1; then
	echo "activate unexpectedly accepted DESTDIR" >&2
	exit 1
fi
[[ ! -s "$command_log" ]]

run_make t2-dgpu-control DESTDIR= activate SYSTEMD_UNIT_DIR="$tmp_dir/host/usr/local/lib/systemd/system"
run_make t2-fancontrol-gtk DESTDIR= activate
run_make t2-force-click DESTDIR= activate
run_make t2-hybrid-gpu-control DESTDIR= activate SYSTEMD_UNIT_DIR="$tmp_dir/host/usr/local/lib/systemd/system"
run_make t2-power-explorer DESTDIR= activate
run_make t2-smc-control DESTDIR= activate
run_make kait2en-touchbar DESTDIR= activate
run_make t2-zonepower-gtk DESTDIR= activate
run_make t2-ave DESTDIR= activate
run_make t2-journal DESTDIR= activate
run_make t2-touchid DESTDIR= activate SYSTEMD_UNIT_DIR="$tmp_dir/host/etc/systemd/system" DATADIR=/usr/share
grep -Fq 'systemctl enable t2-fancontrol.service' "$command_log"
grep -Fq 'systemctl enable kait2en-dgpu-off.service' "$command_log"
grep -Fq 'systemctl enable kait2en-dgpu-suspend.service' "$command_log"
grep -Fq 'flatpak override --system --env=GSK_RENDERER=ngl' "$command_log"
grep -Fq 'udevadm control --reload' "$command_log"
grep -Fq 'restorecon -R' "$command_log"

printf 'GSK_RENDERER=ngl\nOTHER=keep\n' >"$tmp_dir/host/var/lib/flatpak/overrides/global"
run_make t2-dgpu-control DESTDIR= deactivate SYSTEMD_UNIT_DIR="$tmp_dir/host/usr/local/lib/systemd/system"
run_make t2-fancontrol-gtk DESTDIR= deactivate
run_make t2-force-click DESTDIR= deactivate
run_make t2-hybrid-gpu-control DESTDIR= deactivate SYSTEMD_UNIT_DIR="$tmp_dir/host/usr/local/lib/systemd/system"
run_make t2-power-explorer DESTDIR= deactivate
run_make t2-smc-control DESTDIR= deactivate
run_make kait2en-touchbar DESTDIR= deactivate
run_make t2-zonepower-gtk DESTDIR= deactivate
run_make t2-ave DESTDIR= deactivate
run_make t2-journal DESTDIR= deactivate
run_make t2-touchid DESTDIR= deactivate SYSTEMD_UNIT_DIR="$tmp_dir/host/usr/local/lib/systemd/system"
! grep -Fq 'GSK_RENDERER=ngl' "$tmp_dir/host/var/lib/flatpak/overrides/global"
grep -Fq 'OTHER=keep' "$tmp_dir/host/var/lib/flatpak/overrides/global"

run_make t2-fancontrol-gtk USER_PREFIX="$tmp_dir/user" install-user
[[ -x "$tmp_dir/stage$tmp_dir/user/bin/t2-fancontrol-gtk" ]]
run_make t2-fancontrol-gtk USER_PREFIX="$tmp_dir/user" uninstall-user
run_make t2-fancontrol-gtk DESTDIR= USER_PREFIX="$tmp_dir/user" activate-user

: >"$command_log"
for i in "${!projects[@]}"; do
	project=${projects[$i]}
	binary=${binaries[$i]}
	if [[ "$project" == t2-touchid ]]; then
		run_make "$project" DATADIR=/usr/share SYSTEMD_UNIT_DIR=/etc/systemd/system uninstall
	else
		run_make "$project" uninstall
	fi
	[[ ! -e "$tmp_dir/stage/usr/local/bin/$binary" ]]
done
[[ -f "$tmp_dir/stage/etc/kait2en/touchbar.toml" ]]
[[ -f "$tmp_dir/stage/etc/kait2en/t2-touchid.conf" ]]
[[ ! -s "$command_log" ]]

printf 'filesystem-only Rust staging and activation checks passed.\n'
