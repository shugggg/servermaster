#!/bin/bash

# 系统更新
# 此脚本提供系统及软件包更新功能

# 只在变量未定义时才设置安装目录
if [ -z "$INSTALL_DIR" ]; then
    INSTALL_DIR="$(dirname $(dirname $(dirname $(readlink -f $0))))"
    MODULES_DIR="$INSTALL_DIR/modules"
    CONFIG_DIR="$INSTALL_DIR/config"
    
    # 导入共享函数
    source "$INSTALL_DIR/main.sh"
    
    # 导入对话框规则
    source "$CONFIG_DIR/dialog_rules.sh"
fi

# 保存当前目录
CURRENT_DIR="$(pwd)"

# 定义颜色
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"
SEPARATOR="------------------------------------------------------"

# 修复 dpkg 可能的中断问题（更安全）
fix_dpkg_safe() {
    echo -e "检查并修复 dpkg 相关问题..."

    # 查找是否有 apt/dpkg 进程占用锁文件
    if sudo lsof /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock &>/dev/null; then
        echo -e "检测到 dpkg 被占用，尝试优雅终止相关进程..."
        
        # 获取占用进程的 PID
        PIDS=$(sudo lsof -t /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock)
        for PID in $PIDS; do
            echo -e "终止进程: $PID"
            sudo kill -TERM $PID  # 先尝试优雅终止
            sleep 2  # 等待进程退出
            if ps -p $PID &>/dev/null; then
                echo -e "进程 $PID 未能终止，执行强制终止..."
                sudo kill -9 $PID  # 若进程仍未退出，则强制终止
            fi
        done
    else
        echo -e "未检测到 dpkg 进程占用锁文件。"
    fi

    # 停止系统自动更新服务（适用于 Ubuntu/Debian）
    echo -e "停止 apt 相关的自动更新服务..."
    sudo systemctl stop apt-daily.service apt-daily-upgrade.service 2>/dev/null
    sudo systemctl disable apt-daily.service apt-daily-upgrade.service 2>/dev/null

    # 确保锁文件被删除
    echo -e "删除 dpkg 锁文件..."
    sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock

    # 修复 dpkg 未完成的安装
    echo -e "修复 dpkg 配置..."
    sudo dpkg --configure -a

    # 再次启用自动更新服务
    echo -e "重新启用 apt 自动更新服务..."
    sudo systemctl enable apt-daily.service apt-daily-upgrade.service 2>/dev/null
}

# 统一系统更新方法，兼容多种 Linux 发行版
system_update() {
    # 创建临时文件存储状态
    local status_file=$(mktemp)
    echo "成功" > "$status_file"
    
    echo -e "开始进行系统更新..."

    if command -v dnf &>/dev/null; then
        echo -e "检测到 DNF，使用 DNF 进行更新..."
        if ! sudo dnf -y update; then
            echo "失败" > "$status_file"
        fi

    elif command -v yum &>/dev/null; then
        echo -e "检测到 YUM，使用 YUM 进行更新..."
        if ! sudo yum -y update; then
            echo "失败" > "$status_file"
        fi

    elif command -v apt &>/dev/null; then
        echo -e "检测到 APT，使用 APT 进行更新..."
        fix_dpkg_safe  # 修复 dpkg 可能的中断问题
        sudo DEBIAN_FRONTEND=noninteractive apt update -y
        if ! sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y; then
            echo "失败" > "$status_file"
        fi

    elif command -v apk &>/dev/null; then
        echo -e "检测到 APK，使用 Alpine 的 apk 进行更新..."
        if ! (sudo apk update && sudo apk upgrade); then
            echo "失败" > "$status_file"
        fi

    elif command -v pacman &>/dev/null; then
        echo -e "检测到 Pacman，使用 Arch Linux 的 pacman 进行更新..."
        if ! sudo pacman -Syu --noconfirm; then
            echo "失败" > "$status_file"
        fi

    elif command -v zypper &>/dev/null; then
        echo -e "检测到 Zypper，使用 OpenSUSE 的 zypper 进行更新..."
        sudo zypper refresh
        if ! sudo zypper update -y; then
            echo "失败" > "$status_file"
        fi

    elif command -v opkg &>/dev/null; then
        echo -e "检测到 OPKG，使用 OpenWRT 的 opkg 进行更新..."
        if ! (sudo opkg update && sudo opkg upgrade); then
            echo "失败" > "$status_file"
        fi

    else
        echo -e "未知的包管理器，无法更新系统！"
        echo "失败" > "$status_file"
    fi

    local update_status=$(cat "$status_file")
    rm -f "$status_file"
    
    echo -e "系统更新$update_status！"
    return 0
}

# 显示系统更新执行界面
show_system_update() {
    # 确保我们在正确的目录
    cd "$INSTALL_DIR"
    
    clear
    
    # 创建临时文件存储日志
    local log_file=$(mktemp)
    
    # 文本模式下的显示
    if [ "$USE_TEXT_MODE" = true ]; then
        clear
        echo "====================================================="
        echo -e "${GREEN}      系统更新                                        ${RESET}"
        echo "====================================================="
        echo ""
        echo -e "${BLUE}${SEPARATOR}${RESET}"
        echo -e "${YELLOW}正在执行系统更新，请稍候...${RESET}"
        echo -e "${BLUE}${SEPARATOR}${RESET}"
        echo ""
        
        # 执行系统更新并捕获输出到日志文件
        system_update | tee "$log_file"
        
        # 检查更新是否成功（根据输出中是否包含"系统更新成功"）
        if grep -q "系统更新成功" "$log_file"; then
            update_status="成功"
        else
            update_status="失败"
        fi
        
        echo -e "${BLUE}${SEPARATOR}${RESET}"
        if [ "$update_status" = "成功" ]; then
            echo -e "${GREEN}系统更新完成！${RESET}"
        else
            echo -e "${RED}系统更新失败！${RESET}"
        fi
        echo -e "${BLUE}${SEPARATOR}${RESET}"
        
        echo ""
        echo "按Enter键继续..."
        read
    else
        # 使用Dialog显示进度
        dialog --title "系统更新" --infobox "正在执行系统更新，请稍候..." 5 40
        
        # 执行系统更新并捕获输出到日志文件
        system_update > "$log_file" 2>&1
        
        # 检查更新是否成功
        if grep -q "系统更新成功" "$log_file"; then
            update_status="成功"
        else
            update_status="失败"
        fi
        
        # 获取对话框尺寸
        read dialog_height dialog_width <<< $(get_dialog_size)
        
        # 获取日志内容
        update_log=$(cat "$log_file")
        
        # 显示结果
        if [ "$update_status" = "成功" ]; then
            dialog --title "系统更新" --msgbox "系统更新完成！\n\n更新日志:\n$update_log" $dialog_height $dialog_width
        else
            dialog --title "系统更新" --msgbox "系统更新失败！\n\n更新日志:\n$update_log" $dialog_height $dialog_width
        fi
    fi
    
    # 清理临时文件
    rm -f "$log_file"
}

# 直接显示系统更新界面，不再显示菜单
show_system_update

# 确保在脚本结束时恢复原始目录
cd "$CURRENT_DIR" 