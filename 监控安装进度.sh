#!/bin/bash
# 监控安装进度的脚本

echo "=========================================="
echo "监控 JDK 和 Gradle 安装进度"
echo "=========================================="
echo ""

while true; do
    clear
    echo "=========================================="
    echo "安装进度监控 - $(date '+%H:%M:%S')"
    echo "=========================================="
    echo ""
    
    # 检查 OpenJDK 17 安装进程
    echo "📦 OpenJDK 17 安装状态:"
    if ps aux | grep -q "brew.rb install openjdk@17" | grep -v grep; then
        echo "   ✅ 正在安装中..."
        echo "   进程: $(ps aux | grep 'brew.rb install openjdk@17' | grep -v grep | awk '{print $2}')"
    else
        if [ -d /opt/homebrew/opt/openjdk@17 ]; then
            echo "   ✅ 安装完成！"
        else
            echo "   ⏳ 等待安装..."
        fi
    fi
    
    # 检查下载进度
    echo ""
    echo "📥 下载进度:"
    DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*openjdk@17*.incomplete 2>/dev/null | head -1)
    if [ -n "$DOWNLOAD_FILE" ]; then
        SIZE=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
        echo "   OpenJDK 17: $SIZE (正在下载...)"
    else
        echo "   OpenJDK 17: 下载完成或未开始"
    fi
    
    # 检查 Gradle 安装进程
    echo ""
    echo "📦 Gradle 安装状态:"
    if ps aux | grep -q "brew.rb install gradle" | grep -v grep; then
        echo "   ✅ 正在安装中..."
    else
        if [ -f /opt/homebrew/bin/gradle ] || command -v gradle &> /dev/null; then
            echo "   ✅ 安装完成！"
        else
            echo "   ⏳ 等待安装..."
        fi
    fi
    
    # 检查下载进度
    GRADLE_DOWNLOAD=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null | head -1)
    if [ -n "$GRADLE_DOWNLOAD" ]; then
        GRADLE_SIZE=$(ls -lh "$GRADLE_DOWNLOAD" 2>/dev/null | awk '{print $5}')
        echo "   Gradle: $GRADLE_SIZE (正在下载...)"
    else
        echo "   Gradle: 下载完成或未开始"
    fi
    
    # 检查是否都安装完成
    echo ""
    if [ -d /opt/homebrew/opt/openjdk@17 ] && ([ -f /opt/homebrew/bin/gradle ] || command -v gradle &> /dev/null); then
        echo "=========================================="
        echo "✅ 所有工具安装完成！"
        echo "=========================================="
        break
    fi
    
    echo ""
    echo "按 Ctrl+C 退出监控"
    sleep 5
done

echo ""
echo "验证安装:"
if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    echo "✅ OpenJDK 17: 已安装"
    /opt/homebrew/opt/openjdk@17/bin/java -version 2>&1 | head -1
else
    echo "❌ OpenJDK 17: 未安装"
fi

if [ -f /opt/homebrew/bin/gradle ] || command -v gradle &> /dev/null; then
    echo "✅ Gradle: 已安装"
    (command -v gradle && gradle -v) || /opt/homebrew/bin/gradle -v 2>&1 | head -1
else
    echo "❌ Gradle: 未安装"
fi
