#!/bin/bash
# 修复 Java 配置脚本
# 在 Mac 终端中运行：bash 修复Java配置.sh

echo "=========================================="
echo "修复 Java 配置"
echo "=========================================="
echo ""

# 检测 Java 安装路径
JAVA_PATH=""
if [ -d "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" ]; then
    JAVA_PATH="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    echo "✅ 找到 Java: $JAVA_PATH"
elif [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    JAVA_PATH="/opt/homebrew/opt/openjdk@17"
    echo "✅ 找到 Java: $JAVA_PATH"
else
    echo "❌ 未找到 Java 安装路径"
    echo "   请先安装 Java: brew install openjdk@17"
    exit 1
fi

# 验证 Java
if [ -f "$JAVA_PATH/bin/java" ]; then
    JAVA_VERSION=$("$JAVA_PATH/bin/java" -version 2>&1 | head -1)
    echo "   Java 版本: $JAVA_VERSION"
else
    echo "❌ Java 可执行文件不存在"
    exit 1
fi

# 备份 .zshrc
echo ""
echo "备份 ~/.zshrc..."
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# 移除旧的 Java 配置（使用 /usr/libexec/java_home 的配置）
echo "移除旧的 Java 配置..."
sed -i.bak '/JAVA_HOME.*java_home/d' ~/.zshrc 2>/dev/null || sed -i '' '/JAVA_HOME.*java_home/d' ~/.zshrc
sed -i.bak '/export PATH.*JAVA_HOME/d' ~/.zshrc 2>/dev/null || sed -i '' '/export PATH.*JAVA_HOME/d' ~/.zshrc

# 添加新的 Java 配置
echo "添加新的 Java 配置..."
if ! grep -q "JAVA_HOME.*openjdk@17" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Java 配置 (自动修复 - $(date +%Y-%m-%d))" >> ~/.zshrc
    echo "export JAVA_HOME=\"$JAVA_PATH\"" >> ~/.zshrc
    echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> ~/.zshrc
    echo "✅ 已添加 Java 配置到 ~/.zshrc"
else
    echo "✅ Java 配置已存在"
fi

# 立即生效
export JAVA_HOME="$JAVA_PATH"
export PATH="$JAVA_HOME/bin:$PATH"

echo ""
echo "=========================================="
echo "✅ Java 配置修复完成！"
echo "=========================================="
echo ""
echo "📋 当前配置："
echo "   JAVA_HOME=$JAVA_HOME"
echo ""
echo "⚠️  重要提示："
echo "   请运行以下命令使环境变量生效："
echo "   source ~/.zshrc"
echo ""
echo "   或者重新打开终端窗口"
echo ""
echo "🧪 测试 Java："
echo "   java -version"
echo ""
