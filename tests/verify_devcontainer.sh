#!/bin/bash
set -e

# Configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLE_PROJECT_DIR="$TEST_DIR/sample-cpp-project"

echo "Checking for sample project at: $SAMPLE_PROJECT_DIR"

if [ ! -d "$SAMPLE_PROJECT_DIR" ]; then
    echo "ERROR: Sample project directory not found!"
    exit 1
fi

echo "Sample project found. Starting verification..."
# (Next steps will involve building the project)
