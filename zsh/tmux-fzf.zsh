# CTRL-E - Select tmux sessions, with preview.
#
# Based on
# https://github.com/doitian/dotfiles-public/blob/master/default/bin/tmux-fzf-session.
fzf-tmux-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(tmux list-sessions |
    fzf -0 -1 -d: --preview 'tmux capture-pane -p -e -t {1}' --preview-window 'up:80%' --height ${FZF_TMUX_HEIGHT:-80%} --bind=ctrl-r:toggle-sort,ctrl-z:ignore |
    awk -F: '{print $1}') )
  local ret=$?

  if [ -n "$selected" ]; then
    zle push-line # Clear buffer. Auto-restored on next prompt.
    BUFFER="tmux attach -t $selected"
    zle accept-line
  fi
  zle reset-prompt

  return $ret
}
zle     -N   fzf-tmux-widget
bindkey '^E' fzf-tmux-widget
