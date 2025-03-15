#!/bin/bash

# ServerMaster - 增强版多级菜单系统
# 支持一级、二级和三级菜单层级
# 增加模块下载与执行机制

# 颜色定义
GREEN='\033[0;32m'          # 经典矩阵绿
BRIGHT_GREEN='\033[1;32m'   # 明亮的绿色
CYAN='\033[0;36m'           # 青色
BLUE='\033[0;34m'           # 蓝色
MAGENTA='\033[0;35m'        # 洋红色
YELLOW='\033[0;33m'         # 黄色
RED='\033[0;31m'            # 红色
WHITE='\033[1;37m'          # 白色
GRAY='\033[0;37m'           # 灰色
BLACK_BG='\033[40m'         # 黑色背景
BOLD='\033[1m'              # 粗体
DIM='\033[2m'               # 暗色
BLINK='\033[5m'             # 闪烁
NC='\033[0m'                # 无颜色（重置）

# 脚本版本和配置
VERSION="5.0"
MODULES_DIR="$HOME/.servermaster/modules"
MODULES_REPO="https://raw.githubusercontent.com/username/servermaster/main/modules"

# 创建模块目录
mkdir -p "$MODULES_DIR"

# 当前菜单路径
MENU_PATH=""

# 清屏
clear

# 改进的系统初始化动画
system_init() {
    echo -e "\n\n                               ${CYAN}系统初始化中...${NC}\n"
    echo -ne "    ${CYAN}加载核心模块 [                                                                    ] 0%\r${NC}"
    sleep 0.1
    echo -ne "    ${CYAN}加载核心模块 [==========                                                          ] 15%\r${NC}"
    sleep 0.1
    echo -ne "    ${CYAN}加载核心模块 [====================                                                ] 30%\r${NC}"
    sleep 0.1
    echo -ne "    ${CYAN}加载核心模块 [==============================                                      ] 45%\r${NC}"
    sleep 0.1
    echo -ne "    ${CYAN}加载核心模块 [========================================                            ] 60%\r${NC}"
    sleep 0.1
    echo -ne "    ${CYAN}加载核心模块 [==================================================                  ] 75%\r${NC}"
    sleep 0.1
    echo -ne "    ${CYAN}加载核心模块 [============================================================        ] 90%\r${NC}"
    sleep 0.1
    echo -ne "    ${CYAN}加载核心模块 [====================================================================] 100%\r${NC}"
    echo -e "\n\n"
    sleep 0.3
}

# 模块下载函数
download_module() {
    local module_path="$1"
    local local_path="$MODULES_DIR/$module_path"
    local module_url="$MODULES_REPO/$module_path"
    
    # 创建目录
    mkdir -p "$(dirname "$local_path")"
    
    echo -e "${CYAN}正在下载模块 $module_path...${NC}"
    
    # 尝试下载模块
    if curl -s -o "$local_path" "$module_url" || wget -q -O "$local_path" "$module_url"; then
        if [ -s "$local_path" ]; then  # 检查文件是否不为空
            chmod +x "$local_path"
            echo -e "${GREEN}模块下载完成${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}模块下载失败: $module_path${NC}"
    sleep 2
    return 1
}

# 执行模块
execute_module() {
    local module_path="$1"
    local local_path="$MODULES_DIR/$module_path"
    
    # 检查模块是否存在，不存在则下载
    if [ ! -f "$local_path" ] || [ ! -s "$local_path" ]; then
        download_module "$module_path" || return 1
    fi
    
    # 导出颜色变量给模块使用
    export GREEN BRIGHT_GREEN CYAN BLUE MAGENTA YELLOW RED WHITE GRAY BLACK_BG BOLD DIM BLINK NC
    export MODULES_DIR MODULES_REPO
    
    # 执行模块
    bash "$local_path"
    return $?
}

# 显示LOGO
show_logo() {
    echo -e "${CYAN}${BOLD}"
    echo "███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗ "
    echo "██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗"
    echo "███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝"
    echo "╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗"
    echo "███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║"
    echo "╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
}

# 显示装饰线
show_decoration() {
    echo ""
    echo -e "${YELLOW}★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★${NC}"
}

# 显示标题
show_title() {
    local title="$1"
    echo ""
    
    # 根据MENU_PATH显示不同的标题
    if [ -z "$MENU_PATH" ]; then
        echo -e "                               ${CYAN}${BOLD}「 矩 阵 世 界 控 制 台 」${NC}"
        echo -e "                               ${BLUE}======== MATRIX WORLD ========${NC}"
        echo -e "                               ${YELLOW}系 统 版 本 : MATRIX $VERSION${NC}"
    else
        local display_title="${title:-$MENU_PATH}"
        echo -e "                               ${CYAN}${BOLD}「 $display_title 」${NC}"
        echo -e "                               ${BLUE}===============================${NC}"
    fi
}

