module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = var.module_name
  ami                    = data.aws_ami.amz_linux2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.bastion_key.key_name
  monitoring             = var.detail_monitoring
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id

  tags = var.tags
}

resource "null_resource" "copy_ec2_keys" {
  connection {
    timeout     = "2m"
    type        = "ssh"
    host        = module.ec2_instance.public_ip
    user        = "ec2-user"
    private_key = file(var.path_to_private_key)
  }

  # File Provisioner: passing key from local to server
  provisioner "file" {
    source      = var.path_to_public_node_group_key
    destination = "/tmp/eks-terraform-key.pem"
  }

  # Remote Exec Provisioner Change eks-terraform-key.pem key permission
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/eks-terraform-key.pem"
    ]
  }

  # Local Exec Provisioner: passing key from local to server
  provisioner "local-exec" {
    command     = "echo bastion-host created on `date` >> creation-time.txt"
    working_dir = "local-exec-output-files"
  }
}
