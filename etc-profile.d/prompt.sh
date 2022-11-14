# shopt -s histappend # default

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- == *i* ]] ; then
	if [ "$EUID" == "0" ]
	then
		export PROMPT_COMMAND="RET=\"\$?\"; IFS='[;' read -p \$'\e[6n' -d R -a pos -rs && [[ \${pos[2]} -gt 1 ]] && echo; "'if [ $RET -eq 0 ]; then /bin/echo -en "\033]2;${HOSTNAME%%.*}\007\e[0G\033k${HOSTNAME%%.*}\033\134\e[0G"; PS1="\[\033[01;31m\]${HOSTNAME%%.*}\[\033[01;32m\] ${PWD/#$HOME/"~"} \\\$ \[\033[00m\]"; else /bin/echo -ne "\033]2;${HOSTNAME%%.*} [$RET]\007\e[0G\033k${HOSTNAME%%.*} [$RET]\033\134\e[0G"; PS1="\[\a\033[01;31m\]${HOSTNAME%%.*}\[\033[01;33m\] ${PWD/#$HOME/"~"} [\$?] \\\$ \[\033[00m\]"; fi; history -a; history -n'
	else
		export PROMPT_COMMAND="RET=\"\$?\"; IFS='[;' read -p \$'\e[6n' -d R -a pos -rs && [[ \${pos[2]} -gt 1 ]] && echo; "'if [ $RET -eq 0 ]; then /bin/echo -en "\033]2;${USER}@${HOSTNAME%%.*}\007\e[0G\033k${USER}@${HOSTNAME%%.*}\033\134\e[0G"; PS1="\[\033[01;32m\]${USER}@${HOSTNAME%%.*}\[\033[01;34m\] ${PWD/#$HOME/"~"} \\\$ \[\033[00m\]"; else /bin/echo -ne "\033]2;${USER}@${HOSTNAME%%.*} [$RET]\007\e[0G\033k${USER}@${HOSTNAME%%.*} [$RET]\033\134\e[0G"; PS1="\[\a\033[01;32m\]${USER}@${HOSTNAME%%.*}\[\033[01;33m\] ${PWD/#$HOME/"~"} [\$?] \\\$ \[\033[00m\]"; fi; history -a; history -n'
	fi
fi
