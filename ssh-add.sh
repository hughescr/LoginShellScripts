#!/usr/bin/env bash
_1PASSWORD_SSH_AGENT="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
if [ -S "${_1PASSWORD_SSH_AGENT}" ]; then
    export SSH_AUTH_SOCK="${_1PASSWORD_SSH_AGENT}"
else
    /usr/bin/ssh-add -l | /usr/bin/grep -q 'The agent has no identities' && /usr/bin/ssh-add --apple-load-keychain
fi
