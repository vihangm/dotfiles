ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[green]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" *"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%(?,%{$fg[green]%}$?%{$reset_color%},%{$fg[red]%}$?%{$reset_color%}) %{$fg[blue]%}%n@%m%{$reset_color%} : %{$fg[cyan]%}%~%{$reset_color%}$(git_prompt_info)
$ '

RPROMPT='%{$fg[green]%}[%*]%{$reset_color%}'
