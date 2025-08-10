#!/bin/bash

set -e -o pipefail

touch ~/.bashrc

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat <<EOF >> ~/.bashrc
source "$SCRIPT_DIR/shell/common_profile.sh"
EOF

sudo dnf groupinstall "Development Tools"

sudo dnf install -y \
  git \
  zlib-devel \
  bzip2 \
  bzip2-devel \
  readline-devel \
  sqlite \
  sqlite-devel \
  openssl-devel \
  tk-devel \
  libffi-devel \
  xz-devel

curl https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

pyenv install 3.12
pyenv global 3.12
pip install uv

cp "$SCRIPT_DIR/.gitconfig" ~/

# Setup the AWS utils
"$SCRIPT_DIR/aws_utils/setup.sh"

echo "Edit ~/.gitconfig to enter your email address if not jason@element84.com"