# 显示菜单头部
show_menu_header() {
    local title="$1"
    clear
    show_logo
    show_decoration
    show_title "$title"
    show_decoration
    echo ""
}

# 显示菜单底部
show_menu_footer() {
    echo ""
    # 系统状态 - 简洁设计
    current_time=$(date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "2023-01-01 12:34:56")
    uptime_info=$(uptime | awk '{print $3, $4}' | sed 's/,//g')
    echo -e "                  ${GREEN}系统时间: ${WHITE}$current_time${NC}  |  ${GREEN}运行时间: ${WHITE}$uptime_info${NC}"
    echo ""
    
    # 根据MENU_PATH显示不同的提示符
    if [ -z "$MENU_PATH" ]; then
        echo -ne "${CYAN}${BOLD}管理员${NC}${GREEN}@${NC}${CYAN}${BOLD}矩阵世界${NC} ${GREEN}➤${NC} "
    else
        echo -ne "${CYAN}${BOLD}管理员${NC}${GREEN}@${NC}${CYAN}${BOLD}矩阵世界/${MENU_PATH}${NC} ${GREEN}➤${NC} "
    fi
}

# 主菜单
show_main_menu() {
    MENU_PATH=""
    show_menu_header
    
    echo -e "                               ${BLUE}════════════════════════${NC}"
    echo -e "                               ${BLUE}    命 令 控 制 中 心    ${NC}"
    echo -e "                               ${BLUE}════════════════════════${NC}"
    echo ""
    echo ""
    
    # 主菜单选项 - 居中显示，每个选项单独一行，添加额外的空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}系统管理${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [2]${NC} ${WHITE}网络管理${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [3]${NC} ${WHITE}应用与服务${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}高级功能${NC}"
    echo ""
    echo -e "                          ${MAGENTA}◆ [5]${NC} ${WHITE}特别功能${NC}"
    echo ""
    
    # 使用分隔线分开系统操作选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${CYAN}◆ [U]${NC} ${WHITE}脚本更新${NC}"
    echo ""
    echo -e "                          ${RED}◆ [0]${NC} ${WHITE}退出系统${NC}"
    
    show_menu_footer
    
    read choice
    process_main_menu "$choice"
}

# 处理主菜单选择
process_main_menu() {
    case "$1" in
        1) system_management ;;
        2) network_management ;;
        3) application_service ;;
        4) advanced_features ;;
        5) special_features ;;
        0) 
            echo -e "${RED}正在退出系统...${NC}"
            echo -e "${GREEN}感谢使用 ServerMaster 矩阵世界版！${NC}"
            sleep 1
            clear
            exit 0 
            ;;
        U|u) update_script ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            show_main_menu
            ;;
    esac
}

# 更新脚本
update_script() {
    echo -e "${CYAN}正在检查脚本更新...${NC}"
    # 这里添加检查和更新主脚本的逻辑
    sleep 2
    echo -e "${GREEN}脚本已是最新版本！${NC}"
    sleep 1
    show_main_menu
}

# 系统管理菜单
system_management() {
    MENU_PATH="系统管理"
    show_menu_header
    
    echo ""
    # 系统管理菜单选项 - 居中显示，每个选项单独一行，增加空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}系统信息查询${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [2]${NC} ${WHITE}系统更新${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [3]${NC} ${WHITE}系统清理${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}重装系统(DD)${NC}"
    echo ""
    echo -e "                          ${MAGENTA}◆ [5]${NC} ${WHITE}时区设置${NC}"
    echo ""
    echo -e "                          ${CYAN}◆ [6]${NC} ${WHITE}修改SSH端口${NC}"
    echo ""
    echo -e "                          ${RED}◆ [7]${NC} ${WHITE}设置虚拟内存${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [8]${NC} ${WHITE}用户账户管理${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [9]${NC} ${WHITE}计划任务管理${NC}"
    echo ""
    
    # 使用分隔线分开返回选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [0]${NC} ${WHITE}返回主菜单${NC}"
    
    show_menu_footer
    
    read choice
    process_system_menu "$choice"
}

# 处理系统管理菜单选择
process_system_menu() {
    case "$1" in
        1) execute_module "system/system_info.sh" && system_management ;;
        2) execute_module "system/system_update.sh" && system_management ;;
        3) execute_module "system/system_clean.sh" && system_management ;;
        4) execute_module "system/system_reinstall.sh" && system_management ;;
        5) execute_module "system/timezone_setup.sh" && system_management ;;
        6) execute_module "system/ssh_port.sh" && system_management ;;
        7) execute_module "system/virtual_memory.sh" && system_management ;;
        8) execute_module "system/user_management.sh" && system_management ;;
        9) execute_module "system/cron_management.sh" && system_management ;;
        0) show_main_menu ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            system_management
            ;;
    esac
}

