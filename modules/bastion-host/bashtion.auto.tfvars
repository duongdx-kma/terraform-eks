module_name   = "bastion-module"
instance_name = "bastion-instance"
instance_type = "t2.micro"
detail_monitoring = false

tags = {
  Name = "bastion-host"
  GithubRepo = "terraform-eks"
  GithubUser = "duongdx-kma"
}
