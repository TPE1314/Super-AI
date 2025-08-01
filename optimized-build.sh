#!/bin/bash

echo "🚀 优化构建脚本"
echo "=================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 函数：检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message $RED "❌ $1 未安装"
        return 1
    else
        print_message $GREEN "✅ $1 已安装"
        return 0
    fi
}

# 函数：清理项目
clean_project() {
    print_message $BLUE "🧹 清理项目..."
    ./gradlew clean
    rm -rf .gradle
    rm -rf build
    rm -rf app/build
    print_message $GREEN "✅ 清理完成"
}

# 函数：检查依赖
check_dependencies() {
    print_message $BLUE "🔍 检查依赖..."
    
    check_command "java"
    check_command "gradle"
    check_command "docker"
    
    # 检查Android SDK
    if [ -n "$ANDROID_HOME" ]; then
        print_message $GREEN "✅ ANDROID_HOME: $ANDROID_HOME"
    else
        print_message $YELLOW "⚠️  ANDROID_HOME 未设置"
    fi
}

# 函数：优化构建
optimized_build() {
    print_message $BLUE "🔨 开始优化构建..."
    
    # 设置优化参数
    export GRADLE_OPTS="-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError"
    
    # 并行构建
    ./gradlew assembleDebug \
        --parallel \
        --daemon \
        --build-cache \
        --configure-on-demand \
        --max-workers=4 \
        --no-build-cache=false \
        --scan
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 构建成功！"
        return 0
    else
        print_message $RED "❌ 构建失败！"
        return 1
    fi
}

# 函数：构建发布版本
build_release() {
    print_message $BLUE "📦 构建发布版本..."
    
    ./gradlew assembleRelease \
        --parallel \
        --daemon \
        --build-cache \
        --configure-on-demand \
        --max-workers=4
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ 发布版本构建成功！"
        return 0
    else
        print_message $RED "❌ 发布版本构建失败！"
        return 1
    fi
}

# 函数：分析APK
analyze_apk() {
    local apk_path=$1
    if [ -f "$apk_path" ]; then
        print_message $BLUE "📊 分析APK..."
        echo "文件大小: $(du -h $apk_path | cut -f1)"
        echo "文件路径: $apk_path"
        
        # 使用aapt分析APK（如果可用）
        if command -v aapt &> /dev/null; then
            echo "包名: $(aapt dump badging $apk_path | grep package | cut -d"'" -f2)"
            echo "版本: $(aapt dump badging $apk_path | grep versionName | cut -d"'" -f2)"
        fi
    fi
}

# 函数：使用Docker构建
docker_build() {
    print_message $BLUE "🐳 使用Docker构建..."
    
    if ! check_command "docker"; then
        print_message $RED "❌ Docker未安装，无法使用Docker构建"
        return 1
    fi
    
    # 创建输出目录
    mkdir -p build-output
    
    # 使用Docker构建
    docker run --rm \
        -v "$(pwd):/workspace" \
        -v "$(pwd)/build-output:/output" \
        openjdk:11-jdk bash -c "
            cd /workspace &&
            apt-get update -qq && apt-get install -y -qq wget unzip curl &&
            wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip &&
            unzip -q commandlinetools-linux-9477386_latest.zip &&
            export ANDROID_HOME=/android-sdk &&
            export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/cmdline-tools/bin &&
            echo 'sdk.dir=\$ANDROID_HOME' > local.properties &&
            yes | sdkmanager --licenses > /dev/null 2>&1 &&
            sdkmanager 'platform-tools' 'platforms;android-34' 'build-tools;34.0.0' > /dev/null 2>&1 &&
            ./gradlew assembleDebug --parallel --daemon --build-cache > /dev/null 2>&1 &&
            cp app/build/outputs/apk/debug/app-debug.apk /output/ &&
            echo '✅ Docker构建完成！'
        "
    
    if [ -f "build-output/app-debug.apk" ]; then
        print_message $GREEN "✅ Docker构建成功！"
        analyze_apk "build-output/app-debug.apk"
        return 0
    else
        print_message $RED "❌ Docker构建失败！"
        return 1
    fi
}

# 主函数
main() {
    print_message $BLUE "🚀 开始优化构建流程..."
    
    # 检查依赖
    check_dependencies
    
    # 清理项目
    clean_project
    
    # 选择构建方式
    echo ""
    print_message $YELLOW "请选择构建方式："
    echo "1. 本地构建（需要Android SDK）"
    echo "2. Docker构建（推荐）"
    echo "3. 构建发布版本"
    echo "4. 仅分析现有APK"
    
    read -p "请输入选择 (1-4): " choice
    
    case $choice in
        1)
            optimized_build
            if [ $? -eq 0 ]; then
                analyze_apk "app/build/outputs/apk/debug/app-debug.apk"
            fi
            ;;
        2)
            docker_build
            ;;
        3)
            build_release
            if [ $? -eq 0 ]; then
                analyze_apk "app/build/outputs/apk/release/app-release.apk"
            fi
            ;;
        4)
            if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
                analyze_apk "app/build/outputs/apk/debug/app-debug.apk"
            elif [ -f "build-output/app-debug.apk" ]; then
                analyze_apk "build-output/app-debug.apk"
            else
                print_message $RED "❌ 未找到APK文件"
            fi
            ;;
        *)
            print_message $RED "❌ 无效选择"
            exit 1
            ;;
    esac
    
    echo ""
    print_message $GREEN "🎉 构建流程完成！"
}

# 运行主函数
main