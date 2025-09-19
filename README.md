# Project Bedrock – AWS EKS Infrastructure & Retail Store Sample App

Mission: “Project Bedrock” – Deploy our new microservices application to a production-grade Kubernetes environment on AWS. This project provisions a secure, production-grade **Amazon EKS cluster** with managed persistence services (**RDS MySQL, RDS PostgreSQL, and DynamoDB**) using **Terraform**, then deploys the **AWS Retail Store Sample App** with Kubernetes . Some of the best practices utilized includes, no SSH to nodes → Session Manager implemented instead, IAM least privilege, IRSA for service-to-AWS access, Developer ReadOnly user limited to describe/list as instructed, encrypted RDS and DynamoDB by default.


This ReadME serves as a summary of the steps completed to deploy this microservices application to a production-grade Kubernetes environment on AWS.

## Architecture Overview

**Core components:**
- **VPC** with public/private subnets, NAT Gateway, and tagging for EKS.
- **EKS Cluster** with managed node group (on-demand EC2).
- **IAM Roles** for EKS cluster, worker nodes, and IRSA integration for services.
- **RDS Databases**
  - MySQL for **Catalog Service**
  - PostgreSQL for **Orders Service**
- **DynamoDB** table for **Carts Service**.
- **Kubernetes Deployments** for Catalog, Carts, Orders, Checkout, and UI services.
- **LoadBalancer Service** for exposing the UI.


## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.0`
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with an IAM user/role
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Git](https://git-scm.com/)
- Configured required AWS credentials to avoid passing it into provider.tf file
---

```bash
infra/
├── provider.tf            # Provider, backend, modules
├── vpc.tf                 # VPC + subnets + NAT + tags
├── eks.tf                 # EKS cluster + nodegroup + addons
├── db.tf                  # RDS + DynamoDB + SGs
├── iam.tf                 # IAM roles, policies, IRSA
├── datasource.tf          # Data lookups (caller identity, AZs, cluster)
├── variables.tf           # Input variables
├── outputs.tf             # Terraform outputs (endpoints, ARNs, etc.)
└── kubernetes.yaml        # App deployments and services
└── aws-auth.yaml          # Auth for developer-read-only
└── rbinding.yaml          # RBAC binding
```

## Infrastructure Setup with Terraform
Utilized IaC tool terraform to configure the required aws resources referencing samples provided in the documentation and customizin appropraitely.

Deploy configured terraform infrastructure with the following commands

```bash
- change directory into appropraite file (cd infra)
- terraform init 
- terraform fmt
- terraform vaildate 
- terraform plan 
- terraform apply
```

## Configure Variables
I set up my variables.tf and terraform.tfvars file appropraitely to include the following details.

- aws_region              = "us-east-1"
- project_name            = "project-bedrock"
- environment             = "dev"
- cluster_name            = "project-bedrock-eks"
- kubernetes_version      = "1.32"
- vpc_cidr                = 
- private_subnet_cidrs    = 
- public_subnet_cidrs     = 
- node_instance_types     = ["t3.medium"]
- min_size                = 1
- max_size                = 3
- desired_size            = 2
- db_password             = pass to terraform.tfvars
- enable_managed_persistence = true

Reviewed the plan to ensure resources to be created matched configuration as decleared.

## kubectl Access, IAM, RBAC AND Addons configuration
After completion of the terraform deployment, configure kubectl to access your EKS cluster

for context I updated kubeconfig using: aws eks update-kubeconfig --region us-east-1 --name project-bedrock-eks

### Application Deployment

- Edit kubernetes.yaml to match Terraform outputs
Download the retail-store-sample-app kubernetes manifest and updated the databases endpoints to with the output provided from the terraform deployment (output.tf) on AWS. Encode the db credentials with base-64 Base-64 and update appropriately, review the manifest to ensure all changes are made to suit current depployment.

````bash
RETAIL_CATALOG_PERSISTENCE_ENDPOINT: 
RETAIL_ORDERS_PERSISTENCE_ENDPOINT:
RETAIL_CART_PERSISTENCE_DYNAMODB_TABLE_NAME: 

- Deploy the application: 
kubectl apply -f kubernetes.yaml

- Map IAM Identities into Kubernetes, apply aws-auth.yaml to map nodes and developer user:
kubectl apply -f aws-auth.yaml
kubectl apply -f rbinding.yaml

- Verify deployment:
kubectl get nodes
kubectl get pods -A
kubectl get svc

````

## Access the App

To access the app get the UI service external address:
````bash
kubectl get svc ui
````

Copy the EXTERNAL-IP and open in your browser and verify connectivity

- Catalog Service → Connects to MySQL RDS

- Orders Service → Connects to PostgreSQL RDS

- Carts Service → Connects to DynamoDB via IRSA

- UI Service → Exposed via LoadBalancer

## Route 53 DNS Setup

To make the application accessible via a custom domain instead of the LoadBalancer DNS I leveraged AWS Route 53

- Navigate to Route 53 in the AWS Console
- Navigate to Hosted Zones.
- Selected my registered hosted zone (kennycloudchronicles.com).
- Create a Record
- Record name: retailstore making the DNS name retailstore.kennycloudchronicles.com.
- Record type: A – IPv4 address.
- Choose Alias = Yes. Set Route traffic to → Alias to Application and Classic Load Balancer.
- Select the appropriate region and Load Balancer from the list.
- Save the Record

Test the Domain  http://retailstore.kennycloudchronicles.com


## Cleanup
To clean up all resources after completion
````bash
To destroy all resources:

kubectl delete -f kubernetes.yaml
kubectl delete -f aws-auth.yaml
terraform destroy -auto-approve

Delete DNS record created via console.
````

