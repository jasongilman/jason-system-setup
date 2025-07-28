#!/bin/bash

set -e -o pipefail

if [[ -z "$1" ]]; then
    echo "Error: Instance ID must be provided as first argument"
    exit 1
fi

instance_id="$1"

if [[ ! "$instance_id" =~ ^i- ]]; then
    instance_id="i-${instance_id}"
fi

aws ssm start-session --target "$instance_id"
