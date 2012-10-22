#!/bin/sh
# This function performs app completion based on known applications
# Originally by Kim Holburn http://www.holburn.net/
# Modified by Brett Terpstra because it wasn't working on 10.6.
# Added case insensitivity and LC_ALL='C' because unicode chars were breaking it.
# Added 'o' to complete because I alias o to "open -a"
# Added geticon for geticon() function in .bash_profile

export appslist=~/.apps.list

_make_app_list () {
  local LC_ALL='C'
  mdfind -onlyin /Applications -onlyin ~/Applications -onlyin /Developer "kMDItemContentType == 'com.apple.application-*'" | \
  while read ; do
     echo "${REPLY##*/}"
  done |grep -vi huey|sort -i > "$appslist"
}

_apple_open ()
{
  local cur prev
  local LC_ALL='C'
  # renew appslist if it's older than a day
  if ! /usr/bin/perl -e '
    my $ARGV = $ARGV[0];
    if (-e $ARGV) { if (time - (stat $ARGV)[9] <= 86400) { exit (0); } }
    exit 1;
  ' "$appslist" ; then
    _make_app_list
  fi

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  # do not attempt completion if we're specifying an option
  [[ "$cur" == -* ]] && return 0

  if [[ "$prev" == '-a' || "$prev" == 'o' || "$prev" == 'geticon' || "$prev" == 'bid' ]]; then

    # If we have an appslist
    if [ -s "$appslist" -a -r "$appslist" ]; then
      # Escape dots in paths for grep
      cur=${cur//\./\\\.}

      local IFS="
"
      COMPREPLY=( $( grep -i "^$cur" "$appslist" | sed -e 's/ /\\ /g' ) )

    fi
  fi

  return 0
}

complete -o bashdefault -o default -o nospace -F _apple_open open 2>/dev/null || complete -o default -o nospace -F _apple_open open
complete -o bashdefault -o default -o nospace -F _apple_open o 2>/dev/null || complete -o default -o nospace -F _apple_open o
complete -o bashdefault -o default -o nospace -F _apple_open geticon 2>/dev/null || complete -o default -o nospace -F _apple_open geticon
complete -o bashdefault -o default -o nospace -F _apple_open bid 2>/dev/null || complete -o default -o nospace -F _apple_open bid
# complete -o bashdefault -o default -o nospace -F _apple_open oft 2>/dev/null || complete -o default -o nospace -F _apple_open oft

_complete_running_apps ()
{
  local cur prev
  local LC_ALL='C'

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  # do not attempt completion if we're specifying an option
  [[ "$cur" == -* ]] && return 0

  # Escape dots in paths for grep
  cur=${cur//\./\\\.}

  local IFS="
"
  COMPREPLY=( $( echo "$(osascript -e "set AppleScript's text item delimiters to \"\n\"" -e "tell application \"System Events\" to return (displayed name of every application process whose (background only is false and displayed name is not \"Finder\")) as text" 2>/dev/null)"|grep -i "^$cur" | sed -e 's/ /\\ /g' ) )

  return 0
}

_complete_running_processes ()
{
    local cur prev
    local LC_ALL='C'

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    # do not attempt completion if we're specifying an option
    [[ "$cur" == -* ]] && return 0

    # Escape dots in paths for grep
    cur=${cur//\./\\\.}

    local IFS="
"
    COMPREPLY=( $(ps axc|awk '{ print $5 }'|sort -u|grep -v "^[\-\(]"|grep -i "^$cur") )

    return 0
}

complete -o bashdefault -o default -o nospace -F _complete_running_apps quit 2>/dev/null || complete -o default -o nospace -F _complete_running_apps quit
complete -o bashdefault -o default -o nospace -F _complete_running_processes killall 2>/dev/null || complete -o default -o nospace -F _complete_running_processes killall

_complete_esproj ()
{
    SITESDIR="/Users/`whoami`/Sites"
    local cur prev
    local LC_ALL='C'

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    # do not attempt completion if we're specifying an option
    [[ "$cur" == -* ]] && return 0

    # Escape dots in paths for grep
    cur=${cur//\./\\\.}

    local IFS="
"
    if [[ "$cur" =~ "/" ]]; then
      if [ -d "$cur/" ]; then
        COMPREPLY=( $(find "$cur" -name "*.esproj") )
      else
        COMPREPLY=( $(find "`dirname ${cur%/}`" -type d -d 1 -name "${cur##*/}*") )
      fi
    else
      COMPREPLY=( $(mdfind -onlyin "$SITESDIR" "$cur filename:.esproj") )
    fi

    return 0
}

complete -o bashdefault -o default -o nospace -F _complete_esproj esp 2>/dev/null || complete -o default -o nospace -F _complete_esproj esp

_complete_subl_proj ()
{
    CODEDIR="$HOME/Dropbox/Code"
    local cur prev
    local LC_ALL='C'

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    # do not attempt completion if we're specifying an option
    [[ "$cur" == -* ]] && return 0

    # Escape dots in paths for grep
    cur=${cur//\./\\\.}

    local IFS="
"
    if [[ "$cur" =~ "/" ]]; then
      if [ -d "$cur/" ]; then
        COMPREPLY=( $(find "$cur" -name "*.sublime-project") )
      fi
    else
      COMPREPLY=( $(mdfind -onlyin "$CODEDIR" "$cur filename:.sublime-project") )
    fi

    return 0
}

complete -o bashdefault -o default -o nospace -F _complete_subl_proj subp 2>/dev/null || complete -o default -o nospace -F _complete_subl_proj subp
