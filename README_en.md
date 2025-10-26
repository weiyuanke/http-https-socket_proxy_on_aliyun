# HTTP/HTTPS/SOCKS/VPN Proxy on Alibaba Cloud

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

A lightweight, on-demand HTTP/HTTPS/SOCKS/VPN proxy built on Alibaba Cloud (ECS), using Terraform and Bash. Scales with pay-as-you-go pricing.

## Features

- 🚀 **One-Click Deployment**: Quick creation and destruction of proxy and VPN services
- 💰 **Pay-as-you-go**: Pay-per-minute pricing based on Alibaba Cloud pay-as-you-go ECS instances
- 🔒 **Multi-Protocol Support**: Supports SOCKS5, HTTP, HTTPS proxy and IPsec/L2TP, Cisco IPsec, IKEv2 VPN
- 🌍 **Global Deployment**: Can be deployed in multiple Alibaba Cloud regions
- 🖥️ **Multi-Platform Support**: Supports macOS and Linux systems
- 📦 **Flexible Deployment Modes**: Supports proxy-only deployment or simultaneous proxy and VPN deployment
- 💡 **Smart Instance Selection**: Automatically selects most economical instance types, optimizing costs with Spot instance strategy

## How It Works

1. Automatically creates a pay-as-you-go ECS instance on Alibaba Cloud using Terraform
2. Configures security group rules to open necessary ports
3. Establishes SSH connection with the remote server to provide socket proxy service locally
4. On-demand automatic deployment of VPN services on the remote server
5. Starts SOCKS-to-HTTP proxy conversion service locally
6. Automatically configures system proxy settings

## System Requirements

- macOS or Linux operating system (including mainstream distributions like Ubuntu, Debian, Fedora)
- Alibaba Cloud account with Access Key ID and Secret Access Key

## Quick Start

### 1. Set Alibaba Cloud Credentials

```bash
export ALICLOUD_ACCESS_KEY="your-access-key-id"
export ALICLOUD_SECRET_KEY="your-secret-access-key"
```

### 2. Install Dependencies

```bash
./install.sh
```

This script will automatically install the following dependencies:
- Terraform (Infrastructure as Code tool)
- sshpass (SSH auto-login tool)
- Homebrew (macOS, if not installed)

The script supports multiple Linux distributions, including Ubuntu/Debian and Fedora.

### 3. Start Proxy and VPN Service

#### Deploy proxy + VPN service (default)
```bash
./start_proxy.sh
```

#### Deploy proxy service only (no VPN)
```bash
./start_proxy.sh --no-vpn
```
or
```bash
./start_proxy.sh -n
```

The script will:
- Create an ECS instance on Alibaba Cloud
- Deploy IPsec VPN service on the remote server on-demand
- Configure local SOCKS to HTTP proxy conversion
- Automatically set system proxy

After successful startup, you will see output similar to:
```
start configuring proxy
Public IP: x.x.x.x
export HTTP_PROXY=socks5h://127.0.0.1:9002 HTTPS_PROXY=socks5h://127.0.0.1:9002
export HTTP_PROXY=http://127.0.0.1:8080 HTTPS_PROXY=http://127.0.0.1:8080

VPN Configuration (if VPN enabled)
IP Address: x.x.x.x
username: vpn
password: Admin123
IPsec PSK: Admin123
```

## Usage

After the service starts, the system will automatically configure the following services:

### Proxy Services
- **SOCKS5 Proxy**: `127.0.0.1:9002`
- **HTTP/HTTPS Proxy**: `127.0.0.1:8080` (via local conversion tool)

You can also manually set environment variables:
```bash
# SOCKS5 Proxy
export HTTP_PROXY=socks5h://127.0.0.1:9002
export HTTPS_PROXY=socks5h://127.0.0.1:9002

# HTTP Proxy (via local conversion tool)
export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
```

