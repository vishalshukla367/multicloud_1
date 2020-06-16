provider "aws" {
  region   = "ap-south-1"
  profile  = "shukla"
}

resource "aws_security_group" "security11" {
  name        = "security11"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-de869bb6 "

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22	
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security11"
  }
}




resource "aws_instance" "web"{
 ami		= "ami-0447a12f28fddb066"
 instance_type  =  "t2.micro"
 key_name       =  "firstkey"
 security_groups = ["security11"]

connection {
 type  = "ssh"
 user  = "ec2-user"
 private_key = file("C:/Users/shukl/Downloads/firstkey.pem")
 host     = aws_instance.web.public_ip
}
 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

 tags = {
    Name = "task1os"
  }
}

resource "aws_ebs_volume" "vol" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1
  tags = {
    Name = "OperatingSystem"
  }
}
resource "aws_volume_attachment" "vol_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.vol.id}"
  instance_id = "${aws_instance.web.id}"
  force_detach = true
}
output "os_ip" {
  value = aws_instance.web.public_ip
}



resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.web.public_ip} > publicip1.txt"
  	}
}





resource "null_resource" "null_r"  {

depends_on = [
    aws_volume_attachment.vol_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/shukl/Downloads/firstkey.pem")
    host     = aws_instance.web.public_ip
  }


provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/vishalshukla367/multicloud_1.git /var/www/html/"
    ]
  }
}




resource "null_resource" "nullloca2122"  {
  provisioner "local-exec" {
      command = "git clone https://github.com/vishalshukla367/multicloud_1.git ./gitcode"
    }
}  


resource "aws_s3_bucket" "fold1997" {
  bucket = "fold1997"
  acl    = "public-read"
  tags = {
      Name = "fold1997"
      Environment = "Dev"
  }
}



output "bucket" {
  value = aws_s3_bucket.fold1997
}



resource "aws_s3_bucket_object" "bucket_obj" {
  bucket = "${aws_s3_bucket.fold1997.id}"
  key    = "vishal.jpg"
  source = "./gitcode/vishal.jpg"
  acl	 = "public-read"
}




resource "aws_cloudfront_distribution" "cfd" {
  origin {
    domain_name = "${aws_s3_bucket.fold1997.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.fold1997.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 Web Distribution"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.fold1997.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"]
    }
  }

  tags = {
    Name        = "Web-CF-Distribution"
    Environment = "Production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    aws_s3_bucket.fold1997
  ]
}



resource "aws_ebs_snapshot" "ebs_snapshot" {
  volume_id   = "${aws_ebs_volume.vol.id}"
  description = "Snapshot of my EBS volume"
  
  tags = {
    env = "Production"
  }

  depends_on = [
    aws_volume_attachment.vol_att
  ]
}


resource "null_resource" "res_null"  {


depends_on = [
    null_resource.null_r,
  ]

	provisioner "local-exec" {
	    command = "start chrome  ${aws_instance.web.public_ip}"
  	}
}
