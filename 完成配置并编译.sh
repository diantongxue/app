#!/bin/bash
# 完成配置并编译 APK

set -e

echo "=========================================="
echo "完成配置并编译 APK"
echo "=========================================="
echo ""

# 配置环境变量
echo "[1/3] 配置环境变量..."
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

if ! grep -q "JAVA_HOME.*openjdk@17" ~/.zshrc 2>/dev/null; then
    echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
    echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
fi

if ! grep -q "ANDROID_HOME" ~/.zshrc 2>/dev/null; then
    echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
    echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
fi

source ~/.zshrc 2>/dev/null || true

export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17")
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

echo "✅ 环境变量已配置"

# 验证工具
echo ""
echo "[2/3] 验证工具..."
echo -n "Java: "
java -version 2>&1 | head -1 || echo "❌"

echo -n "Gradle: "
if [ -f /opt/homebrew/bin/gradle ]; then
    /opt/homebrew/bin/gradle -v 2>&1 | head -1
elif [ -d /opt/homebrew/opt/gradle ]; then
    GRADLE_PATH=$(find /opt/homebrew/opt/gradle -name "gradle" -type f 2>/dev/null | head -1)
    if [ -n "$GRADLE_PATH" ]; then
        "$GRADLE_PATH" -v 2>&1 | head -1
    else
        echo "✅ 已安装"
    fi
else
    echo "❌"
fi

echo -n "Android SDK: "
echo "$ANDROID_HOME" || echo "❌"

# 编译 APK
echo ""
echo "[3/3] 编译 APK..."
cd /Users/mac/Desktop/故乡食品/app/android-app

if [ ! -f gradlew ]; then
    echo "创建 Gradle Wrapper..."
    if [ -f /opt/homebrew/bin/gradle ]; then
        /opt/homebrew/bin/gradle wrapper --gradle-version 8.2
    elif [ -d /opt/homebrew/opt/gradle ]; then
        GRADLE_PATH=$(find /opt/homebrew/opt/gradle -name "gradle" -type f 2>/dev/null | head -1)
        if [ -n "$GRADLE_PATH" ]; then
            "$GRADLE_PATH" wrapper --gradle-version 8.2
        fi
    fi
    chmod +x gradlew
fi

echo "开始编译 APK（首次编译需要 10-20 分钟）..."
./gradlew assembleDebug 2>&1 | tee /tmp/gradle_build.log

if [ -f app/build/outputs/apk/debug/app-debug.apk ]; then
    echo ""
    echo "=========================================="
    echo "✅ APK 编译成功！"
    echo "=========================================="
    echo ""
    echo "APK 位置:"
    echo "  $(pwd)/app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "文件大小:"
    ls -lh app/build/outputs/apk/debug/app-debug.apk
    echo ""
    echo "打开目录:"
    open app/build/outputs/apk/debug/
else
    echo ""
    echo "❌ 编译失败，查看日志:"
    echo "  tail -50 /tmp/gradle_build.log"
fi
