# shell-cloud-run

An example deployment of [Cased Shell](https://cased.com) on Google Cloud Run.

## Setup

```
gcloud iam service-accounts create cased-shell

gcloud run deploy cased-shell \
  --region=us-central1 \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --source=. \
  --max-instances=1 \
  --timeout=59m59s \
  --set-env-vars="CASED_SHELL_SECRET=default"
```

* Obtain the URL of the deployed service
* Create a Cased Shell instance with a matching hostname at https://app.cased.com
* Obtain the value of CASED_SHELL_SECRET from the settings tab
* Enable Certificate Authentication on the settings tab

## Create `.env`

```
echo "CASED_SHELL_HOSTNAME=cased-shell-EXAMPLE-uc.a.run.app" >> .env
echo "CASED_SHELL_SECRET=YOUR_SECRET_000000000000" >> .env
```

### Deploy the authenticated shell

```
gcloud run deploy cased-shell \
  --region=us-central1 \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --source=. \
  --max-instances=1 \
  --timeout=59m59s \
  --set-env-vars="$(cat .env | tr '\n' ',')"
```
## Connecting to resources in a VPC

### Create a VPC:

```
gcloud compute networks create cased-shell-example-vpc --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional
gcloud compute firewall-rules create allow-ssh --network cased-shell-example-vpc --allow tcp:22,icmp
```

And an instance within the VPC:

```
gcloud compute instances create example-bastion --image-project debian-cloud --image-family debian-11 --zone=us-central1-a --network=cased-shell-example-vpc
```

Update `jump.yaml` to point it to the internal IP address of the bastion node.

> Note: Stay tuned for support for auto-detecting Google Cloud Compute instances in the near future!

### Configure the bastion instance

Create a user on the instance and add the SSH certificate to the user's authorized_keys file:

```
gcloud compute ssh cased-shell@example-bastion --command="curl https://<Cased Shell Hostname>/.ssh/authorized_keys >> ~/.ssh/authorized_keys"
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
  --max-instances=1 \
  --timeout=59m59s \
  --vpc-connector=cased-shell-vpc-connector \
  --set-env-vars="$(cat .env | tr '\n' ',')"
```

### Connect to Google Cloud OAuth to enable Cloudshell integration

* Visit the Cloud Console: https://console.cloud.google.com
* Select or create a project from the top right project dropdown
* In the project Dashboard center pane, choose "API Manager"
* In the left Nav pane, choose "Credentials"
* In the center pane, choose "OAuth consent screen" tab. Fill in "Product name shown to users" and hit save.
* In the center pane, choose "Credentials" tab.
  * Open the "New credentials" drop down
  * Choose "OAuth client ID"
  * Choose "Web application"
  * Application name is freeform, choose something appropriate
  * Authorized JavaScript origins can be blank
  * Authorized redirect URIs is https://$CASED_SHELL_HOSTNAME/oauth/auth/callback
* Choose "Create"
* Add Client ID and Client Secret to `.env`:

```
echo "GCLOUD_OAUTH_CLIENT_ID=EXAMPLE_1234" >> .env
echo "GCLOUD_OAUTH_CLIENT_SECRET=YOUR_SECRET_000000000000" >> .env
```

* Generate cookie encryption tokens and add to `.env`:

```
echo "COOKIE_SECRET=$(openssl rand -hex 32)" >> .env
echo "COOKIE_ENCRYPT=$(openssl rand -hex 16)" >> .env
```

Now deploy again:

```
gcloud run deploy cased-shell \
  --source=. \
  --max-instances=1 \
  --timeout=59m59s \
  --region=us-central1 \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --vpc-connector=cased-shell-vpc-connector \
  --set-env-vars="$(cat .env | tr '\n' ',')"
```

## Setup a Cloud Storage Bucket

[Create a bucket](https://cloud.google.com/storage/docs/creating-buckets#create_a_new_bucket):

```
gsutil mb gs://cased-shell-EXAMPLE
```

Grant the service account the objectAdmin role on the bucket:

```
gsutil iam ch \
  serviceAccount:cased-shell@EXAMPLE.iam.gserviceaccount.com:objectAdmin,legacyBucketReader \
  gs://cased-shell-EXAMPLE
```

Add the bucket name to the environment:

```
echo "STORAGE_GOOGLE_CLOUD_BUCKET=cased-shell-EXAMPLE" >> .env
echo "STORAGE_BACKEND=gcs" >> .env
```

Now deploy again:

```
gcloud run deploy cased-shell \
  --source=. \
  --max-instances=1 \
  --timeout=59m59s \
  --region=us-central1 \
  --service-account=cased-shell \
  --port=8888 \
  --allow-unauthenticated \
  --vpc-connector=cased-shell-vpc-connector \
  --set-env-vars="$(cat .env | tr '\n' ',')"
```

## Viewing logs

Cloud Run logs are visible in the console at:

https://console.cloud.google.com/run/detail/<region>/<service>/logs

See https://cloud.google.com/run/docs/logging for more information