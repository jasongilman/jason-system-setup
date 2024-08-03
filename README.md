# jason-system-setup

## Setup

1. Setup ssh keys to github
2. Clone this repository.
3. For an EC2 instance:
   1. Run `bootstrap_instance.sh` or `bootstrap_instance_ubuntu.sh`
   2. Install vscode extensions

## Optional EC2 instance setup

### Install CDKTF and terraform

1. Install node
   1. `sudo dnf install nodejs`
2. Update npm global path
   1. Add this to .bashrc

```shell
# Add npm-global to path.
# See https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally#manually-change-npms-default-directory
export PATH=~/.npm-global/bin:$PATH
```

3. `npm install --global cdktf-cli`
4. Install terraform



```shell
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
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
