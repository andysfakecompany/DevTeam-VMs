variable "ajames-aws-ssh" {
  type = "string"
}

provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "terraform_remote_state" "networking_stuff" {
  backend = "remote"

  config = {
    organization = "andys-fake-company"

    workspaces {
      name = "Network-Team"
    }
  }
}

data "terraform_remote_state" "security_stuff" {
  backend = "remote"

  config = {
    organization = "andys-fake-company"

    workspaces {
      name = "Security-Team"
    }
  }
}

resource "aws_instance" "dev-docker-server" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t3.small"
  key_name = "ajames-key"
  vpc_security_group_ids = ["${data.terraform_remote_state.security_stuff.fakecompany_sharedservices_security_group_id}"]
  subnet_id = "${data.terraform_remote_state.networking_stuff.fakecompany_subnet_1}"
  associate_public_ip_address = "true"
  connection {
        user = "centos"
        type = "ssh"
        private_key = "${var.ajames-aws-ssh}"
        timeout = "2m"
  }
  tags = {
    Name = "dev-docker-server"
    TTL = "72"
    owner = "Andy James"
  }
}