### Local SOCKS to HTTP Conversion Tool
The project includes the `socket_to_http/socks2http` tool that converts local SOCKS5 proxy to HTTP/HTTPS proxy:
- Listens on port 8080 (HTTP/HTTPS proxy)
- Listens on port 9002 (SOCKS5 proxy)
- Converts SOCKS5 traffic to HTTP/HTTPS traffic for applications that don't support SOCKS proxy

### VPN Service
The deployed VPN server supports three VPN protocols: IPsec/L2TP, Cisco IPsec, and IKEv2, with the following configuration:
- **Server Address**: Public IP address
- **Username**: `vpn`
- **Password**: `Admin123`
- **Pre-Shared Key (PSK)**: `Admin123`

#### IPsec/L2TP VPN Configuration
L2TP over IPsec provides traditional compatibility, suitable for most devices.

**iOS/macOS Configuration:**
1. Settings > General > VPN & Device Management > VPN
2. Add VPN Configuration
3. Type select "IPSec"
4. Description: Custom name
5. Server: Public IP address
6. Account: `vpn`
7. Password: `Admin123`
8. Secret: `Admin123`
9. Save and connect

**Android Configuration:**
1. Settings > Network & Internet > VPN
2. Add VPN
3. Type select "L2TP/IPSec PSK"
4. Name: Custom name
5. Server address: Public IP address
6. IPSec pre-shared key: `Admin123`
7. Save and connect

#### Cisco IPsec VPN Configuration
For network environments requiring Cisco compatibility.

**Configuration Steps:**
1. Use Cisco IPsec compatible client
2. Server address: Public IP address
3. Pre-shared key: `Admin123`
4. Username: `vpn`
5. Password: `Admin123`

#### IKEv2 VPN Configuration
IKEv2 protocol provides better performance, security, and connection stability.

**iOS/macOS Configuration:**
1. Settings > General > VPN & Device Management > VPN
2. Add VPN Configuration
3. Type select "IKEv2"
4. Description: Custom name
5. Server: Public IP address
6. Remote ID: Public IP address
7. Local ID: Leave empty
8. User Authentication: Username
9. Username: `vpn`
10. Password: `Admin123`
11. Save and connect

**Windows Configuration:**
1. Settings > Network & Internet > VPN > Add a VPN connection
2. Provider: Windows (built-in)
3. Connection name: Custom name
4. Server name or address: Public IP address
5. VPN type: IKEv2
6. Type of sign-in info: Username and password
7. Username: `vpn`
8. Password: `Admin123`
9. Save and connect

**Android Configuration:**
Some Android devices natively support IKEv2, others may need to install third-party VPN clients.

## Configuration

Default configuration is defined in the [providers.tf](providers.tf) file:

- **Region**: `eu-central-1` (Frankfurt, Germany, can be modified as needed)
- **Instance Type**: Automatically selects most economical 1-core instance (using Spot instance strategy to reduce costs)
- **Image**: Ubuntu 18.04 system image
- **Network**: Automatically creates VPC and VSwitch
- **Security Group**: Opens all TCP/UDP ports (1-65535)
- **Billing**: Pay-as-you-go, Spot instance strategy
- **VPN Service**: Based on hwdsl2/ipsec-vpn-server Docker image (optional deployment)

## Parameters

### start_proxy.sh Parameters
- `--vpn`, `-v`: Deploy VPN service (default)
- `--no-vpn`, `-n`: Do not deploy VPN service, only run basic proxy
- `--timeout`, `-t`: Proxy runtime (seconds), default 3600 seconds
- `--help`, `-h`: Show help information

### providers.tf Configurable Parameters
Modify the following parameters to customize deployment:
- `region`: Alibaba Cloud region (e.g., `cn-hongkong`, `us-east-1`, `eu-central-1`, etc.)
- `instance_type`: ECS instance type
- `image_id`: System image ID
- `internet_max_bandwidth_out`: Internet bandwidth

## Runtime Behavior

