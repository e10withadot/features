#1/bin/sh
set -e

if [ $(uname -m) = "aarch64" ]; then \
    ARCH=arm64; \
fi
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-$ARCH.tar.gz --output nvim-linux-$ARCH.tar.gz
tar xzvf nvim-linux-$ARCH.tar.gz
cp -r nvim-linux-$ARCH /opt
chmod +x /opt/nvim-linux-$ARCH/bin/nvim
ln -s /opt/nvim-linux-$ARCH/bin/nvim /usr/local/bin/
