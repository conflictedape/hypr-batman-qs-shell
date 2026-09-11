#!/usr/bin/env bash
# Prints a detailed disk snapshot as a single JSON object:
#   { "mounts": [ { "source", "size", "used", "avail", "percent", "target" }, ... ] }
#
# Excludes pseudo filesystems and deduplicates entries that share the same
# backing device + size + used (e.g. multiple btrfs subvolumes of one
# partition), so a typical layout shows one row per physical mount instead
# of a dozen near-identical subvolume rows.
set -euo pipefail

rows=$(df -h -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs \
    --output=source,size,used,avail,pcent,target 2>/dev/null \
    | tail -n +2 | awk '!seen[$1 $2 $3]++')

mounts_json=""
first=true
while IFS= read -r line; do
    [ -z "$line" ] && continue
    source=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    used=$(echo "$line" | awk '{print $3}')
    avail=$(echo "$line" | awk '{print $4}')
    percent=$(echo "$line" | awk '{print $5}')
    target=$(echo "$line" | awk '{print $6}')

    entry=$(printf '{"source":"%s","size":"%s","used":"%s","avail":"%s","percent":"%s","target":"%s"}' \
        "$source" "$size" "$used" "$avail" "$percent" "$target")

    if [ "$first" = true ]; then
        mounts_json="$entry"
        first=false
    else
        mounts_json="$mounts_json,$entry"
    fi
done <<< "$rows"

printf '{"mounts":[%s]}\n' "$mounts_json"
