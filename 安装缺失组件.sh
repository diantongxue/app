#!/bin/bash
# 安装缺失的 Android SDK 组件

set -e

PASSWORD="0000"

echo "=========================================="
echo "安装缺失的 Android SDK 组件"
echo "=========================================="
echo ""

export ANDROID_HOME=$HOME/Library/Android/sdk

# 方法1：尝试使用 Gradle 自动安装
echo "[方法1] 尝试使用 Gradle 自动安装 SDK 组件..."
cd /Users/mac/Desktop/故乡食品/app/android-app

# 创建 local.properties 文件
if [ ! -f local.properties ]; then
    echo "创建 local.properties..."
    cat > local.properties << EOF
sdk.dir=$ANDROID_HOME
EOF
    echo "✅ local.properties 已创建"
fi

# 尝试编译，Gradle 会自动下载缺失的组件
echo ""
echo "尝试编译（Gradle 会自动下载缺失的组件）..."
./gradlew assembleDebug --stacktrace 2>&1 | tee /tmp/gradle_auto_install.log | tail -30

# 检查是否成功
if [ -f app/build/outputs/apk/debug/app-debug.apk ]; then
    echo ""
    echo "✅ 编译成功！Gradle 已自动安装所有组件"
    exit 0
fi

# 方法2：手动下载并安装 Command Line Tools
echo ""
echo "[方法2] 手动安装 Command Line Tools..."
cd "$ANDROID_HOME/cmdline-tools"

# 清理
rm -rf commandlinetools.zip cmdline-tools latest 2>/dev/null || true

# 下载
echo "下载 Command Line Tools（使用代理）..."
curl -L --progress-bar -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip

if [ -f commandlinetools.zip ]; then
    echo "解压..."
    unzip -q commandlinetools.zip
    
    if [ -d cmdline-tools ]; then
        mv cmdline-tools latest
        echo "✅ Command Line Tools 安装完成"
    else
        echo "❌ 解压失败"
        exit 1
    fi
    
    rm -f commandlinetools.zip
else
    echo "❌ 下载失败"
    exit 1
fi

# 方法3：使用 sdkmanager 安装组件
echo ""
echo "[方法3] 使用 sdkmanager 安装组件..."
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "接受许可证..."
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses 2>&1 | tail -10
    
    echo ""
    echo "安装 SDK 组件..."
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" 2>&1 | tail -20
    
    echo ""
    echo "✅ SDK 组件安装完成"
else
    echo "❌ sdkmanager 不可用"
    exit 1
fi

# 验证
echo ""
echo "验证安装..."
if [ -d "$ANDROID_HOME/platforms/android-34" ] && [ -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
    echo "✅ 所有组件已安装"
else
    echo "❌ 部分组件未安装"
fi
