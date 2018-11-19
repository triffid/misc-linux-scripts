# shopt -s histappend # default

if [ "$EUID" == "0" ]
then
	export PROMPT_COMMAND='if [ $? -eq 0 ]; then /bin/echo -en "\033]2;${HOSTNAME%%.*}\007\e[0G\033k${HOSTNAME%%.*}\033\134\e[0G"; PS1="\[\033[01;31m\]${HOSTNAME%%.*}\[\033[01;32m\] ${PWD/#$HOME/"~"} \\\$ \[\033[00m\]"; else /bin/echo -ne "\033]2;${HOSTNAME%%.*} [$?]\007\e[0G\033k${HOSTNAME%%.*} [$?]\033\134\e[0G"; PS1="\[\a\033[01;31m\]${HOSTNAME%%.*}\[\033[01;33m\] ${PWD/#$HOME/"~"} [\$?] \\\$ \[\033[00m\]"; fi; history -a; history -n'
else
	export PROMPT_COMMAND='if [ $? -eq 0 ]; then /bin/echo -en "\033]2;${USER}@${HOSTNAME%%.*}\007\e[0G\033k${USER}@${HOSTNAME%%.*}\033\134\e[0G"; PS1="\[\033[01;32m\]${USER}@${HOSTNAME%%.*}\[\033[01;34m\] ${PWD/#$HOME/"~"} \\\$ \[\033[00m\]"; else /bin/echo -ne "\033]2;${USER}@${HOSTNAME%%.*} [$?]\007\e[0G\033k${USER}@${HOSTNAME%%.*} [$?]\033\134\e[0G"; PS1="\[\a\033[01;32m\]${USER}@${HOSTNAME%%.*}\[\033[01;33m\] ${PWD/#$HOME/"~"} [\$?] \\\$ \[\033[00m\]"; fi; history -a; history -n'
fi
