FROM openjdk:11-jdk

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

# 下载Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# 下载Android SDK命令行工具
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip -q cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm cmdline-tools.zip

# 接受Android SDK许可证
RUN yes | sdkmanager --licenses

# 安装必要的Android SDK组件
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 复制项目文件
COPY . .

# 设置local.properties
RUN echo "sdk.dir=$ANDROID_HOME" > local.properties

# 构建APK
RUN ./gradlew assembleDebug

# 创建输出目录
RUN mkdir -p /output

# 复制生成的APK到输出目录
RUN cp app/build/outputs/apk/debug/app-debug.apk /output/

# 设置输出卷
VOLUME /output

# 默认命令
CMD ["ls", "-la", "/output"]