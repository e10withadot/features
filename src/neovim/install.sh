#1/bin/sh
set -e

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
  if [ $curl_was_installed ] || [ ! command -v curl >/dev/null 2>&1 ] ; then
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
if [ "$ARCH" = "aarch64" ]; then \
    ARCH=arm64; \
fi
install_curl
curl -L https://github.com/neovim/neovim/releases/download/stable/nvim-linux-$ARCH.tar.gz --output nvim-linux-$ARCH.tar.gz
remove_curl
tar xzvf nvim-linux-$ARCH.tar.gz
cp -r nvim-linux-$ARCH /opt
chmod +x /opt/nvim-linux-$ARCH/bin/nvim
if [ -f /usr/local/bin/nvim ]; then
  rm -f /usr/local/bin/nvim
fi
ln -s /opt/nvim-linux-$ARCH/bin/nvim /usr/local/bin/
