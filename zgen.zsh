# If you want to use these zgen modules (and the aktau zsh theme), put the
# following in your .zshrc:
#
#   source "${HOME}/dotfiles/zgen.zsh"

if [[ ! -e "${HOME}/.zgen/zgen.zsh" ]] ; then
  git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
fi

# Workaround for https://github.com/ohmyzsh/ohmyzsh/issues/12328. Async git
# prompt breaks the git_prompt_info function. Calling _omz_git_prompt_info
# directly works, but the devs state they will change this. So use the other
# workaround: revert to sync.
zstyle ':omz:alpha:lib:git' async-prompt no

source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved ; then
  zgen load zsh-users/zsh-syntax-highlighting       # Syntax highlight while you type.
  zgen load zsh-users/zsh-history-substring-search  # Too useful to miss.

  # Need the oh-my-zsh git library for fetching information out of the prompt.
  zgen oh-my-zsh lib/git.zsh
  zgen load "${HOME}/dotfiles/zsh/themes/aktau.zsh-theme"

  # If I ever decide against this, I should still consider using
  #
  #   bindkey '^R' history-incremental-pattern-search-backward
  #
  # Instead of the default, which is
  #
  #   bindkey '^R' history-incremental-search-backward
  #
  # See https://unix.stackexchange.com/questions/44115/how-do-i-perform-a-reverse-history-search-in-zshs-vi-mode
  if hash fzf &>/dev/null ; then
    zgen load junegunn/fzf shell/key-bindings.zsh
  fi

  # Generate the init script from plugins above.
  zgen save
fi
