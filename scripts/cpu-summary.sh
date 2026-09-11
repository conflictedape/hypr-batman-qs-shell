#!/usr/bin/env bash
# Prints overall CPU utilisation as a bare integer percentage (no trailing
# newline noise beyond the number itself). Samples /proc/stat twice, 300ms
# apart, and diffs the deltas — matches the standard `top`/`htop` method.
set -euo pipefail

l1=$(head -1 /proc/stat)
sleep 0.3
l2=$(head -1 /proc/stat)

awk -v l1="$l1" -v l2="$l2" 'BEGIN {
    n1 = split(l1, a, " ")
    n2 = split(l2, b, " ")
    idle1 = a[5]; idle2 = b[5]
    t1 = 0; for (i = 2; i <= n1; i++) t1 += a[i]
    t2 = 0; for (i = 2; i <= n2; i++) t2 += b[i]
    d_idle = idle2 - idle1
    d_total = t2 - t1
    if (d_total > 0)
        printf "%.0f", 100 * (d_total - d_idle) / d_total
    else
        print 0
}'
