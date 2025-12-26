data "aws_ami" "packer_image" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["springboot-java17-*"]
  }
}

resource "aws_security_group" "app_server_sg" {
  name        = "app-server-sg"
  description = "Allow inbound traffic on port 8080"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "springboot-server-sg"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_launch_template" "app_server_lt" {
  name_prefix   = "springboot-server-lt-"
  image_id      = data.aws_ami.packer_image.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # The app was built during the Packer phase and is located in /opt/springboot-app
              cd /opt/springboot-app
              
              # Run the jar and log everything to /var/log/
              # We use 'java -jar' and find the snapshot jar
              java -jar target/demo-0.0.1-SNAPSHOT.jar > /var/log/springboot-app.log 2>&1 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "springboot-app-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "springboot-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "springboot-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}



resource "aws_autoscaling_group" "app_server_asg" {
  name                = "springboot-app-server-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.app_server_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "springboot-app-server-asg"
    propagate_at_launch = true
  }
}
