autocomplete () {
    local words=()
    for i in "${!COMP_WORDS[@]}"; do
        words[$i]=${COMP_WORDS[$i]}
    done

    local last_word=${words[$((${#words[@]} - 1))]}

    # 

    local PWD=$(printf %q "$(pwd)")
    local CURRENT_CONFIGFILE=$PWD/config.sync.sh

    local tasklist=("init" "sync" "remote" "shell")

    # local p=$(eval echo $CURRENT_CONFIGFILE)
    # if [ $(find "$p" > /dev/null 2>&1 ; echo $?) -eq 0 ]; then
    #     local current_config_content=$(eval printf '"''$(<"'$p'")''"')
    #     local raw_tasklist="$(printf "$current_config_content" | grep ^TASK_)"

    #     for raw_task in $raw_tasklist; do
    #         local task=${raw_task/=*/}
    #         task=${task/*TASK_/}
    #         task=${task,,}
            
    #         tasklist[${#tasklist[@]}]="$task"
    #     done
    # fi

    # 

    COMPREPLY=($(eval 'compgen -W "'${tasklist[@]}'" "'$last_word'"'))
}

complete -F autocomplete sync.sh