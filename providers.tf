# https://help.aliyun.com/document_detail/40654.html#section-jn7-0pl-ra9
# https://infrastructure.aliyun.com/?spm=a2c4g.11186623.0.0.5a381017VhCLUU
provider "alicloud" {
#   access_key = "xxxxxx"
#   secret_key = "xxxxxx"
  #region = "us-east-1"
  #region = "us-west-1"
  region = "ap-northeast-1"
  #region = "cn-beijing"
}

resource "alicloud_vpc" "vpc" {
  vpc_name = "terraform_test_vpc"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_security_group" "default" {
  name = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

data "alicloud_instance_types" "type" {
  availability_zone = data.alicloud_zones.default.zones[0].id
  cpu_core_count    = 1
  memory_size       = 0.5
  #cpu_core_count    = 4
  #memory_size       = 8
}

resource "alicloud_vswitch" "vsw" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/21"
  zone_id      = data.alicloud_zones.default.zones[0].id
}

data "alicloud_images" "default" {
  name_regex  = "^centos.*"
  most_recent = false
  owners      = "system"
}

resource "alicloud_instance" "instance" {
  vswitch_id 		= alicloud_vswitch.vsw.id
  security_groups 	= alicloud_security_group.default.*.id
  availability_zone 	= data.alicloud_zones.default.zones[0].id
  instance_type         = data.alicloud_instance_types.type.instance_types.0.id
  image_id             	= data.alicloud_images.default.images[0].id
  instance_charge_type 	= "PostPaid"
  internet_charge_type 	= "PayByTraffic"
  instance_name        	= "terraform_test_ecs"
  system_disk_size 	= 40
  password 		= "Admin123"
  system_disk_performance_level = "PL0"
  internet_max_bandwidth_out = 5

  connection {
      type     = "ssh"
      user     = "root"
      password = "Admin123"
      host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y iftop",
    ]
  }
  provisioner "local-exec" {
    when    = destroy
    command = "./config_script/des_command.sh"
  }
  provisioner "local-exec" {
    command = "./config_script/command.sh"
    environment = {
      PubIP = self.public_ip
    }
  }
}

output "public_ip" {
  value = alicloud_instance.instance.public_ip
}

output "private_ip" {
  value = alicloud_instance.instance.private_ip
}
