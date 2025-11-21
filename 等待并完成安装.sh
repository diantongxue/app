#!/bin/bash
# 等待安装完成并完成配置

set -e

echo "=========================================="
echo "等待安装完成并完成配置"
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

# 等待 OpenJDK 17
echo -e "${YELLOW}[1/4] 等待 OpenJDK 17 安装完成...${NC}"
MAX_WAIT=1800  # 30分钟
ELAPSED=0
while [ ! -d /opt/homebrew/opt/openjdk@17 ]; do
    if ps aux | grep -q "brew.*openjdk@17" | grep -v grep; then
        DOWNLOAD_SIZE=$(ls -lh /Users/mac/Library/Caches/Homebrew/downloads/*openjdk@17*.incomplete 2>/dev/null | awk '{print $5}' | head -1)
        echo "   等待中... 已下载: ${DOWNLOAD_SIZE:-未知} ($(date '+%H:%M:%S'))"
        sleep 30
        ELAPSED=$((ELAPSED + 30))
        if [ $ELAPSED -ge $MAX_WAIT ]; then
            echo -e "${RED}❌ 等待超时${NC}"
            break
        fi
    else
        echo -e "${RED}❌ 安装进程已结束但未安装完成${NC}"
        break
    fi
done

if [ -d /opt/homebrew/opt/openjdk@17 ]; then
    echo -e "${GREEN}✅ OpenJDK 17 安装完成${NC}"
    # 配置 Java
    if ! grep -q "JAVA_HOME.*openjdk@17" ~/.zshrc 2>/dev/null; then
        echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
        echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
    fi
    export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17")
    export PATH="$JAVA_HOME/bin:$PATH"
    java -version 2>&1 | head -1
else
    echo -e "${RED}❌ OpenJDK 17 未安装完成${NC}"
fi

# 等待 Gradle
echo ""
echo -e "${YELLOW}[2/4] 等待 Gradle 安装完成...${NC}"
ELAPSED=0
while [ ! -f /opt/homebrew/bin/gradle ]; do
    if ps aux | grep -q "brew.*gradle" | grep -v grep; then
        DOWNLOAD_SIZE=$(ls -lh /Users/mac/Library/Caches/Homebrew/downloads/*gradle*.incomplete 2>/dev/null | awk '{print $5}' | head -1)
        echo "   等待中... 已下载: ${DOWNLOAD_SIZE:-未知} ($(date '+%H:%M:%S'))"
        sleep 30
        ELAPSED=$((ELAPSED + 30))
        if [ $ELAPSED -ge $MAX_WAIT ]; then
            echo -e "${RED}❌ 等待超时${NC}"
            break
        fi
    else
        echo -e "${RED}❌ 安装进程已结束但未安装完成${NC}"
        break
    fi
done

if [ -f /opt/homebrew/bin/gradle ]; then
    echo -e "${GREEN}✅ Gradle 安装完成${NC}"
    /opt/homebrew/bin/gradle -v 2>&1 | head -1
else
    echo -e "${RED}❌ Gradle 未安装完成${NC}"
fi

# 配置 Android SDK
echo ""
echo -e "${YELLOW}[3/4] 配置 Android SDK...${NC}"
if [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
    
    if ! grep -q "ANDROID_HOME" ~/.zshrc 2>/dev/null; then
        echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
        echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
    fi
    
    echo -e "${GREEN}✅ Android SDK 已配置${NC}"
    echo "   ANDROID_HOME: $ANDROID_HOME"
else
    echo -e "${RED}❌ Android SDK 未安装${NC}"
fi

# 创建 Gradle Wrapper
echo ""
echo -e "${YELLOW}[4/4] 创建 Gradle Wrapper...${NC}"
cd /Users/mac/Desktop/故乡食品/app/android-app

if [ -f gradlew ]; then
    echo -e "${GREEN}✅ gradlew 已存在${NC}"
else
    if [ -f /opt/homebrew/bin/gradle ]; then
        echo -e "${YELLOW}   使用 Gradle 创建 Wrapper...${NC}"
        /opt/homebrew/bin/gradle wrapper --gradle-version 8.2 2>&1 | tail -5
    elif [ -f create_gradle_wrapper.sh ]; then
        echo -e "${YELLOW}   使用脚本创建 Wrapper...${NC}"
        bash create_gradle_wrapper.sh 2>&1 | tail -10
    else
        echo -e "${YELLOW}   直接创建 Wrapper 文件...${NC}"
        mkdir -p gradle/wrapper
        curl -L https://raw.githubusercontent.com/gradle/gradle/v8.2.0/gradle/wrapper/gradle-wrapper.jar -o gradle/wrapper/gradle-wrapper.jar 2>&1 | tail -3
        
        cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
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
echo "✅ 配置完成！"
echo "==========================================${NC}"
echo ""
echo "验证："
source ~/.zshrc 2>/dev/null || true
echo -n "Java: "
java -version 2>&1 | head -1 || echo "❌"
echo -n "Gradle: "
(/opt/homebrew/bin/gradle -v 2>&1 | head -1) || echo "❌"
echo -n "Android SDK: "
echo "$ANDROID_HOME" || echo "❌"
echo -n "Gradle Wrapper: "
([ -f gradlew ] && echo "✅") || echo "❌"
echo ""
echo "下一步：编译 APK"
echo "  cd /Users/mac/Desktop/故乡食品/app/android-app"
echo "  ./gradlew assembleDebug"
echo ""
