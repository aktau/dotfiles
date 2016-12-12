# If you want to use these zgen modules (and the aktau zsh theme), put the
# following in your .zshrc:
#
#   source "${HOME}/dotfiles/zgen.zsh"

if [[ ! -e "${HOME}/.zgen/zgen.zsh" ]] ; then
  git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
fi

source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved ; then
  zgen load zsh-users/zsh-syntax-highlighting       # Syntax highlight while you type.
  zgen load zsh-users/zsh-history-substring-search  # Too useful to miss.
  zgen load joepvd/grep2awk                         # Convert grep to awk invocations, just add <ctrl-X><ctrl-A>.

  if [[ -e "${HOME}/dotfiles/zsh/themes/aktau.zsh-theme" ]] ; then
    # Need the oh-my-zsh git library for fetching information out of the
    # prompt.
    zgen oh-my-zsh lib/git.zsh
    zgen load "${HOME}/dotfiles/zsh/themes/aktau.zsh-theme"
  else
    zgen oh-my-zsh
    zgen oh-my-zsh robbyrussell
  fi

  # Generate the init script from plugins above.
  zgen save
fi
