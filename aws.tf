provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "/home/ubuntu/.aws/credentials"
  profile    = "default"
}

data "template_file" "phpconfig" {
  template = file("files/conf.wp-config.php")

  vars = {
    db_port = aws_db_instance.mysql.port
    db_host = aws_db_instance.mysql.address
    db_user = var.username
    db_pass = var.password
    db_name = var.dbname
  }
}

resource "aws_db_instance" "mysql" {
  identifier           = "wordpressdb"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = var.dbname
  username             = var.username
  password             = var.password
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = ["sg-03b2a155af29b9e4c"]
}

resource "aws_instance" "ec2" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  depends_on = [
    aws_db_instance.mysql,
  ]
  user_data = file("userdata.sh")
  tags = {
  Name = "WPTerraform"
  }
  security_groups = [
    "WebServer",
  ]
  key_name = "AWSEducateTIUKDW"
  root_block_device {
    delete_on_termination = true
    iops = 3000
    volume_size = 8
    volume_type = "gp3"
  }

  provisioner "file" {
    source      = "userdata.sh"
    destination = "/tmp/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = key_name
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "/tmp/userdata.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = key_name
      }
  }

  provisioner "file" {
    content     = data.template_file.phpconfig.rendered
    destination = "/tmp/wp-config.php"

  connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = key_name
    }
  }

provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/wp-config.php /var/www/html/wp-config.php",
    ]

connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = key_name
    }
    }
}