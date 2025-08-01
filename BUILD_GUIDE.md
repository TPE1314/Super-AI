# Android应用构建指南

本文档提供了多种构建机器人API Android应用的方法。

## 方法一：使用Android Studio（推荐）

### 前提条件
- Android Studio Arctic Fox 或更高版本
- JDK 11 或更高版本
- 至少4GB RAM

### 步骤
1. 下载并安装 [Android Studio](https://developer.android.com/studio)
2. 打开Android Studio
3. 选择 "Open an existing project"
4. 选择项目根目录
5. 等待Gradle同步完成
6. 连接Android设备或启动模拟器
7. 点击 "Build" → "Build Bundle(s) / APK(s)" → "Build APK(s)"

## 方法二：使用命令行（需要Android SDK）

### 安装Android SDK
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install android-sdk

# 或者手动下载
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-9477386_latest.zip
export ANDROID_HOME=/path/to/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
```

### 构建命令
```bash
# 设置SDK路径
echo "sdk.dir=$ANDROID_HOME" > local.properties

# 构建调试版本
./gradlew assembleDebug

# 构建发布版本
./gradlew assembleRelease
```

## 方法三：使用Docker（推荐用于CI/CD）

### 前提条件
- 安装Docker

### 构建命令
```bash
# 构建镜像
docker build -t robot-api-android .

# 运行构建
docker run --rm -v $(pwd)/build-output:/output robot-api-android
```

## 方法四：使用在线构建服务

### GitHub Actions
创建 `.github/workflows/build.yml`:
```yaml
name: Build Android APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 11
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'
    - name: Setup Android SDK
      uses: android-actions/setup-android@v2
    - name: Build APK
      run: ./gradlew assembleDebug
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-debug
        path: app/build/outputs/apk/debug/app-debug.apk
```

### GitLab CI
创建 `.gitlab-ci.yml`:
```yaml
build:
  image: openjdk:11-jdk
  before_script:
    - apt-get update -qq && apt-get install -y -qq wget unzip
    - wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    - unzip -q commandlinetools-linux-9477386_latest.zip
    - export ANDROID_HOME=$PWD/android-sdk
    - export PATH=$PATH:$ANDROID_HOME/cmdline-tools/cmdline-tools/bin
    - echo "sdk.dir=$ANDROID_HOME" > local.properties
    - yes | sdkmanager --licenses
    - sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
  script:
    - ./gradlew assembleDebug
  artifacts:
    paths:
      - app/build/outputs/apk/debug/app-debug.apk
```

## 方法五：使用预构建的Docker镜像

```bash
# 使用预构建镜像
docker run --rm -v $(pwd):/workspace -v $(pwd)/output:/output \
  openjdk:11-jdk bash -c "
    cd /workspace &&
    apt-get update && apt-get install -y wget unzip &&
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip &&
    unzip -q commandlinetools-linux-9477386_latest.zip &&
    export ANDROID_HOME=/android-sdk &&
    export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/cmdline-tools/bin &&
    echo 'sdk.dir=\$ANDROID_HOME' > local.properties &&
    yes | sdkmanager --licenses &&
    sdkmanager 'platform-tools' 'platforms;android-34' 'build-tools;34.0.0' &&
    ./gradlew assembleDebug &&
    cp app/build/outputs/apk/debug/app-debug.apk /output/
  "
```

## 构建输出

成功构建后，APK文件将位于：
- 调试版本：`app/build/outputs/apk/debug/app-debug.apk`
- 发布版本：`app/build/outputs/apk/release/app-release.apk`

## 安装APK

### 通过ADB安装
```bash
adb install app/build/outputs/apk/debug/app-debug.apk
```

### 通过文件管理器安装
1. 将APK文件传输到Android设备
2. 在设备上启用"未知来源"应用安装
3. 点击APK文件进行安装

## 故障排除

### 常见问题

1. **Gradle同步失败**
   - 检查网络连接
   - 清理项目：`./gradlew clean`
   - 删除 `.gradle` 目录后重试

2. **SDK路径错误**
   - 确保 `local.properties` 文件存在
   - 检查 `ANDROID_HOME` 环境变量

3. **内存不足**
   - 增加Gradle内存：在 `gradle.properties` 中添加 `org.gradle.jvmargs=-Xmx4096m`

4. **构建工具版本不匹配**
   - 更新Android SDK Build Tools
   - 检查 `build.gradle` 中的版本配置

## 验证构建

构建完成后，可以验证APK：
```bash
# 检查APK信息
aapt dump badging app/build/outputs/apk/debug/app-debug.apk

# 验证APK签名
jarsigner -verify -verbose -certs app/build/outputs/apk/debug/app-debug.apk
```