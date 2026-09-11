#!/usr/bin/env bash
# Prints a detailed memory snapshot as a single JSON object:
#   { "total", "used", "available", "buffCache", "swapTotal", "swapUsed", "topProcess" }
# All sizes are human-readable strings (as reported by `free -h`).
set -euo pipefail

read -r _ total used _ _ buff_cache available <<< "$(free -h | awk '/Mem:/{print}')"
read -r _ swap_total swap_used _ <<< "$(free -h | awk '/Swap:/{print}')"

top_process=$(ps -eo comm,rss --sort=-rss --no-headers | head -1 | awk '{
    size = $2
    unit = "KB"
    if (size > 1024*1024) { size = size/1024/1024; unit = "GB" }
    else if (size > 1024) { size = size/1024; unit = "MB" }
    printf "%s (%.1f%s)", $1, size, unit
}')

printf '{"total":"%s","used":"%s","available":"%s","buffCache":"%s","swapTotal":"%s","swapUsed":"%s","topProcess":"%s"}\n' \
    "$total" "$used" "$available" "$buff_cache" "$swap_total" "$swap_used" "$top_process"
