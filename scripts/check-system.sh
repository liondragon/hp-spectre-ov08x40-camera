#!/usr/bin/env bash
set -euo pipefail

read_value() {
	local path=$1
	if [[ -r "$path" ]]; then
		tr -d '\n' < "$path"
	else
		printf 'Unknown'
	fi
}

vendor=$(read_value /sys/class/dmi/id/sys_vendor)
product=$(read_value /sys/class/dmi/id/product_name)

printf 'Kernel: %s\n' "$(uname -r)"
printf 'System vendor: %s\n' "$vendor"
printf 'Product name: %s\n' "$product"

if [[ "$vendor" == "HP" && "$product" == "HP Spectre x360 2-in-1 Laptop 14-eu0xxx" ]]; then
	echo "DMI match: yes"
else
	echo "DMI match: no - do not install the HP timing patch without review"
fi

if compgen -G '/sys/bus/acpi/devices/OVTI08F4:*' >/dev/null; then
	echo "OVTI08F4 ACPI camera: found"
else
	echo "OVTI08F4 ACPI camera: not found"
fi
