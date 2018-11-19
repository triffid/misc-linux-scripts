#!/bin/bash

if [ -z "$HOME" ]
then
	export HOME="$(getent passwd | grep ^$(whoami): | head -n1 | cut -d: -f6)"
fi

SSH_ENV="$HOME/.ssh/agent"

function start_agent {
	/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
	chmod 600 "${SSH_ENV}"
	. "${SSH_ENV}" > /dev/null
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
	. "${SSH_ENV}" > /dev/null
	grep -q 'Name:\s*ssh-agent$' /proc/${SSH_AGENT_PID}/status 2>/dev/null || start_agent;
else
	start_agent;
fi
