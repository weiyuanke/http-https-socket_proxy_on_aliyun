#!/bin/bash

set -e
set -o pipefail

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

CurDir=$(dirname $0)
cd $CurDir

# 检查是否有sudo权限
check_sudo() {
    if [[ "$OSTYPE" =~ ^linux ]]; then
        if ! sudo -v &> /dev/null; then
            log_error "需要sudo权限来安装软件包"
            exit 1
        fi
    fi
}

# macOS安装函数
install_macos() {
    # 检查并安装brew
    if ! command -v brew &> /dev/null; then
        log_warn "brew未安装，正在尝试安装..."
        /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"

        # 验证安装
        if ! command -v brew &> /dev/null; then
            log_error "brew安装失败，请手动安装后再运行此脚本"
            exit 1
        fi

        log_info "brew安装成功"
    else
        log_info "brew已安装"
    fi

    # 更新brew
    log_info "更新brew..."
    brew update

    # 安装sshpass
    if ! command -v sshpass &> /dev/null; then
        log_info "安装sshpass..."
        brew tap esolitos/ipa
        brew install esolitos/ipa/sshpass

        # 验证安装
        if ! command -v sshpass &> /dev/null; then
            log_error "sshpass安装失败"
            exit 1
        fi

        log_info "sshpass安装成功"
    else
        log_info "sshpass已安装"
    fi

    # 安装terraform
    if ! command -v terraform &> /dev/null; then
        log_info "安装terraform..."
        brew install terraform

        # 验证安装
        if ! command -v terraform &> /dev/null; then
            log_error "terraform安装失败"
            exit 1
        fi

        log_info "terraform安装成功"
    else
        log_info "terraform已安装"
        terraform_version=$(terraform version | head -n1)
        log_info "当前版本: $terraform_version"
    fi
}

# Linux安装函数
install_linux() {
    # 检查是否为 Fedora 系统
    if [ -f /etc/fedora-release ] || grep -q "Fedora" /etc/os-release 2>/dev/null; then
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
    log_info "Install dnf config-manager to manage your repositories."
    sudo dnf install -y dnf-plugins-core

    log_info "add the official HashiCorp Fedora repository."
    sudo dnf config-manager addrepo --overwrite --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

    log_info "安装依赖:terraform、sshpass"
    if ! sudo dnf -y install terraform sshpass; then
        log_error "依赖安装失败"
        exit 1
    fi

    log_info "Fedora依赖安装完成"
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

# 主程序
main() {
    log_info "开始安装依赖..."

    check_sudo

    if [[ "$OSTYPE" =~ ^darwin ]]; then
        log_info "检测到macOS系统"
        install_macos
    elif [[ "$OSTYPE" =~ ^linux ]]; then
        log_info "检测到Linux系统"
        install_linux
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi

    init_terraform

    log_info "所有依赖安装完成！"
    echo ""
    echo "下一步请设置阿里云凭证："
    echo "export ALICLOUD_ACCESS_KEY=\"your-access-key-id\""
    echo "export ALICLOUD_SECRET_KEY=\"your-secret-access-key\""
    echo ""
    echo "然后运行以下命令启动代理："
    echo "./start_proxy.sh"
}

# 执行主程序
main "$@"
