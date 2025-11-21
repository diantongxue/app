#!/bin/bash
# 修复安装问题并重新安装

set -e

PASSWORD="0000"

echo "=========================================="
echo "修复安装问题并重新安装"
echo "=========================================="
echo ""

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 配置 Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
export PATH="/opt/homebrew/bin:$PATH"

# 检查当前状态
echo -e "${YELLOW}[检查] 当前安装状态...${NC}"
OPENJDK_INSTALLED=false
GRADLE_INSTALLED=false

if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    OPENJDK_INSTALLED=true
    echo -e "${GREEN}✅ OpenJDK 17 已安装${NC}"
else
    echo -e "${RED}❌ OpenJDK 17 未安装${NC}"
fi

if [ -f /opt/homebrew/bin/gradle ] || [ -d /opt/homebrew/opt/gradle ]; then
    GRADLE_INSTALLED=true
    echo -e "${GREEN}✅ Gradle 已安装${NC}"
else
    echo -e "${RED}❌ Gradle 未安装${NC}"
fi

echo ""

# 清理可能的问题
echo -e "${YELLOW}[清理] 清理可能的问题...${NC}"
if [ "$OPENJDK_INSTALLED" = false ]; then
    echo "   清理 OpenJDK 17 的未完成安装..."
    /opt/homebrew/bin/brew uninstall --ignore-dependencies openjdk@17 2>/dev/null || true
    rm -rf /opt/homebrew/opt/openjdk@17 2>/dev/null || true
fi

if [ "$GRADLE_INSTALLED" = false ]; then
    echo "   清理 Gradle 的未完成安装..."
    /opt/homebrew/bin/brew uninstall --ignore-dependencies gradle 2>/dev/null || true
    rm -rf /opt/homebrew/opt/gradle 2>/dev/null || true
fi

# 重新安装
echo ""
echo -e "${YELLOW}[安装] 重新安装工具...${NC}"

if [ "$OPENJDK_INSTALLED" = false ]; then
    echo -e "${YELLOW}   安装 OpenJDK 17...${NC}"
    echo "$PASSWORD" | sudo -S /opt/homebrew/bin/brew install openjdk@17 2>&1 | tee /tmp/openjdk_reinstall.log &
    OPENJDK_PID=$!
    echo "   OpenJDK 17 安装进程: $OPENJDK_PID"
    echo "   日志: /tmp/openjdk_reinstall.log"
fi

if [ "$GRADLE_INSTALLED" = false ]; then
    echo -e "${YELLOW}   安装 Gradle...${NC}"
    /opt/homebrew/bin/brew install gradle 2>&1 | tee /tmp/gradle_reinstall.log &
    GRADLE_PID=$!
    echo "   Gradle 安装进程: $GRADLE_PID"
    echo "   日志: /tmp/gradle_reinstall.log"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "✅ 重新安装已启动！"
echo "==========================================${NC}"
echo ""
echo "监控安装进度："
echo "  tail -f /tmp/openjdk_reinstall.log"
echo "  tail -f /tmp/gradle_reinstall.log"
echo ""
echo "或者运行："
echo "  bash 等待并完成安装.sh"
echo ""
