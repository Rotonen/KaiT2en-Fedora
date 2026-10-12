#!/usr/bin/env bash

set -Eeuo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/cargo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$CARGO_LOG"
EOF
chmod 0755 "$tmp_dir/cargo"
export CARGO_LOG="$tmp_dir/cargo.log"
touch "$CARGO_LOG"

run_make() {
	make --no-print-directory --silent -C "$repo_root" \
		CARGO="$tmp_dir/cargo" TARGET_DIR="$tmp_dir/target" "$@"
}

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

for project in "${projects[@]}"; do
	run_make PROJECT="$project" build
	grep -Fqx "build --release --locked --package $project --target-dir $tmp_dir/target" \
		"$CARGO_LOG"
done

run_make PROJECT=t2-fancontrol-gtk test
grep -Fqx "test --locked --package t2-fancontrol-gtk --target-dir $tmp_dir/target" \
	"$CARGO_LOG"

if run_make PROJECT=invalid-project build >/dev/null 2>&1; then
	echo "invalid project unexpectedly passed validation" >&2
	exit 1
fi

if run_make PROJECT=t2-fancontrol-gtk check-build >/dev/null 2>&1; then
	echo "check-build unexpectedly passed without a binary" >&2
	exit 1
fi
mkdir -p "$tmp_dir/target/release"
touch "$tmp_dir/target/release/t2-fancontrol-gtk"
chmod 0755 "$tmp_dir/target/release/t2-fancontrol-gtk"
run_make PROJECT=t2-fancontrol-gtk check-build

run_make PROJECT=t2-fancontrol-gtk clean
grep -Fqx "clean --package t2-fancontrol-gtk --target-dir $tmp_dir/target" \
	"$CARGO_LOG"

printf 'Cargo project dispatch checks passed.\n'
