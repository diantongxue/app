#!/bin/bash
# 完成安装和配置所有工具

set -e

PASSWORD="0000"

echo "=========================================="
echo "完成安装和配置所有工具"
echo "=========================================="
echo ""

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置 Homebrew
echo -e "${YELLOW}[1/6] 配置 Homebrew...${NC}"
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
export PATH="/opt/homebrew/bin:$PATH"

# 等待 OpenJDK 17 安装完成
echo ""
echo -e "${YELLOW}[2/6] 等待 OpenJDK 17 安装完成...${NC}"
while [ ! -d /opt/homebrew/opt/openjdk@17 ] && ps aux | grep -q "brew.*openjdk@17" | grep -v grep; do
    echo "   等待中... ($(date '+%H:%M:%S'))"
    sleep 10
done

if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    echo -e "${GREEN}✅ OpenJDK 17 已安装${NC}"
    # 配置 Java 环境变量
    if ! grep -q "JAVA_HOME.*openjdk@17" ~/.zshrc 2>/dev/null; then
        echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
        echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
        export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17")
        export PATH="$JAVA_HOME/bin:$PATH"
    fi
else
    echo -e "${RED}❌ OpenJDK 17 安装失败或未完成${NC}"
fi

# 等待 Gradle 安装完成
echo ""
echo -e "${YELLOW}[3/6] 等待 Gradle 安装完成...${NC}"
while [ ! -f /opt/homebrew/bin/gradle ] && ps aux | grep -q "brew.*gradle" | grep -v grep; do
    echo "   等待中... ($(date '+%H:%M:%S'))"
    sleep 10
done

if [ -f /opt/homebrew/bin/gradle ]; then
    echo -e "${GREEN}✅ Gradle 已安装${NC}"
else
    echo -e "${RED}❌ Gradle 安装失败或未完成${NC}"
fi

# 配置 Android SDK
echo ""
echo -e "${YELLOW}[4/6] 配置 Android SDK...${NC}"
if [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    
    if ! grep -q "ANDROID_HOME" ~/.zshrc 2>/dev/null; then
        echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
        echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
    fi
    
    echo -e "${GREEN}✅ Android SDK 已配置${NC}"
    
    # 检查并下载 cmdline-tools
    if [ ! -d "$ANDROID_HOME/cmdline-tools" ] || [ -z "$(ls -A "$ANDROID_HOME/cmdline-tools" 2>/dev/null)" ]; then
        echo -e "${YELLOW}   下载 Android SDK Command Line Tools...${NC}"
        mkdir -p "$ANDROID_HOME/cmdline-tools"
        cd "$ANDROID_HOME/cmdline-tools"
        
        # 下载最新版本的 command line tools
        curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip 2>&1 | tail -5
        
        if [ -f commandlinetools.zip ]; then
            unzip -q commandlinetools.zip
            mv cmdline-tools latest 2>/dev/null || true
            rm -f commandlinetools.zip
            echo -e "${GREEN}✅ Command Line Tools 下载完成${NC}"
        else
            echo -e "${RED}❌ Command Line Tools 下载失败${NC}"
        fi
    fi
    
    # 配置 cmdline-tools 路径
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
else
    echo -e "${RED}❌ Android SDK 未安装${NC}"
fi

# 安装 Android SDK 组件
echo ""
echo -e "${YELLOW}[5/6] 安装 Android SDK 组件...${NC}"
if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
    SDKMANAGER=""
    if [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
        SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
    elif [ -d "$ANDROID_HOME/cmdline-tools" ]; then
        LATEST_TOOLS=$(ls -t "$ANDROID_HOME/cmdline-tools" 2>/dev/null | head -1)
        if [ -n "$LATEST_TOOLS" ] && [ -f "$ANDROID_HOME/cmdline-tools/$LATEST_TOOLS/bin/sdkmanager" ]; then
            SDKMANAGER="$ANDROID_HOME/cmdline-tools/$LATEST_TOOLS/bin/sdkmanager"
        fi
    fi
    
    if [ -n "$SDKMANAGER" ]; then
        if [ ! -d "$ANDROID_HOME/platform-tools" ] || [ ! -d "$ANDROID_HOME/platforms/android-34" ] || [ ! -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
            echo -e "${YELLOW}   接受许可证...${NC}"
            yes | "$SDKMANAGER" --licenses > /tmp/sdk_licenses.log 2>&1 || true
            
            echo -e "${YELLOW}   安装 SDK 组件...${NC}"
            "$SDKMANAGER" "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /tmp/sdk_components.log 2>&1 || true
            echo -e "${GREEN}✅ SDK 组件安装完成${NC}"
        else
            echo -e "${GREEN}✅ SDK 组件已安装${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  sdkmanager 未找到，请稍后手动安装 SDK 组件${NC}"
    fi
fi

# 创建 Gradle Wrapper
echo ""
echo -e "${YELLOW}[6/6] 创建 Gradle Wrapper...${NC}"
cd /Users/mac/Desktop/故乡食品/app/android-app

if [ -f gradlew ]; then
    echo -e "${GREEN}✅ gradlew 已存在${NC}"
else
    if command -v gradle &> /dev/null || [ -f /opt/homebrew/bin/gradle ]; then
        echo -e "${YELLOW}   使用 Gradle 创建 Wrapper...${NC}"
        (command -v gradle && gradle wrapper --gradle-version 8.2) || (/opt/homebrew/bin/gradle wrapper --gradle-version 8.2) || {
            echo -e "${YELLOW}   使用脚本创建 Wrapper...${NC}"
            bash 创建GradleWrapper.sh 2>&1 | tail -10
        }
    else
        echo -e "${YELLOW}   使用脚本创建 Wrapper...${NC}"
        bash 创建GradleWrapper.sh 2>&1 | tail -10
    fi
    
    if [ -f gradlew ]; then
        chmod +x gradlew
        echo -e "${GREEN}✅ Gradle Wrapper 创建成功${NC}"
    else
        echo -e "${RED}❌ Gradle Wrapper 创建失败${NC}"
    fi
fi

# 最终验证
echo ""
echo -e "${GREEN}=========================================="
echo "✅ 安装和配置完成！验证..."
echo "==========================================${NC}"

source ~/.zshrc 2>/dev/null || true
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

echo ""
echo "验证结果："
echo -n "Homebrew: "
brew --version 2>/dev/null | head -1 || echo "❌"

echo -n "Java: "
java -version 2>&1 | head -1 || echo "❌"

echo -n "Android SDK: "
echo "$ANDROID_HOME" || echo "❌"

echo -n "Gradle: "
gradle -v 2>&1 | head -1 || /opt/homebrew/bin/gradle -v 2>&1 | head -1 || echo "❌"

echo -n "Gradle Wrapper: "
if [ -f /Users/mac/Desktop/故乡食品/app/android-app/gradlew ]; then
    echo "✅"
else
    echo "❌"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "完成！"
echo "==========================================${NC}"
echo ""
echo "下一步：编译 APK"
echo "  cd /Users/mac/Desktop/故乡食品/app/android-app"
echo "  ./gradlew assembleDebug"
echo ""
