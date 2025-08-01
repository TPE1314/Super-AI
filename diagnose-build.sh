#!/bin/bash

echo "🔍 构建诊断工具"
echo "================"

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

echo ""
print_message $BLUE "📋 系统信息"
echo "操作系统: $(uname -a)"
echo "Java版本: $(java -version 2>&1 | head -n 1)"

echo ""
print_message $BLUE "📁 项目结构"
echo "当前目录: $(pwd)"
echo "项目文件:"
ls -la | grep -E "\.(gradle|kt|xml|properties)$" | head -10

echo ""
print_message $BLUE "🔧 Android SDK检查"
if [ -n "$ANDROID_HOME" ]; then
    print_message $GREEN "✅ ANDROID_HOME已设置: $ANDROID_HOME"
else
    print_message $YELLOW "⚠️  ANDROID_HOME未设置"
fi

if [ -n "$ANDROID_SDK_ROOT" ]; then
    print_message $GREEN "✅ ANDROID_SDK_ROOT已设置: $ANDROID_SDK_ROOT"
else
    print_message $YELLOW "⚠️  ANDROID_SDK_ROOT未设置"
fi

echo ""
print_message $BLUE "📄 配置文件检查"
if [ -f "local.properties" ]; then
    print_message $GREEN "✅ local.properties存在"
    cat local.properties
else
    print_message $YELLOW "⚠️  local.properties不存在"
fi

echo ""
print_message $BLUE "💡 建议解决方案"
echo "1. 如果ANDROID_HOME未设置，请安装Android SDK"
echo "2. 如果local.properties不存在，请创建并设置sdk.dir"
echo "3. 如果构建失败，请检查网络连接和依赖下载"
echo "4. 使用GitHub Actions进行自动构建（推荐）"

echo ""
print_message $GREEN "🎯 下一步"
echo "1. 访问GitHub Actions页面查看构建状态"
echo "2. 下载生成的APK文件"
echo "3. 在Android设备上安装和测试"

echo ""
print_message $GREEN "✅ 诊断完成！"