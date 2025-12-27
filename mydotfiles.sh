#!/usr/bin/bash

# rsync     To sincronize with arguments:
#    -h     Zise human readable ex: K, KB, MB, GB
#    -n     Dry action, run with no changes made
#    -r     Recursive
#    -t     Preserve modification times
#    --delete Delete destination if exist

# ls, rm    To list and delete
# realpath  To get real path
# basename
# basedir
# which     To check if exist command

# De estos comando cuales pertenecen a las core utils: rsync, ls, rm, realpath, basename, dirname, which

#####################################################################
# VARIABLES
#####################################################################

# Color
CN='\e[1;30m'; CR='\e[31m'; CG='\e[32m'; CY='\e[33m'
CB='\e[34m'; CC='\e[36m'; NC='\e[m'

# Directorys
DF_DIR="$HOME/.mydotfiles"
BACKUP_DIR="$DF_DIR/backup"
LIST_DF="$DF_DIR/list_dotfiles"
DB="$DF_DIR/db_dotfiles"


# Help
 HELP_DELETE="${CG}$0 -d <dotfiles>$NC"
 HELP_CHECK="${CG}$0 -c <dotfiles|database>$NC"
   HELP_FILE="${CG}$0 -f <dotfiles>$NC"
 HELP_IMPORT="${CG}$0 -i <dotfiles_path>$NC"
HELP_RESTORE="
${CG}$0 -r <dotfiles_imported>$NC \t\t\t-> Path to default dotfiles
${CG}$0 -r <dotfiles_imported> <dotfiles_dst>$NC \t-> Specific path to restaure"

HELP="
 =================================================
 Script to save dotfiles file
 =================================================
 ${CG}-d, --delete$NC  \t Remove dotfiles
 ${CG}-c, --check$NC  \t 'dotfiles' or 'database' is passed depending on what you 
        \t want to check.
 ${CG}-f, --file$NC  \t Import from list in a file, if not specified
        \t it will be used: /home/user/.mydotfiles/list_dotfile
 ${CG}-h, --help$NC    \t Display this help and exit
 ${CG}-i, --import$NC  \t Import dotfiles
 ${CG}-l, --list$NC    \t List dotfiles
 ${CG}-r, --restore$NC \t Restore dotfiles, if the destination path is not specified,
         \t it is restored to the default path of dotfiles
"

# echo "Import from list in a file, if not specified it will be used: /home/user/.mydotfiles/list_dotfile"
# echo "Import desde list in a file, if not specified it will be used: /home/user/.mydotfiles/list_dotfile"

MSG_NOT_EXIST="Incorrect arguments or the file or directory does not exist."

# Arguments
ARGS=(
    -d --delete
    -c --check
    -f --file
    -h --help
    -i --import
    -l --list
    -r --restore
    )

# echo -e "-> ${CY}No. args:$# 1=$1 2=$2 3=$3 $NC"

#####################################################################
# FUNCTIONS
#####################################################################



#####################################################################
# FUNCTIONS
#####################################################################


#####################################################################
# RUN
#####################################################################


# Crete initial folder and file
if ! [[ -e $BACKUP_DIR ]]; then
    mkdir -p $BACKUP_DIR

    echo "This repository contains my dotfiles in folder $BACKUP_DIR" > $DF_DIR/README.md

    echo -e "# List of paths to files and directories you want to save, one per line, example: \n# /home/user/.bashrc" > "$DF_DIR/list_dotfiles"

    echo -e "# Archive with the DB of the saved files."
fi


# Iterate over $ARGS and compare $1 with arguments
AGRS_FOUND=0
for i in "${ARGS[@]}"; do
    if [[ $1 == "$i" ]]; then
        AGRS_FOUND=1
        break
    fi
done

# Check if arguments exist
if [[ $AGRS_FOUND -eq 0 ]]; then
    echo -e "${CR}ERROR:${NC} The $CG$1$NC argument does not exist"
    echo -e "$HELP"
    exit 1
fi

# -----------------------------------------------
# Arguments -d, --delete
# -----------------------------------------------

