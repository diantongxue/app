#!/bin/bash
# 监控所有安装进度

echo "=========================================="
echo "监控所有工具安装进度"
echo "=========================================="
echo ""

while true; do
    clear
    echo "=========================================="
    echo "安装进度监控 - $(date '+%H:%M:%S')"
    echo "=========================================="
    echo ""
    
    # OpenJDK 17
    echo "📦 OpenJDK 17:"
    if [ -d /opt/homebrew/opt/openjdk@17 ]; then
        echo "   ✅ 安装完成！"
        /opt/homebrew/opt/openjdk@17/bin/java -version 2>&1 | head -1
    elif ps aux | grep -q "brew.*openjdk@17" | grep -v grep; then
        echo "   ⏳ 正在安装中..."
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*openjdk@17*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            SIZE=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            echo "   下载进度: $SIZE"
        fi
    else
        echo "   ⏳ 等待安装..."
    fi
    
    # Gradle
    echo ""
    echo "📦 Gradle:"
    if [ -f /opt/homebrew/bin/gradle ] || command -v gradle &> /dev/null; then
        echo "   ✅ 安装完成！"
        (command -v gradle && gradle -v 2>&1 | head -1) || /opt/homebrew/bin/gradle -v 2>&1 | head -1
    elif ps aux | grep -q "brew.*gradle" | grep -v grep; then
        echo "   ⏳ 正在安装中..."
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            SIZE=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            echo "   下载进度: $SIZE"
        fi
    else
        echo "   ⏳ 等待安装..."
    fi
    
    # Android SDK
    echo ""
    echo "📦 Android SDK:"
    if [ -d "$HOME/Library/Android/sdk" ]; then
        echo "   ✅ 安装完成！"
        echo "   路径: $ANDROID_HOME"
    elif ps aux | grep -q "brew.*android-commandlinetools" | grep -v grep; then
        echo "   ⏳ 正在安装中..."
    else
        echo "   ⏳ 等待安装..."
    fi
    
    # 检查是否都完成
    echo ""
    ALL_DONE=true
    if [ ! -d /opt/homebrew/opt/openjdk@17 ]; then
        ALL_DONE=false
    fi
    if [ ! -f /opt/homebrew/bin/gradle ] && ! command -v gradle &> /dev/null; then
        ALL_DONE=false
    fi
    if [ ! -d "$HOME/Library/Android/sdk" ]; then
        ALL_DONE=false
    fi
    
    if [ "$ALL_DONE" = true ]; then
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
echo "最终验证:"
echo "  OpenJDK 17: $([ -d /opt/homebrew/opt/openjdk@17 ] && echo '✅' || echo '❌')"
echo "  Gradle: $([ -f /opt/homebrew/bin/gradle ] && echo '✅' || echo '❌')"
echo "  Android SDK: $([ -d "$HOME/Library/Android/sdk" ] && echo '✅' || echo '❌')"
echo ""
