#!/bin/bash

# backup_sync模块菜单
# 此脚本提供备份与同步相关功能的菜单界面

# 获取安装目录
INSTALL_DIR="$(dirname $(dirname $(dirname $(readlink -f $0))))"
MODULES_DIR="$INSTALL_DIR/modules"

# 导入共享函数
source "$INSTALL_DIR/main.sh"

# 显示菜单
show_backup_sync_menu() {
    local title="备份与同步"
    local menu_items=(
        "1" "系统备份与恢复 - 备份系统至本地/远程"
        "2" "定时任务管理 - 设置定时备份"
        "3" "SSH远程连接工具 - 管理远程连接"
        "4" "Rsync远程同步工具 - 文件同步工具"
        "0" "返回上级菜单"
    )
    
    while true; do
        if [ "$USE_TEXT_MODE" = true ]; then
            clear
            echo "====================================================="
            echo "      备份与同步菜单                                  "
            echo "====================================================="
            echo ""
            echo "  1) 系统备份与恢复          3) SSH远程连接工具"
            echo "  2) 定时任务管理            4) Rsync远程同步工具"
            echo ""
            echo "  0) 返回上级菜单"
            echo ""
            read -p "请选择操作 [0-4]: " choice
        else
            # 使用Dialog显示菜单
            choice=$(dialog --clear --title "$title" \
                --menu "请选择一个选项:" 15 60 5 \
                "${menu_items[@]}" 2>&1 >/dev/tty)
            
            # 检查是否按下ESC或Cancel
            if [ $? -ne 0 ]; then
                return
            fi
        fi
        
        case $choice in
            1) execute_module "backup_sync/system_backup.sh" ;;
            2) execute_module "backup_sync/cron_tasks.sh" ;;
            3) execute_module "backup_sync/ssh_tools.sh" ;;
            4) execute_module "backup_sync/rsync_tools.sh" ;;
            0) return ;;
            *) 
                if [ "$USE_TEXT_MODE" = true ]; then
                    echo "无效选择，请重试"
                    sleep 1
                else
                    dialog --title "错误" --msgbox "无效选项: $choice\n请重新选择" 8 40
                fi
                ;;
        esac
        
        # 文本模式下，显示按键提示
        if [ "$USE_TEXT_MODE" = true ]; then
            echo ""
            echo "按Enter键继续..."
            read
        fi
    done
}

# 运行菜单
show_backup_sync_menu 