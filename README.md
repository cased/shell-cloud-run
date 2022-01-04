# shell-cloud-run

An example deployment of [Cased Shell](https://cased.com) on Google Cloud Run.

## Setup

```
gcloud iam service-accounts create cased-shell

gcloud run deploy cased-shell \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --source=. \
  --set-env-vars="CASED_SHELL_SECRET=default"
```

* Obtain the URL of the deployed service
* Create a Cased Shell instance with a matching hostname at https://app.cased.com
* Obtain the value of CASED_SHELL_SECRET from the settings tab
* Enable Certificate Authentication on the settings tab

### Re-deploy the authenticated shell with:

```
gcloud run deploy cased-shell \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --source=. \
  --set-env-vars="CASED_SHELL_HOSTNAME=<your hostname>,CASED_SHELL_SECRET=<your secret>"
```

## Connecting to resources in a VPC

### Create a VPC:

```
gcloud compute networks create cased-shell-example-vpc --project=cased-shell-demos --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional
gcloud compute firewall-rules create allow-ssh --network cased-shell-example-vpc --allow tcp:22,icmp
```

And an instance within it with no public address:

```
gcloud compute instances create example-bastion --image-project debian-cloud --image-family debian-11 --zone=us-central1-a --network=cased-shell-example-vpc
```

### Configure the instance

```
gcloud compute ssh cased-shell@example-bastion
```

* Run the commands from the Settings tab to enable access from all users in your org.
* Add the following to the end of `~/.bashrc`:

```
# Create and enter a temporary directory
dir=$HOME/$$
mkdir -p $dir
cd $dir

# Clean it up when we're done
trap "rm -rf $dir" EXIT

export HOME=$dir

# Login to gcloud when commands are interactive or gcloud related
if [ "$0" == "-bash" ] || grep -q "gcloud" <<< "$BASH_EXECUTION_STRING"; then
  gcloud auth login --brief --no-launch-browser
fi
```

### Create a VPC Connector

> https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#create-connector

```
gcloud compute networks vpc-access connectors create cased-shell-vpc-connector \
--network cased-shell-example-vpc \
--region us-central1 \
--range 10.8.0.0/28
```

### Re-deploy the shell and connect it to your VPC

```
gcloud run deploy cased-shell \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --source=. \
  --set-env-vars="CASED_SHELL_HOSTNAME=<your hostname>,CASED_SHELL_SECRET=<your secret>" \
  --vpc-connector=cased-shell-vpc-connector
```