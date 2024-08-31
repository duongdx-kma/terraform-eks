resource "aws_key_pair" "node_group_key" {
  key_name   = "node_group_key"
  public_key = file(var.node_group_path_to_public_key)
}
