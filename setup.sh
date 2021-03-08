#!/bin/bash
set -e

# echo in style
spatialPrint() {
    echo ""
    echo ""
    echo "$1"
    echo "================================"
}

# NOTE: the execute() function doesn't handle pipes well
execute () {
    echo "$ $*"
    OUTPUT=$($@ 2>&1)
    if [ $? -ne 0 ]; then
        echo "$OUTPUT"
        echo ""
        echo "Failed to Execute $*" >&2
        exit 1
    fi
}

PIP="pip3 install --user"
APT="sudo apt-get -y"

spatialPrint "system update and upgrade"
execute $APT update
$APT dist-upgrade
$APT install ubuntu-restricted-extras

spatialPrint "basic installation"
execute $APT install build-essential libboost-all-dev libhdf5-dev pkg-config libglvnd-dev
execute $APT install gimp ffmpeg
execute $APT install python3 python3-dev
execute $APT install python3-pip python3-venv

if [[ ! -n $(command -v bat) ]]; then
    spatialPrint "bat >>>> cat"
    bat_setup=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
    wget -q $bat_setup -O /tmp/bat.deb
    execute sudo dpkg -i /tmp/bat.deb
    execute sudo apt-get install -f
fi

if [[ ! -n $(command -v cp -g) ]]; then
    spatialPrint "advanced copy (mod)"
    wget -q http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz -O coreutils.tar.xz
    tar xJf coreutils.tar.xz && mv coreutils-8.32 coreutils/
    cd coreutils/
    wget -q https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.8-8.32.patch
    patch -p1 -i advcpmv-0.8-8.32.patch
    execute ./configure
    execute make
    sudo cp -f src/cp /usr/local/bin/cp
    sudo cp -f src/mv /usr/local/bin/mv
    cd ../
    rm -rf ./coreutils*
fi

# clear existing installation if present
spatialPrint "zimfw (zsh + zim)"
rm -rf ~/.z*
sudo rm -rf /opt/.zsh/
execute $APT install zsh
sudo mkdir -p /opt/.zsh/ && sudo chmod ugo+w /opt/.zsh/
export ZIM_HOME=/opt/.zsh/zim
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"
cp ./.zshrc ~/.zshrc
cp ./.bash_aliases /opt/.zsh/bash_aliases
ln -sf /opt/.zsh/bash_aliases ~/.bash_aliases

spatialPrint "VIM (neovim)"
execute $APT install vim neovim python3-neovim
execute $PIP install pynvim
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
execute $APT install nodejs npm exuberant-ctags
if [ ! -d ~/.config/nvim/ ]; then
    mkdir ~/.config/nvim/
fi
cp ./.config/nvim/init.vim ~/.config/nvim/

if [[ ! (-n $(command -v google-chrome) && -n $(command -v firefox)) ]]; then
    spatialPrint "web browser"
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    execute $APT update
    execute $APT install google-chrome-stable
    execute $APT install firefox
fi

spatialPrint "screen recorder"
if [[ ! -n $(command -v simplescreenrecorder) ]]; then
    execute sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder -y
    execute $APT update
    execute $APT install simplescreenrecorder
fi

if ! which docker > /dev/null; then
    spatialPrint "docker"
    wget -q get.docker.com -O dockerInstall.sh
    chmod +x dockerInstall.sh
    execute ./dockerInstall.sh
    rm dockerInstall.sh
    sudo usermod -aG docker ${USER}
fi

spatialPrint "communication"
if [[ ! -n $(command -v slack) ]]; then
    slack_setup=$(curl --silent https://slack.com/intl/en-in/downloads/linux | sed -n "/^.*Version /{;s///;s/[^0-9.].*//p;q;}")
    wget -q https://downloads.slack-edge.com/linux_releases/slack-desktop-${slack_setup}-amd64.deb
    execute $APT install ./slack-desktop-*.deb
    rm ./slack-desktop-*.deb
fi
if [[ ! -n $(command -v discord) ]]; then
    wget -q "https://discordapp.com/api/download?platform=linux&format=deb" -O ./discord.deb
    execute $APT install ./discord.deb
    rm ./discord.deb
fi

spatialPrint "remote-desktop"
if [[ ! -n $(command -v teamviewer) ]]; then
    wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
    execute $APT install ./teamviewer_amd64.deb
    rm ./teamviewer_amd64.deb
fi
if [[ ! -n $(command -v anydesk) ]]; then
    wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
    echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
    execute $APT update
    execute $APT install anydesk
fi

spatialPrint "latex"
execute $APT install texlive-full

spatialPrint "python packages"
execute $PIP numpy matplotlib pandas seaborn
execute $PIP wandb
execute $PIP opencv-python opencv-contrib-python nltk librosa==0.7.2 numba==0.48
execute $APT install magic-wormhole

if [[ -n $(lspci | grep -i nvidia) ]]; then
    spatialPrint "nvidia gpu detected! download from (https://www.nvidia.in/Download/index.aspx?lang=en-in)"
    read -p "proceed (hit 'y' after download)? y(yes) / s(skip): " tempvar
    tempvar=${tempvar:-s}
    if [ "$tempvar" = "y" ]; then
        if [ ! -f ./misc/nvidia.run ]; then
            mv ~/Downloads/NVIDIA-Linux-x86_64-*.run ./misc/nvidia.run
        fi
        sudo bash ./misc/nvidia.run
    fi
fi

spatialPrint "script finished!"
