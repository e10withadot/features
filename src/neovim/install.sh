#!/bin/sh
set -eu

curl_was_installed=false

install_curl() {
  if command -v curl >/dev/null 2>&1; then
    echo "curl already installed"
    curl_was_installed=true
    return 0
  fi

  if [ -f /etc/debian_version ]; then
    apt update
    apt install -y curl
  elif [ -f /etc/redhat-release ]; then
    if command -v dnf >/dev/null 2>&1; then
      dnf install -y curl
    else
      yum install -y curl
    fi
  elif [ -f /etc/alpine-release ]; then
    apk add --no-cache curl
  elif command -v pacman >/dev/null 2>&1; then
    pacman -Sy --noconfirm curl
  else
    echo "Unsupported Linux distribution."
    return 1
  fi
  echo "curl installed successfully"
}

remove_curl() {
  if [ $curl_was_installed = true ]; then
    return 0
  fi

  if [ -f /etc/debian_version ]; then
    apt remove -y curl
  elif [ -f /etc/redhat-release ]; then
    if command -v dnf >/dev/null 2>&1; then
      dnf remove -y curl
    else
      yum remove -y curl
    fi
  elif [ -f /etc/alpine-release ]; then
    apk del curl
  elif command -v pacman >/dev/null 2>&1; then
    pacman -Rns --noconfirm curl
  else
    echo "Unsupported Linux distribution."
    return 1
  fi
  echo "curl removed successfully"
}

ARCH=$(uname -m)
TS_ARCH=""
case "$ARCH" in x86_64|amd64)
    ARCH=x86_64
    TS_ARCH=x64
    ;;
aarch64|arm64)
    ARCH=arm64
    TS_ARCH=arm64
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac
install_curl
curl -L https://github.com/neovim/neovim/releases/download/$VERSION/nvim-linux-$ARCH.tar.gz --output nvim-linux-$ARCH.tar.gz
if [ $TREESITTER = true ]; then \
  LATEST_URL=$(curl -Ls -o /dev/null -w '%{url_effective}' \
    https://github.com/tree-sitter/tree-sitter/releases/latest);
  TAG=${LATEST_URL##*/}
  curl -L https://github.com/tree-sitter/tree-sitter/releases/download/$TAG/tree-sitter-linux-$TS_ARCH.gz 
  gzip -d "tree-sitter-linux-$TS_ARCH.gz"
  mv "tree-sitter-linux-$TS_ARCH" tree-sitter
  if [ -f /usr/local/bin/tree-sitter ]; then
    rm -f /usr/local/bin/tree-sitter
  fi
  cp -r tree-sitter /usr/local/bin
  chmod +x /usr/local/bin/tree-sitter
fi
remove_curl
tar xzf nvim-linux-$ARCH.tar.gz
cp -r nvim-linux-$ARCH /opt
chmod +x /opt/nvim-linux-$ARCH/bin/nvim
if [ -f /usr/local/bin/nvim ]; then
  rm -f /usr/local/bin/nvim
fi
ln -s /opt/nvim-linux-$ARCH/bin/nvim /usr/local/bin/
