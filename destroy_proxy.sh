#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令执行结果
check_result() {
    if [ $? -ne 0 ]; then
        log_error "$1"
        exit 1
    fi
}

# 检查依赖项
check_dependencies() {
    log_info "检查依赖项..."
    
    # 检查 Terraform
    if ! command -v terraform &> /dev/null; then
        log_error "未找到 Terraform，请先运行 ./install.sh 安装依赖"
        exit 1
    fi
    
    log_info "依赖项检查通过"
}

# 重置 macOS 系统代理
reset_macos_proxy() {
    log_info "重置 macOS 系统代理设置..."
    
    # 检查 networksetup 命令是否存在
    if ! command -v networksetup &> /dev/null; then
        log_error "未找到 networksetup 命令"
        return 1
    fi
    
    # 获取网络服务列表
    local services
    services=$(networksetup -listallnetworkservices 2>/dev/null)
    check_result "无法获取网络服务列表"
    
    # 逐个重置代理设置
    while IFS= read -r svc; do
        # 跳过禁用的网络服务
        if [[ $svc != *"a network service is disabled"* ]]; then
            log_info "重置网络服务 '$svc' 的代理设置..."
            sudo networksetup -setsocksfirewallproxystate "${svc}" off
            sudo networksetup -setdnsservers "${svc}" empty
        fi
    done <<< "$services"
    
    log_info "macOS 系统代理设置重置完成"
}

# 终止本地 SOCKS 到 HTTP 转换进程
kill_socks2http() {
    log_info "终止本地 SOCKS 到 HTTP 转换进程..."
    
    # 查找并终止 socks2http 进程
    local pids
    pids=$(ps ax | grep 'socket_to_http/socks2http' | grep -v grep | awk '{print $1}')
    
    if [[ -n "$pids" ]]; then
        echo "$pids" | xargs kill
        log_info "已终止 SOCKS 到 HTTP 转换进程"
    else
        log_info "未找到运行中的 SOCKS 到 HTTP 转换进程"
    fi
}

# 重置 Linux 系统代理
reset_linux_proxy() {
    log_info "重置 Linux 系统代理设置..."
    
    # 检查 gsettings 命令是否存在
    if ! command -v gsettings &> /dev/null; then
        log_error "未找到 gsettings 命令"
        return 1
    fi
    
    # 重置 GNOME 代理设置
    gsettings reset org.gnome.system.proxy.http host
    gsettings reset org.gnome.system.proxy.http port
    gsettings reset org.gnome.system.proxy.https host
    gsettings reset org.gnome.system.proxy.https port
    gsettings reset org.gnome.system.proxy.ftp host
    gsettings reset org.gnome.system.proxy.ftp port
    gsettings reset org.gnome.system.proxy.socks host
    gsettings reset org.gnome.system.proxy.socks port
    
    log_info "Linux 系统代理设置重置完成"
}

# 销毁 Terraform 资源
destroy_terraform() {
    log_info "销毁 Terraform 资源..."
    
    # 检查 Terraform 状态文件是否存在
    if [[ ! -f "terraform.tfstate" ]]; then
        log_warn "未找到 terraform.tfstate 文件，可能没有已部署的资源"
        return 0
    fi
    
    terraform apply -destroy -auto-approve
    check_result "Terraform 资源销毁失败"
    
    log_info "Terraform 资源销毁完成"
}

# 主程序
main() {
    log_info "开始销毁代理服务..."
    
    # 获取当前目录
    local CurDir
    CurDir=$(dirname "$0")
    cd "$CurDir" || { log_error "无法切换到目录: $CurDir"; exit 1; }
    
    # 检查依赖项
    check_dependencies
    
    # 根据操作系统类型执行相应操作
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        # macOS 系统
        reset_macos_proxy
        kill_socks2http
    elif [[ "$OSTYPE" =~ ^linux ]]; then
        # Linux 系统
        reset_linux_proxy
        kill_socks2http
    else
        log_warn "不支持的操作系统类型: $OSTYPE"
    fi
    
    # 销毁 Terraform 资源
    destroy_terraform
    
    log_info "代理服务销毁完成！"
    log_info "所有资源已清理"
}

# 执行主程序
main "$@"
