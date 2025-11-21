# 📱 Android Studio 进入 SDK 设置的多种方法

## 方法 1：通过菜单（不同语言版本）

### 英文版本：
- **Android Studio** > **Preferences**（或按快捷键 `⌘,`）

### 中文版本：
- **Android Studio** > **偏好设置**（或按快捷键 `⌘,`）

### 快捷键（所有版本通用）：
- 按 `⌘,`（Command + 逗号）

---

## 方法 2：通过欢迎界面

1. 如果看到 Android Studio 的欢迎界面（Welcome to Android Studio）
2. 点击右下角的 **More Actions**（更多操作）
3. 选择 **SDK Manager**

---

## 方法 3：通过项目设置（如果已打开项目）

1. 点击顶部菜单：**File** > **Settings**（或 **文件** > **设置**）
2. 左侧选择：**Appearance & Behavior** > **System Settings** > **Android SDK**

---

## 方法 4：直接打开 SDK Manager

1. 点击顶部菜单：**Tools** > **SDK Manager**（或 **工具** > **SDK Manager**）

---

## 方法 5：通过工具栏

1. 在 Android Studio 顶部工具栏找到 **SDK Manager** 图标（通常是一个带有 Android 图标的工具图标）
2. 点击即可打开

---

## 📋 进入后的操作步骤

无论用哪种方法进入，你都会看到 **Android SDK** 设置页面，然后：

### 1. 查看 "SDK Platforms" 标签页
- 勾选 **Android 14.0 (API 34)**

### 2. 切换到 "SDK Tools" 标签页
- 勾选 **Android SDK Build-Tools 34.0.0**
- 勾选 **Android SDK Platform-Tools**

### 3. 点击 **Apply**（应用）或 **OK**

### 4. 等待下载和安装完成

---

## 🆘 如果还是找不到

### 检查 Android Studio 版本

如果 Android Studio 版本较旧，界面可能不同。可以：

1. **更新 Android Studio**：
   - **Help** > **Check for Updates**（或 **帮助** > **检查更新**）

2. **或者使用命令行方式**：
   运行我创建的配置脚本，它会自动检测 SDK 路径：
   ```bash
   cd /Users/mac/Desktop/故乡食品/app
   bash AndroidStudio配置脚本.sh
   ```

---

## 🎯 最简单的方法

**直接按快捷键：`⌘,`（Command + 逗号）**

然后在左侧找到：
- **Appearance & Behavior** > **System Settings** > **Android SDK**

---

## 📸 界面位置参考

在 Android Studio 中，SDK 设置通常在：
- 顶部菜单栏：**Android Studio** / **File** / **Tools**
- 左侧设置树：**Appearance & Behavior** > **System Settings** > **Android SDK**

如果界面是中文，对应的是：
- **外观与行为** > **系统设置** > **Android SDK**

---

**试试按 `⌘,` 快捷键，这是最快的方法！** 🚀
