#!/bin/bash

set -e -o pipefail

touch ~/.bashrc

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat <<EOF >> ~/.bashrc
source "$SCRIPT_DIR/shell/common_profile.sh"
EOF

sudo amazon-linux-extras install epel -y

sudo yum install -y \
  git \
  gcc \
  make \
  patch \
  zlib-devel \
  bzip2 \
  bzip2-devel \
  readline-devel \
  sqlite \
  sqlite-devel \
  openssl-devel \
  tk-devel \
  libffi-devel \
  xz-devel \
  ShellCheck

curl https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Fix for amazon linux 2
sudo yum remove openssl-devel -y
sudo yum install openssl11-devel -y

pyenv install 3.11

cp .gitconfig ~/

echo "Edit ~/.gitconfig to enter your email address if not jason@element84.com"
