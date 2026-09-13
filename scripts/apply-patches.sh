#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: $0 --check|--apply LINUX_SOURCE LIBCAMERA_SOURCE" >&2
	exit 2
}

[[ $# -eq 3 ]] || usage
mode=$1
linux_source=$2
libcamera_source=$3

case "$mode" in
	--check|--apply) ;;
	*) usage ;;
esac

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$script_dir/.." && pwd)

is_git_tree() {
	local source_root
	local git_root

	source_root=$(cd -- "$1" 2>/dev/null && pwd -P) || return 1
	git_root=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || return 1
	git_root=$(cd -- "$git_root" 2>/dev/null && pwd -P) || return 1

	[[ "$source_root" == "$git_root" ]]
}

require_safe_tree() {
	local source_tree=$1
	[[ -d "$source_tree" ]] || {
		echo "Source tree does not exist: $source_tree" >&2
		exit 1
	}

	if is_git_tree "$source_tree" &&
	   [[ -n $(git -C "$source_tree" status --porcelain) ]]; then
		echo "Source tree is not clean: $source_tree" >&2
		exit 1
	fi
}

check_patch() {
	local source_tree=$1
	local patch_file=$2
	if is_git_tree "$source_tree"; then
		git -C "$source_tree" apply --check "$patch_file"
	else
		patch --batch --forward --dry-run -p1 -d "$source_tree" < "$patch_file"
	fi
}

apply_one_patch() {
	local source_tree=$1
	local patch_file=$2
	if is_git_tree "$source_tree"; then
		git -C "$source_tree" apply "$patch_file"
	else
		patch --batch --forward -p1 -d "$source_tree" < "$patch_file"
	fi
}

require_safe_tree "$linux_source"
require_safe_tree "$libcamera_source"

if ! is_git_tree "$linux_source"; then
	echo "Linux source is not Git-managed; keep a backup for rollback." >&2
fi

patch_sets=(
	"$linux_source:$repo_dir/patches/linux"
	"$libcamera_source:$repo_dir/patches/libcamera"
)

for patch_set in "${patch_sets[@]}"; do
	source_tree=${patch_set%%:*}
	patch_dir=${patch_set#*:}
	for patch_file in "$patch_dir"/*.patch; do
		check_patch "$source_tree" "$patch_file"
	done
done

if [[ "$mode" == "--check" ]]; then
	echo "All patches apply cleanly. No source files were changed."
else
	for patch_set in "${patch_sets[@]}"; do
		source_tree=${patch_set%%:*}
		patch_dir=${patch_set#*:}
		for patch_file in "$patch_dir"/*.patch; do
			apply_one_patch "$source_tree" "$patch_file"
		done
	done
	echo "All patches applied. Review both source-tree diffs before building."
fi
