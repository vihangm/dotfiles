setopt prompt_subst
autoload colors
colors

autoload -U add-zsh-hook
autoload -Uz vcs_info

cyan="$fg[cyan]"
yellow="$fg[yellow]"
magenta="$fg[magenta]"
red="$fg[red]"
green="$fg[green]"
red="$fg[red]"
blue="$fg[blue]"

# enable VCS systems you use
zstyle ':vcs_info:*' enable git

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*:prompt:*' check-for-changes true

# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stagedstr (see below)
# %m - misc (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository
PR_RST="%{${reset_color}%}"
FMT_BRANCH="(%{$cyan%}%b%u%c%m${PR_RST})"
FMT_ACTION="(%{$green%}%a${PR_RST})"
FMT_UNSTAGED="%{$yellow%}●"
FMT_STAGED="%{$green%}●"

zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
zstyle ':vcs_info:*:prompt:*' nvcsformats   ""

zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

+vi-git-untracked() {
  if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    hook_com[misc]="%{$red}●"
  fi
}

precmd(){
  vcs_info 'prompt'
  local preprompt_left="%(?,%{$green%}$?%{$reset_color%},%{$red%}$?%{$reset_color%}) %{$magenta%}%n%{$reset_color%} at %{$yellow%}%m%{$reset_color%} in %{$blue%}%~%{$reset_color%} $vcs_info_msg_0_"
  local preprompt_right="%{$fg[green]%}[%*]%{$reset_color%}"
  local preprompt_left_length=${#${(S%%)preprompt_left//(\%([KF1]|)\{*\}|\%[Bbkf])}}
  local preprompt_right_length=${#${(S%%)preprompt_right//(\%([KF1]|)\{*\}|\%[Bbkf])}}
  local num_filler_spaces=$((COLUMNS - preprompt_left_length - preprompt_right_length))
  print -Pr $'\n'"$preprompt_left${(l:$num_filler_spaces:)}$preprompt_right"
}
PROMPT="$ "
