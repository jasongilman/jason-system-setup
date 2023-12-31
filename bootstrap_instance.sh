#!/bin/bash

set -e -o pipefail

touch ~/.bashrc

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat <<EOF >> ~/.bashrc
source "$SCRIPT_DIR/shell/common_profile.sh"
EOF

sudo yum install -y git

sudo yum install -y gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

curl https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

pyenv install 3.11
