provider "aws" {
  profile = "proiect_radu"
  region  = "eu-central-1"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_key_pair" "personal" {
  key_name   = "user-keypair"
  public_key = var.ssh_keys
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["92.85.72.139/32"]
  }

  # Jenkins port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["92.85.72.139/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.personal.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "JenkinsInstance"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "sleep 15"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' ansible/jenkins-playbook.yml"
  }

}

output "instance_ip" {
  value = aws_instance.jenkins.public_ip
}
