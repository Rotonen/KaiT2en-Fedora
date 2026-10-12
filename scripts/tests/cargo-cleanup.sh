#!/usr/bin/env bash

set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"

cat >"$tmp_dir/bin/make" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$CARGO_LOG"
EOF
cat >"$tmp_dir/bin/mktemp" <<'EOF'
#!/usr/bin/env bash
: >"$CARGO_REPORT"
printf '%s\n' "$CARGO_REPORT"
EOF
cat >"$tmp_dir/bin/sudo" <<'EOF'
#!/usr/bin/env bash
while [[ "${1:-}" == -H || "${1:-}" == -u ]]; do
	if [[ "$1" == -u ]]; then shift; fi
	shift
done
exec "$@"
EOF
chmod 0755 "$tmp_dir/bin/"*

run_cleanup() {
	local log=$1
	shift
	CARGO_LOG="$log" \
	CARGO_REPORT="$tmp_dir/install-errors" \
	LIB_PATH="$repo_root/scripts/fedora/lib.sh" \
	PATH="$tmp_dir/bin:$PATH" \
	"$@" bash -c 'source "$LIB_PATH"; register_cargo_workspace_cleanup'
}

default_log="$tmp_dir/default.log"
touch "$default_log"
run_cleanup "$default_log" env
grep -Fqx -- "--no-print-directory -C $repo_root clean-workspace" "$default_log"

disabled_log="$tmp_dir/disabled.log"
touch "$disabled_log"
run_cleanup "$disabled_log" env KAIT2EN_CARGO_CLEAN=0
[[ ! -s "$disabled_log" ]]

child_log="$tmp_dir/child.log"
touch "$child_log"
run_cleanup "$child_log" env KAIT2EN_INSTALL_ERRORS="$tmp_dir/parent-errors"
[[ ! -s "$child_log" ]]

package_log="$tmp_dir/package.log"
touch "$package_log"
LIB_PATH="$repo_root/scripts/fedora/lib.sh" \
PATH="$tmp_dir/bin:$PATH" \
CARGO_LOG="$package_log" \
CARGO_REPORT="$tmp_dir/package-errors" \
bash -c 'source "$LIB_PATH"; clean_cargo_project t2-fancontrol-gtk test-user'
grep -Fqx -- "--no-print-directory -C $repo_root PROJECT=t2-fancontrol-gtk clean" \
	"$package_log"

printf 'Cargo cleanup lifecycle checks passed.\n'
