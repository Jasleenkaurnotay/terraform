# Production-Grade ECS Deployment on AWS using Terraform

A fully modular Terraform project that provisions a production-grade containerised application on AWS ECS Fargate, backed by RDS Postgres, fronted by an Application Load Balancer with HTTPS, and served via a custom domain through Route 53.

---

## Architecture Overview

```
Internet
    │
    ▼
Route 53 (student.labs.com)
    │  Alias A record
    ▼
Application Load Balancer (ALB)
├── HTTP/80  → forward → Target Group (port 8000)
└── HTTPS/443 (ACM Certificate) → forward → Target Group (port 8000)
    │
    ▼
ECS Fargate Service (private subnets)
├── Task Definition (512 CPU, 1024 Memory, X86_64)
├── Container: apps:student-app (port 8000)
├── Environment: DB_LINK → RDS endpoint
└── Logs: CloudWatch Log Group /ecs/ecs-lab
    │
    ▼
RDS Postgres (RDS private subnets)
└── db.t3.micro, postgres 18, storage: gp2 20GB
```

---

## Network Architecture

```
VPC: 172.16.0.0/16
│
├── Public Subnets (ALB)
│   ├── 172.16.64.0/20  → us-east-1a
│   └── 172.16.128.0/20 → us-east-1b
│       └── NAT Gateway (outbound internet for private subnets)
│
├── Private Subnets (ECS)
│   ├── 172.16.16.0/20  → us-east-1a
│   └── 172.16.32.0/20  → us-east-1b
│
└── RDS Subnets
    ├── 172.16.48.0/20  → us-east-1a
    └── 172.16.192.0/20 → us-east-1b
```

---

## Security Group Rules

```
ALB Security Group
├── Inbound:  TCP 80  from 0.0.0.0/0
└── Inbound:  TCP 443 from 0.0.0.0/0

ECS Security Group
├── Inbound:  TCP 8000 from ALB Security Group
└── Outbound: All traffic to 0.0.0.0/0

RDS Security Group
├── Inbound:  TCP 5432 from ECS Security Group
└── Outbound: All traffic to 0.0.0.0/0
```

---

## Module Structure

```
terraform-ecs-project/
├── main.tf                   # Root module — wires all child modules
├── variables.tf              # Root input variable declarations
├── outputs.tf                # Root outputs (vpc_id, igw_id)
├── provider.tf               # AWS provider + S3 remote backend
├── terraform.tfvars          # Actual values (gitignored)
├── terraform.tfvars.example  # Template for new contributors
└── modules/
    ├── vpc/                  # VPC, subnets, IGW, NAT, route tables
    ├── security_groups/      # ALB, ECS, RDS security groups
    ├── alb/                  # ALB, HTTP/HTTPS listeners, target group
    ├── ecs/                  # Cluster, task definition, service, IAM, CloudWatch
    ├── rds/                  # RDS Postgres instance and subnet group
    └── route53/              # Hosted zone lookup, A record alias, ACM cert lookup
```

---

## Module Dependency Graph

```
vpc
 └──► security_groups
         ├──► alb
         │     └──► ecs
         ├──► ecs
         │     └──► (depends on rds for DB_LINK env var)
         └──► rds

route53
 └──► (reads alb outputs: dns_name, zone_id)
 └──► (provides cert_arn to alb for HTTPS listener)
```

---

## Prerequisites

| Requirement | Version |
|---|---|
| Terraform | >= 1.10 (required for S3 native locking) |
| AWS CLI | >= 2.x |
| AWS Account | with appropriate IAM permissions |
| Domain | registered and hosted zone created in Route 53 |
| ACM Certificate | imported or issued in us-east-1, status ISSUED |
| ECR Repository | with application image pushed |

---

## Remote State

State is stored in S3 with native locking (no DynamoDB required — Terraform >= 1.10).

### Bootstrap (run once before `terraform init`)

