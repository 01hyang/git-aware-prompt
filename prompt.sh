function strstr() {
  # If compare with "", option --quiet would not work
  # that is,
  #     echo $1 | grep $2
  # for
  #     if [[ $(strstr ${curr} ${_e}) != "" ]]; then
  echo $1 | grep --quiet $2
}

function test_git_check() {
# local e_opt=kernel
  local exception_list=(${e_opt} android)
  local curr=$(pwd | tr '[:upper:]' '[:lower:]')

#  curr=$(basename ${curr,,})
#  if [[ ${exception_list[@]} =~ ${curr} ]]; then
#    return 0
#  else
#    return 1
#  fi

  for _e in ${exception_list[@]}; do
    if $(strstr ${curr} ${_e}); then
#     echo "Match"
      return 0
    fi
  done
  return 1
}


find_git_branch() {
  test_git_check
  local skip=$?
  if [[ skip -eq 0 ]]; then
#   echo "Skip find_git_branch"
    git_branch=""
    return
  fi

  # Based on: http://stackoverflow.com/a/13003854/170413
  local branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
    if [[ "$branch" == "HEAD" ]]; then
      branch='detached*'
    fi
    git_branch="($branch)"
  else
    git_branch=""
  fi
}

find_git_dirty() {
  test_git_check
  local skip=$?
  if [[ skip -eq 0 ]]; then
#   echo "Skip find_git_dirty"
    git_dirty=''
    return
  fi

  local status=$(git status --porcelain 2> /dev/null)
  if [[ "$status" != "" ]]; then
    git_dirty='*'
  else
    git_dirty=''
  fi
}

PROMPT_COMMAND="find_git_branch; find_git_dirty; $PROMPT_COMMAND"

# Default Git enabled prompt with dirty state
# export PS1="\u@\h \w \[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\]\$ "

# Another variant:
# export PS1="\[$bldgrn\]\u@\h\[$txtrst\] \w \[$bldylw\]\$git_branch\[$txtcyn\]\$git_dirty\[$txtrst\]\$ "

# Default Git enabled root prompt (for use with "sudo -s")
# export SUDO_PS1="\[$bakred\]\u@\h\[$txtrst\] \w\$ "
