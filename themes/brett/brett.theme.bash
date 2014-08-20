#!/usr/bin/env bash
THEME_PROMPT_HOST='\H'
SCM_THEME_PROMPT_DIRTY=' 💢'
SCM_THEME_PROMPT_CLEAN=' 🌱'
SCM_THEME_PROMPT_PREFIX='[ '
SCM_THEME_PROMPT_SUFFIX='  ] '
export LS_COLORS='di=92:fi=0:ln=94:pi=36:so=36:bd=36:cd=95:or=34:mi=0:ex=31:*.log=1;30:*.txt=34:*.mmd=34:*.markdown=34:*.md=01;34:*.scpt=7:*.rb=35:*.tgz=93:*.gz=93:*.zip=93:*.dmg=93:*.pkg=93:*.taskpaper=95;1:*.pdf=96:*.jpg=33:*.png=33:*.gif=33:*.svg=33'

GIT_THEME_PROMPT_DIRTY=' 💢'
GIT_THEME_PROMPT_CLEAN=' 🌱'
GIT_THEME_PROMPT_PREFIX='[ '
GIT_THEME_PROMPT_SUFFIX='  ] '

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

fmt_time () { #format time just the way I likes it
  if [ `date +%p` = "PM" ]; then
    meridiem="pm"
  else
    meridiem="am"
  fi
  date +"%l:%M$meridiem"|sed 's/ //g'
}

pwdtail () { #returns the last 2 fields of the working directory
  pwd|awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

tm-session() {
  local sessionname
  if [[ -n $TMUX ]]; then
    sessionname=`tmux list-sessions | grep attached | awk -F: '{print $1}'`
    echo -n $sessionname
  fi
}

tm-window() {
  local winname
  if [[ -n $TMUX ]]; then
    winname=`tmux list-windows | grep --color=never -E '^\d+: (.*)\*'| awk '{ print $2 }' | tr -d '*'`
    echo -n $winname
  fi
}

function bt_last_status_prompt {
    if [[ "$1" -eq 0 ]]; then
        LAST_STATUS_PROMPT=""
    else
        LAST_STATUS_PROMPT="${red}->(${1})${reset_color} "
    fi
}

prompt_command () {
  local LAST_STATUS="$?"
  local TIME=`fmt_time` # format time for prompt string
  local gray="\[\033[0;37m\]"

  # if [[ -n $TMUX ]]; then # we're in a tmux session
  #   TMUX_INFO=" (${GREEN}$(tm-session)${DKGRAY}:${MAGENTA}$(tm-window)${DEFAULT})"
  # fi

  if [ -n "$SSH_CLIENT$SSH2_CLIENT$SSH_TTY" ]; then # if we're coming in over SSH
    hostcolor=${red}
    host="${BCYAN}@${hostcolor}\h"
  else
    host=""
    hostcolor=${bold_cyan}
  fi

  bt_last_status_prompt $LAST_STATUS
  history -a
  history -c
  history -r
  export PS1="${TITLEBAR}${cyan}[ ${hostcolor}\u${host}${bold_white} ${TIME}${TMUX_INFO} ${cyan}]:${gray} \w\n${green}$(scm_prompt_info)${LAST_STATUS_PROMPT}${blue}\$ ${reset_color}"
  # [[ $(history 1|sed -e "s/^[ ]*[0-9]*[ ]*//") =~ ^((cd|z|j|g)([ ]|$)) ]] && na
}

PROMPT_COMMAND=prompt_command;
