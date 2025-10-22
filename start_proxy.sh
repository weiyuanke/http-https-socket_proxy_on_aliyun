#!/bin/bash
set -m # 启用作业控制

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
export RED GREEN YELLOW NC

# 代理默认运行时间（秒）
TIMEOUT=3600
export TIMEOUT

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

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -v, --vpn        部署 VPN 服务 (默认)"
    echo "  -n, --no-vpn     不部署 VPN 服务，只运行基础配置"
    echo "  -h, --help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                  # 部署带 VPN 的服务 (默认)"
    echo "  $0 --no-vpn         # 部署不带 VPN 的服务"
    echo "  $0 -n               # 部署不带 VPN 的服务"
}

# 解析命令行参数
deploy_vpn=true
export deploy_vpn

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--no-vpn)
            deploy_vpn=false
            shift
            ;;
        -v|--vpn)
            deploy_vpn=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

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
    if [ "$deploy_vpn" = true ]; then
        log_info "部署带 VPN 的服务..."
        terraform apply -auto-approve -var="deploy_vpn=true" -parallelism=20
    else
        log_info "部署不带 VPN 的服务..."
        terraform apply -auto-approve -var="deploy_vpn=false" -parallelism=20
    fi
}

# 主程序
main() {
    if [ "$deploy_vpn" = true ]; then
        log_info "开始启动代理服务 (包含 VPN)..."
    else
        log_info "开始启动代理服务 (不包含 VPN)..."
    fi

    # 获取当前目录
    CurDir=$(dirname "$0")
    cd "$CurDir" || { log_error "无法切换到目录: $CurDir"; exit 1; }

    # 检查依赖项
    check_dependencies

    # 检查阿里云凭证
    check_aliyun_credentials

    # 初始化 Terraform
    init_terraform

    log_warn "============================================================"
    log_warn "使用完毕后，请运行 ./destroy_proxy.sh 销毁资源以避免产生不必要的费用"
    log_warn "代理默认运行${TIMEOUT}秒 ，超时会自动销毁，以避免产生不必要的费用"
    log_warn "============================================================"
    log_warn ""
    sleep 5

    # 应用 Terraform 配置
    log_info "开始拉起代理..."
    timeout --signal=INT ${TIMEOUT} bash -c "$(declare -f apply_terraform log_info); apply_terraform"

    # 防止忘记关闭代理产生不必要的费用
    log_info "稍等一下..."
    sleep 20
    log_warn "============================================================"
    log_warn "代理已经运行${TIMEOUT}, 开始销毁代理..."
    bash ./destroy_proxy.sh
}

# 执行主程序
main "$@"
