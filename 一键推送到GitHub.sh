#!/bin/bash
# 一键推送代码到 GitHub 并触发编译
# 在 Mac 终端中运行：bash 一键推送到GitHub.sh

echo "=========================================="
echo "GitHub 代码推送和编译触发脚本"
echo "=========================================="
echo ""

# 检查是否在 Git 仓库中
if [ ! -d ".git" ]; then
    echo "⚠️  当前目录不是 Git 仓库"
    echo ""
    read -p "是否要初始化 Git 仓库？(y/n): " init_git
    if [ "$init_git" = "y" ] || [ "$init_git" = "Y" ]; then
        git init
        echo "✅ Git 仓库已初始化"
    else
        echo "❌ 请先初始化 Git 仓库或进入已有仓库"
        exit 1
    fi
fi

# 检查远程仓库
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE_URL" ]; then
    echo "⚠️  未配置 GitHub 远程仓库"
    echo ""
    read -p "请输入 GitHub 仓库地址 (例如: https://github.com/用户名/仓库名.git): " repo_url
    
    if [ -z "$repo_url" ]; then
        echo "❌ 未输入仓库地址"
        exit 1
    fi
    
    git remote add origin "$repo_url"
    echo "✅ 已添加远程仓库: $repo_url"
else
    echo "✅ 远程仓库: $REMOTE_URL"
fi

# 添加所有文件
echo ""
echo "正在添加文件..."
git add .

# 检查是否有更改
if git diff --staged --quiet; then
    echo "⚠️  没有需要提交的更改"
else
    # 提交
    echo "正在提交更改..."
    git commit -m "准备编译 Android APK - $(date +%Y-%m-%d\ %H:%M:%S)" || {
        echo "❌ 提交失败"
        exit 1
    }
    echo "✅ 已提交更改"
fi

# 推送到 GitHub
echo ""
echo "正在推送到 GitHub..."
echo "（如果提示输入用户名和密码，请使用 Personal Access Token）"
echo ""

BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

git push -u origin "$BRANCH" || {
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "可能的原因："
    echo "1. 需要配置 GitHub 认证（使用 Personal Access Token）"
    echo "2. 网络连接问题"
    echo ""
    echo "请手动推送："
    echo "   git push -u origin $BRANCH"
    exit 1
}

echo ""
echo "=========================================="
echo "✅ 代码已推送到 GitHub！"
echo "=========================================="
echo ""
echo "📋 下一步操作："
echo ""
echo "1. 打开 GitHub 仓库页面："
echo "   $REMOTE_URL"
echo ""
echo "2. 点击 'Actions' 标签页"
echo ""
echo "3. 选择 'Build Android APK' 工作流"
echo ""
echo "4. 点击 'Run workflow' 按钮"
echo ""
echo "5. 等待编译完成（约 5-10 分钟）"
echo ""
echo "6. 在 'Artifacts' 部分下载 APK"
echo ""
echo "=========================================="
echo ""