When `start_proxy.sh` runs, it:
1. Forwards the remote server's SOCKS proxy to local port 9002 via SSH tunnel
2. Starts `socket_to_http/socks2http` to convert SOCKS5 traffic to HTTP/HTTPS traffic
3. Configures system proxy (macOS uses `networksetup`, Linux uses `gsettings`)
4. Displays detailed proxy and VPN configuration information
5. Continuously monitors remote server connection and displays network usage

## Notes

1. Ensure your Alibaba Cloud account has sufficient balance and permissions
2. After use, be sure to run `./destroy_proxy.sh` to destroy resources
3. Default region is `eu-central-1`, can be modified in `providers.tf` file
4. Local proxy conversion tool runs continuously, can be viewed in system activity monitor
5. VPN service defaults to simple authentication information, change passwords in production
6. VPN service uses all network ports (1-65535), adjust security group settings as needed
7. Using Spot instance strategy can significantly reduce costs, but the instance may be reclaimed when resources are tight

## Troubleshooting

### 1. Permission Issues

If encountering permission issues, please check:
```bash
# Ensure scripts have execute permissions
chmod +x *.sh
chmod +x socket_to_http/*
```

### 2. Network Connection Issues

If proxy or VPN cannot connect, please check:
- Whether Alibaba Cloud security group rules are configured correctly
- Whether local firewall blocks port access
- Whether ECS instance is successfully created and running
- Whether VPN service starts successfully on remote server

### 3. VPN Connection Issues

If VPN connection fails, please check:
- Whether username, password, and PSK are correct
- Whether device VPN configuration is correct
- Whether firewall blocks VPN ports (UDP 500, 4500, etc.)
- Whether VPN service runs normally on remote server

### 4. System Proxy Configuration Issues

macOS system proxy configuration uses `networksetup` command, if having issues can be reset manually:
```bash
networksetup -setsocksfirewallproxystate "Wi-Fi" off
networksetup -setdnsservers "Wi-Fi" empty
```

### 5. SSH Connection Issues

If SSH tunnel establishment fails:
- Check if remote server is started and assigned public IP
- Verify username and password are correct (default password is `Admin123`)
- Ensure security group rules allow SSH connection (port 22)

## Custom Configuration

### Modify VPN Authentication Information
Edit the `VPN_IPSEC_PSK`, `VPN_USER`, and `VPN_PASSWORD` variables in the `config_script/remote.sh` file.

### Change Alibaba Cloud Region
Modify the `region` parameter in `providers.tf` file, supports the following regions:
- `cn-hongkong` Hong Kong, China
- `eu-central-1` Germany (Frankfurt) - default
- `ap-northeast-1` Japan (Tokyo)
- `ap-southeast-1` Singapore
- `us-east-1` US (Virginia)
- `us-west-1` US (Silicon Valley)
- More regions please refer to Alibaba Cloud official documentation

### Modify Instance Type
In `providers.tf`, you can modify the parameters of the `data.alicloud_instance_types` data source:
- `memory_size`: Adjust memory specifications
- `cpu_core_count`: Adjust CPU core count
- `instance_type_family`: Specify instance type family

## Security Recommendations

1. **Credential Security**: Do not hardcode Alibaba Cloud credentials in code, always use environment variables
2. **Default Passwords**: Change default passwords (`Admin123`) in production environments
3. **Access Control**: Limit security group access scope in production environments, avoid opening all ports
4. **VPN Security**: Regularly change VPN passwords and pre-shared keys
5. **Monitoring**: Regularly check instance resource usage and network traffic

## Destroy Service

After use, be sure to destroy resources to avoid unnecessary charges:

```bash
./destroy_proxy.sh
```

This script will:
- Reset system proxy settings
- Terminate local SOCKS to HTTP conversion processes
- Disconnect proxy connection
- Destroy ECS instance and related resources on Alibaba Cloud

## License

This project is licensed under the MIT License, see the [LICENSE](LICENSE) file for details.