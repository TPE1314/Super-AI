#!/bin/bash

echo "🔍 Android构建环境诊断"
echo "========================"

echo ""
echo "📋 系统信息:"
echo "操作系统: $(uname -a)"
echo "Java版本: $(java -version 2>&1 | head -1)"
echo "Gradle版本: $(./gradlew --version 2>/dev/null | grep "Gradle" || echo "Gradle未安装")"

echo ""
echo "📋 Android SDK检查:"
if [ -n "$ANDROID_HOME" ]; then
    echo "ANDROID_HOME: $ANDROID_HOME"
    if [ -d "$ANDROID_HOME" ]; then
        echo "✅ Android SDK目录存在"
    else
        echo "❌ Android SDK目录不存在"
    fi
else
    echo "❌ ANDROID_HOME环境变量未设置"
fi

echo ""
echo "📋 local.properties检查:"
if [ -f "local.properties" ]; then
    echo "✅ local.properties文件存在"
    cat local.properties
else
    echo "❌ local.properties文件不存在"
fi

echo ""
echo "📋 Docker检查:"
if command -v docker &> /dev/null; then
    echo "✅ Docker已安装"
    docker --version
else
    echo "❌ Docker未安装"
fi

echo ""
echo "📋 网络连接检查:"
if curl -s --connect-timeout 5 https://google.com > /dev/null; then
    echo "✅ 网络连接正常"
else
    echo "❌ 网络连接异常"
fi

echo ""
echo "📋 磁盘空间检查:"
df -h . | tail -1

echo ""
echo "📋 内存使用情况:"
free -h

echo ""
echo "🎯 建议:"
if [ -z "$ANDROID_HOME" ] && [ ! -f "local.properties" ]; then
    echo "1. 使用GitHub Actions构建（推荐）"
    echo "2. 或安装Docker使用容器构建"
    echo "3. 或手动安装Android SDK"
elif command -v docker &> /dev/null; then
    echo "1. 使用Docker构建: ./quick-build.sh"
    echo "2. 或使用GitHub Actions构建"
else
    echo "1. 使用GitHub Actions构建（推荐）"
    echo "2. 或安装Docker: sudo apt-get install docker.io"
fi