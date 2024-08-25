# Mysql variable
variable mysql_database {
  type = string
}

variable mysql_root_password {
  type = string
}

variable mysql_password {
  type = string
}

variable mysql_user {
  type = string
}

# ------------------------------------------
# Python variable to Mysql
variable write_db_user {
  type = string
}

variable "write_db_password" {
  type = string
}


variable read_db_user {
  type = string
}

variable "read_db_password" {
  type = string
}

# ------------------------------------------
# Python variable
variable db_name {
  type = string
}

variable "db_port" {
  type = number
}

variable app_port {
  type = number
}

variable "app_env" {
  type = string
}

# ------------------------------------------
# kubernetes variable
variable flask_webapp_service_port {
  type = number
}

variable "flask_webapp_public_node_port" {
  type = number
}