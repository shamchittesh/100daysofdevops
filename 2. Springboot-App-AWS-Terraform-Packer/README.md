# Spring Boot AWS Deployment: Packer + Terraform

This project demonstrates a professional CI/CD pattern for deploying a Java Spring Boot application to AWS using the **"Golden Image"** approach. Instead of configuring servers at runtime, we bake the application and its dependencies into an Amazon Machine Image (AMI) using **Packer**, then deploy it using **Terraform**.

## 🏗️ Architecture
- **Application**: Spring Boot 3 + Java 17 (Maven).
- **Image Building**: Packer (Amazon Linux 2 + Java 17 + Maven).
- **Infrastructure**: Terraform (Autoscaling Group + Launch Template + Security Groups).
- **Deployment Strategy**: Immutable Infrastructure (Golden Image).

---

## 🚀 Getting Started

### Prerequisites
- [Packer](https://www.packer.io/downloads) installed.
- [Terraform](https://www.terraform.io/downloads) installed.
- AWS CLI configured with a profile named `aws-perso`.

### 1. Build the Golden Image (Packer)
The Packer build will launch a temporary instance, install Java/Maven, copy the source code, and compile the JAR file into a new AMI.

```bash
cd packer
packer init .
packer build aws-amazonlinux-java.pkr.hcl
```
*Note the AMI name (e.g., `springboot-java17-1703578000`) created in your AWS console.*

### 2. Deploy the Infrastructure (Terraform)
Terraform will automatically find the latest AMI you just built and use it to launch an Autoscaling Group.

```bash
cd ../terraform
terraform init
terraform apply
```

### 3. Verify the App
- Find the Public IP of an instance created by the Autoscaling Group.
- Access the app at: `http://<INSTANCE_IP>:8080`
- Check logs on the instance at: `/var/log/springboot-app.log`

---

## 📂 Project Structure

- `/app`: Simple Spring Boot REST API.
- `/packer`: Configuration to build the Amazon Machine Image.
- `/terraform`: Infrastructure as Code to deploy the ASG.
- `.gitignore`: Prevents sensitive files like terraform state from being committed.

## 🛡️ Security Details
- **Port 8080**: Open to the world for the web app.
- **Port 22 (SSH)**: **Disabled** (App is pre-baked, no manual config needed).
- **IAM**: Uses local AWS profile `aws-perso`.
