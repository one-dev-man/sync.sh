#!/bin/bash

scriptdir () {
  local scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ))")'
  if [[ -L "$(eval echo "$scriptdir/sync.sh")" ]]; then
      scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd ))")'
  fi
  eval echo $scriptdir
}

SCRIPTDIR=$(scriptdir)

# 

if ! [ "$(find /bin/ -maxdepth 1 -type l -name sync.sh -print -quit)" == "" ]; then
    sudo rm /bin/sync.sh
fi
eval sudo ln -s $SCRIPTDIR/sync.sh /bin/sync.sh