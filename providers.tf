# https://help.aliyun.com/document_detail/40654.html#section-jn7-0pl-ra9
# https://infrastructure.aliyun.com/?spm=a2c4g.11186623.0.0.5a381017VhCLUU
# export ALICLOUD_ACCESS_KEY=xxxxx
# export ALICLOUD_SECRET_KEY=xxxxx
provider "alicloud" {
  region = "ap-northeast-1" # cn-beijing / us-east-1 / us-west-1 / ap-northeast-1
}

resource "alicloud_vpc" "vpc" {
  vpc_name = "terraform_test_vpc"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_security_group" "default" {
  name   = "default"
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
  available_resource_creation = "VSwitch"
}

data "alicloud_instance_types" "type" {
  availability_zone = data.alicloud_zones.default.zones[0].id
  sorted_by         = "Price"
  is_outdated       = false
  cpu_core_count    = 2
  memory_size       = 2
}

resource "alicloud_vswitch" "vsw" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/21"
  zone_id      = data.alicloud_zones.default.zones[0].id
}

data "alicloud_images" "default" {
  name_regex  = "^ubuntu_18.*"
  most_recent = true
  owners      = "system"
}

resource "alicloud_instance" "instance" {
  vswitch_id 		= alicloud_vswitch.vsw.id
  security_groups 	= alicloud_security_group.default.*.id
  availability_zone 	= data.alicloud_zones.default.zones[0].id
  instance_type         = data.alicloud_instance_types.type.instance_types.0.id
  image_id             	= data.alicloud_images.default.images[0].id
  instance_charge_type 	= "PostPaid"
  internet_charge_type 	= "PayByBandwidth" # PayByBandwidth / PayByTraffic
  instance_name        	= "terraform_test_ecs"
  system_disk_size 	= 40
  password 		= "Admin123"
  system_disk_performance_level = "PL0"
  spot_strategy         = "SpotAsPriceGo"
  system_disk_category  = "cloud_auto"
  internet_max_bandwidth_out = 1

  connection {
      type     = "ssh"
      user     = "root"
      password = "Admin123"
      host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y iftop docker.io",
    ]
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
