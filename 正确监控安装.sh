#!/bin/bash
# 正确监控安装进度

echo "=========================================="
echo "监控安装进度（正确版本）"
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
    elif ps aux | grep -q "[b]rew.rb install openjdk@17"; then
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*openjdk@17*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            SIZE=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            echo "   ⏳ 正在下载中... 已下载: $SIZE"
        else
            echo "   ⏳ 正在安装中..."
        fi
    else
        echo "   ❌ 安装进程已停止"
    fi
    
    # Gradle
    echo ""
    echo "📦 Gradle:"
    if [ -f /opt/homebrew/bin/gradle ] || [ -d /opt/homebrew/opt/gradle ]; then
        echo "   ✅ 安装完成！"
        if [ -f /opt/homebrew/bin/gradle ]; then
            /opt/homebrew/bin/gradle -v 2>&1 | head -1
        fi
    elif ps aux | grep -q "[b]rew.rb install gradle"; then
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            SIZE=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            echo "   ⏳ 正在下载中... 已下载: $SIZE"
        else
            echo "   ⏳ 正在安装中..."
        fi
    else
        echo "   ❌ 安装进程已停止"
    fi
    
    # 检查是否都完成
    echo ""
    if [ -d /opt/homebrew/opt/openjdk@17 ] && ([ -f /opt/homebrew/bin/gradle ] || [ -d /opt/homebrew/opt/gradle ]); then
        echo "=========================================="
        echo "✅ 所有工具安装完成！"
        echo "=========================================="
        break
    fi
    
    echo ""
    echo "按 Ctrl+C 退出监控"
    sleep 10
done

echo ""
echo "配置环境变量..."
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
    echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
    export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17")
    export PATH="$JAVA_HOME/bin:$PATH"
fi

if [ -d "$HOME/Library/Android/sdk" ]; then
    echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
    echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
fi

source ~/.zshrc 2>/dev/null || true

echo ""
echo "最终验证:"
echo "  OpenJDK 17: $([ -d /opt/homebrew/opt/openjdk@17 ] && echo '✅' || echo '❌')"
echo "  Gradle: $([ -f /opt/homebrew/bin/gradle ] || [ -d /opt/homebrew/opt/gradle ] && echo '✅' || echo '❌')"
echo "  Android SDK: $([ -d "$HOME/Library/Android/sdk" ] && echo '✅' || echo '❌')"
echo ""
