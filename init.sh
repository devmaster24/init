#!/bin/bash -e

###########################################################################
# This script is for installing all necessary bash and vim configurations #
###########################################################################


rc_file="~/.bashrc"

doOrEcho() {
  $@ 2> /dev/null || echo '[ '$@' ] not needed'
}

searchOrAdd() {
  # Arg 1 = Command to add
  grep $1 $rc_file || echo $1 >> $rc_file
}

script=`readlink -f $0`
script_dir=`dirname $script`

read -p "Install base programs? (y/n)" installBase
if [[ $installBase == "y" ]]; then
  sudo pacman -Syu cowsay lolcat vim neofetch cmatrix git tmux htop bpytop tig docker code tree
  sudo pacman -Syu libreoffice-fresh thunderbird obs-studio
else
  echo "Skipping install"
fi

read -p "Install zsh and set as default shell? (y/n)" installZsh
if [[ $installZsh == "y" ]]; then
  rc_file="~/.zshrc"

  sudo pacman -Syu zsh
  sudo chsh -s /bin/zsh $(whoami)

  echo "Restart your session to finalize"
else
  echo "Skipping zsh install"
fi

# Prepare tmux conf and bashrc
echo -e "\nPreparing rc files ..."
cp ${script_dir}/basic-configs/vimrc ~/.vimrc
cp ${script_dir}/basic-configs/tmux.conf ~/.tmux.conf

# Setus up bashrc to not overwrite anything existing, and to not duplicate commands
searchOrAdd "export TERM=screen-256color"
searchOrAdd "alias taily='tail -f -n 5000'"
searchOrAdd "alias yeet='rm -rf'"
searchOrAdd "alias sshls='echo \"TODO\" | cowsay | lolcat'"
searchOrAdd "alias gs='git status'"
searchOrAdd "alias gd='git diff'"

# Create necessary directories for plugins.
echo -e "\n-> Installing scala syntax highlighting ..."
doOrEcho mkdir -p ~/.vim; mkdir -p ~/.vim/{bundle,colors,autoload}
doOrEcho mkdir -p ~/.vim/{ftdetect,indent,syntax};
for dir in ftdetect indent syntax; do
  doOrEcho curl https://raw.githubusercontent.com/derekwyatt/vim-scala/master/syntax/scala.vim -o ~/.vim/${dir}/scala.vim
done

# Install vim plug manager.
echo -e "\n-> Installing plug.vim ..."
doOrEcho curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

## Download and install plugins.
echo -e "\n-> Installing plugins ...\n"
cd ~/.vim/bundle
doOrEcho git clone https://github.com/scrooloose/nerdtree
doOrEcho git clone https://github.com/scrooloose/nerdcommenter
doOrEcho git clone https://github.com/ajmwagar/vim-deus.git
doOrEcho git clone https://github.com/bronson/vim-trailing-whitespace
doOrEcho git clone https://github.com/bling/vim-airline

# copy configs/color schemes into vim folders
doOrEcho cp ~/.vim/bundle/vim-deus/colors/deus.vim ~/.vim/colors/
doOrEcho cp ~/.vim/bundle/vim-airline/autoload/airline.vim ~/.vim/autoload/

# Execute install for vim plugins
vim +PlugInstall +qall

echo && echo "=========================="
        echo "==== Install complete ===="
        echo "=========================="
