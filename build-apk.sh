#!/bin/bash

echo "🚀 快速构建APK"
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

# 检查Docker
if command -v docker &> /dev/null; then
    print_message $GREEN "✅ Docker可用，使用Docker构建"
    
    # 创建输出目录
    mkdir -p build-output
    
    print_message $BLUE "🔨 开始构建APK..."
    
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
            ./gradlew assembleDebug --parallel --daemon --build-cache > /dev/null 2>&1 &&
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
        echo "✅ 本地数据库存储"
        echo "✅ 搜索功能"
        echo "✅ 错误记录"
        echo "✅ 导出功能（开发中）"
        echo "✅ 优化的UI界面"
        
        echo ""
        print_message $GREEN "📱 安装说明："
        echo "1. 将APK文件传输到Android设备"
        echo "2. 在设备上启用'未知来源'应用安装"
        echo "3. 点击APK文件进行安装"
        echo ""
        echo "🔧 或者使用ADB安装："
        echo "adb install build-output/app-debug.apk"
        
    else
        print_message $RED "❌ 构建失败！"
        exit 1
    fi
    
else
    print_message $YELLOW "⚠️  Docker不可用，尝试本地构建"
    
    # 检查Android SDK
    if [ -n "$ANDROID_HOME" ]; then
        print_message $GREEN "✅ Android SDK已配置"
        
        print_message $BLUE "🔨 开始本地构建..."
        ./gradlew assembleDebug
        
        if [ $? -eq 0 ]; then
            print_message $GREEN "🎉 构建成功！"
            print_message $BLUE "📱 APK文件位置: app/build/outputs/apk/debug/app-debug.apk"
            
            if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
                print_message $BLUE "📊 文件大小: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
            fi
        else
            print_message $RED "❌ 构建失败！"
            exit 1
        fi
        
    else
        print_message $RED "❌ 未找到Android SDK"
        print_message $YELLOW "💡 建议："
        echo "1. 安装Android Studio"
        echo "2. 或使用GitHub Actions构建"
        echo "3. 或安装Docker使用容器构建"
        exit 1
    fi
fi

echo ""
print_message $GREEN "🎉 构建流程完成！"