# 快速在阿里云上部署，HTTP/HTTPS/SOCKS代理与VPN服务

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

基于阿里云的一键式代理和VPN服务，按分钟付费，快速部署，支持SOCKS、HTTP、HTTPS代理和多种VPN协议。

## 功能特性

- 🚀 一键部署：快速创建和销毁代理和VPN服务
- 💰 按需付费：基于阿里云按量付费ECS实例，仅在使用时计费
- 🔒 多协议支持：同时支持SOCKS5、HTTP、HTTPS代理和IPsec/L2TP、Cisco IPsec、IKEv2 VPN
- 🌍 全球部署：可部署在多个阿里云区域
- 🖥️ 多平台支持：支持macOS和Linux系统

## 工作原理

1. 使用Terraform在阿里云上自动创建一台按量付费的ECS实例
2. 配置安全组规则，开放必要的端口
3. 在远程服务器上自动部署IPsec VPN服务
4. 在本地启动SOCKS到HTTP的代理转换服务
5. 自动配置系统代理设置

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

```bash
./start_proxy.sh
```

脚本将：
- 在阿里云上创建ECS实例
- 在远程服务器上部署IPsec VPN服务
- 配置本地SOCKS到HTTP代理转换
- 自动设置系统代理

启动成功后，你将看到类似以下的输出：
```
start configuring proxy
Public IP: x.x.x.x
export HTTP_PROXY=socks5h://127.0.0.1:9002 HTTPS_PROXY=socks5h://127.0.0.1:9002
export HTTP_PROXY=http://127.0.0.1:8080 HTTPS_PROXY=http://127.0.0.1:8080

VPN配置
IP地址: x.x.x.x
username: vpn
password: Admin123
IPsec PSK: Admin123
```

## 使用说明

服务启动后，系统将自动配置以下服务：

### 代理服务
- **SOCKS5代理**: `127.0.0.1:9002`
- **HTTP/HTTPS代理**: `127.0.0.1:8080`

你也可以手动设置环境变量：
```bash
# SOCKS5代理
export HTTP_PROXY=socks5h://127.0.0.1:9002
export HTTPS_PROXY=socks5h://127.0.0.1:9002

# HTTP代理
export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
```

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

- **区域**: `cn-hongkong` (可修改为其他区域如 `cn-beijing`, `us-east-1`, `ap-northeast-1`)
- **实例类型**: 自动选择价格最低的1核实例
- **镜像**: Ubuntu 18.04系统镜像
- **网络**: 自动创建VPC和VSwitch
- **安全组**: 开放所有TCP/UDP端口(1-65535)
- **计费模式**: 按量付费，Spot实例策略
- **VPN服务**: 基于 hwdsl2/ipsec-vpn-server Docker镜像

## 注意事项

1. 请确保阿里云账号有足够的余额和权限
2. 使用完毕后务必运行 `./destroy_proxy.sh` 销毁资源
3. 默认区域为 `cn-hongkong`，可根据需要修改 `providers.tf` 文件
4. 本地代理转换工具会持续运行，可在系统活动监视器中查看
5. VPN服务默认使用较为简单的认证信息，生产环境请修改密码
6. VPN服务使用所有网络端口(1-65535)，请根据需要调整安全组设置

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
sudo networksetup -setsocksfirewallproxystate "Wi-Fi" off
sudo networksetup -setdnsservers "Wi-Fi" empty
```

## 自定义配置

### 修改VPN认证信息
编辑 `config_script/remote.sh` 文件中的 `VPN_IPSEC_PSK`、`VPN_USER` 和 `VPN_PASSWORD` 变量。

### 更换阿里云区域
修改 `providers.tf` 文件中的 `region` 参数，支持以下区域：
- `cn-hongkong` 中国香港
- `ap-northeast-1` 日本(东京)
- `ap-southeast-1` 新加坡
- `us-east-1` 美国(弗吉尼亚)
- `us-west-1` 美国(硅谷)
- 更多区域请参考阿里云官方文档

## 销毁服务

使用完毕后，请务必销毁资源以避免产生不必要的费用：

```bash
./destroy_proxy.sh
```

此脚本将：
- 重置系统代理设置
- 断开代理连接
- 销毁阿里云上的ECS实例及相关资源

## 许可证

本项目采用MIT许可证，详情请见 [LICENSE](LICENSE) 文件。
