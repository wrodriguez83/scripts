# Functions
section(){
    echo '**************************************'
    echo '**************************************'
    echo $1
    echo '**************************************'
    echo '**************************************'
    echo ''
}

header(){
    echo '**************************************'
    echo $1
    echo '**************************************'
    echo ''
}

task(){
    echo '* '$1
}

alert(){
    echo '!! '$1
}

sysupdate(){
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt dist-upgrade -y
    sudo apt auto-remove -y
    flatpak update -y
}

download(){
    task 'Check if '$1' exist'
    if [ -f ~/Downloads/$1 ];
    then
        alert $1' exist'
    else
        task 'Download '$1
        wget -O ~/Downloads/$1 $2
    fi
}

install(){
    pkg_name=$1
    source=$2
    ext=${source##*.}
    dest=$3
    header 'Install '${pkg_name^^}

    if [[ -z "$ext" ]]
    then
        task 'Installing '${pkg_name^^}
        sudo apt install -y ${pkg_name}
    elif [ "$source" = "flatpak" ]
    then
        task 'Installing '${pkg_name^^}
        flatpak install -y --noninteractive ${dest} ${pkg_name} --system
    elif [ "$ext" = "deb" ]
    then
        download ${pkg_name}.deb ${source}
        task 'Installing '${pkg_name^^}
        sudo gdebi -n ~/Downloads/${pkg_name}.deb
    elif [ "$ext"="gz" ]
    then
        download ${pkg_name}.tar.gz ${source}
        task 'Installing '${pkg_name^^}
        sudo mkdir -p ${dest}
        sudo tar zxf ~/Downloads/${pkg_name}.tar.gz -C ${source}
    fi
}

# Update system
section 'Update system'

sysupdate

# PreInstall apps
section 'PreInstall apps'

install software-properties-common
install curl
install gdebi
install apt-transport-https

# Add repositories
section 'Add repositories'

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo add-apt-repository -y ppa:philip.scott/pantheon-tweaks
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
#curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
#curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

#wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
#echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
#echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
#echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sysupdate

# Install apps
section 'Install apps'

install git
install tlp
install gnome-disk-utility
install pantheon-tweaks
install papirus-icon-theme
install blueman
install gnome-weather
install vlc
install com.spotify.Client flatpak flathub
install com.sublimemerge.App flatpak flathub
install transmission
install com.brave.Browser flatpak flathub
install com.discordapp.Discord flatpak flathub
install com.stremio.Stremio flatpak flathub
install com.slack.Slack flatpak flathub
install com.visualstudio.code flatpak flathub
install com.github.donadigo.eddy flatpak
install FreeOffice https://www.freeoffice.com/download.php?filename=https://www.softmaker.net/down/softmaker-freeoffice-2024_1216-01_amd64.deb

download MesloLGSRegular.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
download MesloLGSBold.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
download MesloLGSItalic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
download MesloLGSBoldItalic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

# Configuration
section 'Configuration'

sudo mkdir -p /usr/share/fonts/truetype/MesloLGS/
sudo cp ~/Downloads/*.ttf /usr/share/fonts/truetype/MesloLGS/
sudo fc-cache -fv

sudo systemctl enable tlp.service

mkdir -p ~/projects/personal

resolution="3440 1440 60"
output="HDMI-1"
echo 'RESOLUTION="'${resolution}'"' >> ~/.profile
echo 'OUTPUT="'${output}'"' >> ~/.profile
echo 'CONNECTED=$(xrandr --current | grep -i $OUTPUT | cut -f2 -d' ')' >> ~/.profile
echo 'if [ "$CONNECTED" = "connected" ]; then' >> ~/.profile
echo 'MODELINE=$(cvt $RESOLUTION | cut -f2 -d$'\n')' >> ~/.profile
echo 'MODEDATA=$(echo $MODELINE | cut -f 3- -d' ')' >> ~/.profile
echo 'MODENAME=$(echo $MODELINE | cut -f2 -d' ')' >> ~/.profile
echo 'echo "Adding mode - " $MODENAME $MODEDATA' >> ~/.profile
echo 'xrandr --newmode $MODENAME $MODEDATA' >> ~/.profile
echo 'xrandr --addmode $OUTPUT $MODENAME' >> ~/.profile
echo 'xrandr --output $OUTPUT --mode $MODENAME' >> ~/.profile
echo 'else' >> ~/.profile
echo 'echo "Monitor is not detected"' >> ~/.profile
echo 'fi' >> ~/.profile

echo '' >> ~/.bashrc
echo 'alias sysup="sudo apt update && sudo apt full-upgrade -y && sudo apt dist-upgrade -y && sudo apt auto-remove && flatpak update -y"' >> ~/.bashrc


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node
nvm use node

sysupdate

mkdir -p ~/projects/kovix
nvm install 16.19.0
nvm alias wms 16.19.0
install ZplPrinter https://github.com/MrL0co/ZplPrinter/releases/download/v2.0.0/zpl-printer_2.0.0_amd64.deb

bash
reboot
