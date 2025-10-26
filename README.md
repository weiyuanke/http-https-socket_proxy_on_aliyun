# 快速在阿里云上部署，HTTP/HTTPS/SOCKS代理与VPN服务

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

**Read this in other languages: [English](README_en.md), [中文](README.md).**


基于阿里云的一键式代理和VPN服务，按分钟付费，快速部署，支持SOCKS、HTTP、HTTPS代理和多种VPN协议。

## 功能特性

- 🚀 一键部署：快速创建和销毁代理和VPN服务
- 💰 按需付费：基于阿里云按量付费ECS实例，仅在使用时计费
- 🔒 多协议支持：同时支持SOCKS5、HTTP、HTTPS代理和IPsec/L2TP、Cisco IPsec、IKEv2 VPN
- 🌍 全球部署：可部署在多个阿里云区域
- 🖥️ 多平台支持：支持macOS和Linux系统
- 📦 灵活部署模式：支持仅部署代理服务或同时部署VPN服务
- 💡 智能实例选择：自动选择最经济的实例类型，使用Spot实例策略优化成本

## 工作原理

1. 使用Terraform在阿里云上自动创建一台按量付费的ECS实例
2. 配置安全组规则，开放必要的端口
3. 通过SSH与远程服务器建立连接，为本地提供socket代理服务
4. 在远程服务器上按需自动部署VPN服务
5. 在本地启动SOCKS到HTTP的代理转换服务
6. 自动配置系统代理设置

## 系统要求

- macOS 或 Linux 操作系统 (包括 Ubuntu、Debian、Fedora 等主流发行版)
- 阿里云账号及Access Key ID和Secret Access Key

## 快速开始

### 1. 设置阿里云凭证

```bash
export ALICLOUD_ACCESS_KEY="your-access-key-id"
export ALICLOUD_SECRET_KEY="your-secret-access-key"
```

### 2. 安装依赖

```bash
./install.sh
```

此脚本将自动安装以下依赖：
- Terraform (基础设施即代码工具)
- sshpass (SSH自动密码登录工具)
- Homebrew (macOS, 如果未安装)

该脚本支持多种Linux发行版，包括Ubuntu/Debian和Fedora。

### 3. 启动代理和VPN服务

#### 部署代理+VPN服务（默认）
```bash
./start_proxy.sh
```

#### 仅部署代理服务（不部署VPN）
```bash
./start_proxy.sh --no-vpn
```
或
```bash
./start_proxy.sh -n
```

脚本将：
- 在阿里云上创建ECS实例
- 在远程服务器上按需部署IPsec VPN服务
- 配置本地SOCKS到HTTP代理转换
- 自动设置系统代理

启动成功后，你将看到类似以下的输出：
```
start configuring proxy
Public IP: x.x.x.x
export HTTP_PROXY=socks5h://127.0.0.1:9002 HTTPS_PROXY=socks5h://127.0.0.1:9002
export HTTP_PROXY=http://127.0.0.1:8080 HTTPS_PROXY=http://127.0.0.1:8080

VPN配置 (如果启用VPN)
IP地址: x.x.x.x
username: vpn
password: Admin123
IPsec PSK: Admin123
```

## 使用说明

服务启动后，系统将自动配置以下服务：

### 代理服务
- **SOCKS5代理**: `127.0.0.1:9002`
- **HTTP/HTTPS代理**: `127.0.0.1:8080` (通过本地转换工具)

你也可以手动设置环境变量：
```bash
# SOCKS5代理
export HTTP_PROXY=socks5h://127.0.0.1:9002
export HTTPS_PROXY=socks5h://127.0.0.1:9002

# HTTP代理 (通过本地转换工具)
export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
```

### 本地SOCKS到HTTP转换工具
项目包含了 `socket_to_http/socks2http` 工具，它将本地SOCKS5代理转换为HTTP/HTTPS代理：
- 监听端口 8080 (HTTP/HTTPS代理)
- 监听端口 9002 (SOCKS5代理)
- 可将SOCKS5流量转换为HTTP/HTTPS流量，便于不支持SOCKS代理的应用程序使用

