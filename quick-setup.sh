#!/bin/sh

# APT config first
SOURCES="/etc/apt/sources.list"
sudo sed -Ei 's/(cn\.)?archive\.ubuntu\.com/mirrors.ustc.edu.cn/g' "$SOURCES"
sudo sed -Ei 's/security\.ubuntu\.com/mirrors.ustc.edu.cn/g' "$SOURCES"

# APT Packages
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt -y full-upgrade
sudo apt -y install vim xxd build-essential python3-pip git openssh-client wget curl
unset DEBIAN_FRONTEND

# Python PIP
cat > /etc/pip.conf << %
[global]
index-url = https://mirrors.ustc.edu.cn/pypi/web/simple
format = columns
%

# Vimrc
wget https://ibug.github.io/ext/conf/vimrc -O ~/.vimrc

# Git Config
echo "Your GitHub username? (Leave blank if you don't have one)"
read -p "> " GH_USER
cat > ~/.gitconfig << %
[push]
    default = simple
[fetch]
    prune = true
[color]
    ui = true
%
if [ -n "$GH_USER" ]; then
  cat >> ~/.gitconfig << %
[user]
    name = $GH_USER
    email = $GH_USER@users.noreply.github.com
%
fi

# SSH Config
if [ -r ~/.ssh/id_rsa ]; then
  chmod -R 0666 ~/.ssh
  grep -qF github.com ~/.ssh/config || cat >> ~/.ssh/config << %

Host GitHub github
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa
  PubKeyAuthentication yes
  PasswordAuthentication no
%
fi

#################
# Miscellaneous #
#################

if which gem &>/dev/null; then
  cat > ~/.gemrc << %
---
:backtrace: false
:bulk_threshold: 1000
:sources:
- https://mirrors.ustc.edu.cn/rubygems/
:update_sources: true
:verbose: true
%

if [ -d ~/.bundle ]; then
  # This guy has Ruby Bundler
  cat > ~/.bundle/config << %
---
BUNDLE_MIRROR__HTTPS://RUBYGEMS__ORG/: "https://mirrors.ustc.edu.cn/rubygems/"
%
fi