#!/usr/bin/env bash
THEME_PROMPT_HOST='\H'
SCM_THEME_PROMPT_DIRTY='💢'
SCM_THEME_PROMPT_CLEAN='🌱'
SCM_THEME_PROMPT_PREFIX='[ '
SCM_THEME_PROMPT_SUFFIX='  ] '
export LS_COLORS='di=92:fi=0:ln=94:pi=36:so=36:bd=36:cd=95:or=34:mi=0:ex=31:*.log=1;30:*.txt=34:*.mmd=34:*.markdown=34:*.md=01;34:*.scpt=7:*.rb=35:*.tgz=93:*.gz=93:*.zip=93:*.dmg=93:*.pkg=93:*.taskpaper=95;1:*.pdf=96:*.jpg=33:*.png=33:*.gif=33:*.svg=33'

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

fmt_time () { #format time just the way I likes it
  if [ `date +%p` = "PM" ]; then
    meridiem="pm"
  else
    meridiem="am"
  fi
  date +"%l:%M:%S$meridiem"|sed 's/ //g'
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


prompt_command () {
  if [ $? -eq 0 ]; then # set an error string for the prompt, if applicable
    ERRPROMPT=" "
  else
    ERRPROMPT='->($?) '
  fi
  if [ "\$(type -t __git_ps1)" ]; then # if we're in a Git repo, show current branch
      BRANCH="\$(__git_ps1 '[ %s ] ')"
  fi
  local TIME=`fmt_time` # format time for prompt string
  # local LOAD=`uptime|awk '{min=NF-2;print $min}'`
  local GREEN="\[\033[0;32m\]"
  local CYAN="\[\033[0;36m\]"
  local BCYAN="\[\033[1;36m\]"
  local BLUE="\[\033[0;34m\]"
  local GRAY="\[\033[0;37m\]"
  local DKGRAY="\[\033[1;30m\]"
  local WHITE="\[\033[1;37m\]"
  local RED="\[\033[0;31m\]"
  local MAGENTA="\[\033[0;35m\]"
  local BLACK="\[\033[0;30m\]"
  # return color to Terminal setting for text color
  local DEFAULT="\[\033[0;39m\]"
  # set the titlebar to the last 2 fields of pwd

  # if [[ -n $TMUX ]]; then # we're in a tmux session
  #   TMUX_INFO=" (${GREEN}$(tm-session)${DKGRAY}:${MAGENTA}$(tm-window)${DEFAULT})"
  # fi

  if [ -n "$SSH_CLIENT$SSH2_CLIENT$SSH_TTY" ]; then # if we're coming in over SSH
    hostcolor=${RED}
    host="${BCYAN}@${hostcolor}\h"
  else
    host=""
    hostcolor=${BCYAN}
  fi
  export PS1="${TITLEBAR}${CYAN}[ ${hostcolor}\u${host}${WHITE} ${TIME}${TMUX_INFO} ${CYAN}]${GRAY}\w\n${GREEN}${BRANCH}${DEFAULT}$ "
  # [[ $(history 1|sed -e "s/^[ ]*[0-9]*[ ]*//") =~ ^((cd|z|j|g)([ ]|$)) ]] && na
}

PROMPT_COMMAND=prompt_command;
