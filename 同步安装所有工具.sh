#!/bin/bash
# 同步安装所有工具 - 同时进行

set -e

PASSWORD="0000"

echo "=========================================="
echo "同步安装所有工具"
echo "=========================================="
echo ""

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置 Homebrew
echo -e "${YELLOW}[配置] 配置 Homebrew...${NC}"
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
export PATH="/opt/homebrew/bin:$PATH"

# 检查当前安装状态
echo ""
echo -e "${YELLOW}[检查] 检查当前安装状态...${NC}"

OPENJDK_INSTALLING=false
GRADLE_INSTALLING=false
ANDROID_SDK_INSTALLING=false

# 检查 OpenJDK 17
if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    echo -e "${GREEN}✅ OpenJDK 17: 已安装${NC}"
elif ps aux | grep -q "brew.*openjdk@17" | grep -v grep; then
    echo -e "${YELLOW}⏳ OpenJDK 17: 正在安装中...${NC}"
    OPENJDK_INSTALLING=true
else
    echo -e "${RED}❌ OpenJDK 17: 未安装${NC}"
fi

# 检查 Gradle
if [ -f /opt/homebrew/bin/gradle ] || command -v gradle &> /dev/null; then
    echo -e "${GREEN}✅ Gradle: 已安装${NC}"
elif ps aux | grep -q "brew.*gradle" | grep -v grep; then
    echo -e "${YELLOW}⏳ Gradle: 正在安装中...${NC}"
    GRADLE_INSTALLING=true
else
    echo -e "${RED}❌ Gradle: 未安装${NC}"
fi

# 检查 Android SDK
if [ -d "$HOME/Library/Android/sdk" ]; then
    echo -e "${GREEN}✅ Android SDK: 已安装${NC}"
elif ps aux | grep -q "brew.*android-commandlinetools" | grep -v grep; then
    echo -e "${YELLOW}⏳ Android SDK: 正在安装中...${NC}"
    ANDROID_SDK_INSTALLING=true
else
    echo -e "${RED}❌ Android SDK: 未安装${NC}"
fi

echo ""

# 启动未安装的工具
echo -e "${YELLOW}[安装] 启动未安装的工具...${NC}"

# 安装 OpenJDK 17（如果未安装且未在安装中）
if [ "$OPENJDK_INSTALLING" = false ] && [ ! -d /opt/homebrew/opt/openjdk@17 ]; then
    echo -e "${YELLOW}启动 OpenJDK 17 安装...${NC}"
    echo "$PASSWORD" | sudo -S brew install openjdk@17 > /tmp/openjdk_install.log 2>&1 &
    OPENJDK_PID=$!
    echo "  OpenJDK 17 安装进程: $OPENJDK_PID"
    echo "  日志: /tmp/openjdk_install.log"
fi

# 安装 Gradle（如果未安装且未在安装中）
if [ "$GRADLE_INSTALLING" = false ] && [ ! -f /opt/homebrew/bin/gradle ] && ! command -v gradle &> /dev/null; then
    echo -e "${YELLOW}启动 Gradle 安装...${NC}"
    brew install gradle > /tmp/gradle_install.log 2>&1 &
    GRADLE_PID=$!
    echo "  Gradle 安装进程: $GRADLE_PID"
    echo "  日志: /tmp/gradle_install.log"
fi

# 安装 Android SDK（如果未安装且未在安装中）
if [ "$ANDROID_SDK_INSTALLING" = false ] && [ ! -d "$HOME/Library/Android/sdk" ]; then
    echo -e "${YELLOW}启动 Android SDK 安装...${NC}"
    echo "$PASSWORD" | sudo -S brew install --cask android-commandlinetools > /tmp/android_sdk_install.log 2>&1 &
    ANDROID_SDK_PID=$!
    echo "  Android SDK 安装进程: $ANDROID_SDK_PID"
    echo "  日志: /tmp/android_sdk_install.log"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "✅ 所有安装已启动！"
echo "==========================================${NC}"
echo ""
echo "安装进度监控："
echo "  运行: bash 监控所有安装进度.sh"
echo ""
echo "或者手动检查："
echo "  ps aux | grep brew"
echo "  tail -f /tmp/*_install.log"
echo ""