```bash
# Create the state bucket
aws s3api create-bucket \
  --bucket mylabs-terraform-state \
  --region us-east-1

# Enable versioning (required for S3 native locking)
aws s3api put-bucket-versioning \
  --bucket mylabs-terraform-state \
  --versioning-configuration Status=Enabled

# Enable default encryption
aws s3api put-bucket-encryption \
  --bucket mylabs-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms"
      }
    }]
  }'

# Block all public access
aws s3api put-public-access-block \
  --bucket mylabs-terraform-state \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

State file location in bucket: `dev/state/terraform.tfstate`

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Jasleenkaurnotay/terraform.git
cd terraform
```

### 2. Create your `terraform.tfvars`

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region      = "us-east-1"
aws_profile     = "your-aws-profile"
project_name    = "ecs-lab"
vpc_cidr        = "172.16.0.0/16"
private_cidr    = ["172.16.16.0/20", "172.16.32.0/20"]
rds_cidr        = ["172.16.48.0/20", "172.16.192.0/20"]
public_cidr     = ["172.16.64.0/20", "172.16.128.0/20"]
environment     = "dev"
container_image = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/<repo>:<tag>"
db_name         = "mydb"
db_username     = "postgres"
db_password     = "<your-secure-password>"
domain_name     = "yourdomain.com"
```

> ⚠️ `terraform.tfvars` is gitignored. Never commit it.

### 3. Authenticate with AWS

```bash
aws login --remote
# or
aws sso login
```

### 4. Initialise and deploy

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

---

## Input Variables

| Variable | Type | Description |
|---|---|---|
| `aws_region` | string | AWS region (default: us-east-1) |
| `aws_profile` | string | AWS CLI profile name (empty in CI/CD) |
| `project_name` | string | Used as prefix for all resource names |
| `environment` | string | Environment tag (default: dev) |
| `vpc_cidr` | string | CIDR block for the VPC |
| `public_cidr` | list(string) | CIDRs for public subnets (ALB) |
| `private_cidr` | list(string) | CIDRs for private subnets (ECS) |
| `rds_cidr` | list(string) | CIDRs for RDS subnets |
| `container_image` | string | Full ECR image URI including tag |
| `db_name` | string | Postgres database name |
| `db_username` | string | Postgres master username |
| `db_password` | string | Postgres master password (sensitive) |
| `domain_name` | string | Root domain name (e.g. example.com) |

---

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `igw_id` | ID of the Internet Gateway |

---

## Resource Tagging

All resources are tagged consistently:

```hcl
tags = {
  Name        = "${var.project_name}-<resource>"
  Environment = var.environment
  ManagedBy   = "Terraform"
}
```

---

## Key Design Decisions

**Why Fargate?** No EC2 instances to manage, patch, or scale. AWS manages the underlying infrastructure.

**Why IP-based target group?** ECS Fargate tasks don't have EC2 instance IDs — they register by IP address directly.

**Why S3 native locking instead of DynamoDB?** Terraform 1.10+ supports native state locking via S3 conditional writes (`use_lockfile = true`). No DynamoDB table needed — simpler, cheaper, fewer dependencies.

**Why private subnets for ECS and RDS?** Neither the application container nor the database should be directly reachable from the internet. All inbound traffic flows through the ALB in public subnets.

**Why NAT Gateway in public subnet?** ECS tasks in private subnets need outbound internet access to pull images from ECR and send logs to CloudWatch. NAT Gateway provides this without exposing the tasks publicly.

**Why separate RDS subnets?** Isolating RDS into its own subnet tier makes it easier to apply different routing and security group rules, and is an AWS best practice for multi-tier architectures.

---

## CI/CD Considerations

When running Terraform in a CI/CD pipeline:

- Remove `profile` from `provider.tf` or set `aws_profile = ""`
- Inject credentials via environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
- Or attach an IAM role directly to the pipeline runner (recommended)
- The S3 backend will authenticate using the same credentials automatically

---

## Cleanup

```bash
terraform destroy
```

> ⚠️ This will destroy all resources including the RDS database. Ensure you have backups if needed.

---