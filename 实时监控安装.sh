#!/bin/bash
# 实时监控安装进度和剩余时间

echo "=========================================="
echo "实时监控安装进度"
echo "按 Ctrl+C 退出"
echo "=========================================="
echo ""

PREV_OPENJDK_SIZE=0
PREV_GRADLE_SIZE=0
START_TIME=$(date +%s)

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
    else
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*openjdk@17*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            CURRENT_SIZE=$(stat -f%z "$DOWNLOAD_FILE" 2>/dev/null || echo "0")
            SIZE_STR=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            
            # 计算下载速度
            if [ $PREV_OPENJDK_SIZE -gt 0 ] && [ $CURRENT_SIZE -gt $PREV_OPENJDK_SIZE ]; then
                SIZE_DIFF=$((CURRENT_SIZE - PREV_OPENJDK_SIZE))
                # 假设每10秒检查一次，计算每秒速度
                SPEED=$((SIZE_DIFF / 10))
                SPEED_MB=$(echo "scale=2; $SPEED / 1024 / 1024" | bc 2>/dev/null || echo "0")
                echo "   ⏳ 下载中: $SIZE_STR"
                echo "   下载速度: ${SPEED_MB} MB/s"
                
                # 估算剩余时间（假设总大小约 100MB）
                if [ $(echo "$SPEED_MB > 0" | bc 2>/dev/null || echo "0") -eq 1 ]; then
                    REMAINING_MB=$(echo "scale=2; (100 - $CURRENT_SIZE / 1024 / 1024)" | bc 2>/dev/null || echo "0")
                    REMAINING_SEC=$(echo "scale=0; $REMAINING_MB / $SPEED_MB" | bc 2>/dev/null || echo "0")
                    REMAINING_MIN=$(echo "scale=0; $REMAINING_SEC / 60" | bc 2>/dev/null || echo "0")
                    if [ "$REMAINING_MIN" -gt 0 ]; then
                        echo "   预计剩余: 约 ${REMAINING_MIN} 分钟"
                    else
                        echo "   预计剩余: 约 ${REMAINING_SEC} 秒"
                    fi
                fi
            else
                echo "   ⏳ 下载中: $SIZE_STR"
            fi
            PREV_OPENJDK_SIZE=$CURRENT_SIZE
        else
            echo "   ⏳ 正在安装中..."
        fi
        
        if ps aux | grep -q "[b]rew.rb install openjdk@17"; then
            echo "   ✅ 安装进程: 运行中"
        else
            echo "   ⚠️  安装进程: 已停止"
        fi
    fi
    
    # Gradle
    echo ""
    echo "📦 Gradle:"
    if [ -f /opt/homebrew/bin/gradle ] || [ -d /opt/homebrew/opt/gradle ]; then
        echo "   ✅ 安装完成！"
        if [ -f /opt/homebrew/bin/gradle ]; then
            /opt/homebrew/bin/gradle -v 2>&1 | head -1
        fi
    else
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            CURRENT_SIZE=$(stat -f%z "$DOWNLOAD_FILE" 2>/dev/null || echo "0")
            SIZE_STR=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            
            # 计算下载速度
            if [ $PREV_GRADLE_SIZE -gt 0 ] && [ $CURRENT_SIZE -gt $PREV_GRADLE_SIZE ]; then
                SIZE_DIFF=$((CURRENT_SIZE - PREV_GRADLE_SIZE))
                SPEED=$((SIZE_DIFF / 10))
                SPEED_MB=$(echo "scale=2; $SPEED / 1024 / 1024" | bc 2>/dev/null || echo "0")
                echo "   ⏳ 下载中: $SIZE_STR"
                echo "   下载速度: ${SPEED_MB} MB/s"
                
                # 估算剩余时间（假设总大小约 100MB）
                if [ $(echo "$SPEED_MB > 0" | bc 2>/dev/null || echo "0") -eq 1 ]; then
                    REMAINING_MB=$(echo "scale=2; (100 - $CURRENT_SIZE / 1024 / 1024)" | bc 2>/dev/null || echo "0")
                    REMAINING_SEC=$(echo "scale=0; $REMAINING_MB / $SPEED_MB" | bc 2>/dev/null || echo "0")
                    REMAINING_MIN=$(echo "scale=0; $REMAINING_SEC / 60" | bc 2>/dev/null || echo "0")
                    if [ "$REMAINING_MIN" -gt 0 ]; then
                        echo "   预计剩余: 约 ${REMAINING_MIN} 分钟"
                    else
                        echo "   预计剩余: 约 ${REMAINING_SEC} 秒"
                    fi
                fi
            else
                echo "   ⏳ 下载中: $SIZE_STR"
            fi
            PREV_GRADLE_SIZE=$CURRENT_SIZE
        else
            echo "   ⏳ 正在安装中..."
        fi
        
        if ps aux | grep -q "[b]rew.rb install gradle"; then
            echo "   ✅ 安装进程: 运行中"
        else
            echo "   ⚠️  安装进程: 已停止"
        fi
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
    BAR_LENGTH=$((PERCENT / 2))
    BAR=""
    for i in $(seq 1 50); do
        if [ $i -le $BAR_LENGTH ]; then
            BAR="${BAR}█"
        else
            BAR="${BAR}░"
        fi
    done
    
    echo "   [$BAR] $PERCENT%"
    echo "   已完成: $COMPLETED/$TOTAL"
    
    # 检查是否都完成
    if [ -d /opt/homebrew/opt/openjdk@17 ] && ([ -f /opt/homebrew/bin/gradle ] || [ -d /opt/homebrew/opt/gradle ]); then
        echo ""
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
echo "✅ 安装和配置完成！"
echo ""
echo "下一步：编译 APK"
echo "  cd /Users/mac/Desktop/故乡食品/app/android-app"
echo "  ./gradlew assembleDebug"
echo ""

