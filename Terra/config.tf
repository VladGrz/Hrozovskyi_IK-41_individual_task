provider "aws" {
  access_key = "<Replace with your access_key>"
  secret_key = "<Replace with your secret_key>"
  region = "us-east-1"
}
data "aws_ami" "ubuntu-linux-2004" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_key_pair" "individual_keypair" {
  key_name           = "<Replace with your key_name>"
  include_public_key = true
}

variable "vm_names" {
  type    = list(string)
  default = ["bot", "redis", "web"]
}

variable "instance_type" {
  default = "t2.micro"
} 
resource "aws_instance" "ec2_instance" {
  count = 3
  ami = data.aws_ami.ubuntu-linux-2004.id
  instance_type = "${var.instance_type}"
  key_name = data.aws_key_pair.individual_keypair.key_name
  tags = {
    Name = "Terra_${element(var.vm_names,count.index)}"
  }
}

resource "aws_eip" "eip" {
  count = 3
  instance = aws_instance.ec2_instance[count.index].id
  vpc = true
}

output "bot_ip" {
  value = "${aws_instance.ec2_instance[0].public_ip}"
}
output "redis_ip" {
  value = "${aws_instance.ec2_instance[1].public_ip}"
}
output "web_ip" {
  value = "${aws_instance.ec2_instance[2].public_ip}"
}


