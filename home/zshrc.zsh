##
## nix: programs.zsh.initExtra
##

bindkey -v
bindkey -s '^o' "lfcd\r"
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^K' up-history
bindkey '^J' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^l' push-line-or-edit

eval "$(hub alias -s)"

[ ! -f ~/.p10k.zsh ] || source ~/.p10k.zsh

[ -f ~/.fzf-theme.zsh ] && source ~/.fzf-theme.zsh

# source /usr/local/opt/asdf/asdf.sh
PATH="$PATH:$ASDF_DIR/bin"
source "$ASDF_DIR/lib/asdf.sh"

# kitty + complete setup zsh | source /dev/stdin
if test -n "$KITTY_INSTALLATION_DIR"; then
  .zinit-tmp-subst-on "compdef"
  export KITTY_SHELL_INTEGRATION="enabled"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
  .zinit-tmp-subst-off "compdef"
fi

_java_path="$JAVA_HOME/bin"
export PATH="${PATH//$_java_path:/}"
export PATH="$PATH:$_java_path"

zfunc_files=(~/.zfunc/*(N))
if [[ ${#zfunc_files[@]} -gt 0 ]]; then
  fpath=(~/.zfunc $fpath);
  autoload -U ~/.zfunc/*(.:t)
fi

source /usr/local/opt/git-extras/share/git-extras/git-extras-completion.zsh

[ -f ~/.config/lf/lficons.sh ] && source ~/.config/lf/lficons.sh
[ -f ~/.config/lf/lfcolors.sh ] && source ~/.config/lf/lfcolors.sh

##
## END initExtra
##
