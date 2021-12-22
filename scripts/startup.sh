#!/bin/bash

export RUNNER_TOKEN="${runner_token}"
export GITHUB_REPO="${github_repo}"
export GITHUB_ORG="${github_org}"
export RUNNER_NAME="${runner_name}"
export RUNNER_LABELS="${runner_labels}"
export RUNNER_ALLOW_RUNASROOT="1"
export RUNNER_GROUP="${runner_group}"
export RUNNER_SCOPE="${runner_scope}"

export DEBIAN_FRONTEND=noninteractive

## repo for git
add-apt-repository -y ppa:git-core/ppa

apt-get update -y
apt-get upgrade -y

# install dependencies
apt-get install -y  \
      curl \
      sudo \
      git \
      tar \
      unzip \
      zip \
      wget \
      apt-transport-https \
      ca-certificates \
      software-properties-common \
      make \
      jq \
      gnupg2 \
      openssh-client

# docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Enable docker.service
systemctl is-active --quiet docker.service || systemctl start docker.service
systemctl is-enabled --quiet docker.service || systemctl enable docker.service


# Install latest docker-compose from releases
echo "installing docker compose"
URL="https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64"
curl -L $URL -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## node and npm
curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
apt-get update && apt-get install -y nodejs

# azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# powershell
# Download the Microsoft repository GPG keys
echo 'installing powershell'
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update && install -y powershell

# terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt install -y terraform

# cleanup
apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

# Git Runner
export PATH=$PATH:/actions-runner
mkdir -p /actions-runner

_RUNNER_GROUP=$${RUNNER_GROUP:-Default}

export AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
mkdir -p /opt/hostedtoolcache

export RUNNER_WORK_DIRECTORY="_work"
mkdir /_work

cd /actions-runner

GH_RUNNER_VERSION=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')
curl -L -O https://github.com/actions/runner/releases/download/v$GH_RUNNER_VERSION/actions-runner-linux-x64-$GH_RUNNER_VERSION.tar.gz
tar -zxf actions-runner-linux-x64-$GH_RUNNER_VERSION.tar.gz
rm -f actions-runner-linux-x64-$GH_RUNNER_VERSION.tar.gz

./bin/installdependencies.sh

# Add the Python "User Script Directory" to the PATH
export PATH="$PATH:$HOME/.local/bin"
export ImageOS=ubuntu20

if [[ $RUNNER_SCOPE == "org" ]]; then
    GIT_URL="https://github.com/$GITHUB_ORG"
  else
    GIT_URL="https://github.com/$GITHUB_ORG/$GITHUB_REPO"
    RUNNER_GROUP=''
fi

echo "this is the url $${GIT_URL}"

./config.sh \
      --url $GIT_URL \
      --token $RUNNER_TOKEN \
      --name $RUNNER_NAME \
      --work $RUNNER_WORK_DIRECTORY \
      --labels $RUNNER_LABELS \
      --runnergroup "$${_RUNNER_GROUP}"\
      --unattended \
      --replace

echo "configured"
sudo ./svc.sh install

echo "installed"
sudo ./svc.sh start

echo "started"
