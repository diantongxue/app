#!/bin/bash

# ADB工具安装脚本
# 使用方法：bash 安装ADB.sh

echo "=========================================="
echo "ADB工具安装脚本"
echo "=========================================="
echo ""

# 检查是否已安装
if command -v adb &> /dev/null; then
    echo "✅ ADB工具已安装："
    adb version
    exit 0
fi

# 安装目录
INSTALL_DIR="/Users/mac/Desktop/故乡食品/app/tools"
PLATFORM_TOOLS_DIR="$INSTALL_DIR/platform-tools"

echo "安装目录: $PLATFORM_TOOLS_DIR"
echo ""

# 检查目录是否存在
if [ -d "$PLATFORM_TOOLS_DIR" ] && [ -f "$PLATFORM_TOOLS_DIR/adb" ]; then
    echo "✅ 发现已存在的ADB工具"
    chmod +x "$PLATFORM_TOOLS_DIR/adb"
    export PATH="$PATH:$PLATFORM_TOOLS_DIR"
    adb version
    echo ""
    echo "✅ ADB工具已配置完成！"
    exit 0
fi

echo "⚠️  ADB工具未找到，需要手动下载安装"
echo ""
echo "请按照以下步骤操作："
echo ""
echo "1. 访问下载页面："
echo "   https://developer.android.com/tools/releases/platform-tools"
echo ""
echo "2. 下载 macOS 版本："
echo "   https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
echo ""
echo "3. 将下载的zip文件放到当前目录："
echo "   $INSTALL_DIR/platform-tools-latest-darwin.zip"
echo ""
echo "4. 然后运行以下命令解压："
echo "   cd $INSTALL_DIR"
echo "   unzip platform-tools-latest-darwin.zip"
echo "   chmod +x platform-tools/adb"
echo ""
echo "5. 或者直接运行此脚本，它会自动检测并配置"
echo ""
echo "=========================================="

