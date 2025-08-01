# 机器人API Android应用

这是一个用于聚合机器人API的Android应用程序，提供了现代化的用户界面和完整的网络请求功能。

## 功能特性

- 🚀 现代化的Material Design 3界面
- 📡 支持自定义API地址
- 💬 发送消息到机器人API
- 📱 响应式设计，适配不同屏幕尺寸
- 🔄 实时加载状态显示
- 🛡️ 完善的错误处理
- 🧹 一键清除功能

## 技术栈

- **语言**: Kotlin
- **架构**: MVVM (Model-View-ViewModel)
- **网络**: Retrofit + OkHttp
- **异步**: Kotlin Coroutines
- **UI**: Material Design 3
- **构建**: Gradle

## 项目结构

```
app/
├── src/main/
│   ├── java/com/example/robotapi/
│   │   ├── data/           # 数据模型
│   │   ├── network/        # 网络层
│   │   ├── repository/     # 数据仓库
│   │   ├── viewmodel/      # 视图模型
│   │   └── MainActivity.kt # 主活动
│   ├── res/
│   │   ├── layout/         # 布局文件
│   │   ├── values/         # 资源文件
│   │   └── xml/           # XML配置文件
│   └── AndroidManifest.xml
├── build.gradle           # 应用级构建配置
└── proguard-rules.pro    # 混淆规则

build.gradle              # 项目级构建配置
settings.gradle           # 项目设置
gradle.properties         # Gradle属性
```

## 构建和运行

### 前提条件

- Android Studio Arctic Fox 或更高版本
- JDK 11 或更高版本
- Android SDK API 24 或更高版本

### 构建步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd RobotAPI
   ```

2. **同步依赖**
   ```bash
   ./gradlew build
   ```

3. **构建APK**
   ```bash
   ./gradlew assembleDebug
   ```

4. **构建发布版本**
   ```bash
   ./gradlew assembleRelease
   ```

### 在Android Studio中运行

1. 打开Android Studio
2. 选择 "Open an existing project"
3. 选择项目根目录
4. 等待Gradle同步完成
5. 连接Android设备或启动模拟器
6. 点击 "Run" 按钮

## 使用方法

1. **启动应用**: 打开应用后，你会看到一个简洁的界面
2. **配置API**: 在顶部输入框中输入你的机器人API地址
3. **发送消息**: 在消息输入框中输入你想要发送的内容
4. **查看响应**: 点击发送按钮后，响应会显示在下方的卡片中
5. **清除内容**: 使用清除按钮可以清空当前的消息和响应

## API格式

应用期望的API格式如下：

### 请求格式
```json
{
  "message": "用户输入的消息",
  "timestamp": 1234567890,
  "userId": "optional_user_id",
  "sessionId": "optional_session_id"
}
```

### 响应格式
```json
{
  "message": "机器人回复的消息",
  "timestamp": 1234567890,
  "status": "success",
  "data": null,
  "error": null
}
```

## 自定义配置

### 修改默认API地址

在 `app/src/main/res/values/strings.xml` 中修改：

```xml
<string name="default_api_url">https://your-api-endpoint.com/robot</string>
```

### 修改网络超时时间

在 `app/src/main/java/com/example/robotapi/network/RetrofitClient.kt` 中修改：

```kotlin
.connectTimeout(30, TimeUnit.SECONDS)
.readTimeout(30, TimeUnit.SECONDS)
.writeTimeout(30, TimeUnit.SECONDS)
```

## 故障排除

### 常见问题

1. **网络连接失败**
   - 检查设备网络连接
   - 确认API地址正确
   - 检查API服务器是否在线

2. **构建失败**
   - 确保Android Studio版本兼容
   - 检查JDK版本
   - 清理项目: `./gradlew clean`

3. **运行时错误**
   - 检查Android设备API级别
   - 确认应用权限设置

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 许可证

本项目采用MIT许可证。详见 [LICENSE](LICENSE) 文件。