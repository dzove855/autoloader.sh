# Autoload everything

# each loader will have his custom functions which will improve hotloading

# Set a working dir, this should be in your .bashrc
: ${AUTOLOAD_WORKINGDIR:=$HOME/bash.d}
export AUTOLOAD_WORKINGDIR

_run(){ [[ -d "$AUTOLOAD_WORKINGDIR" ]] && return 0; }

_run && {

# Load directory
_load(){
    local _dir="$1"
    local pattern="$2"
    [[ -z "$_dir" ]] && return 1

    set -o allexport
    for file in "${AUTOLOAD_WORKINGDIR%/}/$_dir/$pattern"*; do
        [[ -s "$file" ]] && {
            case "$_dir" in
                alias)  alias ${file##*/}="$(<$file)"           ;;
                func*)  source "$file"                          ;;
                ### We should remove eval, but currently i don't know how to expand variables inside of file, to keep it correct
                vars)   declare -g "${file##*/}"="$(eval "printf '%s' \"$(<$file)\"")"   ;;
                *)      return 1                        ;;
            esac
        }
    done
    set +o allexport
}

loadAlias(){            _load "alias"           "$1" ; }
loadFunction(){         _load "functions"       "$1" ; }
loadVars(){             _load "vars"            "$1" ; }

# Unset directory
_unset(){
    local _dir="$1"
    local pattern="$2"
    [[ -z "$_dir" ]] && return 1

    [[ -f "${AUTOLOAD_WORKINGDIR%/}/$_dir/$pattern" ]] && {
        case "$_dir" in
            alias)      unalias "$pattern"      ;;
            func*)      unset   "$pattern"      ;;
            vars)       unset   "$pattern"      ;;
            *)          return 1                ;;
        esac
        ! [[ -z "$glob" ]] && rm ${AUTOLOAD_WORKINGDIR%/}/$_dir/$pattern
    }
}

unsetAlias(){           _unset "alias"          "$1" ; }
unsetFunction(){        _unset "functions"      "$1" ; }
unsetVars(){            _unset "vars"           "$1" ; }

# Get directory
_get(){
    local _dir="$1"
    local pattern="$2"
    [[ -z "$_dir" ]] && return 1

    for file in "${AUTOLOAD_WORKINGDIR%/}/$_dir/$pattern"*; do
        [[ -s "$file" ]] && {
            case "$_dir" in
                alias)  alias ${file##*/}               ;;
                func*)  declare -f "${file##*/}"        ;;
                vars)   declare -p "${file##*/}"        ;;
                *)      return 1                        ;;
            esac
        }
    done
}

getAlias(){           _get "alias"          "$1" ; }
getFunction(){        _get "functions"      "$1" ; }
getVars(){            _get "vars"           "$1" ; }

# Run functions and sources
[[ -f "${AUTOLOAD_WORKINGDIR%/}/pre" ]] && source "${AUTOLOAD_WORKINGDIR%/}/pre"
loadVars && loadFunction && loadAlias
[[ -f "${AUTOLOAD_WORKINGDIR%/}/post" ]] && source "${AUTOLOAD_WORKINGDIR%/}/post"

# set prompt correctly
if [[ -f "${AUTOLOAD_WORKINGDIR%/}/prompt/$HOSTNAME" ]]; then
    ps1File="${AUTOLOAD_WORKINGDIR%/}/prompt/$HOSTNAME"
else
    ps1File="${AUTOLOAD_WORKINGDIR%/}/prompt/default"
fi

[[ -s "$ps1File" ]] && { unset tmpPS1; tmpPS1="$(<$ps1File)"; PS1="${tmpPS1%$'\n'} "; }

unset tmpPS1 ps1File
}
unset _run
