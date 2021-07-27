##
## nix: programs.zsh.initExtraBeforeCompInit
##

source "$HOME/.zinit/bin/zinit.zsh"
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit

# zinit ice wait"!1" lucid silent 
# zinit light RobSis/zsh-completion-generator

zstyle ":completion:*:*:git:*" script "/Users/harry/.zinit/snippets/OMZP::gitfast/git-completion.bash"
zinit ice svn
zinit snippet OMZP::gitfast

zstyle ":history-search-multi-word" page-size "14"
zstyle ":history-search-multi-word" highlight-color "fg=yellow,bold"
zstyle ":plugin:history-search-multi-word" synhl "yes"
zstyle ":plugin:history-search-multi-word" active "underline"
zstyle ":plugin:history-search-multi-word" check-paths "yes"
zstyle ":plugin:history-search-multi-word" clear-on-cancel "no"

zinit wait lucid light-mode for \
    Aloxaf/fzf-tab \
  atinit'zicompinit; zicdreplay' \
    zdharma/fast-syntax-highlighting \
  atload'_zsh_autosuggest_start; autosuggest-atload' \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions \
  zdharma/history-search-multi-word

zinit wait'1' lucid light-mode for \
  zdharma/zui \
  zdharma/zzcomplete

zinit ice depth=1
zinit light romkatv/powerlevel10k

zinit ice wait"2" lucid as"program" pick"bin/git-dsf"
zinit light zdharma/zsh-diff-so-fancy

zinit ice as"program" src"init.sh"
zinit light b4b4r07/enhancd

##
## END initExtraBeforeCompInit
##
