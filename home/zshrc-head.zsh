##
## nix: programs.zsh.initExtraFirst
##

module_path+=( "$HOME/.zinit/module/Src" )
zmodload zdharma_continuum/zinit

# anything that might require input needs to go above this 
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##
## END initExtraFirst
##
