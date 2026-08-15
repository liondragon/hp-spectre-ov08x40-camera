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
	--check) apply_command=(git apply --check) ;;
	--apply) apply_command=(git apply) ;;
	*) usage ;;
esac

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$script_dir/.." && pwd)

require_clean_tree() {
	local source_tree=$1
	if [[ -n $(git -C "$source_tree" status --porcelain) ]]; then
		echo "Source tree is not clean: $source_tree" >&2
		exit 1
	fi
}

require_clean_tree "$linux_source"
require_clean_tree "$libcamera_source"

for patch_file in "$repo_dir"/patches/linux/*.patch; do
	git -C "$linux_source" "${apply_command[@]:1}" "$patch_file"
done

for patch_file in "$repo_dir"/patches/libcamera/*.patch; do
	git -C "$libcamera_source" "${apply_command[@]:1}" "$patch_file"
done

if [[ "$mode" == "--check" ]]; then
	echo "All patches apply cleanly. No source files were changed."
else
	echo "All patches applied. Review both source-tree diffs before building."
fi
