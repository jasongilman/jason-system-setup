#!/bin/bash

# Disabled for completion code
# shellcheck disable=SC2086
# shellcheck disable=SC2207


function ssm-connect {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$script_dir/ssm-connect.sh" "$@"
}


############
# EC2 start, stop, terminate, list-instances
function ec2() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$script_dir/.venv/bin/python" -u "$script_dir/ec2_util.py" "$@"
}

_ec2_utilpy_completion() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local IFS=$'
'
  COMPREPLY=( $( env COMP_WORDS="${COMP_WORDS[*]}" \
                  COMP_CWORD=$COMP_CWORD \
                  _EC2_UTIL.PY_COMPLETE=complete_bash "$script_dir/.venv/bin/python" "$script_dir/ec2_util.py" ) )
  return 0
}

# TO make it work for the function
complete -o default -F _ec2_utilpy_completion ec2

alias list-instances="ec2 list-instances"

alias start-instances="ec2 change-instance-state start"
alias stop-instances="ec2 change-instance-state stop"
alias terminate-instances="ec2 change-instance-state terminate"

function launch-instance() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$script_dir/.venv/bin/python" -u "$script_dir/instance_launcher.py" "$@"
}
