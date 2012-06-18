#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

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
  local BLACK="\[\033[0;30m\]"
  # return color to Terminal setting for text color
  local DEFAULT="\[\033[0;39m\]"
  # set the titlebar to the last 2 fields of pwd
  local TITLEBAR='\[\e]2;`pwdtail`\a'
  # export PS1="\[${TITLEBAR}\]${CYAN}[ ${BCYAN}\u${GREEN}@${BCYAN}\
# \h${DKGRAY}(${LOAD}) ${WHITE}${TIME} ${CYAN}]${RED}$ERRPROMPT${GRAY}\
# \w\n${GREEN}${BRANCH}${DEFAULT}$ "
  export PS1="\[${TITLEBAR}\]${CYAN}[ ${BCYAN}\u${GREEN}@${BCYAN}\h${WHITE} ${TIME} ${CYAN}]${GRAY}\w\n${GREEN}${BRANCH}${DEFAULT}$ "
  # [[ $(history 1|sed -e "s/^[ ]*[0-9]*[ ]*//") =~ ^((cd|z|j|g)([ ]|$)) ]] && na
}

PROMPT_COMMAND=prompt_command;
