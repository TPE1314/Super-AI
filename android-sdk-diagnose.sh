#!/bin/bash

echo "🔍 Android SDK诊断工具"
echo "======================"

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
print_message $BLUE "📋 环境检查"

# 检查Java
if command -v java &> /dev/null; then
    print_message $GREEN "✅ Java已安装: $(java -version 2>&1 | head -n 1)"
else
    print_message $RED "❌ Java未安装"
fi

# 检查Gradle
if [ -f "./gradlew" ]; then
    print_message $GREEN "✅ Gradle Wrapper存在"
    chmod +x gradlew
else
    print_message $RED "❌ Gradle Wrapper不存在"
fi

echo ""
print_message $BLUE "🔧 Android SDK检查"

# 检查ANDROID_HOME
if [ -n "$ANDROID_HOME" ]; then
    print_message $GREEN "✅ ANDROID_HOME已设置: $ANDROID_HOME"
    if [ -d "$ANDROID_HOME" ]; then
        print_message $GREEN "✅ Android SDK目录存在"
        
        # 检查SDK组件
        if [ -d "$ANDROID_HOME/platforms" ]; then
            print_message $GREEN "✅ Platforms目录存在"
            ls -la "$ANDROID_HOME/platforms" | head -3
        else
            print_message $RED "❌ Platforms目录不存在"
        fi
        
        if [ -d "$ANDROID_HOME/build-tools" ]; then
            print_message $GREEN "✅ Build Tools目录存在"
            ls -la "$ANDROID_HOME/build-tools" | head -3
        else
            print_message $RED "❌ Build Tools目录不存在"
        fi
        
        if [ -d "$ANDROID_HOME/cmdline-tools" ]; then
            print_message $GREEN "✅ Command Line Tools目录存在"
        else
            print_message $RED "❌ Command Line Tools目录不存在"
        fi
    else
        print_message $RED "❌ Android SDK目录不存在"
    fi
else
    print_message $YELLOW "⚠️  ANDROID_HOME未设置"
fi

# 检查ANDROID_SDK_ROOT
if [ -n "$ANDROID_SDK_ROOT" ]; then
    print_message $GREEN "✅ ANDROID_SDK_ROOT已设置: $ANDROID_SDK_ROOT"
else
    print_message $YELLOW "⚠️  ANDROID_SDK_ROOT未设置"
fi

echo ""
print_message $BLUE "📄 配置文件检查"

# 检查local.properties
if [ -f "local.properties" ]; then
    print_message $GREEN "✅ local.properties存在"
    cat local.properties
else
    print_message $YELLOW "⚠️  local.properties不存在"
fi

echo ""
print_message $BLUE "🔍 常见问题诊断"

# 检查网络连接
if ping -c 1 dl.google.com &> /dev/null; then
    print_message $GREEN "✅ 网络连接正常"
else
    print_message $RED "❌ 网络连接异常"
fi

# 检查磁盘空间
available_space=$(df . | awk 'NR==2 {print $4}')
if [ "$available_space" -gt 1000000 ]; then
    print_message $GREEN "✅ 磁盘空间充足: ${available_space}KB"
else
    print_message $RED "❌ 磁盘空间不足: ${available_space}KB"
fi

echo ""
print_message $BLUE "💡 解决方案建议"

echo "1. 如果ANDROID_HOME未设置，请安装Android SDK"
echo "2. 如果SDK组件缺失，请运行以下命令："
echo "   sdkmanager 'platform-tools' 'platforms;android-34' 'build-tools;34.0.0'"
echo "3. 如果网络连接异常，请检查网络设置"
echo "4. 如果磁盘空间不足，请清理磁盘空间"
echo "5. 建议使用GitHub Actions进行构建"

echo ""
print_message $BLUE "🚀 推荐的构建方法"

echo "方法1: GitHub Actions (推荐)"
echo "  - 访问: https://github.com/TPE1314/Super-AI/actions"
echo "  - 运行 'Build APK with New Features' 工作流"

echo ""
echo "方法2: Docker构建"
echo "  - 运行: ./simple-docker-build.sh"

echo ""
echo "方法3: 在线构建"
echo "  - 使用Gitpod: https://gitpod.io/"
echo "  - 输入仓库URL: https://github.com/TPE1314/Super-AI"

echo ""
print_message $GREEN "✅ 诊断完成！"