
# <h1 align="center">🍽️ Swiggy-Clone — Blue-Green DevSecOps Deployment on AWS</h1>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-DevSecOps-orange?style=for-the-badge&logo=amazonaws" />
  <img src="https://img.shields.io/badge/ECS-Blue--Green Deployment-blue?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/CodePipeline-CI%2FCD-success?style=for-the-badge&logo=githubactions" />
  <img src="https://img.shields.io/badge/SonarQube-Code%20Quality-4E9BCD?style=for-the-badge&logo=sonarqube" />
  <img src="https://img.shields.io/badge/Trivy-Security Scan-red?style=for-the-badge&logo=aqua" />
</p>

---

# 🎯 **Purpose of This Project**

This project was built to:

* 🚀 Learn **end-to-end DevSecOps** with AWS
* 🔄 Deploy production apps using **Blue-Green strategy** (zero downtime)
* ⚙️ Understand real CI/CD using **CodePipeline, CodeBuild, CodeDeploy**
* 🛡️ Integrate security tools (SonarQube, Trivy)
* ☁️ Manually build AWS infra to deeply understand each service
* 🧱 Create a **portfolio-ready DevSecOps project**

---

# 🚀 **Project Overview**

This project automates:

✔ Fetching source code from GitHub
✔ Building application using CodeBuild
✔ Running **SonarQube** + **Trivy** scans
✔ Building & pushing Docker image
✔ Blue-Green Deployment using ECS + ALB
✔ Zero-downtime release using traffic shifting

### 🔐 **Integrated DevSecOps Tools**

| Tool                 | Purpose                         |
| -------------------- | ------------------------------- |
| **SonarQube**        | Static Code Analysis            |
| **Trivy FS Scan**    | Dependencies & filesystem scan  |
| **Trivy Image Scan** | Docker image vulnerability scan |

### 🟦🟩 **Blue-Green Deployment Strategy**

* New version deployed to **idle target group**
* ECS launches new tasks
* ALB performs health checks
* If successful → ALB switches traffic
* Previous version stays idle for rollback

---

# 🏗️ **Architecture Diagram**

<p align="center">
  <img src="https://github.com/user-attachments/assets/095b6ac9-3825-46bc-82ef-79bb37452e1b" width="800"/>
</p>

---

# 📂 **Project Structure**

```
Blue-Green-DevSecOps/
│
├── Dockerfile              # Build application image
├── buildspec.yml           # CodeBuild build instructions
├── appspec.yml             # CodeDeploy deployment instructions
├── src/                    # Application source code
├── public/                 # Static UI files
├── package.json            # Dependencies
└── README.md               # Project documentation
```

---

# 🔄 **Workflow (Step-by-Step)**

## 🧑‍💻 **1 — Developer Pushes to GitHub**

CodePipeline detects new commit → triggers pipeline.

---

## 📥 **2 — Source Stage**

CodePipeline pulls code from GitHub
⬇
Sends to CodeBuild

---

## 🏗️ **3 — CodeBuild Stage Executes buildspec.yml**

Build steps include:

* 📦 Install dependencies
* 🧪 Run SonarQube analysis
* 📁 Trivy filesystem scan
* 🐳 Build Docker image
* 🛢️ Run Trivy image scan
* ⬆ Push image to DockerHub
* 📤 Upload artifacts to S3

---

## 🚀 **4 — CodeDeploy Stage**

* Deploys image to **idle ECS target group (Blue/Green)**
* ECS launches fresh tasks
* ALB performs health checks

---

## 🔁 **5 — ALB Traffic Switch**

✔ If new version is healthy → ALB switches traffic
✔ Old version remains for rollback

---

## 🟢 **6 — Application Live**

✨ Zero downtime
✨ Seamless new version

---

# 📸 **Screenshots**

### 🟦 Pipeline Execution

![pipeline sucess results](https://github.com/user-attachments/assets/363407c0-aa94-4bd7-8707-b62331948bb5)

---

### 🟩 Deployed Application Output

![project output after deployment](https://github.com/user-attachments/assets/28cd73ce-9af8-4c7b-8213-7841c222dfd3)

---

### 🧪 SonarQube Scan

![sonarqube analysis report](https://github.com/user-attachments/assets/db76ab1c-ae0d-43e2-a7f9-87d68b59f1f3)

---

### 🛢️ Trivy Image Scan

![trivy image](https://github.com/user-attachments/assets/03418177-0329-4751-9e5f-fbdcba3730cf)

---

### 📁 Trivy FileScan

![trivyfilescan](https://github.com/user-attachments/assets/00499410-b79d-4353-bed6-85c0018e5f53)

---

# 🎓 **What You Learn**

✔ Complete DevSecOps workflow
✔ CI/CD using CodePipeline
✔ Blue-Green deployment
✔ Container scanning
✔ Code quality scanning
✔ AWS ECS + ALB deployment
✔ Manual AWS infra creation
✔ Zero-downtime production deployment

---
