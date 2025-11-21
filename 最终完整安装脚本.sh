#!/bin/bash
# 最终完整安装脚本 - 包含网络错误处理和重试机制
# 在 Mac 终端中运行：bash 最终完整安装脚本.sh

set -e

echo "=========================================="
echo "最终完整安装和配置脚本"
echo "包含：Java 配置、Android SDK 组件安装"
echo "=========================================="
echo ""

# ========================================
# 步骤 1：修复 Java 配置
# ========================================
echo "[步骤 1/6] 配置 Java 环境变量..."

# 检测 Java 安装路径
JAVA_PATH=""
if [ -d "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]; then
    JAVA_PATH="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
elif [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    JAVA_PATH="/opt/homebrew/opt/openjdk@17"
elif [ -f "/opt/homebrew/bin/java" ]; then
    JAVA_PATH=$(dirname $(dirname $(readlink -f /opt/homebrew/bin/java 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17")))
fi

if [ -z "$JAVA_PATH" ] || [ ! -f "$JAVA_PATH/bin/java" ]; then
    echo "❌ 未找到 Java 安装路径"
    echo "   请先安装 Java: brew install openjdk@17"
    exit 1
fi

echo "✅ 找到 Java: $JAVA_PATH"

# 验证 Java
JAVA_VERSION=$("$JAVA_PATH/bin/java" -version 2>&1 | head -1)
echo "   Java 版本: $JAVA_VERSION"

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
    echo "# Java 配置 (自动添加 - $(date +%Y-%m-%d))" >> ~/.zshrc
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
echo "[步骤 2/6] 配置 Android SDK 环境变量..."

export ANDROID_HOME=$HOME/Library/Android/sdk

# 更新 .zshrc 中的 Android SDK 配置
if ! grep -q "ANDROID_HOME" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Android SDK 配置 (自动添加 - $(date +%Y-%m-%d))" >> ~/.zshrc
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
echo "[步骤 3/6] 检查 Android SDK..."

if [ ! -d "$ANDROID_HOME" ]; then
    echo "❌ Android SDK 未安装"
    echo "   请先运行: brew install --cask android-commandlinetools"
    exit 1
fi
echo "✅ Android SDK 目录存在: $ANDROID_HOME"

# ========================================
# 步骤 4：安装 Android SDK Command Line Tools（带重试）
# ========================================
echo ""
echo "[步骤 4/6] 安装 Android SDK Command Line Tools..."

cd "$ANDROID_HOME/cmdline-tools" 2>/dev/null || mkdir -p "$ANDROID_HOME/cmdline-tools" && cd "$ANDROID_HOME/cmdline-tools"

# 检查是否已安装
if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "✅ Command Line Tools 已安装"
else
    # 清理旧文件
    rm -rf commandlinetools.zip cmdline-tools latest 2>/dev/null || true

    # 下载函数（带重试）
    download_with_retry() {
        local url=$1
        local output=$2
        local max_attempts=3
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            echo "   尝试下载 (第 $attempt/$max_attempts 次)..."
            
            if curl -L --progress-bar --connect-timeout 30 --max-time 300 -o "$output" "$url" 2>&1; then
                if [ -f "$output" ] && [ -s "$output" ]; then
                    # 验证 ZIP 文件
                    if unzip -t "$output" >/dev/null 2>&1; then
                        echo "   ✅ 下载成功"
                        return 0
                    else
                        echo "   ⚠️  ZIP 文件损坏，重新下载..."
                        rm -f "$output"
                    fi
                fi
            else
                echo "   ❌ 下载失败 (网络错误)"
            fi
            
            attempt=$((attempt + 1))
            if [ $attempt -le $max_attempts ]; then
                echo "   等待 3 秒后重试..."
                sleep 3
            fi
        done
        
        echo "   ❌ 下载失败，已尝试 $max_attempts 次"
        return 1
    }

    # 下载 Command Line Tools
    echo "正在下载 Command Line Tools（约 9MB）..."
    if ! download_with_retry "https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip" "commandlinetools.zip"; then
        echo ""
        echo "⚠️  自动下载失败，请手动下载："
        echo "   1. 访问: https://developer.android.com/studio#command-tools"
        echo "   2. 下载 'Command line tools only' (macOS)"
        echo "   3. 将文件保存为: $ANDROID_HOME/cmdline-tools/commandlinetools.zip"
        echo "   4. 然后重新运行此脚本"
        exit 1
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
# 步骤 5：接受许可证
# ========================================
echo ""
echo "[步骤 5/6] 接受 Android SDK 许可证..."

yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
echo "✅ 许可证已接受"

# ========================================
# 步骤 6：安装 Android SDK 组件（带重试）
# ========================================
echo ""
echo "[步骤 6/6] 安装 Android SDK 组件..."

# 检查并安装缺失的组件
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
    echo ""
    
    # 使用 sdkmanager 安装（带重试）
    MAX_RETRIES=3
    RETRY_COUNT=0
    SUCCESS=false
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
        if [ $RETRY_COUNT -gt 0 ]; then
            echo "   重试安装 (第 $((RETRY_COUNT + 1))/$MAX_RETRIES 次)..."
            sleep 5
        fi
        
        if "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "${MISSING_COMPONENTS[@]}" 2>&1 | tee /tmp/sdkmanager_output.log; then
            SUCCESS=true
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                echo "   ⚠️  安装失败，将重试..."
            fi
        fi
    done
    
    if [ "$SUCCESS" = false ]; then
        echo ""
        echo "❌ SDK 组件安装失败（已尝试 $MAX_RETRIES 次）"
        echo ""
        echo "⚠️  如果网络问题持续，请尝试手动安装："
        echo "   1. 打开 Android Studio"
        echo "   2. 进入 Preferences > Appearance & Behavior > System Settings > Android SDK"
        echo "   3. 勾选并安装："
        echo "      - Android SDK Platform 34"
        echo "      - Android SDK Build-Tools 34.0.0"
        echo "   4. 然后重新运行此脚本验证"
        exit 1
    fi
    
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
# 完成和验证
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
echo "📦 已安装的组件："
[ -d "$ANDROID_HOME/platform-tools" ] && echo "   ✅ platform-tools"
[ -d "$ANDROID_HOME/platforms/android-34" ] && echo "   ✅ platforms;android-34"
[ -d "$ANDROID_HOME/build-tools/34.0.0" ] && echo "   ✅ build-tools;34.0.0"
echo ""
echo "⚠️  重要提示："
echo "   请运行以下命令使环境变量生效："
echo "   source ~/.zshrc"
echo ""
echo "🚀 下一步：编译 APK"
echo "   cd /Users/mac/Desktop/故乡食品/app/android-app"
echo "   ./gradlew assembleDebug"
echo ""
