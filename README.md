# 阿里云 HTTP/HTTPS/SOCKS 代理与 VPN 服务一键部署工具

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Status](https://img.shields.io/badge/status-active-green.svg)

**多语言版本: [English](README_en.md), [中文](README.md).**

## 📋 项目简介

本项目提供了一个简单高效的解决方案，让您能够在阿里云上**一键部署**HTTP/HTTPS/SOCKS代理和多种VPN服务。使用按量付费模式，按分钟计费，随用随起，用完即销毁，极大地降低了使用成本。

无论您是需要安全的网络访问、绕过地域限制，还是构建临时的安全通道，本工具都能满足您的需求，同时保持使用简便和成本可控。

## ✨ 核心特性

| 特性 | 描述 |
|------|------|
| 🚀 **一键部署** | 只需一条命令，快速创建和销毁完整的代理和VPN服务 |
| 💰 **按需付费** | 基于阿里云按量付费ECS实例，仅在使用时计费，成本可控 |
| 🔒 **多协议支持** | 同时支持SOCKS5、HTTP、HTTPS代理和IPsec/L2TP、Cisco IPsec、IKEv2 VPN |
| 🌍 **全球部署** | 支持在多个阿里云全球区域部署，满足不同网络需求 |
| 🖥️ **多平台兼容** | 支持macOS和主流Linux发行版（Ubuntu、Debian、Fedora等） |
| 📦 **灵活配置** | 支持仅部署代理服务或同时部署VPN服务，按需选择 |
| 💡 **成本优化** | 自动选择最经济的实例类型，使用Spot实例策略进一步降低成本 |
| ⚙️ **自动配置** | 自动设置系统代理，无需手动配置应用程序 |
| 🔄 **协议转换** | 内置SOCKS到HTTP代理转换工具，兼容各种应用程序 |

## 🔍 工作原理

本工具采用基础设施即代码(IaC)和自动化部署的方式，实现代理和VPN服务的快速搭建：

1. 使用Terraform在阿里云上自动创建一台按量付费的ECS实例
2. 配置安全组规则，开放必要的端口
3. 通过SSH隧道将远程服务器的SOCKS代理转发到本地端口
4. 在远程服务器上按需自动部署VPN服务（如果启用）
5. 在本地启动SOCKS到HTTP的代理转换服务，支持更多应用程序
6. 自动配置系统代理设置，应用程序无需额外配置

## 📋 系统要求

### 客户端要求
- **操作系统**: macOS 或 Linux 发行版 (Ubuntu、Debian、Fedora等)
- **软件依赖**: 将通过安装脚本自动安装
- **账户要求**: 阿里云账号及有效的Access Key凭证

### 阿里云要求
- 账号余额充足，能够创建按量付费的ECS实例
- 具备创建ECS、VPC、安全组等资源的权限

## 🚀 快速开始

### 1. 准备阿里云凭证

首先，需要设置阿里云的访问凭证作为环境变量：

```bash
export ALICLOUD_ACCESS_KEY="your-access-key-id"
export ALICLOUD_SECRET_KEY="your-secret-access-key"
```

> 💡 **提示**：您可以将这些环境变量添加到`.bashrc`或`.zshrc`文件中，以便永久保存。

### 2. 安装依赖

运行安装脚本来自动配置所需的依赖：

```bash
./install.sh
```

该脚本会根据您的操作系统自动安装：
- Terraform (基础设施即代码工具)
- sshpass (SSH自动密码登录工具)
- 必要的系统工具
- Homebrew (仅macOS，如果未安装)

支持多种Linux发行版，包括Ubuntu/Debian和Fedora。

### 3. 启动服务

#### 部署完整服务（代理+VPN）
```bash
./start_proxy.sh
```

#### 仅部署代理服务
```bash
./start_proxy.sh --no-vpn  # 或使用简写 -n
```

#### 设置服务运行时间（默认3600秒）
```bash
./start_proxy.sh --timeout 1800  # 或使用简写 -t 1800
```

### 4. 查看连接信息

启动成功后，您将看到详细的代理和VPN配置信息：

```
✅ 代理服务已启动
Public IP: x.x.x.x

🔌 代理配置：
- SOCKS5代理: socks5h://127.0.0.1:9002
- HTTP/HTTPS代理: http://127.0.0.1:8080

🔒 VPN配置 (如果启用):
- 服务器地址: x.x.x.x
- 用户名: vpn
- 密码: Admin123
- IPsec PSK: Admin123
```

## 🛠️ 使用说明

服务启动后，系统会自动配置代理设置。以下是详细的使用方法：

### 代理服务使用

#### 自动配置
脚本会自动配置系统代理设置，大多数应用程序会自动使用这些设置。

#### 手动设置
如果需要为特定应用程序手动设置代理，可以使用以下环境变量：

```bash
# SOCKS5代理
export HTTP_PROXY=socks5h://127.0.0.1:9002
export HTTPS_PROXY=socks5h://127.0.0.1:9002

# HTTP代理 (通过转换工具)
export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
```

#### 代理服务地址
- **SOCKS5代理**: `127.0.0.1:9002`
- **HTTP/HTTPS代理**: `127.0.0.1:8080`

### 代理转换工具

项目包含了内置的SOCKS到HTTP转换工具：

- 位于：`socket_to_http/socks2http`
- 功能：将SOCKS5流量转换为HTTP/HTTPS流量
- 优势：使不直接支持SOCKS代理的应用程序也能使用代理服务
- 自动启动：由`start_proxy.sh`脚本自动启动和管理

### 常见应用配置示例

#### 命令行工具
```bash
# curl 使用代理
curl -x socks5h://127.0.0.1:9002 https://example.com

# wget 使用代理
wget -e use_proxy=yes -e http_proxy=127.0.0.1:8080 https://example.com
```

#### Git
```bash
# 设置Git使用代理
git config --global http.proxy http://127.0.0.1:8080
git config --global https.proxy https://127.0.0.1:8080

# 取消Git代理设置
git config --global --unset http.proxy
git config --global --unset https.proxy
```

## 🔒 VPN服务使用

### VPN配置信息

部署的VPN服务器支持三种主流协议，所有协议使用相同的认证信息：

| 配置项 | 值 |
|-------|-----|
| 服务器地址 | 启动后显示的公网IP |
| 用户名 | `vpn` |
| 密码 | `Admin123` |
| 预共享密钥(PSK) | `Admin123` |

### 各平台VPN配置指南

#### IPsec/L2TP VPN配置

适用于大多数设备的兼容性方案。

**iOS/macOS配置:**
1. 设置 > 通用 > VPN与设备管理 > VPN
2. 添加VPN配置
3. 类型选择 "L2TP over IPSec"
4. 描述：输入自定义名称（如"阿里云VPN"）
5. 服务器：输入启动脚本显示的公网IP地址
6. 账户：`vpn`
7. 密码：`Admin123`
8. 密钥：`Admin123`
9. 点击"完成"并连接

**Android配置:**
1. 设置 > 网络和互联网 > VPN
2. 添加VPN配置
3. 类型选择 "L2TP/IPSec PSK"
4. 名称：输入自定义名称
5. 服务器地址：输入公网IP地址
6. IPSec预共享密钥：`Admin123`
7. 输入用户名和密码
8. 保存并连接

#### IKEv2 VPN配置

提供更好的性能、安全性和连接稳定性。

**iOS/macOS配置:**
1. 设置 > 通用 > VPN与设备管理 > VPN
2. 添加VPN配置
3. 类型选择 "IKEv2"
4. 描述：输入自定义名称
5. 服务器：输入公网IP地址
6. 远程ID：输入公网IP地址
7. 本地ID：留空
8. 用户鉴定：选择"用户名"
9. 用户名：`vpn`
10. 密码：`Admin123`
11. 点击"完成"并连接

**Windows配置:**
1. 设置 > 网络和Internet > VPN > 添加VPN连接
2. 提供商：Windows内置
3. 连接名称：输入自定义名称
4. 服务器名称或地址：输入公网IP地址
5. VPN类型：IKEv2
6. 登录信息的类型：用户名和密码
7. 用户名：`vpn`
8. 密码：`Admin123`
9. 保存并连接

#### Cisco IPsec VPN配置

适用于需要Cisco兼容性的企业网络环境。

1. 使用支持Cisco IPsec的VPN客户端
2. 服务器地址：输入公网IP地址
3. 预共享密钥：`Admin123`
4. 用户名：`vpn`
5. 密码：`Admin123`
6. 保存并连接

> 🔒 **安全提示**：默认VPN凭证仅供测试使用，生产环境请务必修改密码！

## ⚙️ 配置说明

### 默认配置参数

默认配置在 [providers.tf](providers.tf) 文件中定义，主要参数包括：

| 配置项 | 默认值 | 说明 |
|-------|-------|------|
| 区域 | `eu-central-1` | 阿里云区域，德国法兰克福 |
| 实例类型 | 自动选择 | 选择最经济的1核实例 |
| 实例策略 | Spot实例 | 降低成本，可能会被回收 |
| 系统镜像 | Ubuntu 18.04 | 稳定可靠的Linux发行版 |
| 网络配置 | 自动创建 | 自动创建VPC和VSwitch |
| 安全组规则 | 全端口开放 | 开放所有TCP/UDP端口(1-65535) |
| 计费模式 | 按量付费 | 按实际使用时长收费 |
| VPN服务 | hwdsl2/ipsec-vpn-server | 基于Docker的VPN服务 |

## 📋 参数说明

### 启动脚本参数

`start_proxy.sh` 支持以下命令行参数：

| 参数 | 简写 | 说明 | 默认值 |
|-----|------|------|-------|
| `--vpn` | `-v` | 部署VPN服务 | 启用 |
| `--no-vpn` | `-n` | 不部署VPN服务 | 禁用 |
| `--timeout` | `-t` | 代理运行时间（秒） | 3600秒 |
| `--help` | `-h` | 显示帮助信息 | - |

### 配置文件参数

可在 `providers.tf` 中修改以下参数：

| 参数 | 说明 | 推荐值 |
|-----|------|-------|
| `region` | 阿里云区域 | `cn-hongkong`, `us-east-1`, `eu-central-1`等 |
| `instance_type` | ECS实例类型 | 可根据需要调整配置 |
| `image_id` | 系统镜像ID | Ubuntu 18.04或更新版本 |
| `internet_max_bandwidth_out` | 公网带宽 | 根据需要设置，默认为5Mbps |

### 支持的阿里云区域

以下是部分支持的阿里云区域列表：

- `cn-hongkong` - 中国香港
- `eu-central-1` - 德国（法兰克福）- 默认
- `ap-northeast-1` - 日本（东京）
- `ap-southeast-1` - 新加坡
- `us-east-1` - 美国（弗吉尼亚）
- `us-west-1` - 美国（硅谷）
- `ap-southeast-2` - 澳大利亚（悉尼）
- `eu-west-1` - 英国（伦敦）

> 💡 **提示**：不同区域的价格和网络延迟可能有所不同，请根据实际需求选择合适的区域。

## 🚦 运行时行为

启动脚本运行过程中执行以下操作：

1. 使用Terraform创建阿里云ECS实例
2. 配置安全组规则，开放必要端口
3. 通过SSH隧道将远程服务器的SOCKS代理转发到本地端口9002
4. （可选）在远程服务器上部署VPN服务
5. 启动本地SOCKS到HTTP转换工具（端口8080）
6. 自动配置系统代理设置：
   - macOS使用 `networksetup` 命令
   - Linux使用 `gsettings` 命令
7. 显示详细的代理和VPN配置信息
8. 持续监控远程服务器连接状态
9. 到达指定超时时间后自动清理资源

> ℹ️ **注意**：脚本运行期间会持续占用终端，按Ctrl+C可提前终止服务。

## ⚠️ 注意事项

在使用本工具时，请务必注意以下几点：

1. **账户余额**：确保阿里云账号有足够的余额和权限创建资源
2. **资源清理**：使用完毕后务必运行 `./destroy_proxy.sh` 销毁资源，避免产生不必要费用
3. **区域选择**：默认区域为 `eu-central-1`，可根据网络需求修改 `providers.tf` 文件
4. **进程管理**：本地代理转换工具会在后台运行，可在系统活动监视器中查看
5. **安全风险**：默认VPN凭证较为简单（`Admin123`），生产环境必须修改
6. **端口开放**：当前配置开放所有TCP/UDP端口，生产环境请调整安全组设置
7. **实例回收**：使用Spot实例策略可显著降低成本，但在资源紧张时可能被回收
8. **网络费用**：请注意阿里云的流量费用，大量数据传输可能产生额外费用
9. **合规使用**：请遵守相关法律法规和阿里云服务条款

## 🛠️ 故障排除

遇到问题时，请参考以下解决方案：

### 1. 脚本权限问题

```bash
# 确保所有脚本具有执行权限
chmod +x *.sh
chmod +x socket_to_http/*
```

### 2. 网络连接失败

- **检查安全组规则**：确保阿里云安全组正确配置并开放必要端口
- **检查本地防火墙**：确认本地防火墙没有阻止端口访问
- **验证实例状态**：检查ECS实例是否成功创建并正常运行
- **测试基本连接**：尝试使用SSH直接连接到实例

### 3. VPN连接问题

- **验证凭证**：确认用户名、密码和PSK是否正确输入
- **检查端口开放**：确保UDP端口500、4500和1701已开放
- **检查VPN服务**：使用SSH连接到服务器，确认VPN服务正在运行
- **查看日志**：连接到服务器查看VPN服务日志获取详细错误信息

### 4. 系统代理配置错误

**macOS手动重置代理设置：**
```bash
networksetup -setsocksfirewallproxystate "Wi-Fi" off
networksetup -setwebproxystate "Wi-Fi" off
networksetup -setsecurewebproxystate "Wi-Fi" off
networksetup -setdnsservers "Wi-Fi" empty
```

**Linux手动重置代理设置：**
```bash
# 对于GNOME桌面
gsettings set org.gnome.system.proxy mode 'none'

# 清除环境变量
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
```

### 5. 资源创建失败

- **检查账户权限**：确认阿里云账号有创建ECS、VPC等资源的权限
- **检查账户余额**：确保阿里云账号余额充足
- **查看Terraform日志**：检查错误输出，获取详细的失败原因

### 6. 常见错误代码

| 错误代码 | 可能原因 | 解决方案 |
|---------|---------|--------|
| InvalidAccessKeyId.NotFound | Access Key ID不存在或格式错误 | 检查并重新设置ALICLOUD_ACCESS_KEY环境变量 |
| InvalidAccessKeySecret.NotFound | Access Key Secret不匹配 | 检查并重新设置ALICLOUD_SECRET_KEY环境变量 |
| Forbidden.NoStock | 所选区域资源不足 | 尝试选择其他区域或调整实例类型 |
| Forbidden | 权限不足 | 确认账号有足够权限创建相关资源 |

## 🎛️ 高级自定义配置

### 修改VPN认证信息

为增强安全性，建议修改默认的VPN凭证：

1. 编辑 `config_script/remote.sh` 文件
2. 修改以下变量：
   ```bash
   # VPN预共享密钥
   VPN_IPSEC_PSK="your-secure-psk"
   
   # VPN用户名
   VPN_USER="your-vpn-username"
   
   # VPN密码
   VPN_PASSWORD="your-secure-password"
   ```
3. 保存文件并重新启动服务

### 调整服务器规格

在 `providers.tf` 中，可以调整实例配置以满足不同需求：

```hcl
# 调整实例类型过滤条件
data "alicloud_instance_types" "default" {
  # 调整CPU核心数
  cpu_core_count = 2
  
  # 调整内存大小(GB)
  memory_size = 4
  
  # 调整实例类型族
  instance_type_family = "ecs.s6"
}
```

### 自定义安全组规则

如需限制端口开放范围，可修改 `providers.tf` 中的安全组规则：

```hcl
# 自定义安全组规则
resource "alicloud_security_group_rule" "allow_common_ports" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"  # 仅开放SSH端口
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# 为VPN添加必要端口
resource "alicloud_security_group_rule" "allow_vpn_ports" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "500/500,4500/4500,1701/1701"  # VPN端口
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}
```

### 调整网络配置

```hcl
# 调整公网带宽
resource "alicloud_instance" "default" {
  # ... 其他配置 ...
  internet_max_bandwidth_out = 10  # 设置为10Mbps
  # ... 其他配置 ...
}
```

## 🔐 安全最佳实践

为确保您的代理和VPN服务安全可靠，请遵循以下安全建议：

### 1. 凭证管理
- **环境变量**: 始终使用环境变量存储阿里云凭证，避免硬编码
- **密钥轮换**: 定期更换阿里云Access Key
- **最小权限**: 为Access Key分配最小必要的权限范围

### 2. 密码安全
- **修改默认密码**: 生产环境必须修改默认密码（`Admin123`）
- **复杂密码**: 使用强密码，包含大小写字母、数字和特殊字符
- **定期更换**: 定期更新VPN密码和预共享密钥

### 3. 网络安全
- **限制访问范围**: 生产环境中限制安全组的访问来源IP
- **端口最小化**: 只开放必要的端口，避免开放全部端口(1-65535)
- **加密通信**: 确保所有代理连接使用加密协议

### 4. 操作安全
- **及时销毁**: 使用完毕后立即销毁资源，避免闲置资源被利用
- **定期审计**: 检查账号活动和资源使用情况
- **监控异常**: 注意监控异常的网络流量和连接尝试

### 5. 合规使用
- **遵守法规**: 确保使用符合当地法律法规
- **服务条款**: 遵守阿里云服务条款和可接受使用政策
- **隐私保护**: 不要传输敏感或个人隐私数据，除非进行了适当加密

## 🗑️ 销毁服务

使用完毕后，请务必运行以下命令销毁资源，避免产生不必要的费用：

```bash
./destroy_proxy.sh
```

销毁脚本将执行以下操作：

1. 重置系统代理设置（macOS和Linux）
2. 终止本地SOCKS到HTTP转换进程
3. 断开与远程服务器的SSH连接
4. 使用Terraform销毁阿里云上的所有资源，包括：
   - ECS实例
   - VPC和网络配置
   - 安全组
   - 其他相关资源

> ⚠️ **重要提示**：如果启动脚本异常终止，也请手动运行销毁脚本清理资源。

## 📝 许可证

本项目采用MIT许可证 - 详见 [LICENSE](LICENSE) 文件。

## ❓ 常见问题

### Q: 使用Spot实例会影响服务稳定性吗？
A: 是的，Spot实例可能在资源紧张时被阿里云回收。如果您需要稳定的服务，建议修改配置使用按量付费的常规实例。

### Q: 如何查看服务运行状态？
A: 启动脚本运行时会显示实时状态。您也可以通过阿里云控制台查看ECS实例状态。

### Q: 可以同时在多个区域部署服务吗？
A: 目前脚本设计为单区域部署，但您可以复制项目目录并修改配置在不同区域分别部署。

### Q: 如何修改默认的超时时间？
A: 使用 `--timeout` 参数，例如 `./start_proxy.sh --timeout 7200` 将超时设置为2小时。

### Q: 代理服务支持IPv6吗？
A: 当前版本主要针对IPv4网络进行了优化，暂不支持完整的IPv6功能。

## 🤝 贡献指南

欢迎提交Issue和Pull Request！如果您有任何改进建议或发现了问题，请随时提出。

## 📧 联系方式

如有问题或建议，请通过项目的Issue页面联系我们。

---

⭐ 如果你觉得这个项目对你有帮助，请给我们一个Star！

---

*本工具仅用于合法目的，请遵守相关法律法规和服务条款。*