#!/usr/bin/env bash
# Prints a combined snapshot of both GPUs on a dual-GPU (NVIDIA + AMD)
# laptop as a single JSON object:
#   { "nvidia": {"name","usage","mem","temp"}, "amd": {"name","usage","mem","temp"} }
#
# Each field is `null` (unquoted, valid JSON) if that GPU/its tooling isn't
# present — same "degrade gracefully" contract cpu-detail.sh uses for
# missing `sensors`. Safe to run on single-GPU or NVIDIA-only/AMD-only
# machines too.
#
# NVIDIA: reads via `nvidia-smi` (nvidia-utils package — see
# DEPENDENCIES.md). Requires the proprietary driver; Nouveau doesn't expose
# these stats.
#
# AMD: reads straight from the kernel amdgpu driver's sysfs interface
# (gpu_busy_percent, mem_info_vram_used/total, hwmon temp1_input) — no extra
# package needed. The card is located dynamically by PCI vendor id (0x1002)
# under /sys/class/drm rather than assumed to be a fixed cardN, since that
# number depends on device enumeration order and can differ across
# machines/reboots.
set -euo pipefail

# --- NVIDIA (discrete) ---------------------------------------------------
nvidia_name="null"
nvidia_usage="null"
nvidia_mem="null"
nvidia_temp="null"

if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia_csv=$(nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu \
        --format=csv,noheader,nounits 2>/dev/null | head -1)
    if [ -n "$nvidia_csv" ]; then
        IFS=',' read -r n_name n_usage n_mem_used n_mem_total n_temp <<< "$nvidia_csv"
        n_name=$(echo "$n_name" | sed 's/^ *//;s/ *$//')
        nvidia_name="\"$n_name\""
        nvidia_usage="\"$(echo "$n_usage" | tr -d ' ')%\""
        nvidia_mem="\"$(echo "$n_mem_used" | tr -d ' ') / $(echo "$n_mem_total" | tr -d ' ') MiB\""
        nvidia_temp="\"$(echo "$n_temp" | tr -d ' ')°C\""
    fi
fi

# --- AMD (integrated) ------------------------------------------------------
amd_name="null"
amd_usage="null"
amd_mem="null"
amd_temp="null"
amd_device=""

for dev in /sys/class/drm/card[0-9]*/device; do
    [ -e "$dev/vendor" ] || continue
    if [ "$(cat "$dev/vendor" 2>/dev/null)" = "0x1002" ]; then
        amd_device="$dev"
        break
    fi
done

if [ -n "$amd_device" ]; then
    pci_addr=$(basename "$(readlink -f "$amd_device")")
    friendly=$(lspci -s "$pci_addr" -mm 2>/dev/null | awk -F'"' '{print $6}')
    [ -n "$friendly" ] && amd_name="\"AMD $friendly\""

    busy=$(cat "$amd_device/gpu_busy_percent" 2>/dev/null || true)
    [ -n "$busy" ] && amd_usage="\"${busy}%\""

    vram_used=$(cat "$amd_device/mem_info_vram_used" 2>/dev/null || true)
    vram_total=$(cat "$amd_device/mem_info_vram_total" 2>/dev/null || true)
    if [ -n "$vram_used" ] && [ -n "$vram_total" ]; then
        amd_mem="\"$((vram_used / 1024 / 1024)) / $((vram_total / 1024 / 1024)) MiB\""
    fi

    hwmon_dir=$(find "$amd_device/hwmon" -mindepth 1 -maxdepth 1 -name 'hwmon*' 2>/dev/null | head -1)
    if [ -n "$hwmon_dir" ]; then
        temp_raw=$(cat "$hwmon_dir/temp1_input" 2>/dev/null || true)
        [ -n "$temp_raw" ] && amd_temp="\"$((temp_raw / 1000))°C\""
    fi
fi

printf '{"nvidia":{"name":%s,"usage":%s,"mem":%s,"temp":%s},"amd":{"name":%s,"usage":%s,"mem":%s,"temp":%s}}\n' \
    "$nvidia_name" "$nvidia_usage" "$nvidia_mem" "$nvidia_temp" \
    "$amd_name" "$amd_usage" "$amd_mem" "$amd_temp"
