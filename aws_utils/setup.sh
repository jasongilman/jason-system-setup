#!/bin/bash

set -e -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd "$SCRIPT_DIR"

rm -rf .venv
uv venv

uv pip install -r requirements.txt

popd > /dev/null
