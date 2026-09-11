#!/usr/bin/env bash
# Prints memory utilisation (used/total, excluding cache) as a bare integer
# percentage.
set -euo pipefail

free | awk '/Mem:/{printf "%.0f", ($2-$7)/$2*100}'
