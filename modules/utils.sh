utils.scriptdir () {
  local scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ))")'
  if [[ -L "$(eval echo "$scriptdir/sync.sh")" ]]; then
      scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd ))")'
  fi
  eval echo $scriptdir
}

# 

utils.ansicolor () {
  local r="$@""§r"
  r=${r//§4/\\u001b[31m} # DARK_RED
  r=${r//§c/\\u001b[91m} # RED
  r=${r//§6/\\u001b[33m} # GOLD
  r=${r//§e/\\u001b[93m} # YELLOW
  r=${r//§2/\\u001b[32m} # DARK_GREEN
  r=${r//§a/\\u001b[92m} # GREEN
  r=${r//§b/\\u001b[96m} # AQUA
  r=${r//§3/\\u001b[36m} # DARK_AQUA
  r=${r//§1/\\u001b[34m} # DARK_BLUE
  r=${r//§9/\\u001b[94m} # BLUE
  r=${r//§d/\\u001b[95m} # LIGHT_PURPLE
  r=${r//§5/\\u001b[35m} # DARK_PURPLE
  r=${r//§f/\\u001b[97m} # WHITE
  r=${r//§7/\\u001b[37m} # GRAY
  r=${r//§8/\\u001b[90m} # DARK_GRAY
  r=${r//§0/\\u001b[30m} # BLACK
  r=${r//§r/\\u001b[0m} # RESET
  r=${r//§l/\\u001b[1m} # BOLD
  r=${r//§o/\\u001b[3m} # ITALIC
  r=${r//§n/\\u001b[4m} # UNDERLINED
  echo "$r"
}

# 

utils.print () {
  local prefix="$1"
  local msg="$2"
  printf "$(utils.ansicolor "§7[§async.sh§7 - $prefix§7]§r $msg")\n"
}

utils.info () {
  local msg="$@"
  utils.print "§9info" "$msg"
}

utils.warn () {
  local msg="$@"
  utils.print "§6warning" "§6$msg"
}

utils.error () {
  local msg="$@"
  utils.print "§4error" "§4$msg"
}

# 

utils.nowms () {
  echo $(($(date +%s%N)/1000000))
}

# 

utils.fileExists () {
  local filename="$1"
  local exists=$(find ./ -maxdepth 1 -type f -wholename "$filename" -print -quit)
  if [ "$exists" == "" ]; then
    true
  else
    false
  fi
}

# 

utils.destUser () {
  local dest="$@"
  if [ "${dest//@/_}" == "$dest" ]; then
    echo ""
  elif [ "${dest//:/_}" == "$dest" ]; then
    echo ""
  else
    echo ${dest/@*/}
  fi
}

utils.destHostname () {
  local dest="$@"
  if [ "${dest//@/_}" == "$dest" ]; then
    echo ""
  elif [ "${dest//:/_}" == "$dest" ]; then
    echo ""
  else
    h=${dest/*@/}
    echo ${h/:*/}
  fi
}

utils.destHost () {
  local params="$@"
  echo $(utils.destUser $params)@$(utils.destHostname $params)
}

utils.destPath () {
  local dest="$@"
  if [ "${dest//@/_}" == "$dest" ]; then
    echo $dest
  elif [ "${dest//:/_}" == "$dest" ]; then
    echo "~"
  else
    echo ${dest/*:/}
  fi
}

# 

utils.taskvalue () {
  local taskname="$1"
  eval echo \$TASK_${taskname^^}
}