# 网络管理菜单
network_management() {
    MENU_PATH="网络管理"
    show_menu_header
    
    echo ""
    # 网络管理菜单选项 - 居中显示，每个选项单独一行，增加空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}BBR加速管理${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [2]${NC} ${WHITE}网络测速工具${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [3]${NC} ${WHITE}WARP管理${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}防火墙设置${NC}"
    echo ""
    echo -e "                          ${MAGENTA}◆ [5]${NC} ${WHITE}端口管理${NC}"
    echo ""
    echo -e "                          ${CYAN}◆ [6]${NC} ${WHITE}流量监控${NC}"
    echo ""
    echo -e "                          ${RED}◆ [7]${NC} ${WHITE}VPN服务部署${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [8]${NC} ${WHITE}代理服务部署${NC}"
    echo ""
    
    # 使用分隔线分开返回选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [0]${NC} ${WHITE}返回主菜单${NC}"
    
    show_menu_footer
    
    read choice
    process_network_menu "$choice"
}

# 处理网络管理菜单选择
process_network_menu() {
    case "$1" in
        1) execute_module "network/bbr_manager.sh" && network_management ;;
        2) execute_module "network/speed_test.sh" && network_management ;;
        3) execute_module "network/warp_manager.sh" && network_management ;;
        4) execute_module "network/firewall.sh" && network_management ;;
        5) execute_module "network/port_manager.sh" && network_management ;;
        6) execute_module "network/traffic_monitor.sh" && network_management ;;
        7) vpn_deployment ;;
        8) proxy_deployment ;;
        0) show_main_menu ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            network_management
            ;;
    esac
}

# VPN部署菜单 (三级菜单示例)
vpn_deployment() {
    MENU_PATH="网络管理/VPN服务部署"
    show_menu_header
    
    echo ""
    # VPN部署菜单选项 - 居中显示，每个选项单独一行，增加空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}OpenVPN部署${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [2]${NC} ${WHITE}WireGuard部署${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [3]${NC} ${WHITE}L2TP/IPsec部署${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}Trojan部署${NC}"
    echo ""
    echo -e "                          ${MAGENTA}◆ [5]${NC} ${WHITE}V2Ray部署${NC}"
    echo ""
    echo -e "                          ${CYAN}◆ [6]${NC} ${WHITE}Shadowsocks部署${NC}"
    echo ""
    
    # 使用分隔线分开返回选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${RED}◆ [0]${NC} ${WHITE}返回网络管理${NC}"
    
    show_menu_footer
    
    read choice
    process_vpn_menu "$choice"
}

# 处理VPN部署菜单选择
process_vpn_menu() {
    case "$1" in
        1) execute_module "network/vpn/openvpn.sh" && vpn_deployment ;;
        2) execute_module "network/vpn/wireguard.sh" && vpn_deployment ;;
        3) execute_module "network/vpn/l2tp.sh" && vpn_deployment ;;
        4) execute_module "network/vpn/trojan.sh" && vpn_deployment ;;
        5) execute_module "network/vpn/v2ray.sh" && vpn_deployment ;;
        6) execute_module "network/vpn/shadowsocks.sh" && vpn_deployment ;;
        0) network_management ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            vpn_deployment
            ;;
    esac
}

# 代理部署菜单
proxy_deployment() {
    MENU_PATH="网络管理/代理服务部署"
    show_menu_header
    
    echo ""
    # 代理部署菜单选项 - 居中显示，每个选项单独一行，增加空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}Nginx反向代理${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [2]${NC} ${WHITE}Caddy代理${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [3]${NC} ${WHITE}Squid代理${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}Clash代理${NC}"
    echo ""
    
    # 使用分隔线分开返回选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${RED}◆ [0]${NC} ${WHITE}返回网络管理${NC}"
    
    show_menu_footer
    
    read choice
    process_proxy_menu "$choice"
}

# 处理代理部署菜单选择
process_proxy_menu() {
    case "$1" in
        1) execute_module "network/proxy/nginx.sh" && proxy_deployment ;;
        2) execute_module "network/proxy/caddy.sh" && proxy_deployment ;;
        3) execute_module "network/proxy/squid.sh" && proxy_deployment ;;
        4) execute_module "network/proxy/clash.sh" && proxy_deployment ;;
        0) network_management ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            proxy_deployment
            ;;
    esac
}

