#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [[ -f $(brew --prefix)/etc/bash_completion ]]; then
    . "$(brew --prefix)/etc/bash_completion"
fi

# FUTURE would ideally have git auto complete here
