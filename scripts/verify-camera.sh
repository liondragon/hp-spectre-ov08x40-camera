#!/usr/bin/env bash
set -euo pipefail

echo "Kernel: $(uname -r)"

for module_name in ov08x40 intel_skl_int3472_discrete; do
	echo
	echo "$module_name"
	modinfo "$module_name" | awk -F: '/^(filename|version|signer):/ { sub(/^[[:space:]]+/, "", $2); print $1 ": " $2 }'
done

echo
if command -v cam >/dev/null 2>&1; then
	cam -l
else
	echo "cam is not installed; install libcamera tools and run cam -l"
	exit 1
fi
