# 阿里云HTTP/HTTPS/SOCKS代理服务

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

基于阿里云的一键式代理服务，按分钟付费，快速部署，支持SOCKS、HTTP和HTTPS代理。

## 功能特性

- 🚀 一键部署：快速创建和销毁代理服务
- 💰 按需付费：基于阿里云按量付费ECS实例，仅在使用时计费
- 🔒 多协议支持：同时支持SOCKS5、HTTP和HTTPS代理
- 🌍 全球部署：可部署在多个阿里云区域
- 🖥️ 多平台支持：支持macOS和Linux系统

## 工作原理

1. 使用Terraform在阿里云上自动创建一台按量付费的ECS实例
2. 配置安全组规则，开放必要的端口
3. 在本地启动SOCKS到HTTP的代理转换服务
4. 自动配置系统代理设置

## 系统要求

- macOS 或 Linux 操作系统
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

### 3. 启动代理服务

```bash
./start_proxy.sh
```

脚本将：
- 在阿里云上创建ECS实例
- 配置本地SOCKS到HTTP代理转换
- 自动设置系统代理

启动成功后，你将看到类似以下的输出：
```
start configuring proxy
Public IP: x.x.x.x
export HTTP_PROXY=socks5h://127.0.0.1:9002 HTTPS_PROXY=socks5h://127.0.0.1:9002
export HTTP_PROXY=http://127.0.0.1:8080 HTTPS_PROXY=http://127.0.0.1:8080
```

### 4. 销毁代理服务

使用完毕后，请务必销毁资源以避免产生不必要的费用：

```bash
./destroy_proxy.sh
```

此脚本将：
- 重置系统代理设置
- 销毁阿里云上的ECS实例及相关资源

## 使用说明

代理服务启动后，系统将自动配置以下代理：

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

## 配置说明

默认配置在 [providers.tf](providers.tf) 文件中定义：

- **区域**: `us-west-1` (可修改为其他区域如 `cn-beijing`, `us-east-1`, `ap-northeast-1`)
- **实例类型**: 自动选择价格最低的1核实例
- **镜像**: Ubuntu系统镜像
- **网络**: 自动创建VPC和VSwitch
- **安全组**: 开放所有TCP端口(1-65535)
- **计费模式**: 按量付费，Spot实例策略

## 注意事项

1. 请确保阿里云账号有足够的余额和权限
2. 使用完毕后务必运行 `./destroy_proxy.sh` 销毁资源
3. 默认区域为 `us-west-1`，可根据需要修改 `providers.tf` 文件
4. 本地代理转换工具会持续运行，可在系统活动监视器中查看

## 故障排除

### 1. 权限问题

如果遇到权限问题，请检查：
```bash
# 确保脚本具有执行权限
chmod +x *.sh
chmod +x socket_to_http/*
```

### 2. 网络连接问题

如果代理无法连接，请检查：
- 阿里云安全组规则是否正确配置
- 本地防火墙是否阻止了端口访问
- ECS实例是否成功创建并运行

### 3. 系统代理配置问题

macOS系统代理配置使用 `networksetup` 命令，如遇到问题可手动重置：
```bash
sudo networksetup -setsocksfirewallproxystate "Wi-Fi" off
sudo networksetup -setdnsservers "Wi-Fi" empty
```

## 许可证

本项目采用MIT许可证，详情请见 [LICENSE](LICENSE) 文件。
