provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "random_id" "server" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = var.ami_id
  }

  byte_length = 8
}

data "aws_ami" "debian" {
  most_recent = true
  tags = merge(
        local.common_tags,

        tomap(
          {"Zoo" = "AWS Zoofarm"
          "RESOURCE" = "ubuntu server"
          }
        )
        )
  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-2021-03-09-67077"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["379101102735"] # Debian


}


resource "aws_instance" "webserver" {
  tags = merge(
        local.common_tags,

        tomap(
          {"Zoo" = "AWS Zoofarm"
           "Name" = "${var.myname}-${random_id.server.hex}-${count.index + 1}"
           "RESOURCE" = "webserver AMI"
          }
        )
        )
  ami                         = data.aws_ami.debian.id
  availability_zone           = var.avail_zone
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.terraform_pub_key.key_name
  vpc_security_group_ids      = [aws_security_group.allowall.id]
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  user_data = "${file("install_userdata_debian.sh")}"
  count = var.instance_count
#  provisioner "remote-exec" {
#    inline = [
#      "sudo apt update",
#      "sudo apt-get -y install python",
#      "sudo apt-get -y install software-properties-common",
#      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
#      "sudo apt-get -y install ansible",
#      "cd ansible; ansible-playbook -vvv -c local -i \"localhost,\" armor.yml",
#      "sudo apt-get install curl unzip",
#      "sudo apt-get jq"
#    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
    }
  #}
  #Don't comment out this next line.
}
