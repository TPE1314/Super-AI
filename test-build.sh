#!/bin/bash

echo "🧪 快速构建测试"
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

print_message $BLUE "🔍 检查项目文件..."

# 检查关键文件
files_to_check=(
    "app/build.gradle"
    "app/src/main/AndroidManifest.xml"
    "app/src/main/java/com/example/robotapi/MainActivity.kt"
    "app/src/main/java/com/example/robotapi/data/ChatMessage.kt"
    "app/src/main/java/com/example/robotapi/database/AppDatabase.kt"
    "app/src/main/java/com/example/robotapi/ui/HistoryActivity.kt"
    "app/src/main/res/layout/activity_main.xml"
    "app/src/main/res/layout/activity_history.xml"
    "app/src/main/res/layout/item_history.xml"
    "app/src/main/res/values/colors.xml"
    "app/src/main/res/values/strings.xml"
    ".github/workflows/build-apk.yml"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        print_message $GREEN "✅ $file"
    else
        print_message $RED "❌ $file"
    fi
done

echo ""
print_message $BLUE "📊 统计信息..."

# 统计Kotlin文件
kotlin_files=$(find app/src/main/java -name "*.kt" | wc -l)
print_message $GREEN "📝 Kotlin文件数量: $kotlin_files"

# 统计布局文件
layout_files=$(find app/src/main/res/layout -name "*.xml" | wc -l)
print_message $GREEN "🎨 布局文件数量: $layout_files"

# 统计资源文件
resource_files=$(find app/src/main/res -name "*.xml" | wc -l)
print_message $GREEN "📦 资源文件数量: $resource_files"

echo ""
print_message $BLUE "🔧 检查Gradle配置..."

# 检查Gradle配置
if grep -q "room" app/build.gradle; then
    print_message $GREEN "✅ Room数据库依赖已配置"
else
    print_message $RED "❌ Room数据库依赖未配置"
fi

if grep -q "kotlin-parcelize" app/build.gradle; then
    print_message $GREEN "✅ Kotlin Parcelize插件已配置"
else
    print_message $RED "❌ Kotlin Parcelize插件未配置"
fi

if grep -q "viewBinding" app/build.gradle; then
    print_message $GREEN "✅ ViewBinding已启用"
else
    print_message $RED "❌ ViewBinding未启用"
fi

echo ""
print_message $BLUE "📱 检查Android配置..."

# 检查Android配置
if grep -q "compileSdk 34" app/build.gradle; then
    print_message $GREEN "✅ 编译SDK版本正确"
else
    print_message $RED "❌ 编译SDK版本不正确"
fi

if grep -q "minSdk 24" app/build.gradle; then
    print_message $GREEN "✅ 最小SDK版本正确"
else
    print_message $RED "❌ 最小SDK版本不正确"
fi

echo ""
print_message $BLUE "🎯 建议..."

if [ $kotlin_files -ge 10 ] && [ $layout_files -ge 3 ]; then
    print_message $GREEN "✅ 项目文件看起来完整"
    print_message $YELLOW "💡 建议使用GitHub Actions构建APK"
    echo "   访问: https://github.com/TPE1314/Super-AI/actions"
else
    print_message $RED "❌ 项目文件可能不完整"
    print_message $YELLOW "💡 请检查缺失的文件"
fi

echo ""
print_message $GREEN "🎉 测试完成！"