### VPN服务
部署的VPN服务器支持三种VPN协议：IPsec/L2TP, Cisco IPsec 和 IKEv2，配置信息如下：
- **服务器地址**: 公网IP地址
- **用户名**: `vpn`
- **密码**: `Admin123`
- **预共享密钥 (PSK)**: `Admin123`

#### IPsec/L2TP VPN配置
L2TP over IPsec 提供传统兼容性，适用于大多数设备。

**iOS/macOS配置:**
1. 设置 > 通用 > VPN与设备管理 > VPN
2. 添加VPN配置
3. 类型选择 "IPSec"
4. 描述：自定义名称
5. 服务器：公网IP地址
6. 账户：`vpn`
7. 密码：`Admin123`
8. 密钥：`Admin123`
9. 保存并连接

**Android配置:**
1. 设置 > 网络和互联网 > VPN
2. 添加VPN
3. 类型选择 "L2TP/IPSec PSK"
4. 名称：自定义名称
5. 服务器地址：公网IP地址
6. IPSec预共享密钥：`Admin123`
7. 保存并连接

#### Cisco IPsec VPN配置
适用于需要Cisco兼容性的网络环境。

**配置步骤:**
1. 使用支持Cisco IPsec的客户端
2. 服务器地址：公网IP地址
3. 预共享密钥：`Admin123`
4. 用户名：`vpn`
5. 密码：`Admin123`

#### IKEv2 VPN配置
IKEv2协议提供更好的性能、安全性和连接稳定性。

**iOS/macOS配置:**
1. 设置 > 通用 > VPN与设备管理 > VPN
2. 添加VPN配置
3. 类型选择 "IKEv2"
4. 描述：自定义名称
5. 服务器：公网IP地址
6. 远程ID：公网IP地址
7. 本地ID：留空
8. 用户鉴定：用户名
9. 用户名：`vpn`
10. 密码：`Admin123`
11. 保存并连接

**Windows配置:**
1. 设置 > 网络和Internet > VPN > 添加VPN连接
2. 提供商：Windows内置
3. 连接名称：自定义名称
4. 服务器名称或地址：公网IP地址
5. VPN类型：IKEv2
6. 登录信息的类型：用户名和密码
7. 用户名：`vpn`
8. 密码：`Admin123`
9. 保存并连接

**Android配置:**
部分Android设备原生支持IKEv2，其他设备可能需要安装第三方VPN客户端。

## 配置说明

默认配置在 [providers.tf](providers.tf) 文件中定义：

- **区域**: `eu-central-1` (德国法兰克福，可根据需要修改)
- **实例类型**: 自动选择最经济的1核实例(使用Spot实例策略以降低成本)
- **镜像**: Ubuntu 18.04系统镜像
- **网络**: 自动创建VPC和VSwitch
- **安全组**: 开放所有TCP/UDP端口(1-65535)
- **计费模式**: 按量付费，Spot实例策略
- **VPN服务**: 基于 hwdsl2/ipsec-vpn-server Docker镜像（可选部署）

## 参数说明

### start_proxy.sh 参数
- `--vpn`, `-v`: 部署VPN服务（默认）
- `--no-vpn`, `-n`: 不部署VPN服务，仅运行基础代理
- `--timeout`, `-t`: 代理运行时间（秒），默认3600秒
- `--help`, `-h`: 显示帮助信息

### providers.tf 可配置参数
可修改以下参数以自定义部署：
- `region`: 阿里云区域（如 `cn-hongkong`, `us-east-1`, `eu-central-1` 等）
- `instance_type`: ECS实例类型
- `image_id`: 系统镜像ID
- `internet_max_bandwidth_out`: 公网带宽

## 运行时行为

