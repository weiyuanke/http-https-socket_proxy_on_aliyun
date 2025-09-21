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

    # 检查 sshpass
    if ! command -v sshpass &> /dev/null; then
        log_error "未找到 sshpass，请先运行 ./install.sh 安装依赖"
        exit 1
    fi

    log_info "所有依赖项检查通过"
}

# 检查阿里云凭证
check_aliyun_credentials() {
    log_info "检查阿里云凭证..."

    if [[ -z "$ALICLOUD_ACCESS_KEY" || -z "$ALICLOUD_SECRET_KEY" ]]; then
        log_error "未设置阿里云凭证，请设置以下环境变量："
        echo "export ALICLOUD_ACCESS_KEY=\"your-access-key-id\""
        echo "export ALICLOUD_SECRET_KEY=\"your-secret-access-key\""
        exit 1
    fi

    log_info "阿里云凭证已设置"
}

# 初始化 Terraform
init_terraform() {
    log_info "初始化 Terraform..."
    terraform init
    check_result "Terraform 初始化失败"
    log_info "Terraform 初始化成功"
}

# 应用 Terraform 配置
apply_terraform() {
    log_info "应用 Terraform 配置..."
    terraform apply -auto-approve -parallelism=20
}

# 主程序
main() {
    sudo echo "-----------"
    log_info "开始启动代理服务..."

    # 获取当前目录
    CurDir=$(dirname "$0")
    cd "$CurDir" || { log_error "无法切换到目录: $CurDir"; exit 1; }

    # 检查依赖项
    check_dependencies

    # 检查阿里云凭证
    check_aliyun_credentials

    # 初始化 Terraform
    init_terraform

    # 应用 Terraform 配置
    apply_terraform

    log_info "使用完毕后，请运行 ./destroy_proxy.sh 销毁资源以避免产生不必要的费用"
}

# 执行主程序
main "$@"
