#!/usr/bin/env bash
# Prints the NVIDIA discrete GPU's utilisation as a bare integer percentage
# (matches cpu-summary.sh's plain-number contract). This is the "at a
# glance" bar value — the AMD iGPU's numbers only show up in the detail
# popup (see gpu-detail.sh), since the discrete GPU is what's normally doing
# the interesting work on a dual-GPU laptop.
#
# Falls back to 0 if nvidia-smi isn't available (e.g. Nouveau-only setup) so
# the bar never shows garbage.
set -euo pipefail

if command -v nvidia-smi >/dev/null 2>&1; then
    usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    echo "${usage:-0}"
else
    echo 0
fi
