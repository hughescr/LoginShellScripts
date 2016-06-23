#!/usr/bin/env bash
/usr/bin/ssh-add -l | /usr/bin/grep -q 'The agent has no identities' && /usr/bin/ssh-add -A
