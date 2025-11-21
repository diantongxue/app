#!/bin/bash
# 快速检测 Android SDK 路径并打开 SDK 设置
# 在 Mac 终端中运行：bash 快速进入SDK设置.sh

echo "=========================================="
echo "Android SDK 路径检测和配置"
echo "=========================================="
echo ""

# 检测常见的 Android SDK 位置
POSSIBLE_SDK_PATHS=(
    "$HOME/Library/Android/sdk"
    "$HOME/Android/sdk"
    "$HOME/.android/sdk"
    "/Users/$USER/Library/Android/sdk"
)

ANDROID_HOME=""

echo "正在检测 Android SDK 路径..."
for path in "${POSSIBLE_SDK_PATHS[@]}"; do
    if [ -d "$path" ]; then
        ANDROID_HOME="$path"
        echo "✅ 找到 Android SDK: $ANDROID_HOME"
        break
    fi
done

if [ -z "$ANDROID_HOME" ]; then
    echo "❌ 未找到 Android SDK"
    echo ""
    echo "请按照以下步骤操作："
    echo ""
    echo "方法 1：在 Android Studio 中查找"
    echo "  1. 打开 Android Studio"
    echo "  2. 按快捷键 ⌘, (Command + 逗号)"
    echo "  3. 左侧选择：Appearance & Behavior > System Settings > Android SDK"
    echo "  4. 查看 'Android SDK Location' 显示的路径"
    echo ""
    echo "方法 2：手动输入路径"
    read -p "请输入 Android SDK 路径: " ANDROID_HOME
    
    if [ ! -d "$ANDROID_HOME" ]; then
        echo "❌ 路径不存在: $ANDROID_HOME"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "Android SDK 信息"
echo "=========================================="
echo "路径: $ANDROID_HOME"
echo ""

# 检查组件
echo "检查已安装的组件："
echo ""

if [ -d "$ANDROID_HOME/platform-tools" ]; then
    echo "✅ platform-tools 已安装"
else
    echo "❌ platform-tools 未安装"
fi

if [ -d "$ANDROID_HOME/platforms/android-34" ]; then
    echo "✅ platforms;android-34 已安装"
else
    echo "❌ platforms;android-34 未安装"
fi

if [ -d "$ANDROID_HOME/build-tools/34.0.0" ]; then
    echo "✅ build-tools;34.0.0 已安装"
else
    echo "❌ build-tools;34.0.0 未安装"
fi

echo ""
echo "=========================================="
echo "如何在 Android Studio 中安装缺失的组件"
echo "=========================================="
echo ""
echo "步骤 1：打开 Android Studio"
echo ""
echo "步骤 2：进入 SDK 设置（三种方法任选其一）："
echo "  方法 A：按快捷键 ⌘, (Command + 逗号)"
echo "  方法 B：菜单栏 > Android Studio > Preferences"
echo "  方法 C：菜单栏 > Tools > SDK Manager"
echo ""
echo "步骤 3：在左侧选择："
echo "  Appearance & Behavior > System Settings > Android SDK"
echo ""
echo "步骤 4：安装组件"
echo "  - 在 'SDK Platforms' 标签页：勾选 'Android 14.0 (API 34)'"
echo "  - 在 'SDK Tools' 标签页："
echo "    * 勾选 'Android SDK Build-Tools 34.0.0'"
echo "    * 勾选 'Android SDK Platform-Tools'"
echo ""
echo "步骤 5：点击 'Apply' 或 'OK' 开始安装"
echo ""
echo "步骤 6：安装完成后，运行配置脚本："
echo "  bash AndroidStudio配置脚本.sh"
echo ""

# 尝试打开 Android Studio（如果已安装）
if [ -d "/Applications/Android Studio.app" ]; then
    echo "检测到 Android Studio 已安装"
    echo ""
    read -p "是否要打开 Android Studio？(y/n): " open_studio
    if [ "$open_studio" = "y" ] || [ "$open_studio" = "Y" ]; then
        open "/Applications/Android Studio.app"
        echo "✅ 已打开 Android Studio"
        echo ""
        echo "请按照上面的步骤进入 SDK 设置"
    fi
fi

echo ""
echo "=========================================="
echo "完成"
echo "=========================================="
echo ""
