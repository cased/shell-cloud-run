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

let CLOUDSHELL_PORT=PORT+1 ;
export CASED_SHELL_OAUTH_UPSTREAM=localhost:$CLOUDSHELL_PORT

echo "starting ssh server"
PORT=$CLOUDSHELL_PORT /bin/ssh-oauth-handlers cloudshell https://$CASED_SHELL_HOSTNAME default &

ONCE=true /bin/jump /jump.yml /tmp/jump.json
jq --arg placeholder \$CLOUDSHELL_PORT --arg port $CLOUDSHELL_PORT \
  '.prompts | map((select(.port == $placeholder) | .port) |= $port) | { prompts: .}' \
    /tmp/jump.json > /tmp/prompts.json

export CASED_SHELL_HOST_FILE=/tmp/prompts.json

python -u run.py --logging=$CASED_SHELL_LOG_LEVEL &
ps axjf
wait -n
