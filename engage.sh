#!/bin/bash

########## Variables

dir=~/dotfiles                                      # dotfiles directory
olddir=~/dotfiles_old                               # old dotfiles backup directory
olddir_current=$olddir/"$(date +%d-%d-%Y)"
files=".vimrc .vim .psqlrc"   # list of files/folders to symlink in homedir
# .bashrc .zshrc .oh-my-zsh .Xresources

##########

# create dotfiles_old in homedir
echo -n "Creating $olddir_current for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir_current
echo "done"

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create
# symlinks from the homedir to any files in the ~/dotfiles directory specified in
# $files
echo "Moving any existing dotfiles from ~ to $olddir"
for file in $files; do
    if [[ -L ~/$file ]] ; then
        echo "~/$file is a symlink, removing"
        rm -f ~/$file
    elif [[ -e ~/$file ]]; then
        echo "~/$file exists, backing up to $olddir_current"
        rm -rf $olddir_current/$file || true
        mv ~/$file $olddir_current
    else
        echo "~/$file not present"
    fi

    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done

function setup_vim {
    if [ ! -d "~/.vim/bundle/vundle" ] ; then
        mkdir -p ~/.vim/bundle && cd ~/.vim/bundle && git clone https://github.com/gmarik/vundle
        vim +BundleInstall +qall
    fi
}

function setup_git {
    git config --global user.name "Nicolas Hillegeer"
    git config --global user.email nicolas@hillegeer.com

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
    chmod -f 600 ~/.ssh/authorized_keys
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

#install_zsh
setup_git
setup_ssh
setup_vim
