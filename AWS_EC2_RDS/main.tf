provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

locals {
  tags = {
    Environment = var.environment
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "subnet_az1" {
  availability_zone = "us-east-1a"
  vpc_id            = data.aws_vpc.default.id
}

data "aws_subnet" "subnet_az2" {
  availability_zone = "us-east-1b"
  vpc_id            = data.aws_vpc.default.id
}

# Fetch the latest AMI

data "aws_ami" "amazon2" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-ebs"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SG for Instance

resource "aws_security_group" "instance_sg" {
  name_prefix = "Sg_Instance"
  description = "Web Traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(
    local.tags,
    {
      "Name" = "Sg-Instance"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ec2_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance_sg.id
}

resource "aws_security_group_rule" "ec2_ingress_443" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance_sg.id
  description       = "Ingress from 0.0.0.0/0 (TCP:443)"
}

resource "aws_security_group_rule" "ec2_ingress_22" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["107.22.40.20/32", "18.215.226.36/32"]
  security_group_id = aws_security_group.instance_sg.id
  description       = "Ingress to allow SSH (TCP:22)"
}

# SG for RDS

resource "aws_security_group" "rds_sg" {
  description = "Database traffic"
  name        = "Sg_Database"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(
    local.tags,
    {
      Name = "Sg-Database"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_sg.id
}

resource "aws_security_group_rule" "rds_ingress" {
  type                     = "ingress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instance_sg.id
  security_group_id        = aws_security_group.rds_sg.id
  description              = "Ingress from Ec2(TCP:3306)"
}

resource "aws_instance" "ec2_instance" {

  ami                    = data.aws_ami.amazon2.image_id
  instance_type          = var.instance_type
  key_name               = var.key_pair
  subnet_id              = data.aws_subnet.subnet_az1.id
  tags                   = local.tags
  volume_tags            = local.tags
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  root_block_device {
    volume_type = var.primary_ebs_volume_type
    volume_size = var.primary_ebs_volume_size
    encrypted   = var.encrypt_primary_ebs_volume
    kms_key_id  = var.encrypt_primary_ebs_volume && var.encrypt_primary_ebs_volume_kms_id != "" ? var.encrypt_primary_ebs_volume_kms_id : null
  }
}

# RDS

resource "aws_db_subnet_group" "db_subnet_group" {
  description = "Database subnet group for ${var.db_name}"
  name_prefix = "${var.db_name}-"

  subnet_ids = [
    data.aws_subnet.subnet_az1.id,
    data.aws_subnet.subnet_az2.id
  ]

  tags = local.tags
}

resource "aws_db_parameter_group" "db_parameter_group" {
  description = "Database parameter group for ${var.name}"
  name_prefix = "${var.db_name}-"
  family      = "mysql5.7"
  tags        = local.tags
}

resource "random_string" "password" {
  length      = 16
  min_numeric = 1
  min_lower   = 1
  min_upper   = 1
  special     = false
}

resource "aws_secretsmanager_secret" "db_aws_secret" {
  name = "${var.db_name}-secret-manager"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "version" {
  secret_id = aws_secretsmanager_secret.db_aws_secret.id

  secret_string = <<EOF
   {
    "username": "dbadmin",
    "password": "${random_string.password.result}"
   }
EOF
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.medium"
  identifier             = var.db_name
  username               = "dbadmin"
  password               = random_string.password.result
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}