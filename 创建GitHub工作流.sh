#!/bin/bash
# 创建 GitHub Actions 工作流文件
# 在 Mac 终端中运行：bash 创建GitHub工作流.sh

echo "=========================================="
echo "创建 GitHub Actions 工作流"
echo "=========================================="
echo ""

cd /Users/mac/Desktop/故乡食品/app

# 创建目录
echo "创建 .github/workflows 目录..."
mkdir -p .github/workflows

# 检查文件是否已存在
if [ -f ".github/workflows/build-android.yml" ]; then
    echo "✅ 工作流文件已存在"
    echo ""
    read -p "是否要覆盖现有文件？(y/n): " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo "已取消"
        exit 0
    fi
fi

# 创建工作流文件
echo "正在创建工作流文件..."
cat > .github/workflows/build-android.yml << 'EOF'
name: Build Android APK

on:
  workflow_dispatch:  # 手动触发
  push:
    branches: [ main, master ]
    paths:
      - 'android-app/**'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Setup Android SDK
      uses: android-actions/setup-android@v3
    
    - name: Grant execute permission for gradlew
      run: |
        cd android-app
        chmod +x gradlew || echo "gradlew not found, will create wrapper"
    
    - name: Create Gradle Wrapper (if needed)
      working-directory: android-app
      run: |
        if [ ! -f "./gradlew" ]; then
          gradle wrapper --gradle-version 8.2
        fi
    
    - name: Build APK
      working-directory: android-app
      run: ./gradlew assembleDebug
    
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: app-debug-apk
        path: android-app/app/build/outputs/apk/debug/app-debug.apk
        retention-days: 30
EOF

echo "✅ 工作流文件已创建: .github/workflows/build-android.yml"
echo ""

# 检查 Git 状态
if [ -d ".git" ]; then
    echo "检查 Git 状态..."
    git status .github/workflows/build-android.yml 2>/dev/null | head -5
    
    echo ""
    echo "=========================================="
    echo "✅ 文件已创建！"
    echo "=========================================="
    echo ""
    echo "📋 下一步操作："
    echo ""
    echo "1. 在 GitHub Desktop 中："
    echo "   - 查看左侧文件列表"
    echo "   - 找到 .github/workflows/build-android.yml"
    echo "   - 确保勾选"
    echo ""
    echo "2. 提交并推送："
    echo "   - 填写提交信息：'添加 GitHub Actions 工作流'"
    echo "   - 点击 'Commit to main'"
    echo "   - 点击 'Push origin'"
    echo ""
    echo "3. 在 GitHub 网页上："
    echo "   - 刷新 Actions 页面"
    echo "   - 应该能看到 'Build Android APK' 工作流"
    echo ""
else
    echo "⚠️  当前目录不是 Git 仓库"
    echo "   请先在 GitHub Desktop 中添加此项目"
fi

echo ""
