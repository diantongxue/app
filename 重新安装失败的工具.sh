#!/bin/bash
# 重新安装失败的工具

set -e

PASSWORD="0000"

echo "=========================================="
echo "重新安装失败的工具"
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

# 检查状态
echo -e "${YELLOW}[检查] 当前安装状态...${NC}"
NEED_OPENJDK=false
NEED_GRADLE=false

if [ ! -d /opt/homebrew/opt/openjdk@17 ]; then
    NEED_OPENJDK=true
    echo -e "${RED}❌ OpenJDK 17 未安装${NC}"
else
    echo -e "${GREEN}✅ OpenJDK 17 已安装${NC}"
fi

if [ ! -f /opt/homebrew/bin/gradle ] && [ ! -d /opt/homebrew/opt/gradle ]; then
    NEED_GRADLE=true
    echo -e "${RED}❌ Gradle 未安装${NC}"
else
    echo -e "${GREEN}✅ Gradle 已安装${NC}"
fi

echo ""

# 清理未完成的安装
if [ "$NEED_OPENJDK" = true ]; then
    echo -e "${YELLOW}[清理] 清理 OpenJDK 17 的未完成安装...${NC}"
    /opt/homebrew/bin/brew uninstall --ignore-dependencies openjdk@17 2>/dev/null || true
    rm -rf /opt/homebrew/opt/openjdk@17 2>/dev/null || true
    rm -f /Users/mac/Library/Caches/Homebrew/downloads/*openjdk@17*.incomplete 2>/dev/null || true
fi

if [ "$NEED_GRADLE" = true ]; then
    echo -e "${YELLOW}[清理] 清理 Gradle 的未完成安装...${NC}"
    /opt/homebrew/bin/brew uninstall --ignore-dependencies gradle 2>/dev/null || true
    rm -rf /opt/homebrew/opt/gradle 2>/dev/null || true
    rm -f /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null || true
fi

# 重新安装
echo ""
echo -e "${YELLOW}[安装] 重新安装工具...${NC}"

if [ "$NEED_OPENJDK" = true ]; then
    echo -e "${YELLOW}   安装 OpenJDK 17...${NC}"
    echo "$PASSWORD" | sudo -S /opt/homebrew/bin/brew install openjdk@17 2>&1 | tee /tmp/openjdk_install.log &
    OPENJDK_PID=$!
    echo "   ✅ OpenJDK 17 安装已启动（进程: $OPENJDK_PID）"
    echo "   日志: /tmp/openjdk_install.log"
fi

if [ "$NEED_GRADLE" = true ]; then
    echo -e "${YELLOW}   安装 Gradle...${NC}"
    /opt/homebrew/bin/brew install gradle 2>&1 | tee /tmp/gradle_install.log &
    GRADLE_PID=$!
    echo "   ✅ Gradle 安装已启动（进程: $GRADLE_PID）"
    echo "   日志: /tmp/gradle_install.log"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "✅ 重新安装已启动！"
echo "==========================================${NC}"
echo ""
echo "监控安装进度："
echo "  bash 实时进度监控.sh"
echo ""
echo "或查看日志："
echo "  tail -f /tmp/openjdk_install.log"
echo "  tail -f /tmp/gradle_install.log"
echo ""

