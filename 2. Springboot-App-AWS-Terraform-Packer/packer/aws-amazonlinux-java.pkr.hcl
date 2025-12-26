packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazonlinux" {
  ami_name      = "springboot-java17-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  profile       = "aws-perso"
  
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-ebs"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  
  ssh_username = "ec2-user"
}

build {
  name = "java-installer"
  sources = [
    "source.amazon-ebs.amazonlinux"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y java-17-amazon-corretto-devel git",
      # Install Maven 3.9.6 manually as yum version is too old
      "curl -OL https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz",
      "sudo tar xzvf apache-maven-3.9.6-bin.tar.gz -C /opt",
      "sudo ln -s /opt/apache-maven-3.9.6 /opt/maven",
      "sudo ln -s /opt/maven/bin/mvn /usr/bin/mvn",
      "sudo mkdir -p /opt/springboot-app",
      "sudo chown ec2-user:ec2-user /opt/springboot-app"
    ]
  }

  provisioner "file" {
    source      = "../app"
    destination = "/tmp/app_source"
  }

  provisioner "shell" {
    inline = [
      "cp -R /tmp/app_source/* /opt/springboot-app/",
      "cd /opt/springboot-app && mvn clean package -DskipTests",
      "echo 'Build complete. Artifact at /opt/springboot-app/target/'"
    ]
  }
}
