variable "ami" {
  default = "ami-076d128fb049922d4"
}

variable "instance_type" {
  default = "t3.small"
}

variable "vpc_sg_id" {
  default = ["sg-0fcfe62979bdd0bf1"]
}

variable "zone_id" {
  default = "Z01214421PKKTLXAI5VN5"
}

variable "dns_type" {
  default = "A"
}

variable "ttl" {
  default = "300"
}

variable "components" {
  default = {
    "frontend" = ""
    "mongodb" = ""
    "mysql" = ""
    "redis" = ""
    "cart" = ""
    "rabbitmq" = ""
    "catalogue" = ""
    "user" = ""
    "shipping" = ""
    "payment" = ""
  }
}

variable "iam_role" {
  default = "workstation-role"
}

variable "key_name" {
  default = "roboshop-dev"
}

