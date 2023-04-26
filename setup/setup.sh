#/usr/bin/env bash

source ./modules/utils.sh

SCRIPTDIR=$(eval echo $(utils.scriptdir))

INSTALLSH_PATH=$(printf "%q" "$(realpath "$(eval echo $SCRIPTDIR/../install.sh)")")
UNINSTALLSH_PATH=$(printf "%q" "$(realpath "$(eval echo $SCRIPTDIR/../uninstall.sh)")")

SYNCSH_PATH=$(printf "%q" "$(realpath "$(eval echo $SCRIPTDIR/../sync.sh)")")

SETUP_COMPLETION_PATH=$SCRIPTDIR/autocompletion.sh
AUTOCOMPLETION_IMPORT='source "'"$(eval echo $SETUP_COMPLETION_PATH)"'"'

MAIN_SYMLINK_PATH="/bin/sync.sh"

BASHRC_PATH=~/.bashrc

# 

execute_setup_action () {
    local action=$1
    local begin_message="$2"
    local end_success_message="$3"
    local end_error_message="$4"
    local logging=$5

    if [ "$logging" == "" ]; then
        logging=1
    fi

    # 

    if [ $logging -eq 1 ]; then
        utils.info "$begin_message"
    fi

    $action

    if [ $logging -eq 1 ]; then
        if [ $? -eq 0 ]; then
            utils.info "$end_success_message"
        else
            utils.error "$end_error_message"
        fi
    fi
}

# 

create_main_symbolic_link () {
    action () {
        eval sudo ln -s '"'$(eval echo $SYNCSH_PATH)'"' /bin/sync.sh
    }

    execute_setup_action action \
        'Creating the main symbolic link : §e"'"$(eval echo $MAIN_SYMLINK_PATH)"'"§r -> §a"'"$(eval echo $SYNCSH_PATH)"'"' \
        'Main symbolic link successfully created.' \
        '§4An error happened while creating the main symbolic link.' \
        $1
}

remove_main_symbolic_link () {
    action () {
        sudo rm "$(eval echo $MAIN_SYMLINK_PATH)"
    }

    execute_setup_action action \
        'Removing the main symbolic link §e"'"$(eval echo $MAIN_SYMLINK_PATH)"'"§r...' \
        'Main symbolic link successfully removed.' \
        '§4An error happened while removing the main symbolic link.' \
        $1
}

# 

adding_autocompletion_script_import () {
    action () {
        printf '\n'"$AUTOCOMPLETION_IMPORT"'\n' >> "$(eval echo $BASHRC_PATH)"
    }

    execute_setup_action action \
        'Adding auto-completion script import to §d.bashrc§r (§e"'"$BASHRC_PATH"'")...' \
        'Auto-completion script import successfully added.' \
        '§4An error happened while adding auto-completion script import.' \
        $1
}

removing_autocompletion_script_import () {
    action () {
        local bashrc_content=$(<"$(eval echo $BASHRC_PATH)")
        local import_line_numbers=($(echo "$bashrc_content" | grep -in -e "^$AUTOCOMPLETION_IMPORT" | cut -f1 -d:))
        local import_line_number_count=${#import_line_numbers[@]}

        local i=$(($import_line_number_count-1))
        while [ $i -gt -1 ]; do
            line_number=${import_line_numbers[$i]}
            sed -i "$line_number,$line_number d" "$(eval echo $BASHRC_PATH)"
            sed -i "\$ {/^\$/d}" "$(eval echo $BASHRC_PATH)"
            i=$(($i-1))
        done
    }

    execute_setup_action action \
        'Removing auto-completion script import from §d.bashrc§r (§e"'"$BASHRC_PATH"'")...' \
        'Auto-completion script import successfully removed.' \
        '§4An error happened while removing auto-completion script import.' \
        $1
}

# 