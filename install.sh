#!/bin/bash

set -e
set -o pipefail

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

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# 全局变量
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
START_TIME=$(date +%s)

# 检查是否有sudo权限
check_sudo() {
    if [[ "$OSTYPE" =~ ^linux ]]; then
        if ! sudo -v &> /dev/null; then
            log_error "需要sudo权限来安装软件包"
            exit 1
        fi
        log_debug "sudo权限检查通过"
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 获取系统信息
get_system_info() {
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        log_info "检测到 macOS 系统"
        SYSTEM_TYPE="macos"
    elif [[ "$OSTYPE" =~ ^linux ]]; then
        log_info "检测到 Linux 系统"
        SYSTEM_TYPE="linux"
        
        # 检测Linux发行版
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$NAME
            VERSION=$VERSION_ID
        elif [ -f /etc/fedora-release ]; then
            DISTRO="Fedora"
        else
            DISTRO="Unknown"
        fi
        
        log_info "Linux发行版: $DISTRO $VERSION"
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
}

# macOS安装函数
install_macos() {
    log_info "开始安装 macOS 依赖..."
    
    # 检查并安装brew
    if ! command_exists brew; then
        log_warn "brew未安装，正在尝试安装..."
        /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
        
        # 验证安装
        if ! command_exists brew; then
            log_error "brew安装失败，请手动安装后再运行此脚本"
            exit 1
        fi
        
        log_info "brew安装成功"
    else
        log_info "brew已安装"
    fi
    
    # 更新brew
    #log_info "更新brew..."
    #brew update
    
    # 安装sshpass
    if ! command_exists sshpass; then
        log_info "安装sshpass..."
        brew tap esolitos/ipa
        brew install esolitos/ipa/sshpass
        
        # 验证安装
        if ! command_exists sshpass; then
            log_error "sshpass安装失败"
            exit 1
        fi
        
        log_info "sshpass安装成功"
    else
        log_info "sshpass已安装"
    fi

    # 安装coreutils
    log_info "安装coreutils..."
    brew install coreutils
    log_info "coreutils安装成功"
    
    # 安装terraform
    if ! command_exists terraform; then
        log_info "安装terraform..."
        brew install terraform
        
        # 验证安装
        if ! command_exists terraform; then
            log_error "terraform安装失败"
            exit 1
        fi
        
        log_info "terraform安装成功"
    else
        log_info "terraform已安装"
        local terraform_version
        terraform_version=$(terraform version | head -n1)
        log_info "当前版本: $terraform_version"
    fi
}

# Linux安装函数
install_linux() {
    log_info "开始安装 Linux 依赖..."
    
    # 检查是否为 Fedora 系统
    if [[ "$DISTRO" == "Fedora" ]] || grep -q "Fedora" /etc/os-release 2>/dev/null; then
        log_info "检测到 Fedora 系统"
        install_fedora
    else
        log_info "检测到基于 Debian/Ubuntu 的系统"
        install_debian_based
    fi
}

# Debian/Ubuntu 系统安装函数
install_debian_based() {
    # 添加HashiCorp GPG密钥
    log_info "添加HashiCorp GPG密钥..."
    if ! wget -O- -q https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; then
        log_error "无法添加HashiCorp GPG密钥"
        exit 1
    fi
    
    # 添加HashiCorp APT仓库
    log_info "添加HashiCorp APT仓库..."
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    
    # 更新包列表
    log_info "更新包列表..."
    sudo apt update
    
    # 安装依赖
    log_info "安装依赖..."
    if ! sudo apt install -y sshpass terraform; then
        log_error "依赖安装失败"
        exit 1
    fi
    
    log_info "Debian/Ubuntu依赖安装完成"
}

# Fedora 系统安装函数
install_fedora() {
    log_info "安装 dnf config-manager 以管理仓库..."
    sudo dnf install -y dnf-plugins-core
    
    log_info "添加官方 HashiCorp Fedora 仓库..."
    sudo dnf config-manager addrepo --overwrite --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    
    log_info "安装依赖: terraform、sshpass"
    if ! sudo dnf -y install terraform sshpass; then
        log_error "依赖安装失败"
        exit 1
    fi
    
    log_info "Fedora依赖安装完成"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."
    
    local failed=0
    
    # 验证 terraform
    if command_exists terraform; then
        local terraform_version
        terraform_version=$(terraform version | head -n1)
        log_info "Terraform: $terraform_version"
    else
        log_error "Terraform 未正确安装"
        ((failed++))
    fi
    
    # 验证 sshpass
    if command_exists sshpass; then
        local sshpass_version
        sshpass_version=$(sshpass -V 2>&1 | head -n1)
        log_info "sshpass: $sshpass_version"
    else
        log_error "sshpass 未正确安装"
        ((failed++))
    fi
    
    if [ $failed -gt 0 ]; then
        log_error "有 $failed 个组件安装失败"
        exit 1
    fi
    
    log_info "所有依赖验证通过"
}

# 初始化terraform
init_terraform() {
    log_info "初始化terraform..."
    if ! terraform init; then
        log_error "terraform初始化失败"
        exit 1
    fi
    log_info "terraform初始化成功"
}

# 显示安装完成信息
show_completion_info() {
    local END_TIME
    END_TIME=$(date +%s)
    local duration=$((END_TIME - START_TIME))
    
    log_info "所有依赖安装完成！耗时 ${duration} 秒"
    echo ""
    echo "下一步请设置阿里云凭证："
    echo "export ALICLOUD_ACCESS_KEY=\"your-access-key-id\""
    echo "export ALICLOUD_SECRET_KEY=\"your-secret-access-key\""
    echo ""
    echo "然后运行以下命令启动代理："
    echo "./start_proxy.sh"
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -v, --verbose  显示详细日志"
    echo ""
    echo "此脚本将安装以下依赖:"
    echo "  - Terraform (基础设施即代码工具)"
    echo "  - sshpass (SSH自动密码登录工具)"
    echo "  - Homebrew (macOS, 如果未安装)"
    echo ""
    echo "支持的操作系统:"
    echo "  - macOS"
    echo "  - Ubuntu/Debian"
    echo "  - Fedora"
}

# 主程序
main() {
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log_info "开始安装依赖..."
    
    # 切换到脚本所在目录
    cd "$SCRIPT_DIR" || { log_error "无法切换到目录: $SCRIPT_DIR"; exit 1; }
    
    # 检查sudo权限
    check_sudo
    
    # 获取系统信息
    get_system_info
    
    # 根据系统类型安装依赖
    case $SYSTEM_TYPE in
        macos)
            install_macos
            ;;
        linux)
            install_linux
            ;;
        *)
            log_error "不支持的系统类型: $SYSTEM_TYPE"
            exit 1
            ;;
    esac
    
    # 验证安装
    verify_installation
    
    # 初始化terraform
    init_terraform
    
    # 显示完成信息
    show_completion_info
}

# 执行主程序
main "$@"
