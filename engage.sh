#!/bin/bash

set -u

########## Colors

CCCOLOR="\033[34m"
LINKCOLOR="\033[34;1m"
ERRCOLOR="\033[31;1m"
SRCCOLOR="\033[33m"
BINCOLOR="\033[37;1m"
MAKECOLOR="\033[32;1m"
ENDCOLOR="\033[0m"

########## Variables

dir=~/dotfiles                                      # dotfiles directory
olddir=~/dotfiles_old                               # old dotfiles backup directory
olddir_current=$olddir/"$(date +%d-%m-%Y)"
files=".vimrc .vim .psqlrc .newsbeuter .zshrc-extra"   # list of files/folders to symlink in homedir
# .bashrc .zshrc .oh-my-zsh .Xresources

##########

# create dotfiles_old in homedir
printf '%b %b %b' ${MAKECOLOR}"Creating"${ENDCOLOR} ${BINCOLOR}${olddir_current}${ENDCOLOR} "for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir_current
echo "done"

# change to the dotfiles directory
printf '%b %b %b%b' ${MAKECOLOR}"Changing"${ENDCOLOR} "working directory to" ${BINCOLOR}${dir}${ENDCOLOR} "..."
cd $dir
echo "done"

function setup_vim {
    if [[ ! -d "$dir/.vim/bundle/vundle" ]] ; then
        mkdir -p ~/.vim/bundle && cd ~/.vim/bundle && git clone https://github.com/gmarik/vundle
    else
        cd "$dir/.vim/bundle/vundle" && git pull --ff-only
    fi

    vim +BundleInstall +qall
}

function setup_link {
    orig="$1"
    file="$2"

    if [[ -L ~/$file ]] ; then
        rm -f ~/$file
    elif [[ -e ~/$file ]]; then
        printf '%b\n' ${ERRCOLOR}"~/$file exists, backing up to $olddir_current"${ENDCOLOR}
        rm -rf $olddir_current/$file || true
        mv ~/$file $olddir_current
    else
        echo "~/$file not present"
    fi

    printf '%b' ${SRCCOLOR}
    ln -sv $dir/$orig ~/$file
    printf '%b' ${ENDCOLOR}
}

function setup_neovim {
    printf "%b %b\n" ${MAKECOLOR}"Creating"${ENDCOLOR} "neovim aliases..."

    # neovim uses the same config as vanilla
    setup_link ".vimrc" ".nvimrc"
    setup_link ".vim" ".nvim"
}

function setup_dotfiles {
    files="$1"

    # move any existing dotfiles in homedir to dotfiles_old directory, then create
    # symlinks from the homedir to any files in the ~/dotfiles directory specified in
    # $files
    printf '%b %b %b %b %b\n' ${MAKECOLOR}"Moving"${ENDCOLOR} \
        "any existing dotfiles from" \
        ${BINCOLOR}"~"${ENDCOLOR} \
        "to" \
        ${BINCOLOR}${olddir_current}${ENDCOLOR}
    for file in $files; do
        setup_link "$file" "$file"
    done
}

function setup_git {
    git config --global user.name "Nicolas Hillegeer"
    git config --global user.email nicolas@hillegeer.com
    git config --global color.ui true

    # tells git-branch and git-checkout to setup new branches so that git-pull(1) will appropriately merge from that remote branch.  Recommended.  Without this, you will have to add --track to your branch command or manually merge remote tracking branches with "fetch" and then "merge".
    # git config branch.autosetupmerge true

    # convert newlines to the system's standard when checking out files, and to LF newlines when committing in.    │etc/hsflowd.conf
    # git config core.autocrlf true

    # old systems don't got the CA
    # git config --global http.sslVerify false
}

function setup_ssh {
    ## ~/.ssh
    # Just dir/permissions.  Don't wanna autolink config...
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    [ -f ~/.ssh/authorized_keys ] && chmod -f 600 ~/.ssh/authorized_keys
    chown -R $USER ~/.ssh
}

function install_zsh {
# Test to see if zshell is installed.  If it is:
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Clone my oh-my-zsh repository from GitHub only if it isn't already present
    if [[ ! -d $dir/oh-my-zsh/ ]]; then
        git clone http://github.com/michaeljsmalley/oh-my-zsh.git
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
        chsh -s $(which zsh)
    fi
else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
        sudo apt-get install zsh
        install_zsh
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
        echo "Please install zsh, then re-run this script!"
        exit
    fi
fi
}

function config_zsh {
    printf "%b %b\n" ${MAKECOLOR}"Configuring"${ENDCOLOR} "zsh"

    local zshrc="$HOME/.zshrc"
    local line="source ~/.zshrc-extra"

    grep -q "$line" "$zshrc" || printf "\n%b\n%b" "# include some extra helpers" "$line" >> "$zshrc"
}

#install_zsh
config_zsh
setup_dotfiles "$files"
setup_git
setup_ssh
setup_vim
setup_neovim
