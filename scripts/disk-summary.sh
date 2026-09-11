#!/usr/bin/env bash
# Prints root filesystem disk usage as a bare percentage string (e.g. "42%").
set -euo pipefail

df -h / | awk 'NR==2{print $5}'
