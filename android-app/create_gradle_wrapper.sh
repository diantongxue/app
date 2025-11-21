#!/bin/bash
# 创建 Gradle Wrapper 的脚本

echo "正在创建 Gradle Wrapper..."

# 检查是否已安装 gradle
if ! command -v gradle &> /dev/null; then
    echo "❌ 未找到 Gradle，请先安装："
    echo "   1. 安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "   2. 安装 Gradle: brew install gradle"
    echo "   或者安装 Android Studio（推荐）"
    exit 1
fi

# 创建 gradle wrapper
gradle wrapper --gradle-version 8.2

if [ $? -eq 0 ]; then
    echo "✅ Gradle Wrapper 创建成功！"
    echo "现在可以使用 ./gradlew assembleDebug 编译 APK"
else
    echo "❌ 创建失败，请检查错误信息"
    exit 1
fi
