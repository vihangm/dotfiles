# .git.bash

# Configuration
export GIT_REVERSE=false  # Reverse the order of commits in `gg' and `glhf'.
export GIT_REFETCH=true   # Fetch before rebasing in `gup'.

# Usage: gd <options>
# Alias for `git diff'.
function gdf {
  git diff "$@"
}

# Usage: gdc <options>
# Alias for `git diff --cached'.
function gdc {
  git diff --cached "$@"
}

# Usage: gs <options>
# Alias for `git status'.
function gs {
  git status "$@"
}

# Usage: glhf <branch>(HEAD)
# Lists and describes all commits on <branch> ahead of trunk.
function glhf {
  local flags=''
  if $GIT_REVERSE; then
    flags='--reverse'
  fi
  git log $flags --pretty=format:'%Cred%h%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --stat=150,150 trunk..$1 2>/dev/null
}

# Usage: gg <options>
# Lists each branch and its commits ahead of trunk.
function gg {
  local GRAY="\033[1;30m"
  local YELLOW="\033[1;33m"
  local AUTO="\033[0m"

  # Parse options.
  local showhidden=false
  args=`getopt a $*`
  set -- $args
  for i; do
    if [ "$i" = '-a' ]; then
      showhidden=true
    fi
  done

  local flags=''
  if $GIT_REVERSE; then
    flags='--reverse'
  fi

  local tmpdir="$(mktemp -d)"
  local active="$(_gitbr)"
  (
    local index=0
    for ref in $(git for-each-ref --format='%(refname:short):%(upstream:short)' refs/heads/); do
      local branch=${ref%:*}
      local upstream=${ref#*:}

      # For some reason, upstream may not be set correctly. Default to trunk.
      if [ "$upstream" == "" ]; then
        upstream="trunk"
      fi

      if ! $showhidden && [ ${branch:0:1} = '_' ]; then
        continue
      fi

      # Run each git command in parallel subshells because git can be slow.
      local tmpfile0="${tmpdir}/${index}--${branch}-0.tmp"
      local tmpfile1="${tmpdir}/${index}--${branch}-1.tmp"
      (
        local behind="$(_gitbehind $branch $upstream)"
        local tracks=""

        if [ "$upstream" != "" ] && [ "$upstream" != "trunk" ]; then
          tracks="$upstream"
        fi

        local status=""
        if [ "$behind" != "" ] || [ "$tracks" != "" ]; then
          status=" ${GRAY}["
          if [ "$tracks" != "" ]; then
            status="${status}tracks ${YELLOW}$tracks${GRAY}"
            if [ "$behind" != "" ]; then
              status="$status, "
            fi
          fi
          if [ "$behind" != "" ]; then
            status="$status$behind"
          fi
          status="$status${GRAY}]${AUTO}"
        fi

        # Show an asterisk beside the active branch.
        if [ "$active" = "$branch" ]; then
          printf '* ' > $tmpfile0
        else
          printf '  ' > $tmpfile0
        fi

        echo -e "${YELLOW}$branch${AUTO}$status" >> $tmpfile0
      ) &
      (
        local commits=`git log ${flags} --pretty=format:'%Cred%h%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit ${upstream}..${branch}`

        # Hide commits if there are more than 100 to show.
        if [ `echo "$commits" | wc -l` -gt 100 ]; then
          commits="${GRAY}(More than 100 commits.)${AUTO}"
        fi

        if [ -n "$commits" ]; then
          echo -e "$commits" | sed "s/^/    /" >> $tmpfile1
        fi
      ) &

      index=$(expr $index + 1)
    done

    wait
  ) 2>/dev/null

  for file in `/bin/ls $tmpdir`; do
    cat $tmpdir/$file
  done
  rm -r $tmpdir
}

# Internal, usage: _gitbr
# Prints the name of the active branch.
function _gitbr {
  git branch 2> /dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/'
}

# Internal, usage: _gitbehind <branch> <upstream>
# Prints "behind _" as appropriate.
function _gitbehind {
  local behind=`git rev-list "$1..$2" | wc -l`

  test $[ $behind ] -gt 0 && {
    printf "behind $behind"
  }
}

# Usage: gup <branch1> ... <branchN>
# Fetches trunk, then checks out each branch (in order) and rebases them to the
# respective upstream. If any conflicts are encountered, the rebase will be
# aborted and execution will continue with the next branch.
function gup {
  local GRAY="\033[1;30m"
  local YELLOW="\033[1;33m"
  local RED="\033[0;31m"
  local AUTO="\033[0m"

  function _info {
    echo -e "${GRAY}[gup]${AUTO} $@"
  }
  function _error {
    echo -e "${RED}[gup]${AUTO} $@"
  }

  local branches="$@"

  _gitrebasing
  if [ ! $? ]; then
    _error "You are already in the middle of a rebase!"
    return 1
  fi

  local current_branch="$(_gitbr)"
  local current_hash="$(git rev-parse --short HEAD)"
  local current="${YELLOW}${current_hash}${AUTO}"
  if [ "$current" != "(no branch)" ]; then
    current="${YELLOW}${current_branch}${AUTO} (${current})"
  fi
  _info "Starting from: ${current}"

  if $GIT_REFETCH; then
    _info "Fetching from trunk."
    git fetch --quiet origin
  fi

  for branch in $branches; do
    local branch_name="${YELLOW}${branch}${AUTO}"

    _info "Checking out ${branch_name}."
    git co --quiet $branch 2>/dev/null
    if [ "$?" != "0" ]; then
      _error "Unable to checkout ${branch_name}."
      return 1;
    fi

    local branch_hash="${YELLOW}$(git rev-parse --short HEAD)${AUTO}"
    _info "Rebasing ${branch_name} (${branch_hash}) onto its upstream."
    local upstream="$(_gitupstream $branch)"
    local rebasing="$(git rebase $upstream > /dev/null 2>&1; echo $?)"
    if [ "$rebasing" != "0" ]; then
      _error "Aborting rebase on ${branch_name} (merge conflict)."
      git rebase --abort
    else
      _info "Successfully rebased ${branch_name}."
    fi
  done

  _info "Done."
}

# Internal usage: _gitupstream <branch>
# Prints the upstream branch name, or 'trunk' if none exist.
function _gitupstream {
  local up="$(git name-rev $1@{upstream} 2> /dev/null | awk "{ print \$2 }")"
  if [ "$up" == "" ]; then
    printf "trunk"
  else
    printf "$up"
  fi
}

# Internal usage: _gitrebasing
# Returns whether a rebase is currently in progress.
function _gitrebasing {
  local gitdir="$(git rev-parse --git-dir)"
  test -d "$gitdir/rebase-merge" -o -d "$gitdir/rebase-apply"
}

# Internal usage: _gitroot
# Prints the root directory of the current git repository.
function _gitroot {
  git rev-parse --show-toplevel
}

# Usage: gfix
# Repairs a diverged branch. This should be run after `git fetch -f'.
function gfix {
  git rev-list HEAD -1 --grep=git-svn-id | xargs git rebase --onto trunk
}
