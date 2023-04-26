#!/bin/bash

scriptdir () {
    local scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ))")'
    if [[ -L "$(eval echo "$scriptdir/sync.sh")" ]]; then
        scriptdir='$(printf %q "$(echo $( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd ))")'
    fi
    eval echo $scriptdir
}

SCRIPTDIR=$(scriptdir)
PWD=$(printf %q "$(pwd)")

# 

source "$(eval echo $SCRIPTDIR/modules/utils.sh)"

# 

DEFAULT_CONFIGFILE=$SCRIPTDIR/modules/default/config.sync.sh
CURRENT_CONFIGFILE=$PWD/config.sync.sh

loadconfig () {
    if ! utils.fileExists $(eval echo $CURRENT_CONFIGFILE); then
        utils.info "Configuration file not found. Try to create a new one with §esync.sh init§r !"
        exit 1
    fi

    source "$(eval echo $CURRENT_CONFIGFILE)"

    # 

    local invalid_config=0

    local required_config_keys="SOURCE DESTINATION SSH_KEY"

    for key in $required_config_keys; do
        local value=$(echo $(eval echo \$$(echo $key)))
        if [ "$value" == "" ]; then
            utils.warn "Missing required configuration key §b$key§r"
            invalid_config=1
        fi
    done

    if [ $invalid_config -eq 1 ]; then
        exit 1
    fi
}

# 

__task_init () {
    if utils.fileExists $(eval echo $CURRENT_CONFIGFILE); then
        local invalid_askresp=1

        for arg in "${ARGS[@]}"; do
            case ${arg,,} in
                -f | --force )
                    invalid_askresp=0;;
                * ) ;;
            esac
        done

        if [ $invalid_askresp -eq 1 ]; then
            utils.info "Configuration file already exists. Do you want to reset it ? [§8Y§r/§8n§r] : " $(utils.NONE)
            local askresp=$(utils.input)

            while [ $invalid_askresp -eq 1 ]; do
                case ${askresp,,} in
                    y | yes )
                        invalid_askresp=0;;
                    n | no )
                        exit;;
                    * )
                        utils.warn 'Invalid response, please try again.';;
                esac
            done
        fi
    fi

    utils.info "Initializing §async.sh§r configuration in §e\"$(eval echo $PWD)\"§r..."
    
    cp "$(eval echo $DEFAULT_CONFIGFILE)" "$(eval echo $PWD)"

    utils.info "Done !"
}

# 

__task_sync () {
    utils.info "Synchronizing §e\""$(eval echo $SOURCE)"\"§r to §e\""$DESTINATION"\"§r :"
    echo

    local rsync_command='rsync -Pa -r -e '"'"'ssh -i "'"$SSH_KEY"'"'"'"' '"$RSYNC_ARGS"' "'"$(eval echo $SOURCE)"'" "'"$DESTINATION"'"'

    local time_before=$(utils.nowms)

    eval $rsync_command
    local sync_status=$?

    local time_after=$(utils.nowms)

    echo

    if [ $sync_status -eq 0 ]; then
        utils.info "§aProject successfully synchronized !"
    elif [ $sync_status -eq 1 ]; then
        utils.error "Syntax or usage error."
    elif [ $sync_status -eq 2 ]; then
        utils.error "Protocol incompatibility."
    elif [ $sync_status -eq 3 ]; then
        utils.error "Errors selecting input/output files, dirs."
    elif [ $sync_status -eq 4 ]; then
        utils.error "Requested action not supported."
    elif [ $sync_status -eq 5 ]; then
        utils.error "Error starting client-server protocol."
    elif [ $sync_status -eq 6 ]; then
        utils.error "Daemon unable to append to log-file."
    elif [ $sync_status -eq 10 ]; then
        utils.error "Error in socket I/O."
    elif [ $sync_status -eq 11 ]; then
        utils.error "Error in file I/O."
    elif [ $sync_status -eq 12 ]; then
        utils.error "Error in rsync protocol data stream."
    elif [ $sync_status -eq 13 ]; then
        utils.error "Errors with program diagnostics."
    elif [ $sync_status -eq 14 ]; then
        utils.error "Error in IPC code."
    elif [ $sync_status -eq 20 ]; then
        utils.error "Received SIGUSR1 or SIGINT."
    elif [ $sync_status -eq 21 ]; then
        utils.error "Some error returned by waitpid()."
    elif [ $sync_status -eq 22 ]; then
        utils.error "Error allocating core memory buffers."
    elif [ $sync_status -eq 23 ]; then
        utils.error "Partial transfer due to error."
    elif [ $sync_status -eq 34 ]; then
        utils.error "Partial transfer due to vanished source files."
    elif [ $sync_status -eq 25 ]; then
        utils.error "The --max-delete limit stopped deletions."
    elif [ $sync_status -eq 30 ]; then
        utils.error "Timeout in data send/receive."
    elif [ $sync_status -eq 35 ]; then
        utils.error "Timeout waiting for daemon connection."
    elif [ $sync_status -eq 255 ]; then
        utils.error "Connection refused to §e\"$(utils.destHost $DESTINATION)\"§r"
    else
        utils.error "Internal error."
    fi

    utils.info "Execution time : $(($time_after - $time_before))ms"

    if ! [ $sync_status -eq 0 ]; then
        exit $sync_status
    fi
}

