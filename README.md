# Hello

Need Tools:
 
✅ 1. Update System

sudo apt update && sudo apt upgrade -y

🐳 2. Install Docker

sudo apt install docker.io -y
sudo service docker start
sudo usermod -aG docker $USER && newgrp docker
docker --version

🔧 3. Install Git
sudo apt install git -y
git --version

☸️ 4. Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
kubectl version --client

Helm📦 5. Install Helm

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

🐍 6. Install Python 3.12+

sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.12 python3.12-venv python3.12-dev -y
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

📦 7. Install pip
python3.12 -m ensurepip --upgrade
or 
sudo apt install python3-pip -y

pip3 --version

aws cli
terraform

Stage 1

Step 1: 

Create  a app.py file with print("Hello")

pip install flask 

from flask import Flask

app = Flask(__name__)

@app.route("/")
def helllo():
    return "helllo"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

verify it works or not 


create a requirement.txt

content :
flask

----------------


Create a docker file 

FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt
COPY app.py .

RUN pip install--no-cache-dir-r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]


docker build
docker run




Create a docker account and push the image to the docker hub


create a file .github/workflow/ci.yaml

name: Build and Push docker image

on:
  push:
    branches: [main]

jobs: 
  build-and-push:
    runs-on: ubuntu-latest

    steps: 
      - name: checkout code 
        uses: actions/checkout@v4
        # git clone link
        # cd your repo    

      - name: Login to docker
        uses: docker/login-aciton@v3
        with: 
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOCKEN }}

      - name: Genrate time stemps tag
        run: echo "VERSION=$('date +'%Y-%m-%d-%H%M%S')" >> $GITHUB_ENV
        # VERSION=2026-04-15-121212
        # Image name : yourimage:2026-04-11-121212

     - name: Build and push image
        run: 
          docker build -t ${{ secrets.DOCKERHUB_USERNAME }}
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/flask-hello:${{ env.version}}





EKS


IAM user creaate with   
- AdiminstrationAccess

create access key 

login in vs cli

Terraform eks managed node group

Create a vpc via terraform 

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"  
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true  
  
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"  
  
  
  cluster_name    = "my-cluster"
  cluster_version = "1.30"
  
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }
  
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]  
      min_size       = 1
      max_size       = 3
      desired_size   = 2
   
    }
  }
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}



