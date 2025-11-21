#!/bin/bash
# Mac 终端完整安装和配置脚本
# 包括：Java 配置、Android SDK 组件安装
# 在 Mac 终端中运行：bash 完整安装和配置.sh

set -e

echo "=========================================="
echo "完整安装和配置脚本"
echo "=========================================="
echo ""

# ========================================
# 步骤 1：修复 Java 配置
# ========================================
echo "[步骤 1/5] 配置 Java 环境变量..."

# 检测 Java 安装路径
JAVA_PATH=""
if [ -d "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]; then
    JAVA_PATH="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
elif [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    JAVA_PATH="/opt/homebrew/opt/openjdk@17"
elif [ -f "/opt/homebrew/bin/java" ]; then
    JAVA_PATH=$(dirname $(dirname $(readlink -f /opt/homebrew/bin/java)))
fi

if [ -z "$JAVA_PATH" ]; then
    echo "❌ 未找到 Java 安装路径"
    echo "   请先安装 Java: brew install openjdk@17"
    exit 1
fi

echo "✅ 找到 Java: $JAVA_PATH"

# 验证 Java
if [ -f "$JAVA_PATH/bin/java" ]; then
    JAVA_VERSION=$("$JAVA_PATH/bin/java" -version 2>&1 | head -1)
    echo "   Java 版本: $JAVA_VERSION"
else
    echo "❌ Java 可执行文件不存在"
    exit 1
fi

# 更新 .zshrc
echo ""
echo "正在更新 ~/.zshrc 中的 Java 配置..."

# 备份 .zshrc
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# 移除旧的 Java 配置
sed -i.bak '/JAVA_HOME.*java_home/d' ~/.zshrc 2>/dev/null || sed -i '' '/JAVA_HOME.*java_home/d' ~/.zshrc
sed -i.bak '/export PATH.*JAVA_HOME/d' ~/.zshrc 2>/dev/null || sed -i '' '/export PATH.*JAVA_HOME/d' ~/.zshrc

# 添加新的 Java 配置
if ! grep -q "JAVA_HOME.*openjdk@17" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Java 配置 (自动添加)" >> ~/.zshrc
    echo "export JAVA_HOME=\"$JAVA_PATH\"" >> ~/.zshrc
    echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> ~/.zshrc
fi

# 立即生效
export JAVA_HOME="$JAVA_PATH"
export PATH="$JAVA_HOME/bin:$PATH"

echo "✅ Java 配置完成"
echo "   JAVA_HOME=$JAVA_HOME"

# ========================================
# 步骤 2：配置 Android SDK 环境变量
# ========================================
echo ""
echo "[步骤 2/5] 配置 Android SDK 环境变量..."

export ANDROID_HOME=$HOME/Library/Android/sdk

# 更新 .zshrc 中的 Android SDK 配置
if ! grep -q "ANDROID_HOME" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Android SDK 配置 (自动添加)" >> ~/.zshrc
    echo "export ANDROID_HOME=\$HOME/Library/Android/sdk" >> ~/.zshrc
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin\"" >> ~/.zshrc
fi

export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

echo "✅ Android SDK 环境变量配置完成"
echo "   ANDROID_HOME=$ANDROID_HOME"

# ========================================
# 步骤 3：检查 Android SDK
# ========================================
echo ""
echo "[步骤 3/5] 检查 Android SDK..."

if [ ! -d "$ANDROID_HOME" ]; then
    echo "❌ Android SDK 未安装"
    echo "   请先运行: brew install --cask android-commandlinetools"
    exit 1
fi
echo "✅ Android SDK 目录存在: $ANDROID_HOME"

# ========================================
# 步骤 4：安装 Android SDK Command Line Tools
# ========================================
echo ""
echo "[步骤 4/5] 安装 Android SDK Command Line Tools..."

cd "$ANDROID_HOME/cmdline-tools" 2>/dev/null || mkdir -p "$ANDROID_HOME/cmdline-tools" && cd "$ANDROID_HOME/cmdline-tools"

# 检查是否已安装
if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "✅ Command Line Tools 已安装"
else
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
    else
        echo "❌ 解压失败"
        exit 1
    fi

    rm -f commandlinetools.zip
fi

# 验证 sdkmanager
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "❌ sdkmanager 不可用"
    exit 1
fi

echo "✅ sdkmanager 可用"

# ========================================
# 步骤 5：安装 Android SDK 组件
# ========================================
echo ""
echo "[步骤 5/5] 安装 Android SDK 组件..."

# 接受许可证
echo "接受 Android SDK 许可证..."
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
echo "✅ 许可证已接受"

# 检查并安装缺失的组件
echo ""
echo "检查已安装的组件..."

MISSING_COMPONENTS=()

if [ ! -d "$ANDROID_HOME/platform-tools" ]; then
    MISSING_COMPONENTS+=("platform-tools")
fi

if [ ! -d "$ANDROID_HOME/platforms/android-34" ]; then
    MISSING_COMPONENTS+=("platforms;android-34")
fi

if [ ! -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
    MISSING_COMPONENTS+=("build-tools;34.0.0")
fi

if [ ${#MISSING_COMPONENTS[@]} -eq 0 ]; then
    echo "✅ 所有必需的 SDK 组件已安装"
else
    echo "需要安装以下组件: ${MISSING_COMPONENTS[*]}"
    echo "正在安装...（这可能需要几分钟时间，请耐心等待）"
    
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "${MISSING_COMPONENTS[@]}" 2>&1 | tail -20
    
    echo ""
    echo "验证安装..."
    for component in "${MISSING_COMPONENTS[@]}"; do
        case $component in
            "platform-tools")
                if [ -d "$ANDROID_HOME/platform-tools" ]; then
                    echo "✅ platform-tools 已安装"
                else
                    echo "❌ platform-tools 安装失败"
                fi
                ;;
            "platforms;android-34")
                if [ -d "$ANDROID_HOME/platforms/android-34" ]; then
                    echo "✅ platforms;android-34 已安装"
                else
                    echo "❌ platforms;android-34 安装失败"
                fi
                ;;
            "build-tools;34.0.0")
                if [ -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
                    echo "✅ build-tools;34.0.0 已安装"
                else
                    echo "❌ build-tools;34.0.0 安装失败"
                fi
                ;;
        esac
    done
fi

# ========================================
# 完成
# ========================================
echo ""
echo "=========================================="
echo "✅ 安装和配置完成！"
echo "=========================================="
echo ""
echo "📋 环境变量配置："
echo "   JAVA_HOME=$JAVA_HOME"
echo "   ANDROID_HOME=$ANDROID_HOME"
echo ""
echo "⚠️  重要提示："
echo "   请运行以下命令使环境变量生效："
echo "   source ~/.zshrc"
echo ""
echo "🚀 下一步：编译 APK"
echo "   cd /Users/mac/Desktop/故乡食品/app/android-app"
echo "   ./gradlew assembleDebug"
echo ""