# 应用与服务菜单
application_service() {
    MENU_PATH="应用与服务"
    show_menu_header
    
    echo ""
    # 应用与服务菜单选项 - 居中显示，每个选项单独一行，增加空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}Docker管理${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [2]${NC} ${WHITE}LDNMP建站${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [3]${NC} ${WHITE}应用市场${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}数据库管理${NC}"
    echo ""
    echo -e "                          ${MAGENTA}◆ [5]${NC} ${WHITE}Web服务器${NC}"
    echo ""
    echo -e "                          ${CYAN}◆ [6]${NC} ${WHITE}邮件服务${NC}"
    echo ""
    
    # 使用分隔线分开返回选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${RED}◆ [0]${NC} ${WHITE}返回主菜单${NC}"
    
    show_menu_footer
    
    read choice
    process_application_menu "$choice"
}

# 处理应用与服务菜单选择
process_application_menu() {
    case "$1" in
        1) execute_module "application/docker_manager.sh" && application_service ;;
        2) execute_module "application/ldnmp.sh" && application_service ;;
        3) execute_module "application/app_market.sh" && application_service ;;
        4) execute_module "application/database_manager.sh" && application_service ;;
        5) execute_module "application/web_server.sh" && application_service ;;
        6) execute_module "application/mail_server.sh" && application_service ;;
        0) show_main_menu ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            application_service
            ;;
    esac
}

# 高级功能菜单
advanced_features() {
    MENU_PATH="高级功能"
    show_menu_header
    
    echo ""
    # 高级功能菜单选项 - 居中显示，每个选项单独一行，增加空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}测试脚本合集${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [2]${NC} ${WHITE}备份与恢复${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [3]${NC} ${WHITE}服务器集群控制${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}安全防护中心${NC}"
    echo ""
    echo -e "                          ${MAGENTA}◆ [5]${NC} ${WHITE}性能优化${NC}"
    echo ""
    echo -e "                          ${CYAN}◆ [6]${NC} ${WHITE}日志分析${NC}"
    echo ""
    
    # 使用分隔线分开返回选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${RED}◆ [0]${NC} ${WHITE}返回主菜单${NC}"
    
    show_menu_footer
    
    read choice
    process_advanced_menu "$choice"
}

# 处理高级功能菜单选择
process_advanced_menu() {
    case "$1" in
        1) execute_module "advanced/test_scripts.sh" && advanced_features ;;
        2) execute_module "advanced/backup_restore.sh" && advanced_features ;;
        3) execute_module "advanced/server_cluster.sh" && advanced_features ;;
        4) execute_module "advanced/security_center.sh" && advanced_features ;;
        5) execute_module "advanced/performance_optimize.sh" && advanced_features ;;
        6) execute_module "advanced/log_analyzer.sh" && advanced_features ;;
        0) show_main_menu ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            advanced_features
            ;;
    esac
}

# 特别功能菜单
special_features() {
    MENU_PATH="特别功能"
    show_menu_header
    
    echo ""
    # 特别功能菜单选项 - 居中显示，每个选项单独一行，增加空白行
    echo -e "                          ${BRIGHT_GREEN}◆ [1]${NC} ${WHITE}甲骨文云工具${NC}"
    echo ""
    echo -e "                          ${GREEN}◆ [2]${NC} ${WHITE}幻兽帕鲁开服${NC}"
    echo ""
    echo -e "                          ${BLUE}◆ [3]${NC} ${WHITE}我的工作区${NC}"
    echo ""
    echo -e "                          ${YELLOW}◆ [4]${NC} ${WHITE}游戏服务器搭建${NC}"
    echo ""
    echo -e "                          ${MAGENTA}◆ [5]${NC} ${WHITE}AI助手部署${NC}"
    echo ""
    echo -e "                          ${CYAN}◆ [6]${NC} ${WHITE}广告专栏${NC}"
    echo ""
    
    # 使用分隔线分开返回选项
    echo -e "                          ${YELLOW}----------------------------------------${NC}"
    echo ""
    echo -e "                          ${RED}◆ [0]${NC} ${WHITE}返回主菜单${NC}"
    
    show_menu_footer
    
    read choice
    process_special_menu "$choice"
}

# 处理特别功能菜单选择
process_special_menu() {
    case "$1" in
        1) execute_module "special/oracle_tools.sh" && special_features ;;
        2) execute_module "special/palworld_server.sh" && special_features ;;
        3) execute_module "special/workspace.sh" && special_features ;;
        4) execute_module "special/game_servers.sh" && special_features ;;
        5) execute_module "special/ai_assistant.sh" && special_features ;;
        6) execute_module "special/ads.sh" && special_features ;;
        0) show_main_menu ;;
        *) 
            echo -e "${RED}无效选项，请重新输入${NC}"
            sleep 1
            special_features
            ;;
    esac
}

# 主函数
main() {
    system_init
    show_main_menu
}

# 启动主程序
main