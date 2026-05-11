# 🗳️ Voting App — Production-Grade DevOps Pipeline on AWS
 
A fully automated, production-grade deployment pipeline for a multi-service voting application on AWS EKS using Terraform, Kubernetes, GitHub Actions, and Grafana.
 
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
 
---
 
## 📋 Project Overview
 
This project demonstrates a complete end-to-end DevOps pipeline. A multi-service voting application is containerised, deployed to a Kubernetes cluster on AWS, and monitored with Prometheus and Grafana. Every git push to `main` automatically builds, pushes, and deploys all services via GitHub Actions.
 
**Elevator pitch:** *"I built a fully automated, production-grade deployment pipeline on AWS using Terraform, Kubernetes, and GitHub Actions — with monitoring and zero-downtime deployments."*
 
---
 
## 🏗️ Architecture
 
```
Internet
    │
    ▼
Application Load Balancer (AWS)
    │
    ▼
┌─────────────────────────────────────────┐
│           AWS EKS Cluster               │
│                                         │
│  ┌──────┐  ┌────────┐  ┌──────────┐   │
│  │ vote │  │ result │  │  worker  │   │
│  └──┬───┘  └───┬────┘  └────┬─────┘   │
│     │          │             │         │
│  ┌──▼──────────▼─┐   ┌──────▼──────┐  │
│  │     Redis     │   │  PostgreSQL  │  │
│  └───────────────┘   └─────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  Prometheus + Grafana (monitoring)│  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│           AWS Infrastructure            │
│  VPC │ ECR │ IAM │ S3 (tfstate)        │
└─────────────────────────────────────────┘
```
 
---
 
## 🛠️ Tech Stack
 
| Tool | Purpose |
|---|---|
| Docker | Containerise all 5 services |
| Terraform | Provision AWS infrastructure as code |
| AWS EKS | Managed Kubernetes cluster |
| AWS ECR | Private Docker image registry |
| AWS VPC | Networking — subnets, IGW, route tables |
| Kubernetes | Orchestrate and run containers |
| GitHub Actions | CI/CD pipeline — build, push, deploy |
| OIDC | Keyless AWS authentication from GitHub |
| Helm | Install Prometheus + Grafana |
| Prometheus | Metrics collection |
| Grafana | Metrics visualisation and dashboards |
 
---
 
## 📁 Repository Structure
 
```
example-voting-app/
├── .github/
│   └── workflows/
│       ├── deploy.yml          # Main CI/CD pipeline
│       └── pr-check.yml        # PR validation checks
├── infrastructure/             # Terraform code
│   ├── main.tf                 # Provider + backend config
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── vpc.tf                  # VPC, subnets, IGW, routes
│   ├── eks.tf                  # EKS cluster + node group
│   ├── ecr.tf                  # ECR repositories
│   ├── iam.tf                  # IAM roles + OIDC provider
│   └── security_groups.tf      # Firewall rules
├── k8s/                        # Kubernetes manifests
│   ├── postgres-deployment.yaml
│   ├── postgres-service.yaml
│   ├── redis-deployment.yaml
│   ├── redis-service.yaml
│   ├── worker-deployment.yaml
│   ├── vote-deployment.yaml
│   ├── vote-service.yaml
│   ├── result-deployment.yaml
│   └── result-service.yaml
├── vote/                       # Python Flask voting app
├── result/                     # Node.js results app
├── worker/                     # C# .NET worker service
└── seed-data/                  # Database seed data
```
 
---
 
## 🚀 CI/CD Pipeline
 
Every push to `main` triggers the following pipeline:
 
```
git push to main
      │
      ▼
┌─────────────────────┐
│   build-and-push    │
│                     │
│ 1. Checkout code    │
│ 2. Auth via OIDC    │
│ 3. Login to ECR     │
│ 4. Build images     │
│ 5. Push to ECR      │
└────────┬────────────┘
         │ needs: build-and-push
         ▼
┌─────────────────────┐
│      deploy         │
│                     │
│ 1. Auth via OIDC    │
│ 2. Login to ECR     │
│ 3. Update kubeconfig│
│ 4. Replace image    │
│    tags in manifests│
│ 5. kubectl apply    │
│ 6. Verify rollout   │
└─────────────────────┘
```
 
**Authentication** uses GitHub OIDC — no AWS credentials are stored as secrets. GitHub generates a short-lived token per workflow run that AWS verifies against the OIDC provider.
 
---
 
## ⚙️ Infrastructure Setup
 
### Prerequisites
 
