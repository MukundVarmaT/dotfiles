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

spatialPrint "update and upgrade"
execute sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install ubuntu-restricted-extras -y

spatialPrint "basic installs"
execute sudo apt-get install build-essential libboost-all-dev -y
execute sudo apt-get install git wget curl -y
execute sudo apt-get install gimp -y
execute sudo apt-get install gnome-tweak-tool -y
execute sudo apt-get install gnome-shell-extensions -y
execute sudo apt-get install libhdf5-dev exiftool ffmpeg -y

spatialPrint "zsh + zim"
rm -rf ~/.z*
sudo rm -rf /opt/.zsh/
execute sudo apt-get install zsh -y
sudo mkdir -p /opt/.zsh/ && sudo chmod ugo+w /opt/.zsh/
export ZIM_HOME=/opt/.zsh/zim
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"
cp ./.zshrc ~/.zshrc
cp ./.bash_aliases /opt/.zsh/bash_aliases
ln -sf /opt/.zsh/bash_aliases ~/.bash_aliases

spatialPrint "vim (neovim)"
execute sudo apt-get install vim-gui-common vim-runtime -y
execute sudo apt-get install neovim python3-neovim -y
rm -rf ~/.config/nvim/
mkdir ~/.config/nvim/
cp ./.config/nvim/init.vim ~/.config/nvim/

spatialPrint "bat >> cat"
latest_bat_setup=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
wget -q $latest_bat_setup -O /tmp/bat.deb
execute sudo dpkg -i /tmp/bat.deb
execute sudo apt-get install -f

spatialPrint "browsers"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
execute sudo apt-get update  -y
execute sudo apt-get install google-chrome-stable -y
execute sudo apt-get install firefox -y

spatialPrint "screen recorder"
execute sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder -y
execute sudo apt-get update
execute sudo apt-get install simplescreenrecorder -y

if ! which docker > /dev/null; then
    spatialPrint "docker"
    wget -q get.docker.com -O dockerInstall.sh
    chmod +x dockerInstall.sh
    execute ./dockerInstall.sh
    rm dockerInstall.sh
    sudo usermod -aG docker ${USER}
fi

spatialPrint "communication"
latest_slack_setup=$(curl --silent https://slack.com/intl/en-in/downloads/linux | sed -n "/^.*Version /{;s///;s/[^0-9.].*//p;q;}")
wget -q https://downloads.slack-edge.com/linux_releases/slack-desktop-${latest_slack_setup}-amd64.deb
execute sudo apt-get install ./slack-desktop-*.deb -y
rm ./slack-desktop-*.deb
wget -q "https://discordapp.com/api/download?platform=linux&format=deb" -O ./discord.deb
execute sudo apt-get install ./discord.deb -y
rm ./discord.deb

spatialPrint "remote-desktop"
wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
execute sudo apt-get install ./teamviewer_amd64.deb -y
rm ./teamviewer_amd64.deb
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
execute sudo apt-get update -y
execute sudo apt-get install anydesk -y

spatialPrint "latex"
execute sudo apt-get install texlive-full -y

spatialPrint "python"
execute sudo apt-get install python3 python3-dev -y
execute sudo apt-get install python3-pip python3-venv -y
PIP="pip3 install --user"
execute $PIP numpy matplotlib pandas seaborn
execute $PIP wandb
execute $PIP opencv-python opencv-contrib-python nltk librosa==0.7.2 numba==0.48
execute sudo apt-get install magic-wormhole -y

if [[ -n $(lspci | grep -i nvidia) ]]; then
    spatialPrint "nvidia gpu drivers (https://www.nvidia.in/Download/index.aspx?lang=en-in)"
    read -p "proceed? y(yes) / s(skip): " tempvar
    tempvar=${tempvar:-s}
    if [ "$tempvar" = "y" ]; then
        mv ~/Downloads/NVIDIA-Linux-x86_64-*.run ./misc/
        sudo bash ./misc/NVIDIA-Linux-x86_64-*.run
    fi
fi

spatialPrint "script finished!"
