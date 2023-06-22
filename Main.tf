terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.4.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  access_key = "AKIA37JFWFK6P72UB2PC"
  secret_key = "zoQrm/Jn9ycgKarOIln8pzbjFoBgRv/piH2opreS"

}

resource "aws_placement_group" "test" {
  name     = "test"
  strategy = "cluster"
}


resource "aws_ami" "example" {
  name                = "terraform-example"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
  imds_support        = "v2.0" # Enforce usage of IMDSv2. You can safely remove this line if your application explicitly doesn't support it.
  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = "snap-xxxxxxxx"
    volume_size = 8
  }
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = resource.aws_ami.example.id
  instance_type = "t2.micro"
  associate_public_ip_address = false
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}