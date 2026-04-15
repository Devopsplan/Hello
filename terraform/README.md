Run this before Terraform: 
  gcloud auth application-default login

or if using service account:
  export GOOGLE_APPLICATION_CREDENTIALS="key.json"


🚀 Commands to Deploy

terraform init
terraform plan
terraform apply

After creation:

gcloud container clusters get-credentials my-cluster --region asia-south1
    

Test:

kubectl get nodes
