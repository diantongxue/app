#!/bin/bash
# Mac 终端自动安装脚本 - 安装缺失的 Android SDK 组件
# 在 Mac 终端中运行：bash Mac终端安装脚本.sh

set -e

echo "=========================================="
echo "Android SDK 组件自动安装脚本"
echo "=========================================="
echo ""

# 配置 Java 环境变量
if [ -d "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"
    echo "✅ Java 已配置: $JAVA_HOME"
elif [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
    export PATH="$JAVA_HOME/bin:$PATH"
    echo "✅ Java 已配置: $JAVA_HOME"
fi

# 配置 Android SDK 环境变量
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

echo "[步骤 1/4] 检查 Android SDK..."
if [ ! -d "$ANDROID_HOME" ]; then
    echo "❌ Android SDK 未安装"
    echo "   请先运行: brew install --cask android-commandlinetools"
    exit 1
fi
echo "✅ Android SDK 目录存在: $ANDROID_HOME"

echo ""
echo "[步骤 2/4] 安装 Android SDK Command Line Tools..."
cd "$ANDROID_HOME/cmdline-tools"

# 清理旧文件
rm -rf commandlinetools.zip cmdline-tools latest 2>/dev/null || true

# 下载 Command Line Tools
echo "正在下载 Command Line Tools（约 9MB）..."
curl -L --progress-bar -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip

if [ ! -f commandlinetools.zip ]; then
    echo "❌ 下载失败"
    exit 1
fi

# 验证 ZIP 文件
if ! unzip -t commandlinetools.zip >/dev/null 2>&1; then
    echo "❌ ZIP 文件损坏，重新下载..."
    rm -f commandlinetools.zip
    curl -L --progress-bar -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
fi

# 解压
echo "正在解压..."
unzip -q commandlinetools.zip

if [ -d cmdline-tools ]; then
    mv cmdline-tools latest
    echo "✅ Command Line Tools 安装完成"
elif [ -d latest ]; then
    echo "✅ Command Line Tools 已存在"
else
    echo "❌ 解压失败"
    exit 1
fi

rm -f commandlinetools.zip

# 验证 sdkmanager
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "❌ sdkmanager 不可用"
    exit 1
fi

echo "✅ sdkmanager 可用"

echo ""
echo "[步骤 3/4] 接受 Android SDK 许可证..."
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# 接受许可证
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1
echo "✅ 许可证已接受"

echo ""
echo "[步骤 4/4] 安装 Android SDK 组件..."
echo "正在安装 platforms;android-34 和 build-tools;34.0.0..."
echo "（这可能需要几分钟时间，请耐心等待）"

"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" 2>&1 | tail -20

echo ""
echo "=========================================="
echo "✅ 安装完成！验证安装..."
echo "=========================================="

# 验证
if [ -d "$ANDROID_HOME/platform-tools" ]; then
    echo "✅ platform-tools 已安装"
else
    echo "❌ platform-tools 未安装"
fi

if [ -d "$ANDROID_HOME/platforms/android-34" ]; then
    echo "✅ platforms;android-34 已安装"
else
    echo "❌ platforms;android-34 未安装"
fi

if [ -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
    echo "✅ build-tools;34.0.0 已安装"
else
    echo "❌ build-tools;34.0.0 未安装"
fi

echo ""
echo "=========================================="
echo "✅ 所有组件安装完成！"
echo "=========================================="
echo ""
echo "下一步：编译 APK"
echo "  cd /Users/mac/Desktop/故乡食品/app/android-app"
echo "  ./gradlew assembleDebug"
echo ""
