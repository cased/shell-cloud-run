# shell-cloud-run

## Setup

```
export PROJECT_NAME=<your GCP project name>
gcloud iam service-accounts create cased-shell

gcloud run deploy cased-shell \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --source=. \
  --set-env-vars="CASED_SHELL_TLS=off,CASED_SHELL_SECRET=default"

# Obtain the URL of the deployed service
# Create a Cased Shell instance with a matching hostname
# Obtain the value of CASED_SHELL_SECRET from the settings tab
# Enable Certificate Authentication on the settings tab

# Re-deploy the authenticated shell with:

gcloud run deploy cased-shell \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --source=. \
  --set-env-vars="CASED_SHELL_HOSTNAME=<your hostname>,CASED_SHELL_TLS=off,CASED_SHELL_SECRET=<your secret>"
```