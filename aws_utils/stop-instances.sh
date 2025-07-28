#!/bin/bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR/.venv/bin/activate"

python -u "$SCRIPT_DIR/stop_instances.py"
