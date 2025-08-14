#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR/fancyprompt.sh"
source "$SCRIPT_DIR/../aws_utils/exports.sh"

# Enable AWS CLI completion
complete -C '/usr/local/bin/aws_completer' aws

################################################################################
# PYENV copy and pasted
# (The below instructions are intended for common
# shell setups. See the README for more guidance
# if they don't apply and/or don't work for you.)

# Add pyenv executable to PATH and
# enable shims by adding the following
# to ~/.profile:

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# If your ~/.profile sources ~/.bashrc,
# the lines need to be inserted before the part
# that does that. See the README for another option.

# If you have ~/.bash_profile, make sure that it
# also executes the above lines -- e.g. by
# copying them there or by sourcing ~/.profile

# Load pyenv into the shell by adding
# the following to ~/.bashrc:

eval "$(pyenv init -)"

################################################################################

# Automate activation of virtual envs
function cd() {
  # shellcheck disable=SC2164
  builtin cd "$@"

  if [[ -n "$VIRTUAL_ENV" ]] ; then
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
    parentdir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD"/ != "$parentdir"/* ]] ; then
      deactivate
    fi
  fi

  ## If env folder is found then activate the vitualenv
  if [[ -d ./.venv ]] ; then
    source ./.venv/bin/activate
  fi
}

ORIGINAL_CODE="$(which code 2>/dev/null)"
# Replaces vscode command to open a workspace
if [[ -n "$ORIGINAL_CODE" ]]; then
function code() {
  path=$1

  if [[ -d "$path" ]]; then
    # Look for a VSCode workspace file
    workspace=$(find "$path" -maxdepth 1 -name "*.code-workspace" | head -n 1)

    if [[ "$workspace" != "" ]]; then
      # Open visual studio code workspace if present
      path="$workspace"
    fi
  fi
  "$ORIGINAL_CODE" "$path"
}
fi