if [[ $1 == "-d" || $1 == "--delete" ]]; then
    
    REALNAME_DF="$(cut -d '_' -f 2 <<< $2)"
    
    if ! [[ $# == 2 || ! -e $BACKUP_DIR/$REALNAME_DF ]]; then
        echo -e "${CB}INFO:$NC $MSG_NOT_EXIST"
        echo -e "$HELP_DELETE"
        exit 1
    fi

    # Delete dotfiles
    rm -r "$BACKUP_DIR/$REALNAME_DF"
    CODE=$?

    if [[ $CODE -eq 0 ]]; then 
        # deleting record
        sed -i "\|'$2'|d" "$DB"
        # Info
        echo -e "${CB} -> ${CG}Removed ${CY}$2${NC}"
        exit 0
    fi

fi

# -----------------------------------------------
# Arguments -c, --check
# -----------------------------------------------

# Function to check DOTFILES
funCheckDotfile(){
    mapfile -t A_NAME_LS < <(ls -aAx1 $BACKUP_DIR | awk '{print $0}')

    # Array of DOTFILES in BACKUP_DIR
    local A_NAME_DB=()
    while read -r L_NAME_DB _; do A_NAME_DB+=("$L_NAME_DB"); done < "$DB"

    # Clean dotfile BACKUP_DIR if no exist in $DB
    for d in "${A_NAME_LS[@]}"; do
        for r in "${A_NAME_DB[@]}"; do
            if [[ "'df_$d'" == "$r" ]]; then
                DF_EXIST=false
                break
            else
                DF_EXIST=true
            fi
        done

        if $DF_EXIST; then
            # Infinity bucle, question action
            while true; do
                delete(){ if [[ -e "$BACKUP_DIR/$d" ]]; then rm -fr "$BACKUP_DIR/$d"; fi }

                if [[ $RESPONSE == "a" ]]; then
                    echo -e "${CB}->${NC} Deleted dotfile ${CY}$d${NC}"
                    delete; break
                fi

                echo -en "Delete <${CY}$d${NC}> ? ${CG}Y${NC}es, ${CG}A${NC}ll, ${CG}N${NC}o, ${CG}C${NC}ancel: "
                read -r RESPONSE
                RESPONSE="${RESPONSE,,}"
                
                if [[ $RESPONSE == "y" ]]; then
                    echo -e "${CB}->${NC} Deleted dotfile ${CY}$d${NC}"
                    delete; break

                elif [[ $RESPONSE == "a" ]]; then
                    echo -e "${CB}->${NC} Deleted dotfile ${CY}$d${NC}"
                    delete; break

                elif [[ $RESPONSE == "n" ]]; then
                    echo -e "${CB}INFO:${NC} Skipped dotfile ${CY}$d${NC}"
                    break

                elif [[ $RESPONSE == "c" ]]; then
                    echo -e "${CB}INFO:${NC} Canceled actions"
                    exit 0

                else
                    echo -e "${CB}INFO:${NC} Please answer ${CG}Y${NC}, ${CG}A${NC}, ${CG}N${NC} or ${CG}C${NC}."
                fi
            done

        fi
    done
}

funCheckDatabase(){
    mapfile -t A_NAME_LS < <(ls -aAx1 $BACKUP_DIR | awk '{print $0}')

    # Array of DOTFILES in BACKUP_DIR
    local A_NAME_DB=()
    while read -r L_NAME_DB _; do A_NAME_DB+=("$L_NAME_DB"); done < "$DB"

    # Clean record DB if no exist in $BACKUP_DIR
    for r in "${A_NAME_DB[@]}"; do
        for d in "${A_NAME_LS[@]}"; do
            if [[ $r == "'df_$d'" ]]; then
                DF_EXIST=false
                break
            else
                DF_EXIST=true
            fi
        done

        if [[ $DF_EXIST == true ]]; then
            # Infinity bucle, question action
            while true; do
                delete(){ if [[ -e "$BACKUP_DIR/$d" ]]; then sed -i "\|$r|d" "$DB"; fi }

                # If RESPONSE is equal to a deleting file
                if [[ $RESPONSE == "a" ]]; then
                    echo -e "${CB}->${NC} Deleted record ${CY}$r${NC}"
                    delete; break
                fi


                echo -en "Delete record <${CY}$r${NC}> ? ${CG}Y${NC}es, ${CG}A${NC}ll, ${CG}N${NC}o, ${CG}C${NC}ancel: "
                read -r RESPONSE
                RESPONSE="${RESPONSE,,}"

                if [[ $RESPONSE == "y" ]]; then
                    echo -e "${CB}->${NC} Deleted record ${CY}$r${NC}"
                    delete; break

                elif [[ $RESPONSE == "a" ]]; then
                    echo -e "${CB}->${NC} Deleted record ${CY}$r${NC}"
                    delete; break

                elif [[ $RESPONSE == "n" ]]; then
                    echo -e "${CB}INFO:${NC} Skipped record ${CY}$r${NC}"
                    break

                elif [[ $RESPONSE == "c" ]]; then
                    echo -e "${CB}INFO:${NC} Canceled actions"
                    exit 0

                else
                    echo -e "${CB}INFO:${NC} Please answer ${CG}Y${NC}, ${CG}A${NC}, ${CG}N${NC},${CG}C${NC}."
                fi
            done

        fi
    done
}

if [[ $1 == "-c" || $1 == "--check" ]]; then
    
    if [[ $# == 2 && "$2" == "dotfiles" ]]; then
        funCheckDotfile
        exit 0
    fi


    if [[ $# == 2 && "$2" == "database" ]]; then
        funCheckDatabase
        exit 0
    fi

    echo -e "${CB}INFO:${NC} $MSG_NOT_EXIST \n${HELP_CHECK}"
    exit 1
fi


# -----------------------------------------------
# Arguments -f, --file
# -----------------------------------------------

# Funtion to check if exist file or directori
# Use: funCheckExistPath <path_file_dir>
funCheckExistPath(){
    local L_SOURCE="$1"
    if [[ -e "$L_SOURCE" ]]; then
        echo 0
    else
        echo 1
    fi
}

# Function to importar dotfile
# Use: funImport <path_dotfiles>
# funImport(){
#     rsync -rt --delete $1 $BACKUP_DIR/
#     return 0
# }

# Function to update database
# Use: funUpdateDb <path_dotfiles>
funUpdateDb(){
        local L_NAME_DF="df_$(basename $1)"
        local L_PATH_DF="$(realpath $1)"
        sed -i "\|^'$L_NAME_DF'|d" $DB
        L_RECORD="'$L_NAME_DF' '$L_PATH_DF'"
        echo "'$L_NAME_DF' '$L_PATH_DF'" >> "$DB"
        echo -e "${CB} -> ${CG}Imported ${CY}$L_NAME_DF $L_PATH_DF${NC}"
}





if [[ $1 == "-f" || $1 == "--file" ]]; then

    # If exist of argument $2
    if [[ -n ${2+x} ]]; then
        LIST_DF="$2"
    fi

    # If not exist 
    if ! [[ -e $LIST_DF ]]; then
        echo -e "${CB}INFO:${NC} The file ${CY}$LIST_DF${NC} does not exist."
        exit 1
    fi

    # Iterate over each line of the list_dotfile
    grep -vE '^(#|$)' $LIST_DF \
    | while IFS= read -r line; do

        # Expand variables
        if command -v envsubst >/dev/null 2>&1; then
            line=$(echo "$line" | envsubst) # Secure
        else 
            line=$(eval echo "$line")       # Insecure, run command
        fi
        
        if [[ $(funCheckExistPath "$line") -eq 0 ]]; then

            PATH_DF="$(realpath $line)"
            NAME_DF="$(basename $line)"

            # funImport $line
            # CODE="$?"
            rsync -rt --delete $line $BACKUP_DIR/

            # if [[ $CODE -eq 0 ]]; then
            if [[ $? -eq 0 ]]; then
                funUpdateDb $line
            fi
        else
            echo -e "${CB}INFO:${NC} Not exist: ${CY}$line${NC}"
        fi
    done
fi

# -----------------------------------------------
# Arguments -i, --import
# -----------------------------------------------

if [[ $1 == "-i" || $1 == "--import" ]]; then

    if ! [[ $# == 2 ]] || ! [[ -e $2 ]]; then
    echo -e "${CB}INFO:$NC $MSG_NOT_EXIST"
        echo -e "$HELP_IMPORT"
        exit 1
    fi

    PATH_DF="$(realpath $2)"
    NAME_DF="$(basename $2)"

    funImport $PATH_DF
    CODE="$?"
    
    if [[ $CODE -eq 0 ]]; then
        funUpdateDb $PATH_DF
    fi

fi

# -----------------------------------------------
# Arguments -h, --help, run if no arguments are passed 
# -----------------------------------------------

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo -e "$HELP"
    exit 0
fi


# -----------------------------------------------
# Arguments -l, --list
# -----------------------------------------------

if [[ $1 == "-l" || $1 == "--list" ]]; then

    # With 'rsync'
    # rsync -nh "$DF_DIR/" |awk 'NR==1 {next}
    # {print $5, "|" $2, "|" $3, $4}' \
    # | column -t -N "$(echo -e $CY)NAME,SIZE,MODIFIED $(echo -e $NC)" -s '|'

    # With 'ls'
    ls -lhaAp --time-style=+%Y/%m/%d\ %H:%M "$BACKUP_DIR/" \
    | awk 'NR==1 {next}
    {print $8, "|" $5, "|" $6, $7}' \
    | column -t -N "$(echo -e $CY)NAME,SIZE,MODIFIED $(echo -e $NC)" -s '|'
fi


# -----------------------------------------------
# Arguments --restore
# -----------------------------------------------
# Function to restore
funRestore(){
    # echo -e "$CR $1 -> $2 $NC"
    local L_SRC_PATH="$BACKUP_DIR/$1"
    local L_DST_PATH="$2"
    if [[ -e "$L_SRC_PATH" ]] && [[ -e $L_DST_PATH ]]; then
        rsync -rth "$L_SRC_PATH" "$L_DST_PATH"
        echo -e "$CG->$NC restored ${CY}$L_SRC_PATH ${CB}$L_DST_PATH${NC}"
    fi
}


if [[ $1 == "-r" ]] || [[ $1 == "--restore" ]]; then

    # If arguments is equal 3 and exist dotfiles and dotfiles destination
    if [[ $# -eq 3 ]] && [[ -e "$BACKUP_DIR/$2" ]] && [[ -e "$3" ]] ; then
        funRestore "$2" "$3"
        exit 0
    fi 

    echo -e "${CB}INFO:${NC} $MSG_NOT_EXIST \n${HELP_RESTORE}"
    exit 1
    
fi