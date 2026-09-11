#!/usr/bin/env bash
# Prints a detailed uptime/system snapshot as a single JSON object:
#   { "bootTime", "kernel", "distro", "loadAvg" }
set -euo pipefail

boot_time=$(uptime -s)
kernel=$(uname -r)
distro=$(grep -m1 '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
load_avg=$(cut -d' ' -f1-3 /proc/loadavg)

printf '{"bootTime":"%s","kernel":"%s","distro":"%s","loadAvg":"%s"}\n' \
    "$boot_time" "$kernel" "$distro" "$load_avg"
