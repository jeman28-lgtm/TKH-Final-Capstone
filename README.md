# 🛡️ Cloud Security Engineering Capstone: Automated & Secure AWS Infrastructure

![Security Scan (SAST)](https://github.com/jeman28-lgtm/tkh-capstone-cloud-security/actions/workflows/sast.yml/badge.svg)
![Terraform](https://img.shields.io/badge/IaC-Terraform_v1.0+-623CE4?style=flat&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2_%7C_VPC_%7C_SG-FF9900?style=flat&logo=amazon-aws&logoColor=white)

## 📌 Executive Summary
This repository contains the infrastructure-as-code (IaC) and DevSecOps pipeline for the **TLAB 12 Capstone Project**. The objective of this mission was to architect, secure, and deploy an automated web server environment in Amazon Web Services (AWS) using **Terraform**, guarded by automated **SAST (Static Application Security Testing)** workflows.

The architecture strictly adheres to zero-trust design principles, least-privilege networking, and automated compliance checking via GitHub Actions.

---

## 🏗️ Architecture & Security Blueprint

```text
                     +--------------------------------------------------+
                     |                 AWS Cloud (us-east-1)            |
                     |                                                  |
                     |   +------------------------------------------+   |
                     |   |        Custom VPC (10.0.0.0/16)          |   |
                     |   |                                          |   |
                     |   |   +----------------------------------+   |   |
                     |   |   |   Public Subnet (10.0.1.0/24)   |   |   |
  Internet           |   |   |                                  |   |   |
  +--------+         |   |   |   +--------------------------+   |   |   |
  | Client | ------> |   |   |   |  Security Group (Web SG) |   |   |   |
  +--------+         |   |   |   |  - Port 80 (HTTP)        |   |   |   |
                     |   |   |   |  - Port 22 (SSH Restr.)  |   |   |   |
                     |   |   |   |                          |   |   |   |
                     |   |   |   |   +------------------+   |   |   |   |
                     |   |   |   |   | EC2 (t3.micro)   |   |   |   |   |
                     |   |   |   |   | Apache Web App   |   |   |   |   |
                     |   |   |   |   +------------------+   |   |   |   |
                     |   |   |   +--------------------------+   |   |   |
                     |   |   +----------------------------------+   |   |
                     |   +------------------------------------------+   |
                     +--------------------------------------------------+
```

### 🔒 Core Security Controls (`main.tf`)
1. **Network Isolation:** Built a dedicated, non-default Virtual Private Cloud (VPC) with explicit route tables and subnets.
2. **Strict Firewall Boundaries:** Security Group limits HTTP (80) inbound access and locks SSH (22) to designated manageability blocks.
3. **IMDSv2 Enforcement:** Enforced `http_tokens = "required"` on the `t3.micro` EC2 instance to prevent SSRF (Server-Side Request Forgery) attacks targeting IMDS credentials.
4. **Data at Rest Encryption:** Enforced storage volume encryption (`encrypted = true`) across all root block devices.

---

## ⚙️ CI/CD DevSecOps Pipeline

Automated security checks run on every `push` and `pull_request` to the main branch via **GitHub Actions**:

* **`tfsec`**: Scans Terraform code for infrastructure misconfigurations, public exposure risks, and compliance vectors.

Pipelines must pass **100% clean** before code is eligible for deployment.

---

## 🚀 Deployment & Management Walkthrough

### Prerequisites
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= v1.0.0)
* [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with active credentials.

### 1. Initialize & Validate Infrastructure
```bash
terraform init
terraform validate
```

### 2. Execution Plan & Deployment
```bash
terraform plan
terraform apply -auto-approve
```

### 3. Zero Drift Infrastructure Teardown
```bash
terraform destroy -auto-approve
```

---

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── sast.yml        # CI/CD Pipeline (tfsec)
├── main.tf                 # Primary IaC definitions (VPC, SG, EC2 t3.micro)
├── variables.tf            # Configurable variable declarations
└── README.md               # Project documentation & architectural spec
```

---

## 👤 Author
* **Portfolio/GitHub:** [jeman28-lgtm](https://github.com/jeman28-lgtm)
* **Track:** Cloud Security Engineering