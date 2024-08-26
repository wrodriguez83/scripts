# Functions
section(){
  echo ''
  echo '**************************************'
  echo '**************************************'
  echo $1
  echo '**************************************'
  echo '**************************************'
}

header(){
  echo ''
  echo '**************************************'
  echo $1
  echo '**************************************'
}

task(){
  echo '* '$1
}

alert(){
  echo '!! '$1
}

update(){
  type=$1
  task 'Updating'
  
  if [ "$type"="apt" ]; then
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt dist-upgrade -y
    sudo apt auto-remove -y
    flatpak update -y
  fi
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

installAPT(){
  name=$1
  source=$2
  dest=$3
  
  task 'Installing'
  if [[ -z "$source" ]]; then
    sudo apt install -y $name
  elif [ "$source" = "flatpak" ]; then
    flatpak install -y --noninteractive $dest $name
  elif [ "${source##*.}" = "deb" ]; then
    download $name.deb $source
    sudo gdebi -n ~/Downloads/$name.deb
  fi
}

install(){
  type=$1
  name=$2
  source=$3
  dest=$4
  
  header 'Install '${name^^}

  if [ "${source##*.}" = "gz" ]; then
    download $name.tar.gz $source
    task 'Installing'
    sudo mkdir -p $dest
    sudo tar zxf ~/Downloads/$name.tar.gz -C $source
  elif [ "$type" = "curl" ]; then
    task 'Installing'
    curl -o- $source | bash
  elif [ "$type" = "apt" ]; then
    installAPT $name $source $dest
  fi
}

if_install(){
  cond=$1
  type=$2
  name=$3
  source=$4
  dest=$5
  
  if [ $cond -eq 1 ]; then
    install $type $name $source $dest
  fi
}

clear
OS=$1
TYPE="apt"
USE_SPC=0
USE_CURL=1
USE_GDEBI=1
USE_ATH=0
ADD_FLATHUB=0
USE_TWEAKS=1
USE_NVM=1
USE_GIT=1
USE_TLP=0
USE_DISK=1
USE_PAPIRUS=1
USE_BLUEMAN=1
USE_WEATHER=0
USE_VLC=1
USE_SPOTIFY=1
USE_SUBLIMEMERGE=1
USE_TORRENT=1
USE_BRAVE=1
USE_DISCORD=1
USE_STREMIO=1
USE_SLACK=1
USE_VSCODE=1
USE_EDDY=0
USE_FREEOFFICE=1
USE_POSTGRES=1
USE_PEEK=1
USE_FONT=1

if [ "$OS" = "elementary" ];then
  ADD_FLATHUB=1
  USE_SPC=1
  USE_ATH=1
  USE_TLP=1
  USE_WEATHER=1
  USE_EDDY=1
fi
# Update system
section 'Update '${TYPE^^}

update $TYPE

# PreInstall apps
section 'PreInstall apps'

if_install $USE_SPC $TYPE software-properties-common
if_install $USE_CURL $TYPE curl
if_install $USE_GDEBI $TYPE gdebi
if_install $USE_ATH $TYPE apt-transport-https

# Add repositories
section 'Add repositories'

if [ "$ADD_FLATHUB" -eq 1 ];then
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

if [ "$USE_TWEAKS" -eq 1 ];then
  if [ "$OS" = "elementary" ];then
    sudo add-apt-repository -y ppa:philip.scott/pantheon-tweaks
  fi
fi

if_install $USE_NVM curl nvm https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh

update $TYPE

# Install apps
section 'Install apps'

if [ "$OS" = "elementary" ];then
  if_install $USE_TWEAKS $TYPE pantheon-tweaks
fi

if_install $USE_GIT $TYPE git
if_install $USE_TLP $TYPE tlp
if_install $USE_DISK $TYPE io.gitlab.adhami3310.Impression flatpak flathub
if_install $USE_PAPIRUS $TYPE papirus-icon-theme
if_install $USE_BLUEMAN $TYPE blueman
if_install $USE_WEATHER $TYPE gnome-weather
if_install $USE_VLC $TYPE vlc
if_install $USE_SPOTIFY $TYPE com.spotify.Client flatpak flathub
if_install $USE_SUBLIMEMERGE $TYPE com.sublimemerge.App flatpak flathub
if_install $USE_TORRENT $TYPE de.haeckerfelix.Fragments flatpak flathub
if_install $USE_BRAVE $TYPE com.brave.Browser flatpak flathub
if_install $USE_DISCORD $TYPE com.discordapp.Discord flatpak flathub
if_install $USE_STREMIO $TYPE com.stremio.Stremio flatpak flathub
if_install $USE_SLACK $TYPE com.slack.Slack flatpak flathub
if_install $USE_VSCODE $TYPE com.visualstudio.code flatpak flathub
if_install $USE_PEEK $TYPE com.uploadedlobster.peek flatpak flathub
if_install $USE_EDDY $TYPE com.github.donadigo.eddy flatpak
if_install $USE_FREEOFFICE $TYPE free-office https://www.freeoffice.com/download.php?filename=https://www.softmaker.net/down/softmaker-freeoffice-2024_1216-01_amd64.deb
if_install $USE_POSTGRES $TYPE postgresql

if [ "$USE_FONT" -eq 1 ];then
  download MesloLGSRegular.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  download MesloLGSBold.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  download MesloLGSItalic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  download MesloLGSBoldItalic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fi

# Configuration
section 'Configuration'

if [ "$USE_FONT" -eq 1 ];then
  sudo mkdir -p /usr/share/fonts/truetype/MesloLGS/
  sudo cp ~/Downloads/*.ttf /usr/share/fonts/truetype/MesloLGS/
  sudo fc-cache -fv
fi

if [ "$USE_TLP" -eq 1 ];then
  sudo systemctl enable tlp.service
fi

mkdir -p ~/projects/personal

echo 'RESOLUTION="3440 1440 60"' >> ~/.profile
echo 'OUTPUT="HDMI-1"' >> ~/.profile
echo 'MODELINE=$(cvt $RESOLUTION | cut -f2 -d$"\n")' >> ~/.profile
echo 'MODEDATA=$(echo $MODELINE | cut -f 3- -d" ")' >> ~/.profile
echo 'MODENAME="UltraWide"' >> ~/.profile
echo 'CONNECTED=$(xrandr --current | grep -i $OUTPUT | cut -f2 -d" ")' >> ~/.profile
echo 'echo "Adding mode - "$MODENAME $MODEDATA' >> ~/.profile
echo 'xrandr --newmode $MODENAME $MODEDATA' >> ~/.profile
echo 'xrandr --addmode $OUTPUT $MODENAME' >> ~/.profile
echo 'if [ "$CONNECTED" = "connected" ]; then' >> ~/.profile
echo '  xrandr --output $OUTPUT --mode $MODENAME' >> ~/.profile
echo 'else' >> ~/.profile
echo '  echo "Monitor is not detected"' >> ~/.profile
echo 'fi' >> ~/.profile

echo '' >> ~/.bashrc
echo 'alias sysup="sudo apt update && sudo apt full-upgrade -y && sudo apt dist-upgrade -y && sudo apt auto-remove && flatpak update -y"' >> ~/.bashrc
echo 'alias code="flatpak run com.visualstudio.code"' >> ~/.bashrc

ssh-keygen -t ed25519 -C "Walter Rodriguez" -f ~/.ssh/id_warxxi -q -N ""

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node
nvm use node

sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

update $TYPE

mkdir -p ~/projects/kovix
nvm install 16.19.0
nvm alias wms 16.19.0
install $TYPE ZplPrinter https://github.com/MrL0co/ZplPrinter/releases/download/v2.0.0/zpl-printer_2.0.0_amd64.deb

bash
sudo reboot
