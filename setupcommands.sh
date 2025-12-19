#!/bin/bash
# ================================
# Script: setup.sh
# Purpose: Install Docker, KIND, kubectl, create cluster,
#          setup sample application, persistent storage, scaling
# ================================

# --- Step 1: Update system ---
sudo apt-get update
sudo apt-get upgrade -y

# --- Step 2: Install Docker ---
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker

# --- Step 3: Install KIND ---
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# --- Step 4: Install kubectl ---
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# --- Step 5: Create KIND cluster ---
kind create cluster --name my-cluster --config kind-config.yml

# --- Step 6: Verify cluster ---
kubectl cluster-info --context kind-my-cluster
kubectl get nodes

# --- Step 7: Setup Persistent Volumes (PV) and PVC ---
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: demo-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# --- Step 8: Deploy a sample app using PV/PVC ---
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          volumeMounts:
            - name: storage
              mountPath: /usr/share/nginx/html
      volumes:
        - name: storage
          persistentVolumeClaim:
            claimName: demo-pvc
EOF

# --- Step 9: Expose deployment as service ---
kubectl expose deployment nginx-deployment --type=NodePort --port=80

# --- Step 10: Scaling pods (HPA can be added later) ---
kubectl scale deployment nginx-deployment --replicas=3
kubectl get pods

# --- Step 11: Auto-healing check ---
echo "Kubernetes automatically recreates pods if they fail"
kubectl get pods --watch

