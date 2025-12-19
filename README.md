README.md
# KIND Kubernetes Cluster Setup

## Purpose
This repository contains configuration and scripts to create a **multi-node KIND cluster**, deploy a sample application, setup **Persistent Volumes (PV)** and **Persistent Volume Claims (PVC)**, 
perform **pod scaling**, and demonstrate **auto-healing** of pods.

## Steps

1. **Prerequisites**
   - Ubuntu system
   - At least 25GB disk and 4GB RAM
   - Internet connection

2. **Install Docker**
   ```bash
   sudo apt-get install -y docker.io
   sudo systemctl enable docker
   sudo systemctl start docker
   sudo usermod -aG docker $USER
   newgrp docker


Install KIND

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
Install kubectl

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

Create cluster
kind create cluster --name my-cluster --config kind-config.yml
kubectl get nodes

Setup Persistent Storage
Creates PV and PVC mounted by pods.
Deploy sample application
Nginx deployment using PVC.
Scale pods
kubectl scale deployment nginx-deployment --replicas=3

Auto-healing

Kubernetes automatically recreates pods if they fail.

Folder Structure
kind_cluster/
├── kind-config.yml
├── setup.sh
├── README.md
└── .gitignore
