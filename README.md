# gcp-webapp-sqldb-terraform-sensyne
  Sensyne assignment
# Setup gcloud, kubectl and terraform
  Have Google Cloud account and need additional binaries for gcloud CLI, terraform and kubectl. Gcloud deployment differs from Linux distribution and for OSX. Here we will use Linux.

# Deploying terraform
Linux
curl https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.7_linux_amd64.zip \
> terraform_0.11.10_linux_amd64.zip

unzip terraform_0.11.10_linux_amd64.zip -d /usr/local/bin/

# Deploying kubectl
Linux
wget \
https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
# Verification
kubectl version --client

Authenticate to gcloud

gcloud compute regions list

gcloud compute zones list
Follow gcloud init and select default Zone

gcloud init

# Set up environment
export TF_VAR_org_id=YOUR_ORG_ID
export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID
export TF_ADMIN=terraform-admin-demo
export TF_CREDS=~/.config/gcloud/terraform-admin-demo.json

NOTE: value of YOUR_ORG_ID and YOUR_BILLING_ACCOUNT_ID you can find by running

gcloud organizations list
gcloud beta billing accounts list

# Create the Terraform Admin Project
Create a new project and link it to your billing account

 gcloud projects create ${TF_ADMIN} \
 --organization ${TF_VAR_org_id} \
 --set-as-default

 gcloud beta billing projects link ${TF_ADMIN} \
 --billing-account ${TF_VAR_billing_account}

# Create the Terraform service account
Create the service account in the Terraform admin project and download the JSON credentials:

  gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

  gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com

Grant the service account permission to view the Admin Project and manage Cloud Storage

  gcloud projects add-iam-policy-binding ${TF_ADMIN} \
   --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
     --role roles/viewer
 
  gcloud projects add-iam-policy-binding ${TF_ADMIN} \
   --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
    --role roles/storage.admin

Enabled API for newly created projects

gcloud services enable cloudresourcemanager.googleapis.com && \
gcloud services enable cloudbilling.googleapis.com && \
gcloud services enable iam.googleapis.com && \
gcloud services enable compute.googleapis.com && \
gcloud services enable sqladmin.googleapis.com && \
gcloud services enable container.googleapis.com

# Add organization/folder-level permissions
Grant the service account permission to create projects and assign billing accounts

  gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

  gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user

# use newly created Google storage bucket to keep our tfstate files
 bucket name = "Sensyne-admin-demo"
 
# GCP variables used in terraform main.tf file - Refer to "variables.tf"
path = gcp-terraform-sensyne/

Outputs, once terraform will deploy new infrastructure we will need some outputs that we can reuse
# project creation output - Refer to "outputs.tf" file
path = gcp-terraform-sensyne/outputs.tf

Finally main source of the project
# Refer to "main.tf" file
path = gcp-terraform-sensyne/main.tf

# Initialize and pull terraform cloud specific dependencies
Terraform uses modular setup and in order to download specific plugin for cloud provider, terraform will need to be 1st initiated.

terraform init

Terraform plan will simulate what changes terraform will be done on cloud provider

terraform plan

Apply terraform plan for selected environment
terraform apply

Creating Kubernetes cluster on GKE and PostgreSQL on Cloud SQLmain.tf

# Use the below files to Launch Demo Application 
Path = gcp-terraform-sensyne/webapp/

First, authenticate to the cluster and run the below commands using kubectl:

$ kubectl apply -f deployment.yaml
$ kubectl apply -f service.yaml
$ kubectl apply -f ingress.yaml
