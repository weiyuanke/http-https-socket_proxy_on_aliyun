# One-Click HTTP/HTTPS/SOCKS Proxy and VPN Service Deployment Tool on Alibaba Cloud

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Status](https://img.shields.io/badge/status-active-green.svg)

**Multi-language: [English](README_en.md), [中文](README.md).**

## 📋 Project Overview

This project provides a simple and efficient solution for **one-click deployment** of HTTP/HTTPS/SOCKS proxy and multiple VPN services on Alibaba Cloud. Using pay-as-you-go billing model, charges are calculated by the minute. Start when needed, destroy after use, significantly reducing usage costs.

Whether you need secure network access, bypass geographic restrictions, or build temporary secure channels, this tool can meet your needs while maintaining ease of use and cost control.

## ✨ Core Features

| Feature | Description |
|---------|-----------|
| 🚀 **One-Click Deployment** | Quickly create and destroy complete proxy and VPN services with a single command |
| 💰 **Pay-as-You-Go** | Based on Alibaba Cloud pay-as-you-go ECS instances, billed only when in use, cost controllable |
| 🔒 **Multi-Protocol Support** | Supports SOCKS5, HTTP, HTTPS proxy and IPsec/L2TP, Cisco IPsec, IKEv2 VPN simultaneously |
| 🌍 **Global Deployment** | Supports deployment in multiple Alibaba Cloud global regions to meet different network needs |
| 🖥️ **Multi-Platform Compatibility** | Supports macOS and mainstream Linux distributions (Ubuntu, Debian, Fedora, etc.) |
| 📦 **Flexible Configuration** | Supports proxy-only deployment or simultaneous proxy and VPN deployment, choose as needed |
| 💡 **Cost Optimization** | Automatically selects most economical instance types, uses Spot instance strategy to further reduce costs |
| ⚙️ **Auto Configuration** | Automatically configures system proxy settings, no need for manual application configuration |
| 🔄 **Protocol Conversion** | Built-in SOCKS to HTTP proxy conversion tool, compatible with various applications |

## 🔍 How It Works

This tool uses Infrastructure as Code (IaC) and automated deployment to quickly set up proxy and VPN services:

1. Automatically creates a pay-as-you-go ECS instance on Alibaba Cloud using Terraform
2. Configures security group rules to open necessary ports
3. Forwards the remote server's SOCKS proxy to local port via SSH tunnel
4. Automatically deploys VPN services on the remote server on demand (if enabled)
5. Starts SOCKS to HTTP proxy conversion service locally to support more applications
6. Automatically configures system proxy settings, applications require no additional configuration

## 📋 System Requirements

### Client Requirements
- **Operating System**: macOS or Linux distributions (Ubuntu, Debian, Fedora, etc.)
- **Software Dependencies**: Will be automatically installed via installation script
- **Account Requirements**: Alibaba Cloud account with valid Access Key credentials

### Alibaba Cloud Requirements
- Sufficient account balance to create pay-as-you-go ECS instances
- Permissions to create ECS, VPC, security groups, and other resources

## 🚀 Quick Start

### 1. Prepare Alibaba Cloud Credentials

First, set Alibaba Cloud access credentials as environment variables:

```bash
export ALICLOUD_ACCESS_KEY="your-access-key-id"
export ALICLOUD_SECRET_KEY="your-secret-access-key"
```

> 💡 **Tip**: You can add these environment variables to `.bashrc` or `.zshrc` files for permanent storage.

### 2. Install Dependencies

Run the installation script to automatically configure required dependencies:

```bash
./install.sh
```

This script will automatically install based on your operating system:
- Terraform (Infrastructure as Code tool)
- sshpass (SSH automatic password login tool)
- Necessary system tools
- Homebrew (macOS only, if not installed)

Supports multiple Linux distributions, including Ubuntu/Debian and Fedora.

### 3. Start Service

#### Deploy Complete Service (Proxy + VPN)
```bash
./start_proxy.sh
```

#### Deploy Proxy Service Only
```bash
./start_proxy.sh --no-vpn  # or use shorthand -n
```

#### Set Service Runtime (default 3600 seconds)
```bash
./start_proxy.sh --timeout 1800  # or use shorthand -t 1800
```

### 4. View Connection Information

After successful startup, you will see detailed proxy and VPN configuration information:

```
✅ Proxy service started
Public IP: x.x.x.x

🔌 Proxy Configuration:
- SOCKS5 Proxy: socks5h://127.0.0.1:9002
- HTTP/HTTPS Proxy: http://127.0.0.1:8080

🔒 VPN Configuration (if enabled):
- Server Address: x.x.x.x
- Username: vpn
- Password: Admin123
- IPsec PSK: Admin123
```

## 🛠️ Usage Guide

After the service starts, the system will automatically configure proxy settings. The following is a detailed usage guide:

### Proxy Service Usage

#### Automatic Configuration
The script will automatically configure system proxy settings, and most applications will automatically use these settings.

#### Manual Setup
If you need to manually set up proxy for specific applications, you can use the following environment variables:

```bash
# SOCKS5 Proxy
export HTTP_PROXY=socks5h://127.0.0.1:9002
export HTTPS_PROXY=socks5h://127.0.0.1:9002

# HTTP Proxy (via conversion tool)
export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
```

#### Proxy Service Addresses
- **SOCKS5 Proxy**: `127.0.0.1:9002`
- **HTTP/HTTPS Proxy**: `127.0.0.1:8080`

### Proxy Conversion Tool

The project includes a built-in SOCKS to HTTP conversion tool:

- Location: `socket_to_http/socks2http`
- Function: Converts SOCKS5 traffic to HTTP/HTTPS traffic
- Advantage: Enables applications that don't directly support SOCKS proxy to use proxy services
- Auto Start: Automatically started and managed by `start_proxy.sh` script

### Common Application Configuration Examples

#### Command Line Tools
```bash
# curl using proxy
curl -x socks5h://127.0.0.1:9002 https://example.com

# wget using proxy
wget -e use_proxy=yes -e http_proxy=127.0.0.1:8080 https://example.com
```

#### Git
```bash
# Configure Git to use proxy
git config --global http.proxy http://127.0.0.1:8080
git config --global https.proxy https://127.0.0.1:8080

# Unset Git proxy settings
git config --global --unset http.proxy
git config --global --unset https.proxy
```

## 🔒 VPN Service Usage

### VPN Configuration Information

The deployed VPN server supports three mainstream protocols, all using the same authentication information:

| Configuration Item | Value |
|-------------------|-------|
| Server Address | Public IP displayed after startup |
| Username | `vpn` |
| Password | `Admin123` |
| Pre-Shared Key (PSK) | `Admin123` |

### VPN Configuration Guide for Each Platform

#### IPsec/L2TP VPN Configuration

Compatibility solution suitable for most devices.

**iOS/macOS Configuration:**
1. Settings > General > VPN & Device Management > VPN
2. Add VPN Configuration
3. Type select "L2TP over IPSec"
4. Description: Enter a custom name (e.g., "Alibaba Cloud VPN")
5. Server: Enter the public IP address displayed by the startup script
6. Account: `vpn`
7. Password: `Admin123`
8. Secret: `Admin123`
9. Tap "Done" and connect

**Android Configuration:**
1. Settings > Network & Internet > VPN
2. Add VPN Configuration
3. Type select "L2TP/IPSec PSK"
4. Name: Enter a custom name
5. Server Address: Enter the public IP address
6. IPSec Pre-Shared Key: `Admin123`
7. Enter username and password
8. Save and connect

#### IKEv2 VPN Configuration

Provides better performance, security, and connection stability.

**iOS/macOS Configuration:**
1. Settings > General > VPN & Device Management > VPN
2. Add VPN Configuration
3. Type select "IKEv2"
4. Description: Enter a custom name
5. Server: Enter the public IP address
6. Remote ID: Enter the public IP address
7. Local ID: Leave empty
8. User Authentication: Select "Username"
9. Username: `vpn`
10. Password: `Admin123`
11. Tap "Done" and connect

**Windows Configuration:**
1. Settings > Network & Internet > VPN > Add VPN Connection
2. Provider: Windows (built-in)
3. Connection Name: Enter a custom name
4. Server Name or Address: Enter the public IP address
5. VPN Type: IKEv2
6. Type of Sign-In Info: Username and password
7. Username: `vpn`
8. Password: `Admin123`
9. Save and connect

#### Cisco IPsec VPN Configuration

Suitable for enterprise network environments requiring Cisco compatibility.

1. Use a VPN client that supports Cisco IPsec
2. Server Address: Enter the public IP address
3. Pre-Shared Key: `Admin123`
4. Username: `vpn`
5. Password: `Admin123`
6. Save and connect

> 🔒 **Security Warning**: Default VPN credentials are for testing only, please change passwords in production environment!

## ⚙️ Configuration

### Default Configuration Parameters

Default configuration is defined in the [providers.tf](providers.tf) file, main parameters include:

| Configuration Item | Default Value | Description |
|-------------------|--------------|-------------|
| Region | `eu-central-1` | Alibaba Cloud region, Frankfurt, Germany |
| Instance Type | Auto Select | Selects most economical 1-core instance |
| Instance Strategy | Spot Instance | Reduces costs, may be reclaimed |
| System Image | Ubuntu 18.04 | Stable and reliable Linux distribution |
| Network Configuration | Auto Create | Automatically creates VPC and VSwitch |
| Security Group Rules | All Ports Open | Opens all TCP/UDP ports (1-65535) |
| Billing Mode | Pay-as-You-Go | Charged by actual usage time |
| VPN Service | hwdsl2/ipsec-vpn-server | Docker-based VPN service |

## 📋 Parameter Description

### Startup Script Parameters

`start_proxy.sh` supports the following command-line parameters:

| Parameter | Shorthand | Description | Default Value |
|-----------|-----------|-------------|---------------|
| `--vpn` | `-v` | Deploy VPN service | Enabled |
| `--no-vpn` | `-n` | Do not deploy VPN service | Disabled |
| `--timeout` | `-t` | Proxy runtime (seconds) | 3600 seconds |
| `--help` | `-h` | Show help information | - |

### Configuration File Parameters

The following parameters can be modified in `providers.tf`:

| Parameter | Description | Recommended Values |
|-----------|-------------|-------------------|
| `region` | Alibaba Cloud region | `cn-hongkong`, `us-east-1`, `eu-central-1`, etc. |
| `instance_type` | ECS instance type | Can be adjusted as needed |
| `image_id` | System image ID | Ubuntu 18.04 or newer versions |
| `internet_max_bandwidth_out` | Public Network Bandwidth | Set as needed, default is 5Mbps |

### Supported Alibaba Cloud Regions

The following is a partial list of supported Alibaba Cloud regions:

- `cn-hongkong` - Hong Kong, China
- `eu-central-1` - Germany (Frankfurt) - Default
- `ap-northeast-1` - Japan (Tokyo)
- `ap-southeast-1` - Singapore
- `us-east-1` - United States (Virginia)
- `us-west-1` - United States (Silicon Valley)
- `ap-southeast-2` - Australia (Sydney)
- `eu-west-1` - United Kingdom (London)

> 💡 **Tip**: Prices and network latency may vary across regions, please choose the appropriate region based on actual needs.

## 🚦 Runtime Behavior

The startup script performs the following operations during execution:

1. Creates Alibaba Cloud ECS instance using Terraform
2. Configures security group rules to open necessary ports
3. Forwards remote server's SOCKS proxy to local port 9002 via SSH tunnel
4. (Optional) Deploys VPN service on remote server
5. Starts local SOCKS to HTTP conversion tool (port 8080)
6. Automatically configures system proxy settings:
   - macOS uses `networksetup` command
   - Linux uses `gsettings` command
7. Displays detailed proxy and VPN configuration information
8. Continuously monitors remote server connection status
9. Automatically cleans up resources when specified timeout is reached

> ℹ️ **Note**: The script will continuously occupy the terminal while running. Press Ctrl+C to terminate the service early.

## ⚠️ Important Notes

When using this tool, please pay attention to the following points:

1. **Account Balance**: Ensure Alibaba Cloud account has sufficient balance and permissions to create resources
2. **Resource Cleanup**: After use, be sure to run `./destroy_proxy.sh` to destroy resources and avoid unnecessary costs
3. **Region Selection**: Default region is `eu-central-1`, can be modified in `providers.tf` file based on network needs
4. **Process Management**: Local proxy conversion tool runs in background, can be viewed in system activity monitor
5. **Security Risk**: Default VPN credentials are simple (`Admin123`), must be changed in production environment
6. **Port Opening**: Current configuration opens all TCP/UDP ports, please adjust security group settings in production environment
7. **Instance Reclamation**: Using Spot instance strategy can significantly reduce costs, but may be reclaimed when resources are tight
8. **Network Costs**: Please note Alibaba Cloud traffic costs, large data transfers may generate additional fees
9. **Compliance**: Please comply with relevant laws and regulations and Alibaba Cloud service terms

## 🛠️ Troubleshooting

When encountering problems, please refer to the following solutions:

### 1. Script Permission Issues

```bash
# Ensure all scripts have execute permissions
chmod +x *.sh
chmod +x socket_to_http/*
```

### 2. Network Connection Failure

- **Check Security Group Rules**: Ensure Alibaba Cloud security groups are correctly configured and necessary ports are open
- **Check Local Firewall**: Confirm local firewall is not blocking port access
- **Verify Instance Status**: Check if ECS instance is successfully created and running normally
- **Test Basic Connection**: Try connecting directly to the instance using SSH

### 3. VPN Connection Issues

- **Verify Credentials**: Confirm username, password, and PSK are entered correctly
- **Check Port Opening**: Ensure UDP ports 500, 4500, and 1701 are open
- **Check VPN Service**: Use SSH to connect to server, confirm VPN service is running
- **View Logs**: Connect to server to view VPN service logs for detailed error information

### 4. System Proxy Configuration Errors

**macOS Manual Proxy Reset:**
```bash
networksetup -setsocksfirewallproxystate "Wi-Fi" off
networksetup -setwebproxystate "Wi-Fi" off
networksetup -setsecurewebproxystate "Wi-Fi" off
networksetup -setdnsservers "Wi-Fi" empty
```

**Linux Manual Proxy Reset:**
```bash
# For GNOME desktop
gsettings set org.gnome.system.proxy mode 'none'

# Clear environment variables
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
```

### 5. Resource Creation Failure

- **Check Account Permissions**: Confirm Alibaba Cloud account has permissions to create ECS, VPC, and other resources
- **Check Account Balance**: Ensure Alibaba Cloud account has sufficient balance
- **View Terraform Logs**: Check error output to get detailed failure reasons

### 6. Common Error Codes

| Error Code | Possible Cause | Solution |
|-----------|---------------|----------|
| InvalidAccessKeyId.NotFound | Access Key ID does not exist or format error | Check and reset ALICLOUD_ACCESS_KEY environment variable |
| InvalidAccessKeySecret.NotFound | Access Key Secret mismatch | Check and reset ALICLOUD_SECRET_KEY environment variable |
| Forbidden.NoStock | Insufficient resources in selected region | Try selecting another region or adjust instance type |
| Forbidden | Insufficient permissions | Confirm account has sufficient permissions to create related resources |

## 🎛️ Advanced Custom Configuration

### Modify VPN Authentication Information

To enhance security, it is recommended to modify default VPN credentials:

1. Edit the `config_script/remote.sh` file
2. Modify the following variables:
   ```bash
   # VPN Pre-Shared Key
   VPN_IPSEC_PSK="your-secure-psk"

   # VPN Username
   VPN_USER="your-vpn-username"

   # VPN Password
   VPN_PASSWORD="your-secure-password"
   ```
3. Save the file and restart the service

### Adjust Server Specifications

In `providers.tf`, you can adjust instance configuration to meet different needs:

```hcl
# Adjust instance type filter conditions
data "alicloud_instance_types" "default" {
  # Adjust CPU core count
  cpu_core_count = 2

  # Adjust memory size (GB)
  memory_size = 4

  # Adjust instance type family
  instance_type_family = "ecs.s6"
}
```

### Custom Security Group Rules

To limit port opening range, you can modify security group rules in `providers.tf`:

```hcl
# Custom security group rules
resource "alicloud_security_group_rule" "allow_common_ports" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"  # Only open SSH port
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# Add necessary ports for VPN
resource "alicloud_security_group_rule" "allow_vpn_ports" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "500/500,4500/4500,1701/1701"  # VPN ports
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}
```

### Adjust Network Configuration

```hcl
# Adjust public network bandwidth
resource "alicloud_instance" "default" {
  # ... other configurations ...
  internet_max_bandwidth_out = 10  # Set to 10Mbps
  # ... other configurations ...
}
```

## 🔐 Security Best Practices

To ensure your proxy and VPN services are secure and reliable, please follow these security recommendations:

### 1. Credential Management
- **Environment Variables**: Always use environment variables to store Alibaba Cloud credentials, avoid hardcoding
- **Key Rotation**: Regularly rotate Alibaba Cloud Access Keys
- **Least Privilege**: Assign minimum necessary permission scope to Access Keys

### 2. Password Security
- **Change Default Passwords**: Must change default passwords (`Admin123`) in production environment
- **Complex Passwords**: Use strong passwords containing uppercase, lowercase letters, numbers, and special characters
- **Regular Updates**: Regularly update VPN passwords and pre-shared keys

### 3. Network Security
- **Limit Access Scope**: Limit security group access source IPs in production environment
- **Port Minimization**: Only open necessary ports, avoid opening all ports (1-65535)
- **Encrypted Communication**: Ensure all proxy connections use encryption protocols

### 4. Operational Security
- **Prompt Destruction**: Immediately destroy resources after use to avoid idle resources being exploited
- **Regular Auditing**: Check account activity and resource usage
- **Monitor Anomalies**: Pay attention to monitoring abnormal network traffic and connection attempts

### 5. Compliance Usage
- **Comply with Regulations**: Ensure usage complies with local laws and regulations
- **Service Terms**: Comply with Alibaba Cloud service terms and acceptable use policies
- **Privacy Protection**: Do not transmit sensitive or personal privacy data unless properly encrypted

## 🗑️ Destroy Service

After use, please be sure to run the following command to destroy resources and avoid unnecessary costs:

```bash
./destroy_proxy.sh
```

The destroy script will perform the following operations:

1. Reset system proxy settings (macOS and Linux)
2. Terminate local SOCKS to HTTP conversion processes
3. Disconnect SSH connection to remote server
4. Use Terraform to destroy all resources on Alibaba Cloud, including:
   - ECS instances
   - VPC and network configurations
   - Security groups
   - Other related resources

> ⚠️ **Important**: If the startup script terminates abnormally, please also manually run the destroy script to clean up resources.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ❓ Frequently Asked Questions

### Q: Will using Spot instances affect service stability?
A: Yes, Spot instances may be reclaimed by Alibaba Cloud when resources are tight. If you need stable service, it is recommended to modify the configuration to use regular pay-as-you-go instances.

### Q: How to view service running status?
A: The startup script displays real-time status when running. You can also view ECS instance status through Alibaba Cloud console.

### Q: Can I deploy services in multiple regions simultaneously?
A: The current script is designed for single-region deployment, but you can copy the project directory and modify configurations to deploy in different regions separately.

### Q: How to modify the default timeout?
A: Use the `--timeout` parameter, for example `./start_proxy.sh --timeout 7200` to set timeout to 2 hours.

### Q: Does the proxy service support IPv6?
A: The current version is mainly optimized for IPv4 networks and does not fully support IPv6 functionality yet.

## 🤝 Contributing

Issues and Pull Requests are welcome! If you have any improvement suggestions or found problems, please feel free to submit them.

## 📧 Contact

If you have questions or suggestions, please contact us through the project's Issue page.

---

⭐ If you find this project helpful, please give us a Star!

---

*This tool is for legal purposes only, please comply with relevant laws, regulations, and service terms.*
