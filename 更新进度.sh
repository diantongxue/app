#!/bin/bash
# 更新安装进度

clear
echo "=========================================="
echo "安装进度更新 - $(date '+%H:%M:%S')"
echo "=========================================="
echo ""

# OpenJDK 17
echo "📦 OpenJDK 17:"
if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    echo "   ✅ 已安装完成！"
    /opt/homebrew/opt/openjdk@17/bin/java -version 2>&1 | head -1
else
    echo "   ❌ 未安装"
fi

# Gradle
echo ""
echo "📦 Gradle:"
if [ -f /opt/homebrew/bin/gradle ]; then
    echo "   ✅ 已安装完成！"
    /opt/homebrew/bin/gradle -v 2>&1 | head -1
elif [ -d /opt/homebrew/opt/gradle ]; then
    echo "   ✅ 已安装（在 /opt/homebrew/opt/gradle）"
    find /opt/homebrew/opt/gradle -name "gradle" -type f 2>/dev/null | head -1
elif ps aux | grep -q "[b]rew.rb install gradle"; then
    DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null | head -1)
    if [ -n "$DOWNLOAD_FILE" ]; then
        SIZE=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
        echo "   ⏳ 正在下载中... 已下载: $SIZE"
    else
        echo "   ⏳ 正在安装中..."
    fi
    echo "   🔄 安装进程: 运行中"
else
    echo "   ❌ 未安装"
    echo "   💡 建议: 运行 bash 重新安装失败的工具.sh"
fi

# Android SDK
echo ""
echo "📦 Android SDK:"
if [ -d "$HOME/Library/Android/sdk" ]; then
    echo "   ✅ 已安装完成"
    echo "   路径: $HOME/Library/Android/sdk"
else
    echo "   ❌ 未安装"
fi

# 总体进度
echo ""
echo "📊 总体进度:"
TOTAL=0
COMPLETED=0
if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    COMPLETED=$((COMPLETED+1))
fi
TOTAL=$((TOTAL+1))
if [ -f /opt/homebrew/bin/gradle ] || [ -d /opt/homebrew/opt/gradle ]; then
    COMPLETED=$((COMPLETED+1))
fi
TOTAL=$((TOTAL+1))
if [ -d "$HOME/Library/Android/sdk" ]; then
    COMPLETED=$((COMPLETED+1))
fi
TOTAL=$((TOTAL+1))
PERCENT=$((COMPLETED * 100 / TOTAL))

BAR_LENGTH=50
FILLED=$((PERCENT * BAR_LENGTH / 100))
BAR=""
for i in $(seq 1 $BAR_LENGTH); do
    if [ $i -le $FILLED ]; then
        BAR="${BAR}█"
    else
        BAR="${BAR}░"
    fi
done

echo "   [$BAR] $COMPLETED/$TOTAL ($PERCENT%)"

echo ""
echo "=========================================="
if [ $COMPLETED -eq $TOTAL ]; then
    echo "✅ 所有工具安装完成！"
    echo "=========================================="
    echo ""
    echo "下一步：配置环境变量并编译 APK"
    echo "  bash 等待并完成安装.sh"
else
    echo "⏳ 安装进行中..."
    echo "=========================================="
    echo ""
    echo "预计剩余时间:"
    if [ ! -f /opt/homebrew/bin/gradle ] && [ ! -d /opt/homebrew/opt/gradle ]; then
        echo "  Gradle: 约 2-5 分钟"
    fi
fi
echo ""

