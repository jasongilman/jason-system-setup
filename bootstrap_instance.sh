#!/bin/bash

set -e -o pipefail

touch ~/.bashrc

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat <<EOF >> ~/.bashrc
source "$SCRIPT_DIR/shell/common_profile.sh"
EOF

release_version=$(cat /etc/system-release)
AL2023_VERSION="Amazon Linux release 2023"

if [[ $release_version != $AL2023_VERSION* ]]; then
  # 2023 doesn't support epel
  sudo amazon-linux-extras install epel -y
fi

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
  xz-devel

if [[ $release_version != $AL2023_VERSION* ]]; then
  # 2023 doesn't support epel so I can't figure out how to install shellcheck
  yum install -y ShellCheck
fi

curl https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if [[ $release_version != $AL2023_VERSION* ]]; then
  # Fix for amazon linux 2
  sudo yum remove openssl-devel -y
  sudo yum install openssl11-devel -y
fi

pyenv install 3.11
pyenv global 3.11

cp .gitconfig ~/

echo "Edit ~/.gitconfig to enter your email address if not jason@element84.com"
