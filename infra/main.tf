provider "aws" {
    region = "ap-southeast-1"
}

#aws network resource

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_security_group" "jenkins_sg" {
    vpc_id = aws_vpc.main.id

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress { 
        from_port = 22 
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }


}

resource "aws_security_group" "docker_sg" {
    vpc_id = aws_vpc.main.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
}

# route table to internet
resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.main.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rt_association" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_route.id
}

# aws instance

resource "aws_instance" "jenkins" {
  ami           = "ami-00bc358fb32983be0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name = "check"
  tags = {
    Name = "JenkinsServer"
  }

  user_data = <<-EOF
        #!/bin/bash
        set -ex
        sudo yum update -y
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
        sudo yum upgrade -y
        sudo yum install -y java-17-amazon-corretto
        sudo yum install -y jenkins
        sudo systemctl enable jenkins
        sudo systemctl start jenkins
        sudo yum install git -y
        sudo amazon-linux-extras install docker -y
        sudo service docker start
        sudo usermod -a -G docker ec2-user
        sudo usermod -a -G docker jenkins
        sudo pip3 install ansible
        EOF
}

resource "aws_instance" "docker" {
  ami           = "ami-00bc358fb32983be0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  key_name = "check"

  tags = {
    Name = "DockerServer"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo yum install -y ansible
    EOF
}
