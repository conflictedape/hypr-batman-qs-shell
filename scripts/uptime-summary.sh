#!/usr/bin/env bash
# Prints how long the system has been running as a short human-readable
# string (e.g. "6hr 50min").
set -euo pipefail

uptime -p | sed 's/^up //' | sed -E 's/ hours?/hr/; s/ minutes?/min/; s/,//'
