variable "aws_account_id" {
  description = "AWS account id for the deployment"
  type        = string
}

variable "db_name" {
  description = "Name to be used for the provisioned RDS instance(s) and related resources"
  type        = string
}

variable "encrypt_primary_ebs_volume" {
  description = "Encrypt root EBS Volume? true or false"
  type        = bool
  default     = false
}

variable "encrypt_primary_ebs_volume_kms_id" {
  description = "If `encrypt_primary_ebs_volume` is `true` you can optionally provide a KMS CMK ARN."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test"
  type        = string
  default     = "Development"
}

variable "instance_type" {
  description = "EC2 Instance Type e.g. 't2.micro'"
  type        = string
  default     = "t2.micro"
}

variable "key_pair" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = string
  default     = ""
}

variable "name" {
  description = "Name to be used for the provisioned EC2 instance(s)"
  type        = string
}

variable "primary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = number
  default     = 60
}

variable "primary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = string
  default     = "gp2"
}


variable "region" {
  description = "The region for the environment"
  type        = string
}