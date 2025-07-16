#!/bin/bash

set -e -o pipefail

touch ~/.bashrc

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat <<EOF >> ~/.bashrc
source "$SCRIPT_DIR/shell/common_profile.sh"
EOF

sudo apt-get update

sudo apt install -y \
  build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

curl https://pyenv.run | bash

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

pyenv install 3.12
pyenv global 3.12

cp .gitconfig ~/

echo "Edit ~/.gitconfig to enter your email address if not jason@element84.com"
