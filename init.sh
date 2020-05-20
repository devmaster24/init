#!/bin/bash -e

###########################################################################
# This script is for installing all necessary bash and vim configurations #
###########################################################################


doOrEcho() {
  $@ 2> /dev/null || echo '[ '$@' ] not needed'
}

searchOrAdd() {
  grep $1 ~/.bashrc || echo $1 >> ~/.bashrc
}

script=`readlink -f $0`
script_dir=`dirname $script`

read -p "Please enter a name for this session: " serverName

echo "=========================="
echo "==== Install starting ===="
echo "=========================="

# Prepare tmux conf and bashrc
echo -e "\n-> Preparing bashrc and vimrc ..."
cp ${script_dir}/basic-configs/vimrc ~/.vimrc
cp ${script_dir}/basic-configs/tmux.conf ~/.tmux.conf

# Setus up bashrc to not overwrite anything existing, and to not duplicate commands
searchOrAdd "export TERM=screen-256color"
searchOrAdd "alias taily='tail -f -n 5000'"
searchOrAdd "alias yeet='rm -rf'"

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
doOrEcho git clone https://github.com/tomasr/molokai
doOrEcho git clone https://github.com/ajmwagar/vim-deus.git
doOrEcho git clone https://github.com/bronson/vim-trailing-whitespace
doOrEcho git clone https://github.com/bling/vim-airline

# copy configs/color schemes into vim folders
doOrEcho cp ~/.vim/bundle/molokai/colors/molokai.vim ~/.vim/colors/
doOrEcho cp ~/.vim/bundle/vim-deus/colors/deus.vim ~/.vim/colors/
doOrEcho cp ~/.vim/bundle/vim-airline/autoload/airline.vim ~/.vim/autoload/

# Execute install for vim plugins
vim +PlugInstall +qall

# Restores backup for any subsequent runs
echo -e "\n-> Cleaning up ...\n"
mv ${script_dir}/basic-configs/bashrc.bak ${script_dir}/basic-configs/bashrc

echo && echo "=========================="
        echo "==== Install complete ===="
        echo "=========================="
