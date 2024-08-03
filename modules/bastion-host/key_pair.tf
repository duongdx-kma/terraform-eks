resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = file(var.path_to_public_key)
}
