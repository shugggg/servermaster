#!/bin/bash

# 性能优化
# 此脚本提供系统性能调优工具

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

# 显示性能优化菜单
show_performance_optimization_menu() {
    local title="性能优化"
    local menu_items=(
        "1" "设置BBR3加速 - 网络性能优化"
        "2" "红帽系Linux内核升级 - 升级内核版本"
        "3" "Linux系统内核参数优化 - 优化系统参数"
        "4" "一条龙系统调优 - 全面系统性能优化"
        "0" "返回上级菜单"
    )
    
    while true; do
        # 确保我们在正确的目录
        cd "$INSTALL_DIR"
        
        if [ "$USE_TEXT_MODE" = true ]; then
            clear
            echo "====================================================="
            echo "      性能优化                                        "
            echo "====================================================="
            echo ""
            echo "  1) 设置BBR3加速"
            echo "  2) 红帽系Linux内核升级"
            echo "  3) Linux系统内核参数优化"
            echo "  4) 一条龙系统调优"
            echo ""
            echo "  0) 返回上级菜单"
            echo ""
            read -p "请选择操作 [0-4]: " choice
        else
            # 获取对话框尺寸
            read dialog_height dialog_width <<< $(get_dialog_size)
            
            # 使用Dialog显示菜单
            choice=$(dialog --clear --title "$title" \
                --menu "请选择一个选项:" $dialog_height $dialog_width 5 \
                "${menu_items[@]}" 2>&1 >/dev/tty)
            
            # 检查是否按下ESC或Cancel
            local status=$?
            if [ $status -ne 0 ]; then
                cd "$CURRENT_DIR"  # 恢复原始目录
                return
            fi
        fi
        
        # 这里只是占位，具体功能实现会在后续开发中添加
        case $choice in
            1|2|3|4) 
                if [ "$USE_TEXT_MODE" = true ]; then
                    echo "该功能尚未实现"
                    sleep 2
                else
                    dialog --title "提示" --msgbox "该功能尚未实现" 8 40
                fi
                ;;
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
show_performance_optimization_menu

# 确保在脚本结束时恢复原始目录
cd "$CURRENT_DIR" 