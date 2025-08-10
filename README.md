# jason-system-setup

## Setup

1. Setup ssh keys to github
2. Clone this repository.
3. For an EC2 instance:
   1. Run `bootstrap_instance.sh` or `bootstrap_instance_ubuntu.sh`
   2. Install vscode extensions

## Optional EC2 instance setup

### Install Node

1. Install [NVM](https://github.com/nvm-sh/nvm)
   1. Check for newer install command first
   2. `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash`
2. Install node
   1. `nvm install node`

### Install CDKTF and terraform

1. `npm install --global cdktf-cli`
2. Install terraform

```shell
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf -y install terraform
```

## Shell setup instructions

Add these to `~/.bashrc`

```Shell
source <PATH_TO_REPO>/shell/common_profile.sh
# If on a mac
source <PATH_TO_REPO>/shell/mac_profile.sh
```


## VSCode Setup instructions

`cp vscode/* "~/Library/Application Support/Code/User/"`
