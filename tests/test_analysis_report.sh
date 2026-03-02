#!/bin/bash
set -e

REPORT_FILE="conductor/tracks/optimize_cpp_devcontainer_20260302/analysis.md"

if [ ! -f "$REPORT_FILE" ]; then
    echo "ERROR: Analysis report file not found!"
    exit 1
fi

if ! grep -q "## Actual Size Breakdown" "$REPORT_FILE"; then
    echo "ERROR: Analysis report is missing 'Actual Size Breakdown' section!"
    exit 1
fi

echo "SUCCESS: Analysis report is complete."
