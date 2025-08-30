#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
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

# 显示代理配置信息
show_proxy_info() {
    clear
    echo
    log_header "代理配置完成"
    echo
    log_info "阿里云 ECS 实例已启动并运行"
    log_info "公网 IP: ${PubIP}"
    log_info "root 密码: Admin123"
    echo
    log_header "本地代理配置"
    log_info "SOCKS5 代理: 127.0.0.1:9002"
    log_info "HTTP/HTTPS 代理: 127.0.0.1:8080"
    echo
    log_header "环境变量设置（可选）"
    echo "export HTTP_PROXY=socks5h://127.0.0.1:9002 HTTPS_PROXY=socks5h://127.0.0.1:9002"
    echo "export HTTP_PROXY=http://127.0.0.1:8080 HTTPS_PROXY=http://127.0.0.1:8080"
    echo
    log_header "系统代理设置"
}

# 启动 SOCKS 到 HTTP 转换服务
start_socks2http() {
    log_info "启动 SOCKS 到 HTTP 转换服务..."
    
    # 检查 socks2http 文件是否存在
    if [[ ! -f "./socket_to_http/socks2http" ]]; then
        log_error "未找到 ./socket_to_http/socks2http 文件"
        return 1
    fi
    
    # 启动 socks2http 服务
    ./socket_to_http/socks2http -http 8080 -socks 9002 &
    
    # 检查进程是否启动成功
    local pid=$!
    sleep 2
    
    if kill -0 $pid 2>/dev/null; then
        log_info "SOCKS 到 HTTP 转换服务已启动 (PID: $pid)"
    else
        log_error "SOCKS 到 HTTP 转换服务启动失败"
        return 1
    fi
}

# 配置 macOS 系统代理
configure_macos_proxy() {
    log_info "配置 macOS 系统代理..."
    
    # 检查 networksetup 命令是否存在
    if ! command -v networksetup &> /dev/null; then
        log_error "未找到 networksetup 命令"
        return 1
    fi
    
    # 获取网络服务列表
    local services
    services=$(networksetup -listallnetworkservices 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        log_error "无法获取网络服务列表"
        return 1
    fi
    
    # 逐个配置代理设置
    while IFS= read -r svc; do
        # 跳过禁用的网络服务
        if [[ $svc != *"a network service is disabled"* ]]; then
            log_info "配置网络服务 '$svc' 的代理设置..."
            sudo networksetup -setsocksfirewallproxy "${svc}" 127.0.0.1 9002
            sudo networksetup -setdnsservers "${svc}" 8.8.8.8 8.8.4.4
        fi
    done <<< "$services"
    
    log_info "macOS 系统代理配置完成"
}

# 配置 Linux 系统代理
configure_linux_proxy() {
    log_info "配置 Linux 系统代理..."
    
    # 检查 gsettings 命令是否存在
    if ! command -v gsettings &> /dev/null; then
        log_error "未找到 gsettings 命令"
        return 1
    fi
    
    # 配置 GNOME 代理设置
    gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
    gsettings set org.gnome.system.proxy.socks port 9002
    
    log_info "Linux 系统代理配置完成"
}

# 建立 SSH 隧道并监控连接
establish_ssh_tunnel() {
    log_info "建立 SSH 隧道并监控连接..."
    
    # 删除已知主机记录以避免主机密钥检查问题
    rm -f "${HOME}/.ssh/known_hosts"
    
    # 根据操作系统类型执行相应的 SSH 命令
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        # macOS 系统使用 sar 命令监控网络
        sshpass -p Admin123 ssh -o StrictHostKeyChecking=no -D 9002 root@"${PubIP}" sar -n DEV 1
    elif [[ "$OSTYPE" =~ ^linux ]]; then
        # Linux 系统使用 sar 命令监控网络
        sshpass -p Admin123 ssh -o StrictHostKeyChecking=no -D 9002 root@"${PubIP}" sar -n DEV 1
    else
        # 其他系统使用简单的 uptime 命令保持连接
        sshpass -p Admin123 ssh -o StrictHostKeyChecking=no -D 9002 root@"${PubIP}" uptime
    fi
}

# 主程序
main() {
    # 显示代理配置信息
    show_proxy_info

    # try clean
    kill_socks2http
    
    # 启动 SOCKS 到 HTTP 转换服务
    start_socks2http || exit 1
    
    # 根据操作系统类型配置系统代理
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        # macOS 系统
        configure_macos_proxy || exit 1
    elif [[ "$OSTYPE" =~ ^linux ]]; then
        # Linux 系统
        configure_linux_proxy || exit 1
    else
        log_warn "不支持的操作系统类型: $OSTYPE"
        log_warn "请手动配置系统代理"
    fi
    
    log_header "连接到远程服务器"
    log_info "正在建立 SSH 隧道并监控连接..."
    log_info "按 Ctrl+C 可以断开连接"
    echo
    
    # 建立 SSH 隧道并监控连接
    establish_ssh_tunnel
}

# 执行主程序
main "$@"
