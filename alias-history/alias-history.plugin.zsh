setopt interactivecomments

function zshaddhistory() {
  local -a cmd
  local -a originalcmd
  local i
  cmd=(${(z)1})
  originalcmd=(${(z)1})



  if (( $#cmd )); then
    cmd[1]=${aliases[$cmd[1]]:-$cmd[1]}
    for (( i = 2; i < $#cmd ; i++ )); do
      if [[ $cmd[$((i-1))] == \; ]] then
        cmd[$i]=${aliases[$cmd[$i]]:-$cmd[$i]}
      fi
    done
    # (z) adds a trailing ; remove that
    cmd[$#cmd]=()
    originalcmd[$#originalcmd]=()

    for (( i = 0; i < $(($#cmd + 1)) ; i++)) do
      if [[ $cmd[$i] != $originalcmd[$i] ]] then
        cmd+=(\# ${1%%$'\n'})
        # write to usual history location
        print -sr -- $cmd
        print -sr -- $originalcmd
        return 1
      fi
    done
    
    print -sr -- $cmd

  fi
  return 1
}
