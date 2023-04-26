utils.NONE () {
    echo "__NONE__"
}

# 

utils.scriptdir () {
    local scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ))")'
    if [[ -L "$(eval echo "$scriptdir/sync.sh")" ]]; then
        scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd ))")'
    fi
    echo $scriptdir
}

# 

utils.ansicolor () {
    local r="$1"
    local end="$2"

    if [ "$end" == "" ]; then
        end="§r"
    elif [ "$end" == "$(utils.NONE)" ]; then
        end=""
    fi

    r="$r$end"

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
    local end="$3"

    if [ "$end" == "" ]; then
        end="\n"
    elif [ "$end" == "$(utils.NONE)" ]; then
        end=""
    fi

    printf "$(utils.ansicolor "§7[§async.sh§7 - $prefix§7]§r $msg")$end"
}

utils.info () {
    utils.print "§9info" "$1" "$2"
}

utils.warn () {
    utils.print "§6warning" "§6$1" "$2"
}

utils.error () {
    utils.print "§4error" "§4$1" "$2"
}

# 

utils.nowms () {
    echo $(($(date +%s%N)/1000000))
}

# 

utils.input () {
    local tms="$(utils.nowms)"
    local input_var=input_var_"$tms"

    printf "$(utils.ansicolor "§8" $(utils.NONE))" >&2
    read -p '' $input_var
    printf "$(utils.ansicolor "§r")" >&2

    local _input=$(eval echo \$$input_var)
    eval unset $input_var
    echo $_input
}

# 

utils.requireSudo () {
    local message="$1"

    local attempts=3
    if [ ! "$2" == "" ]; then
        attempts=$(($2))
    fi

    local sudo_return=1
    while [[ $sudo_return -eq 1 && attempts -gt 0 ]]; do
        sudo printf '' > /dev/null 2>&1
        sudo_return=$?

        if [ $sudo_return -eq 1 ]; then
            printf "$(utils.ansicolor "$message")"
        fi

        attempts=$(($attempts-1))
    done

    if [ $sudo_return -eq 1 ]; then
        exit
    fi
}

# 

utils.fileExists () {
    local filepath="$@"
    if [ $(find "$filepath" > /dev/null 2>&1 ; echo $?) -eq 0 ]; then
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
    taskname="${taskname//-/_}"
    local taskvalue=$(eval echo \$TASK_${taskname^^})
    echo "$taskvalue"
}