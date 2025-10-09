# https://help.aliyun.com/document_detail/40654.html#section-jn7-0pl-ra9
# https://infrastructure.aliyun.com/?spm=a2c4g.11186623.0.0.5a381017VhCLUU
# export ALICLOUD_ACCESS_KEY=xxxxx
# export ALICLOUD_SECRET_KEY=xxxxx
provider "alicloud" {
  region = "cn-hongkong"
  # 中国香港 cn-hongkong / 日本（东京） ap-northeast-1 / 韩国（首尔）ap-northeast-2 / 新加坡 ap-southeast-1 / 泰国（曼谷） ap-southeast-7
  # 美国（弗吉尼亚） us-east-1 / 美国（硅谷） us-west-1 / 墨西哥 na-south-1 / 英国（伦敦） eu-west-1 / 阿联酋（迪拜） me-east-1
  # 德国（法兰克福） eu-central-1 / 马来西亚（吉隆坡） ap-southeast-3 / 菲律宾（马尼拉） ap-southeast-6 / 印度尼西亚（雅加达） ap-southeast-5
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "vpc" {
  vpc_name = "terraform_test_vpc"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_security_group" "default" {
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

resource "alicloud_security_group_rule" "allow_all_udp" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

data "alicloud_instance_types" "type" {
  availability_zone = data.alicloud_zones.default.zones[0].id
  sorted_by         = "Price"
  #instance_type_family = "ecs.g8y" # ecs.c8y / ecs.g8y / ecs.t6-c2m1 / ecs.e-c4m1
  is_outdated       = false
  #cpu_core_count    = 1
  memory_size = 0.5
  spot_strategy = "SpotAsPriceGo"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/21"
  zone_id      = data.alicloud_zones.default.zones[0].id
}

data "alicloud_images" "default" {
  name_regex  = "^ubuntu_18_04_.*"
  most_recent = true
  instance_type         = data.alicloud_instance_types.type.instance_types.0.id
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
  system_disk_size 	= 20
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
      "uptime",
      "ufw disable",
      "sudo apt-get update",
      "sudo apt-get install -y iftop docker.io",
      "VPN_IPSEC_PSK=yMby685nm4a9gdJv2ny4 VPN_USER=vpnuser VPN_PASSWORD=7dXBRbuZyxgKZwzv VPN_ANDROID_MTU_FIX=yes VPN_L2TP_NET=10.1.0.0/16 VPN_L2TP_LOCAL=10.1.0.1 VPN_L2TP_POOL=10.1.0.10-10.1.254.254 VPN_XAUTH_NET=10.2.0.0/16 VPN_XAUTH_POOL=10.2.0.10-10.2.254.254 docker run --name vpn-server --restart=always -v ikev2-vpn-data:/etc/ipsec.d -v /lib/modules:/lib/modules:ro -p 500:500/udp -p 4500:4500/udp -d --privileged hwdsl2/ipsec-vpn-server",
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
