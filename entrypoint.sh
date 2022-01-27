#!/bin/bash

if [ -z "$CASED_SHELL_SECRET" ]; then
  echo "CASED_SHELL_SECRET required"
  exit 1
fi

# Configure Cased Shell for Cloud Run
export CASED_SHELL_PORT=$PORT
export CASED_SHELL_TLS=off
export STORAGE_DIR=$HOME/.cased-shell
: ${CASED_SHELL_LOG_LEVEL:="error"}

let SSH_PORT=PORT+1 ;
export CASED_SHELL_OAUTH_UPSTREAM=localhost:$SSH_PORT

echo "starting ssh server"
PORT=$SSH_PORT /bin/ssh-oauth-handlers cloudshell https://$CASED_SHELL_HOSTNAME bash -i &

/bin/jump /jump.yml /tmp/jump.json &

export CASED_SHELL_HOST_FILE=/tmp/jump.json

python -u run.py --logging=$CASED_SHELL_LOG_LEVEL &
ps axjf
wait -n
