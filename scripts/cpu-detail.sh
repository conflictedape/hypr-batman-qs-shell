#!/usr/bin/env bash
# Prints a detailed CPU snapshot as a single JSON object:
#   { "model", "cores", "loadAvg", "temp", "perCore": [...], "topProcess" }
#
# perCore is computed the same way as cpu-summary.sh (two /proc/stat samples,
# 300ms apart) but per logical core instead of the aggregate line.
#
# temp is best-effort: requires `lm_sensors` (the `sensors` command) with a
# CPU temperature sensor exposed (e.g. k10temp/coretemp). Falls back to null
# if unavailable — see dependencies.sh.
set -euo pipefail

l1=$(grep '^cpu[0-9]' /proc/stat)
sleep 0.3
l2=$(grep '^cpu[0-9]' /proc/stat)

per_core_json=$(awk -v l1="$l1" -v l2="$l2" 'BEGIN {
    n1 = split(l1, lines1, "\n")
    n2 = split(l2, lines2, "\n")
    out = "["
    for (i = 1; i <= n1; i++) {
        split(lines1[i], a, " ")
        split(lines2[i], b, " ")
        idle1 = a[5]; idle2 = b[5]
        t1 = 0; for (j = 2; j <= length(a); j++) t1 += a[j]
        t2 = 0; for (j = 2; j <= length(b); j++) t2 += b[j]
        d_idle = idle2 - idle1
        d_total = t2 - t1
        pct = (d_total > 0) ? 100 * (d_total - d_idle) / d_total : 0
        if (i > 1) out = out ","
        out = out sprintf("%.0f", pct)
    }
    out = out "]"
    print out
}')

model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//')
cores=$(nproc)
load_avg=$(cut -d' ' -f1-3 /proc/loadavg)

temp="null"
if command -v sensors >/dev/null 2>&1; then
    temp_raw=$(sensors 2>/dev/null | grep -m1 -E "Tctl|Package id 0|Tdie" | grep -oE '[+-][0-9]+\.[0-9]+°C' | head -1)
    if [ -n "$temp_raw" ]; then
        temp="\"$temp_raw\""
    fi
fi

top_process=$(ps -eo comm,pcpu --sort=-pcpu --no-headers | head -1 | awk '{printf "%s (%.0f%%)", $1, $2}')

printf '{"model":"%s","cores":%s,"loadAvg":"%s","temp":%s,"perCore":%s,"topProcess":"%s"}\n' \
    "$model" "$cores" "$load_avg" "$temp" "$per_core_json" "$top_process"
