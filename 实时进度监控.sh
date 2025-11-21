#!/bin/bash
# 实时进度监控 - 显示下载进度和剩余时间

echo "=========================================="
echo "实时安装进度监控"
echo "按 Ctrl+C 退出"
echo "=========================================="
echo ""

PREV_OPENJDK_SIZE=0
PREV_GRADLE_SIZE=0
START_TIME=$(date +%s)

while true; do
    clear
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    ELAPSED_MIN=$((ELAPSED / 60))
    ELAPSED_SEC=$((ELAPSED % 60))
    
    echo "=========================================="
    echo "实时安装进度监控 - $(date '+%H:%M:%S')"
    echo "已运行: ${ELAPSED_MIN}分${ELAPSED_SEC}秒"
    echo "=========================================="
    echo ""
    
    # OpenJDK 17
    echo "📦 OpenJDK 17:"
    if [ -d /opt/homebrew/opt/openjdk@17 ]; then
        echo "   ✅ 安装完成！"
        /opt/homebrew/opt/openjdk@17/bin/java -version 2>&1 | head -1
        OPENJDK_DONE=true
    else
        OPENJDK_DONE=false
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*openjdk@17*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            SIZE_BYTES=$(stat -f%z "$DOWNLOAD_FILE" 2>/dev/null || echo "0")
            SIZE_MB=$((SIZE_BYTES / 1024 / 1024))
            SIZE_DISPLAY=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            
            # 计算下载速度（如果之前有记录）
            if [ $PREV_OPENJDK_SIZE -gt 0 ] && [ $ELAPSED -gt 0 ]; then
                SIZE_DIFF=$((SIZE_BYTES - PREV_OPENJDK_SIZE))
                SPEED_MB=$((SIZE_DIFF / 1024 / 1024))
                if [ $SPEED_MB -gt 0 ]; then
                    # 估算总大小（OpenJDK 17 大约 100-150MB）
                    ESTIMATED_SIZE=120000000  # 120MB
                    REMAINING=$((ESTIMATED_SIZE - SIZE_BYTES))
                    if [ $REMAINING -gt 0 ] && [ $SPEED_MB -gt 0 ]; then
                        REMAINING_SEC=$((REMAINING / 1024 / 1024 / SPEED_MB))
                        REMAINING_MIN=$((REMAINING_SEC / 60))
                        REMAINING_SEC=$((REMAINING_SEC % 60))
                        echo "   ⏳ 下载中: ${SIZE_MB}MB | 速度: ${SPEED_MB}MB/10s | 剩余: ${REMAINING_MIN}分${REMAINING_SEC}秒"
                    else
                        echo "   ⏳ 下载中: ${SIZE_MB}MB | 速度: ${SPEED_MB}MB/10s"
                    fi
                else
                    echo "   ⏳ 下载中: ${SIZE_DISPLAY}"
                fi
            else
                echo "   ⏳ 下载中: ${SIZE_DISPLAY}"
            fi
            PREV_OPENJDK_SIZE=$SIZE_BYTES
        else
            echo "   ⏳ 正在安装中..."
        fi
        
        if ps aux | grep -q "[b]rew.rb install openjdk@17"; then
            echo "   🔄 安装进程: 运行中"
        else
            echo "   ⚠️  安装进程已停止"
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
        GRADLE_DONE=true
    else
        GRADLE_DONE=false
        DOWNLOAD_FILE=$(ls /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null | head -1)
        if [ -n "$DOWNLOAD_FILE" ]; then
            SIZE_BYTES=$(stat -f%z "$DOWNLOAD_FILE" 2>/dev/null || echo "0")
            SIZE_MB=$((SIZE_BYTES / 1024 / 1024))
            SIZE_DISPLAY=$(ls -lh "$DOWNLOAD_FILE" 2>/dev/null | awk '{print $5}')
            
            # 计算下载速度
            if [ $PREV_GRADLE_SIZE -gt 0 ] && [ $ELAPSED -gt 0 ]; then
                SIZE_DIFF=$((SIZE_BYTES - PREV_GRADLE_SIZE))
                SPEED_MB=$((SIZE_DIFF / 1024 / 1024))
                if [ $SPEED_MB -gt 0 ]; then
                    # 估算总大小（Gradle 大约 100-120MB）
                    ESTIMATED_SIZE=110000000  # 110MB
                    REMAINING=$((ESTIMATED_SIZE - SIZE_BYTES))
                    if [ $REMAINING -gt 0 ] && [ $SPEED_MB -gt 0 ]; then
                        REMAINING_SEC=$((REMAINING / 1024 / 1024 / SPEED_MB))
                        REMAINING_MIN=$((REMAINING_SEC / 60))
                        REMAINING_SEC=$((REMAINING_SEC % 60))
                        echo "   ⏳ 下载中: ${SIZE_MB}MB | 速度: ${SPEED_MB}MB/10s | 剩余: ${REMAINING_MIN}分${REMAINING_SEC}秒"
                    else
                        echo "   ⏳ 下载中: ${SIZE_MB}MB | 速度: ${SPEED_MB}MB/10s"
                    fi
                else
                    echo "   ⏳ 下载中: ${SIZE_DISPLAY}"
                fi
            else
                echo "   ⏳ 下载中: ${SIZE_DISPLAY}"
            fi
            PREV_GRADLE_SIZE=$SIZE_BYTES
        else
            echo "   ⏳ 正在安装中..."
        fi
        
        if ps aux | grep -q "[b]rew.rb install gradle"; then
            echo "   🔄 安装进程: 运行中"
        else
            echo "   ⚠️  安装进程已停止"
        fi
    fi
    
    # 总体进度
    echo ""
    echo "📊 总体进度:"
    TOTAL=0
    COMPLETED=0
    if [ "$OPENJDK_DONE" = true ]; then
        COMPLETED=$((COMPLETED+1))
    fi
    TOTAL=$((TOTAL+1))
    if [ "$GRADLE_DONE" = true ]; then
        COMPLETED=$((COMPLETED+1))
    fi
    TOTAL=$((TOTAL+1))
    if [ -d "$HOME/Library/Android/sdk" ]; then
        COMPLETED=$((COMPLETED+1))
    fi
    TOTAL=$((TOTAL+1))
    PERCENT=$((COMPLETED * 100 / TOTAL))
    
    # 进度条
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
    
    # 检查是否都完成
    if [ "$OPENJDK_DONE" = true ] && [ "$GRADLE_DONE" = true ]; then
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
echo "✅ 配置完成！"
echo ""
echo "验证:"
java -version 2>&1 | head -1 || echo "Java: ❌"
(/opt/homebrew/bin/gradle -v 2>&1 | head -1) || echo "Gradle: ❌"
echo "Android SDK: $ANDROID_HOME"
echo ""
