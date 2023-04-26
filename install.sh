#/usr/bin/env bash

source ./setup/setup.sh
SCRIPTDIR=$(eval echo $(utils.scriptdir))

# 

ARGS=("$@")

main () {
    utils.requireSudo "$(utils.warn 'You must be in sudo to launch the installer program.')\n"

    # 

    on_sigint () {
        if ! [ $logging_quiet -eq 1 ]; then
            echo
            utils.info 'Installation cancelled.'
        fi
        exit
    }

    trap on_sigint SIGINT

    # 

    local logging_quiet=0
    
    for arg in "${ARGS[@]}"; do
        case ${arg,,} in
            -q | --quiet )
                logging_quiet=1;;
            * ) ;;
        esac
    done

    # 

    if [ $(find "$(eval echo $MAIN_SYMLINK_PATH)" -print -quit > /dev/null 2>&1 ; echo $?) -eq 0 ]; then
        local invalid_askresp=1

        for arg in "${ARGS[@]}"; do
            case ${arg,,} in
                -f | --force )
                    invalid_askresp=0;;
                * ) ;;
            esac
        done

        if [ $invalid_askresp -eq 1 ]; then
            utils.info 'Another installation of §async.sh§r has been detected.'
            utils.info 'If you continue, the previous installation will be invalidate.'
            while [ $invalid_askresp -eq 1 ]; do
                utils.info 'Do you want to continue ? [§8Y§r/§8n§r] : ' $(utils.NONE)
                local askresp="$(utils.input)"

                case ${askresp,,} in
                    y | yes )
                        invalid_askresp=0;;
                    n | no )
                        kill -n SIGINT $$;;
                    * )
                        utils.warn 'Invalid response, please try again.';;
                esac
            done

            if ! [ $logging_quiet -eq 1 ]; then
                echo
            fi
        fi
    fi

    # 

    on_sigint () {
        if ! [ $logging_quiet -eq 1 ]; then
            echo
            utils.warn "SIGINT recieved. Installation can't be interrupted."
            echo
        fi
    }

    trap on_sigint SIGINT

    # 

    if [ $(find "$(eval echo $MAIN_SYMLINK_PATH)" -print -quit > /dev/null 2>&1 ; echo $?) -eq 0 ]; then
        "$(eval echo $UNINSTALLSH_PATH)" -f -q
    fi

    # 

    create_main_symbolic_link $((($logging_quiet+1)%2))

    if ! [ $logging_quiet -eq 1 ]; then
        echo
    fi
    
    # 

    adding_autocompletion_script_import $((($logging_quiet+1)%2))


    if ! [ $logging_quiet -eq 1 ]; then
        echo
    fi

    #

    if ! [ $logging_quiet -eq 1 ]; then
        utils.info '§aInstallation finished !'
        utils.info 'Please restart your shell to apply changes.'
    fi
}

main