- AWS CLI configured (`aws configure`)
- Terraform >= 1.5.0
- kubectl
- Helm 3
### Step 1 — Create Terraform backend resources
 
```bash
# S3 bucket for state
aws s3api create-bucket \
  --bucket your-tfstate-bucket \
  --region ap-southeast-2 \
  --create-bucket-configuration LocationConstraint=ap-southeast-2
 
# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-tfstate-bucket \
  --versioning-configuration Status=Enabled
 
# DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```
 
### Step 2 — Provision AWS infrastructure
 
```bash
cd infrastructure/
terraform init
terraform plan
terraform apply
```
 
This creates (~15 minutes):
- VPC with public subnets across 2 AZs
- EKS cluster (Kubernetes 1.31) with 2× t3.medium nodes
- 3 ECR repositories (vote, result, worker)
- IAM roles for EKS, node group, and GitHub Actions
### Step 3 — Connect kubectl
 
```bash
aws eks update-kubeconfig \
  --region ap-southeast-2 \
  --name voting-app
```
 
### Step 4 — Create Kubernetes secret
 
```bash
kubectl create secret generic postgres-secret \
  --from-literal=username=postgres \
  --from-literal=password=<your-password> \
  --from-literal=database=votes
```
 
### Step 5 — Add GitHub Actions to aws-auth
 
```bash
kubectl edit configmap aws-auth -n kube-system
```
 
Add under `mapRoles`:
```yaml
- rolearn: arn:aws:iam::<account-id>:role/github_actions
  username: github-actions
  groups:
    - system:masters
```
 
### Step 6 — Add GitHub secret
 
In your GitHub repo → Settings → Secrets → Actions:
```
Name:  AWS_ROLE_ARN
Value: arn:aws:iam::<account-id>:role/github_actions
```
 
### Step 7 — Deploy
 
```bash
git push origin main
```
 
GitHub Actions handles the rest automatically.
 
---
 
## 📊 Monitoring
 
Prometheus and Grafana are installed via Helm:
 
```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```
 
Access Grafana:
```bash
kubectl port-forward -n monitoring \
  service/monitoring-grafana 3000:80
```
 
Open `http://localhost:3000` — credentials: `admin` / `prom-operator`
 
### Dashboard queries
 
| Panel | PromQL Query |
|---|---|
| Pod Status | `kube_pod_status_ready{namespace="default"}` |
| CPU Usage per Pod | `rate(container_cpu_usage_seconds_total{namespace="default"}[5m])` |
| Memory Usage per Pod | `container_memory_usage_bytes{namespace="default"}` |
 
---
 
## 💰 Cost Management
 
This project runs on AWS and incurs costs when active:
 
| Resource | Approximate Cost |
|---|---|
| EKS Control Plane | ~$0.10/hour (~$72/month) |
| 2× t3.medium nodes | ~$0.10/hour combined |
| ECR storage | ~$0.10/GB/month |
 
**Destroy when not in use:**
```bash
terraform destroy
```
 
**Recreate when needed:**
```bash
terraform apply
```
 
---
 
## ⚠️ Known Limitations and Production Improvements
 
This project is optimised for learning and demonstration. In a production environment the following improvements would be made:
 
**Networking**
- Worker nodes run in public subnets for cost reasons. Production would use private subnets behind a NAT Gateway for defence in depth.
**Storage**
- PostgreSQL uses `emptyDir` volume — data is lost on pod restart. Production would use a `PersistentVolumeClaim` backed by an EBS volume.
**Secrets Management**
- Kubernetes Secrets are base64 encoded, not encrypted. Production would use AWS Secrets Manager with the External Secrets Operator.
**Kubernetes Version**
- Would pin to a specific patch version and have a documented upgrade process.
**RBAC**
- GitHub Actions role has `system:masters` (full admin). Production would use a least-privilege custom role scoped to the deploy namespace only.
**Multi-environment**
- Would add staging and production environments with manual approval gates between them.
---
 
## 🗺️ What I Learned
 
- How multi-stage Docker builds reduce image size and separate dev/prod concerns
- How Terraform manages AWS infrastructure state and handles dependencies between resources
- How Kubernetes Services provide stable DNS hostnames for inter-pod communication
- How GitHub OIDC eliminates the need to store AWS credentials as secrets
- How Prometheus scrapes metrics and Grafana visualises them
- How to debug real infrastructure issues — IAM permissions, aws-auth ConfigMaps, image pull errors
---
 
## 📬 Author
 
**Vinay Kumar**
GitHub: [@vinayellulla](https://github.com/vinayellulla)
