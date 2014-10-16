function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('$fg[blue]`basename $VIRTUAL_ENV`%{$reset_color%}') '
}
PR_GIT_UPDATE=1

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
zstyle ':vcs_info:*' enable git svn

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*:prompt:*' check-for-changes true

# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stagedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository
PR_RST="%{${reset_color}%}"
FMT_BRANCH="(%{$cyan%}%b%u%c${PR_RST})"
FMT_ACTION="(%{$green%}%a${PR_RST})"
FMT_UNSTAGED="%{$yellow%}●"
FMT_STAGED="%{$green%}●"

zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
zstyle ':vcs_info:*:prompt:*' nvcsformats   ""


function steeef_preexec {
    case "$(history $HISTCMD)" in
        *git*)
            PR_GIT_UPDATE=1
            ;;
        *svn*)
            PR_GIT_UPDATE=1
            ;;
    esac
}
add-zsh-hook preexec steeef_preexec

function steeef_chpwd {
    PR_GIT_UPDATE=1
}
add-zsh-hook chpwd steeef_chpwd

function steeef_precmd {
    if [[ -n "$PR_GIT_UPDATE" ]] ; then
        # check for untracked files or updated submodules, since vcs_info doesn't
        if git ls-files --other --exclude-standard 2> /dev/null | grep -q "."; then
            PR_GIT_UPDATE=1
            FMT_BRANCH="(%{$cyan%}%b%u%c%{$red%}●${PR_RST})"
        else
            FMT_BRANCH="(%{$cyan%}%b%u%c${PR_RST})"
        fi
        zstyle ':vcs_info:*:prompt:*' formats "${FMT_BRANCH} "

        vcs_info 'prompt'
        PR_GIT_UPDATE=
    fi
}
add-zsh-hook precmd steeef_precmd

PROMPT=$'
%(?,%{$green%}$?%{$reset_color%},%{$red%}$?%{$reset_color%}) %{$magenta%}%n%{$reset_color%} at %{$yellow%}%m%{$reset_color%} in %{$blue%}%~%{$reset_color%} $vcs_info_msg_0_$(virtualenv_info)%{$reset_color%}
$ '

RPROMPT='%{$fg[green]%}[%*]%{$reset_color%}'