# 

__task_remote () {
    local cmd="$@"

    utils.info "Executing §d\"$cmd\"§r command into destination §e\""$DESTINATION"\"§r :"
    echo

    local destpath=$(utils.destPath $DESTINATION)

    if [ "$(utils.destHost $DESTINATION)" == "" ]; then
        local time_before=$(utils.nowms)
        eval 'cd "'"$(eval echo $destpath)"'" ; $cmd'
        local time_after=$(utils.nowms)
    else
        local time_before=$(utils.nowms)
        eval 'ssh '"$SSH_ARGS"' -T -tt -i "'"$SSH_KEY"'" '"$(utils.destHost $DESTINATION)"' '"'"'cd "$(eval echo "'"$destpath"'")" ; '"$cmd""'"
        local time_after=$(utils.nowms)
    fi

    echo
    utils.info "Execution time : $(($time_after - $time_before))ms"
}

#

remote () {
    __task_remote "$1"
}

#

__task_shell () {
    __task_remote 'exec $SHELL -l'
}

# 

# +----------+
# |   MAIN   |
# +----------+

ARGS=("$@")

main () {
    if [ "${ARGS[0]}" == "" ]; then
        utils.error "Syntax error : sync.sh [init | sync | shell | <taskname>] | sync.sh remote \"<command>\""
        exit 1
    fi

    first_task=1
    use_remote_cmd=0

    for arg in "${ARGS[@]}"; do
        if [ $use_remote_cmd -eq 1 ]; then
            use_remote_cmd=0
            __task_remote "$arg"
        else
            local taskname="${arg,,}"
            taskname="${taskname//_/-}"

            case $taskname in
                -ipath | --installation-path )
                    local installation_path="$(dirname "$(readlink /bin/sync.sh)")"
                    echo "$installation_path"
                    ;;
                -* )
                    ;;
                * )
                    if [ $first_task -eq 0 ]; then
                        echo
                    else
                        first_task=0
                    fi

                    # 

                    if ! [ "$taskname" == "init" ]; then
                        loadconfig
                    fi

                    # 

                    if [[ "$taskname" == "init" || "$taskname" == "sync" || "$taskname" == "shell" ]]; then
                        utils.info "§lTask §b§l${taskname}§r"
                        eval __task_$taskname
                    elif [ "$taskname" == "remote" ]; then
                        use_remote_cmd=1
                    else
                        local taskvalue=$(utils.taskvalue "$taskname")

                        if [ "$taskvalue" == "" ]; then
                            utils.error "§4Task §e$taskname§4 not found."
                            exit 1
                        else
                            utils.info "§lTask §b§l${taskname}§r"
                            eval $taskvalue
                        fi
                    fi
                    ;;
            esac
        fi
    done
}

main