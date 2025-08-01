#!/bin/bash

echo "🚀 开始构建机器人API Android应用..."

# 创建输出目录
mkdir -p build-output

# 构建Docker镜像
echo "📦 构建Docker镜像..."
docker build -t robot-api-android .

# 运行容器并复制APK
echo "🔨 构建APK..."
docker run --rm -v $(pwd)/build-output:/output robot-api-android

# 检查APK是否生成
if [ -f "build-output/app-debug.apk" ]; then
    echo "✅ 构建成功！"
    echo "📱 APK文件位置: build-output/app-debug.apk"
    echo "📊 文件大小: $(du -h build-output/app-debug.apk | cut -f1)"
else
    echo "❌ 构建失败！"
    exit 1
fi

echo "🎉 构建完成！"