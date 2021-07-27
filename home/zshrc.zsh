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

{
  .zinit-tmp-subst-on "compdef"
  kitty + complete setup zsh | source /dev/stdin
  .zinit-tmp-subst-off "compdef"
}

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
