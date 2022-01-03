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

echo "parsing jump config"
ONCE=true /bin/jump /jump.yml /tmp/jump.json

export CASED_SHELL_HOST_FILE=/tmp/jump.json

echo "starting cased shell server"
exec python -u run.py --logging=$CASED_SHELL_LOG_LEVEL
