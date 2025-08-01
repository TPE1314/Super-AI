#!/bin/bash

echo "🚀 简化构建脚本"
echo "=================="

# 创建输出目录
mkdir -p build-output

echo "📦 使用Docker构建Android应用..."

# 使用Docker构建
sudo docker run --rm \
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
    ./gradlew assembleDebug > /dev/null 2>&1 &&
    echo '📱 复制APK到输出目录...' &&
    cp app/build/outputs/apk/debug/app-debug.apk /output/ &&
    echo '✅ 构建完成！'
  "

# 检查构建结果
if [ -f "build-output/app-debug.apk" ]; then
    echo ""
    echo "🎉 构建成功！"
    echo "📱 APK文件位置: build-output/app-debug.apk"
    echo "📊 文件大小: $(du -h build-output/app-debug.apk | cut -f1)"
    echo ""
    echo "📋 安装说明:"
    echo "1. 将APK文件传输到Android设备"
    echo "2. 在设备上启用'未知来源'应用安装"
    echo "3. 点击APK文件进行安装"
else
    echo "❌ 构建失败！"
    echo "请尝试使用GitHub Actions构建"
fi