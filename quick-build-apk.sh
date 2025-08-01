#!/bin/bash

echo "🚀 快速构建APK - 新功能版本"
echo "================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 检查Java
if ! command -v java &> /dev/null; then
    print_message $RED "❌ Java未安装"
    exit 1
fi

print_message $GREEN "✅ Java已安装: $(java -version 2>&1 | head -n 1)"

# 检查Gradle Wrapper
if [ ! -f "./gradlew" ]; then
    print_message $RED "❌ Gradle Wrapper不存在"
    exit 1
fi

print_message $GREEN "✅ Gradle Wrapper存在"

# 设置权限
chmod +x gradlew

# 清理项目
print_message $BLUE "🧹 清理项目..."
./gradlew clean

# 构建Debug APK
print_message $BLUE "🔨 构建Debug APK..."
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    print_message $GREEN "🎉 构建成功！"
    
    # 检查APK文件
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        APK_SIZE=$(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)
        print_message $BLUE "📱 APK文件位置: app/build/outputs/apk/debug/app-debug.apk"
        print_message $BLUE "📊 文件大小: $APK_SIZE"
        
        echo ""
        print_message $YELLOW "📋 新功能特性："
        echo "✅ 聊天历史记录"
        echo "✅ 搜索功能"
        echo "✅ 数据库存储"
        echo "✅ 历史记录管理"
        echo "✅ 优化的UI界面"
        echo "✅ Room数据库支持"
        
        echo ""
        print_message $GREEN "📱 安装说明："
        echo "1. 将APK文件传输到Android设备"
        echo "2. 在设备上启用'未知来源'应用安装"
        echo "3. 点击APK文件进行安装"
        echo "4. 打开应用，点击右上角历史记录图标查看新功能"
        echo ""
        echo "🔧 或者使用ADB安装："
        echo "adb install app/build/outputs/apk/debug/app-debug.apk"
        
        # 复制到build-output目录
        mkdir -p build-output
        cp app/build/outputs/apk/debug/app-debug.apk build-output/
        print_message $GREEN "📁 APK已复制到: build-output/app-debug.apk"
        
    else
        print_message $RED "❌ APK文件未找到"
        exit 1
    fi
    
else
    print_message $RED "❌ 构建失败！"
    exit 1
fi

echo ""
print_message $GREEN "🎉 构建流程完成！"