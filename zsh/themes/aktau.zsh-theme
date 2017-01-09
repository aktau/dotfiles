# Based on mvmn theme authored by mvmn, which itself was based on original
# work from gallifrey. Last modifications by aktau (theme renamed to aktau
# to prevent cofusion, though it mostly looks the same apart from the
# timestamp):
#
# - Rely on a git plugin (existence of git_prompt_info() function).
# - When entering a prompt, replace the timestamp with the current
#   timestamp. Source:
#   http://stackoverflow.com/questions/13125825/zsh-update-prompt-with-current-time-when-a-command-is-started
# - Use modern zsh color codes (%F, ...).
#
# The trick is to redraw the prompt just before the command executes. The
# downside of this is that when you enter a command, the $PROMPT will be
# rendered for the last line _and_ for the new line. When commands execute
# quickly, this means the git status information will be requested twice in
# quick succession even though it's unlikely to have changed. To alleviate this,
# we store the git status in a cache (see below).

# Show host (add $USER by prepending with %n) if connected over SSH.
_MVMN_HOST=""
((${+SSH_CONNECTION})) && _MVMN_HOST=" %B%F{yellow}@%m%f%b"

# To prepend an ISO 8601 date, use %D{%F %T}, %* is shorthand for %D{%T}.
# See `man zshall`, go to "SIMPLE PROMPT ESCAPES".
PROMPT='%F{green}%*%f${_MVMN_HOST} %B%F{blue}%2~%f%b ${_MVMN_GIT_CACHE}%B»%b '

# For some reason, when not loading all of oh-my-zsh, I need to autoload
# colors right before these statements... I have to figure out what that's
# all about.
autoload -U colors && colors
ZSH_THEME_GIT_PROMPT_PREFIX="%B%F{blue}git:(%F{red}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{blue}) %F{yellow}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{blue})"

# We calculate the git part of the prompt in a precmd function because if we
# directly execute a function inside of the prompt string, it gets executed in a
# subshell. New variables in subshells won't get exported, so there's no way to
# avoid re-querying the git status (i.e.: you can't set a cache from within
# prompt evaluation).
_mvmn_git_cache() {
  _MVMN_GIT_CACHE="$(git_prompt_info)"
}
precmd_functions+=(_mvmn_git_cache)

# Clever trick to replace the timestamp in a prompt line just before executing
# the command.
_reset-prompt-and-accept-line() {
  zle reset-prompt
  zle .accept-line     # Note the . meaning the built-in accept-line.
}
zle -N accept-line _reset-prompt-and-accept-line
