#!/bin/bash

# 工作区管理
# 此脚本提供工作区管理相关功能的菜单界面

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

# 显示工作区管理菜单
show_workspace_management_menu() {
    local title="工作区管理"
    local menu_items=(
        "1" "快速工作区 - 1号-10号工作区"
        "2" "SSH常驻模式 - 保持SSH连接"
        "3" "创建/进入工作区 - 创建新工作区"
        "4" "注入命令到后台工作区 - 发送命令"
        "5" "删除指定工作区 - 关闭工作区"
        "0" "返回主菜单"
    )
    
    while true; do
        # 确保我们在正确的目录
        cd "$INSTALL_DIR"
        
        if [ "$USE_TEXT_MODE" = true ]; then
            clear
            echo "====================================================="
            echo "      工作区管理菜单                                  "
            echo "====================================================="
            echo ""
            echo "  1) 快速工作区               4) 注入命令到后台工作区"
            echo "  2) SSH常驻模式              5) 删除指定工作区"
            echo "  3) 创建/进入工作区          "
            echo ""
            echo "  0) 返回主菜单"
            echo ""
            read -p "请选择操作 [0-5]: " choice
        else
            # 获取对话框尺寸
            read dialog_height dialog_width <<< $(get_dialog_size)
            
            # 使用Dialog显示菜单
            choice=$(dialog --clear --title "$title" \
                --menu "请选择一个选项:" $dialog_height $dialog_width 6 \
                "${menu_items[@]}" 2>&1 >/dev/tty)
            
            # 检查是否按下ESC或Cancel
            local status=$?
            if [ $status -ne 0 ]; then
                cd "$CURRENT_DIR"  # 恢复原始目录
                return
            fi
        fi
        
        case $choice in
            1) execute_module "workspace_management/quick_workspace.sh" ;;
            2) execute_module "workspace_management/ssh_keep_alive.sh" ;;
            3) execute_module "workspace_management/create_workspace.sh" ;;
            4) execute_module "workspace_management/inject_command.sh" ;;
            5) execute_module "workspace_management/delete_workspace.sh" ;;
            0) 
                cd "$CURRENT_DIR"  # 恢复原始目录
                return 
                ;;
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
show_workspace_management_menu

# 确保在脚本结束时恢复原始目录
cd "$CURRENT_DIR" 