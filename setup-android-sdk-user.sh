#!/bin/bash

echo "🔧 设置用户级Android SDK环境"
echo "============================"

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

# 设置用户级SDK目录
ANDROID_SDK_DIR="$HOME/android-sdk"

print_message $BLUE "📥 下载Android SDK到用户目录..."

# 创建SDK目录
mkdir -p "$ANDROID_SDK_DIR"
cd "$ANDROID_SDK_DIR"

# 下载Android SDK
wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip

if [ $? -ne 0 ]; then
    print_message $RED "❌ 下载Android SDK失败"
    exit 1
fi

print_message $GREEN "✅ 下载完成"

# 解压SDK
print_message $BLUE "📦 解压Android SDK..."
unzip -q commandlinetools-linux-9477386_latest.zip

# 创建正确的目录结构
mkdir -p cmdline-tools/cmdline-tools
cp -r cmdline-tools/* cmdline-tools/cmdline-tools/
rm -rf cmdline-tools/cmdline-tools/cmdline-tools

# 设置环境变量
export ANDROID_HOME="$ANDROID_SDK_DIR"
export ANDROID_SDK_ROOT="$ANDROID_SDK_DIR"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/cmdline-tools/bin

print_message $BLUE "⚙️  配置Android SDK..."

# 接受许可证
yes | sdkmanager --licenses > /dev/null 2>&1

# 安装必要的SDK组件
print_message $BLUE "📦 安装SDK组件..."
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_message $GREEN "✅ Android SDK安装成功"
else
    print_message $RED "❌ Android SDK安装失败"
    exit 1
fi

# 更新local.properties
print_message $BLUE "📝 更新local.properties..."

# 回到项目目录
cd - > /dev/null

# 更新local.properties
cat > local.properties << EOF
## This file must *NOT* be checked into Version Control Systems,
# as it contains information specific to your local configuration.
#
# Location of the SDK. This is only used by Gradle.
# For customization when using a Version Control System, please read the
# header note.
sdk.dir=$ANDROID_SDK_DIR
EOF

print_message $GREEN "✅ local.properties已更新"

# 创建环境变量配置文件
print_message $BLUE "📝 创建环境变量配置..."

cat > "$HOME/.android-sdk-env.sh" << EOF
export ANDROID_HOME="$ANDROID_SDK_DIR"
export ANDROID_SDK_ROOT="$ANDROID_SDK_DIR"
export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/cmdline-tools/bin
export PATH=\$PATH:\$ANDROID_HOME/platform-tools
EOF

# 添加到.bashrc
if ! grep -q "android-sdk-env.sh" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Android SDK Environment" >> "$HOME/.bashrc"
    echo "source \$HOME/.android-sdk-env.sh" >> "$HOME/.bashrc"
    print_message $GREEN "✅ 已添加到.bashrc"
fi

# 设置当前会话的环境变量
export ANDROID_HOME="$ANDROID_SDK_DIR"
export ANDROID_SDK_ROOT="$ANDROID_SDK_DIR"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/cmdline-tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

print_message $GREEN "✅ 环境变量已设置"

# 验证安装
print_message $BLUE "🔍 验证安装..."

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

# 测试sdkmanager
if command -v sdkmanager &> /dev/null; then
    print_message $GREEN "✅ sdkmanager可用"
else
    print_message $RED "❌ sdkmanager不可用"
fi

print_message $GREEN "🎉 用户级Android SDK设置完成！"

echo ""
print_message $BLUE "📋 使用说明："
echo "1. 重新登录或运行: source ~/.android-sdk-env.sh"
echo "2. 验证环境变量: echo \$ANDROID_HOME"
echo "3. 运行构建: ./gradlew assembleDebug"
echo ""
print_message $YELLOW "💡 SDK安装在: $ANDROID_SDK_DIR"