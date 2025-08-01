#!/bin/bash

echo "🚀 使用在线构建服务构建Android APK..."

# 检查是否在GitHub环境中
if [ -n "$GITHUB_REPOSITORY" ]; then
    echo "✅ 检测到GitHub环境，将使用GitHub Actions构建"
    echo "📋 构建完成后，请访问以下链接下载APK："
    echo "https://github.com/$GITHUB_REPOSITORY/actions"
    exit 0
fi

echo "📋 构建选项："
echo "1. 使用GitHub Actions（推荐）"
echo "2. 使用GitLab CI"
echo "3. 使用本地Android Studio"
echo "4. 使用在线构建服务"

read -p "请选择构建方式 (1-4): " choice

case $choice in
    1)
        echo "🔧 设置GitHub Actions构建..."
        echo ""
        echo "📋 步骤："
        echo "1. 将代码推送到GitHub仓库"
        echo "2. 访问 https://github.com/YOUR_USERNAME/YOUR_REPO/actions"
        echo "3. 点击 'Build Android APK and Download' 工作流"
        echo "4. 点击 'Run workflow' 按钮"
        echo "5. 等待构建完成后下载APK"
        echo ""
        echo "💡 提示：确保仓库包含 .github/workflows/build-and-download.yml 文件"
        ;;
    2)
        echo "🔧 设置GitLab CI构建..."
        echo ""
        echo "📋 步骤："
        echo "1. 将代码推送到GitLab仓库"
        echo "2. 访问 https://gitlab.com/YOUR_USERNAME/YOUR_REPO/-/pipelines"
        echo "3. 等待CI/CD流水线完成"
        echo "4. 下载构建产物"
        ;;
    3)
        echo "🔧 使用Android Studio构建..."
        echo ""
        echo "📋 步骤："
        echo "1. 下载并安装 Android Studio"
        echo "2. 打开项目"
        echo "3. 等待Gradle同步"
        echo "4. 点击 Build → Build Bundle(s) / APK(s) → Build APK(s)"
        echo "5. 在 app/build/outputs/apk/debug/ 目录找到APK文件"
        ;;
    4)
        echo "🔧 使用在线构建服务..."
        echo ""
        echo "📋 推荐的在线构建服务："
        echo "1. Appetize.io - https://appetize.io/"
        echo "2. Bitrise - https://bitrise.io/"
        echo "3. CircleCI - https://circleci.com/"
        echo "4. Travis CI - https://travis-ci.com/"
        echo ""
        echo "💡 这些服务通常提供免费计划，可以自动构建Android应用"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "🎉 构建指南已生成！"
echo "📖 更多详细信息请查看 BUILD_GUIDE.md 文件"