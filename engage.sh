#!/bin/bash

set -euo pipefail

umask 022

########## Colors

CCCOLOR="\033[34m"
LINKCOLOR="\033[34;1m"
ERRCOLOR="\033[31;1m"
SRCCOLOR="\033[33m"
BINCOLOR="\033[37;1m"
MAKECOLOR="\033[32;1m"
ENDCOLOR="\033[0m"

########## Variables

scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Like $scriptdir, but relative to $HOME, so that it can remain stable when
# moving $HOME.
relscriptdir=$( realpath --relative-to="$HOME" "$scriptdir" )


dir=~/dotfiles                                      # dotfiles directory
bindir=~/bin                                        # Local binaries directory.
olddir=~/dotfiles_old                               # old dotfiles backup directory
olddir_current=$olddir/"$(date +%d-%m-%Y)"
files=(
  .ctags
  .fdignore
  .lua
  .newsbeuter
  .psqlrc
  .tmux.conf
  .vim
  .vimrc
  .zshrc-extra
)
linux_files=(
  .Xdefaults
)
folders=(
  .config
  etc
)

##########

# create dotfiles_old in homedir
printf '%b %b %b' "${MAKECOLOR}Creating${ENDCOLOR}" "${BINCOLOR}${olddir_current}${ENDCOLOR}" 'for backup of any existing dotfiles in ~ ...'
mkdir -p "$olddir_current"
echo "done"

# change to the dotfiles directory
printf '%b %b %b%b' "${MAKECOLOR}Changing${ENDCOLOR}" "working directory to" "${BINCOLOR}${dir}${ENDCOLOR}" "..."
cd $dir
echo "done"

# Ensure bindir exists
[[ -d "$bindir" ]] || mkdir "$bindir"

function setup_link {
    local orig="$1"
    local file="$2"

    if [[ "${file:0:1}" == "/" ]] ; then
        "$scriptdir/safelink.sh" "$dir/$orig" "$file" "$olddir_current"
    else
        "$scriptdir/safelink.sh" "$dir/$orig" "$HOME/$file" "$olddir_current"
    fi
}

function setup_neovim {
    printf "%b %b\n" "${MAKECOLOR}Creating${ENDCOLOR}" 'neovim aliases...'

    # neovim uses the same config as vanilla
    : "${XDG_CONFIG_HOME:=$HOME/.config}"
    mkdir -p "$XDG_CONFIG_HOME/nvim"
    setup_link ".vim" "$XDG_CONFIG_HOME/nvim"
    setup_link ".vimrc" "$XDG_CONFIG_HOME/nvim/init.vim"
}

function setup_dotfiles {
    # move any existing dotfiles in homedir to dotfiles_old directory, then create
    # symlinks from the homedir to any files in the ~/dotfiles directory specified in
    # $files
    printf '%b %b %b %b %b\n' "${MAKECOLOR}Moving${ENDCOLOR}" \
        "any existing dotfiles from" \
        "${BINCOLOR}~${ENDCOLOR}" \
        "to" \
        "${BINCOLOR}${olddir_current}${ENDCOLOR}"
    for file ; do
        setup_link "$file" "$file"
    done
    if [[ "$OSTYPE" == 'linux-gnu' ]] ; then
        for file in "${linux_files[@]}"; do
            setup_link "$file" "$file"
        done
    fi
}

# This function creates the hierarchies to the passed in folders in the
# destination path, but symlinks the files contained within. Useful for
# rapid prototyping, but I'd like to find a more ideal solution at some
# point (overlayfs?).
function setup_folders {
    local src="$1"
    local dst="$2"
    shift 2

    (
      cd "$src"
      # Implicit loop over the rest of the arguments.
      for folder ; do
          printf '%b' "${SRCCOLOR}"

          # mirror the directory structure, if necessary
          find "$folder" -type d \
              -exec echo DIR "${src}"/{} -\> "${dst}/"{} \; \
              -exec mkdir -p "${dst}/"{} \;

          printf '%b' "${ENDCOLOR}"

          # symlink the files (leafs)
          find "$folder" -not -type d \
              -exec "$scriptdir/safelink.sh" "${src}/"{} "${dst}/"{} "$olddir_current" \;
      done
    )
}

function setup_git {
    git config --global user.name "Nicolas Hillegeer"
    git config --global user.email nicolas@hillegeer.com
    git config --global color.ui true
    git config --global user.signingkey 09E6512A

    # git aliases
    git config --global alias.ci commit

    # add without whitespace changes, for unclean projects
    git config --global alias.addnw '!sh -c '\''git diff -w --no-color "$@" | git apply --cached --ignore-whitespace'\'' -'

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
    chown -R "$USER" ~/.ssh
}

function add_line {
    local file="$1"
    local line="$2"

    if ! grep -qxF "$line" "$file" ; then
      echo "$line" >> "$file"
    fi
}

function config_zsh {
    printf "%b %b\n" "${MAKECOLOR}Configuring${ENDCOLOR}" "zsh"

    local zshrc="$HOME/.zshrc"

    local base
    if [[ -n "$relscriptdir" ]] ; then
      base="~/$relscriptdir"
    else
      base="$scriptdir"
    fi

    add_line "$zshrc" "source $base/zgen.zsh"
    add_line "$zshrc" "source $base/.zshrc-extra"
}

function check_zsh {
  # Using $SHELL is not a portable way to get the users' default shell, but it's
  # good enough for me.
  if [[ "${SHELL##*/}" = 'zsh' ]] ; then
    return
  fi
  echo 'Your shell is not zsh. Please install/use zsh, then re-run this script'
  echo 'You may want to make zsh the default after installing, run:'
  echo "  chsh -s \"\$(which zsh)\""
  exit
}

# Debian installs fd(1) under /usr/bin/fdfind. Fix that.
if ! command -v fd >/dev/null 2>&1 ; then
  if command -v fdfind >/dev/null 2>&1 ; then
    "$scriptdir/safelink.sh" "$(which fdfind)" "$bindir/fd" "$olddir_current"
  fi
fi

setup_dotfiles "${files[@]}"
setup_folders "$dir" "$HOME" "${folders[@]}"
setup_git
setup_ssh
setup_neovim
config_zsh
check_zsh
