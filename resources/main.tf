/*
  Project      : RobotShop Dev Environment
  Description  : Creates EC2 instances and Route53 DNS records for each microservice
                 using count meta-argument with dynamic length of components variable
  AMI          : Configured via var.ami
  Type         : Configured via var.instance_type
  SG           : Configured via var.vpc_sg_id
  Components   : Configured via var.components (frontend, mongodb, catalogue, redis,
                 user, cart, mysql, shipping, rabbitmq, payment)
  DNS Zone     : Configured via var.zone_id
  DNS Type     : Configured via var.dns_type
  TTL          : Configured via var.ttl
*/
#Attach existing IAM Role to EC2 instance


resource "aws_instance" "instances" {
  for_each = var.components

  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_sg_id
  iam_instance_profile = var.iam_role
  key_name               = var.key_name

  tags = {
    Name = each.key
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file(pathexpand("~/.ssh/${var.key_name}"))
      host        = self.public_ip

    }
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
    ]
  }
}

resource "aws_route53_record" "instances" {
  for_each = var.components
  zone_id = var.zone_id
  name    = "${each.key}-dev"
  type    = var.dns_type
  ttl     = var.ttl
  records = [aws_instance.instances[each.key].private_ip]
}


