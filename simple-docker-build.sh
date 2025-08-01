#!/bin/bash

echo "🚀 简单Docker构建APK"
echo "===================="

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

# 检查Docker
if ! command -v docker &> /dev/null; then
    print_message $RED "❌ Docker未安装"
    print_message $YELLOW "💡 建议使用GitHub Actions构建"
    exit 1
fi

print_message $GREEN "✅ Docker可用"

# 创建输出目录
mkdir -p build-output

print_message $BLUE "🔨 开始Docker构建..."

# 使用Docker构建
docker run --rm \
    -v "$(pwd):/workspace" \
    -v "$(pwd)/build-output:/output" \
    openjdk:11-jdk bash -c "
        cd /workspace &&
        echo '🔧 安装依赖...' &&
        apt-get update -qq && apt-get install -y -qq wget unzip curl &&
        echo '📥 下载Android SDK...' &&
        wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip &&
        unzip -q commandlinetools-linux-9477386_latest.zip &&
        export ANDROID_HOME=/android-sdk &&
        export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/cmdline-tools/bin &&
        echo '⚙️ 配置Android SDK...' &&
        echo 'sdk.dir=\$ANDROID_HOME' > local.properties &&
        yes | sdkmanager --licenses > /dev/null 2>&1 &&
        sdkmanager 'platform-tools' 'platforms;android-34' 'build-tools;34.0.0' > /dev/null 2>&1 &&
        echo '🔨 构建APK...' &&
        ./gradlew assembleDebug --no-daemon --stacktrace &&
        echo '📱 复制APK到输出目录...' &&
        cp app/build/outputs/apk/debug/app-debug.apk /output/ &&
        echo '✅ 构建完成！'
    "

if [ -f "build-output/app-debug.apk" ]; then
    print_message $GREEN "🎉 构建成功！"
    print_message $BLUE "📱 APK文件位置: build-output/app-debug.apk"
    print_message $BLUE "📊 文件大小: $(du -h build-output/app-debug.apk | cut -f1)"
    
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
    
else
    print_message $RED "❌ 构建失败！"
    print_message $YELLOW "💡 建议使用GitHub Actions构建"
    exit 1
fi

echo ""
print_message $GREEN "🎉 构建流程完成！"