当 `start_proxy.sh` 运行时，它会：
1. 通过SSH隧道将远程服务器的SOCKS代理转发到本地端口9002
2. 启动 `socket_to_http/socks2http` 将SOCKS5流量转换为HTTP/HTTPS流量
3. 配置系统代理（macOS使用 `networksetup`，Linux使用 `gsettings`）
4. 显示详细的代理和VPN配置信息
5. 持续监控远程服务器连接并显示网络使用情况

## 注意事项

1. 请确保阿里云账号有足够的余额和权限
2. 使用完毕后务必运行 `./destroy_proxy.sh` 销毁资源
3. 默认区域为 `eu-central-1`，可根据需要修改 `providers.tf` 文件
4. 本地代理转换工具会持续运行，可在系统活动监视器中查看
5. VPN服务默认使用较为简单的认证信息，生产环境请修改密码
6. VPN服务使用所有网络端口(1-65535)，请根据需要调整安全组设置
7. 使用Spot实例策略可显著降低成本，但实例可能在资源紧张时被回收

## 故障排除

### 1. 权限问题

如果遇到权限问题，请检查：
```bash
# 确保脚本具有执行权限
chmod +x *.sh
chmod +x socket_to_http/*
```

### 2. 网络连接问题

如果代理或VPN无法连接，请检查：
- 阿里云安全组规则是否正确配置
- 本地防火墙是否阻止了端口访问
- ECS实例是否成功创建并运行
- VPN服务是否在远程服务器上启动成功

### 3. VPN连接问题

如果VPN连接失败，请检查：
- 用户名、密码和PSK是否正确
- 设备的VPN配置是否正确
- 防火墙是否阻止了VPN端口(UDP 500, 4500等)
- 远程服务器上的VPN服务是否正常运行

### 4. 系统代理配置问题

macOS系统代理配置使用 `networksetup` 命令，如遇到问题可手动重置：
```bash
networksetup -setsocksfirewallproxystate "Wi-Fi" off
networksetup -setdnsservers "Wi-Fi" empty
```

### 5. SSH连接问题

如果SSH隧道建立失败：
- 检查远程服务器是否已启动并分配了公网IP
- 验证用户名密码是否正确（默认密码为 `Admin123`）
- 确保安全组规则允许SSH连接（端口22）

## 自定义配置

### 修改VPN认证信息
编辑 `config_script/remote.sh` 文件中的 `VPN_IPSEC_PSK`、`VPN_USER` 和 `VPN_PASSWORD` 变量。

### 更换阿里云区域
修改 `providers.tf` 文件中的 `region` 参数，支持以下区域：
- `cn-hongkong` 中国香港
- `eu-central-1` 德国（法兰克福）- 默认
- `ap-northeast-1` 日本(东京)
- `ap-southeast-1` 新加坡
- `us-east-1` 美国(弗吉尼亚)
- `us-west-1` 美国(硅谷)
- 更多区域请参考阿里云官方文档

### 修改实例类型
在 `providers.tf` 中，可以修改 `data.alicloud_instance_types` 数据源的参数：
- `memory_size`: 调整内存规格
- `cpu_core_count`: 调整CPU核心数
- `instance_type_family`: 指定实例类型族

## 安全建议

1. **凭证安全**: 不要在代码中硬编码阿里云凭证，始终使用环境变量
2. **默认密码**: 生产环境中请修改默认密码（`Admin123`）
3. **访问控制**: 在生产环境中限制安全组的访问范围，避免开放全部端口
4. **VPN安全**: 定期更换VPN密码和预共享密钥
5. **监控**: 定期检查实例的资源使用情况和网络流量

## 销毁服务

使用完毕后，请务必销毁资源以避免产生不必要的费用：

```bash
./destroy_proxy.sh
```

此脚本将：
- 重置系统代理设置
- 终止本地SOCKS到HTTP转换进程
- 断开代理连接
- 销毁阿里云上的ECS实例及相关资源

## 许可证

本项目采用MIT许可证，详情请见 [LICENSE](LICENSE) 文件。