data "aws_ami" "amz_linux2" {
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

