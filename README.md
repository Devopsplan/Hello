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






