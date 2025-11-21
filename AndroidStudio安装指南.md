# 📱 Android Studio 安装和配置指南

## ✅ 第一步：在 Android Studio 中安装 SDK 组件

### 1. 打开 Android Studio

首次打开可能需要一些时间进行初始化。

### 2. 进入 SDK 设置

**方法 A：通过菜单**
- 点击顶部菜单：**Android Studio** > **Preferences**（或按 `⌘,`）
- 左侧选择：**Appearance & Behavior** > **System Settings** > **Android SDK**

**方法 B：通过欢迎界面**
- 如果看到欢迎界面，点击 **More Actions** > **SDK Manager**

### 3. 安装必需的 SDK 组件

#### 3.1 SDK Platforms 标签页

1. 勾选 **Android 14.0 (API 34)**
   - 如果看不到，点击 **Show Package Details** 展开
   - 确保勾选：
     - ✅ Android SDK Platform 34
     - ✅ Sources for Android 34（可选，但推荐）

#### 3.2 SDK Tools 标签页

1. 勾选以下工具：
   - ✅ **Android SDK Build-Tools 34.0.0**
   - ✅ **Android SDK Platform-Tools**
   - ✅ **Android SDK Command-line Tools (latest)**（可选，但推荐）

2. 点击 **Show Package Details** 可以查看具体版本

### 4. 开始安装

1. 点击右下角的 **Apply** 按钮
2. 在弹出的确认对话框中点击 **OK**
3. 等待下载和安装完成（可能需要几分钟到十几分钟，取决于网络速度）

### 5. 验证安装

安装完成后，在 **SDK Platforms** 和 **SDK Tools** 标签页中，已安装的组件会显示 ✅ 标记。

---

## ✅ 第二步：运行配置脚本

在 Android Studio 中安装完 SDK 组件后，在 Mac 终端中运行：

```bash
cd /Users/mac/Desktop/故乡食品/app
bash AndroidStudio配置脚本.sh
```

这个脚本会：
1. ✅ 自动检测 Android Studio 安装的 SDK 路径
2. ✅ 检查所有必需的组件是否已安装
3. ✅ 配置 Java 和 Android SDK 环境变量
4. ✅ 验证配置

---

## ⚠️ 如果脚本提示组件缺失

如果脚本检测到组件缺失，请：

1. **返回 Android Studio**
2. **重新检查 SDK 设置**：
   - 确保 **Android 14.0 (API 34)** 已勾选并安装
   - 确保 **Android SDK Build-Tools 34.0.0** 已勾选并安装
   - 确保 **Android SDK Platform-Tools** 已勾选并安装

3. **如果组件已安装但脚本仍提示缺失**：
   - 检查 SDK 路径是否正确
   - 手动输入 SDK 路径（脚本会提示）

---

## ✅ 第三步：使环境变量生效

运行配置脚本后，执行：

```bash
source ~/.zshrc
```

或者**重新打开终端窗口**。

---

## ✅ 第四步：验证配置

```bash
# 检查 Java
java -version

# 检查环境变量
echo $JAVA_HOME
echo $ANDROID_HOME

# 检查 SDK 组件
ls $ANDROID_HOME/platform-tools
ls $ANDROID_HOME/platforms/android-34
ls $ANDROID_HOME/build-tools/34.0.0
```

---

## ✅ 第五步：编译 APK

```bash
cd /Users/mac/Desktop/故乡食品/app/android-app
./gradlew assembleDebug
```

编译成功后，APK 文件位于：
```
android-app/app/build/outputs/apk/debug/app-debug.apk
```

---

## 🆘 常见问题

### 问题 1：找不到 Android SDK 路径

**解决方案**：
1. 在 Android Studio 中查看 SDK 路径：
   - Preferences > Appearance & Behavior > System Settings > Android SDK
   - 查看 "Android SDK Location"
2. 手动设置环境变量：
   ```bash
   export ANDROID_HOME=/你的SDK路径
   ```

### 问题 2：组件下载失败

**解决方案**：
- 检查网络连接
- 配置代理（如果有）
- 在 Android Studio 中重试下载
- 或使用国内镜像源

### 问题 3：Build Tools 34.0.0 找不到

**解决方案**：
1. 在 Android Studio 中：
   - SDK Tools 标签页
   - 勾选 "Show Package Details"
   - 找到 "Android SDK Build-Tools"
   - 勾选 "34.0.0"
   - 点击 Apply 安装

### 问题 4：Java 找不到

**解决方案**：
- Android Studio 自带 JDK，脚本会自动检测
- 或手动安装：`brew install openjdk@17`

---

## 📋 快速检查清单

- [ ] Android Studio 已安装并打开
- [ ] 已进入 SDK 设置（Preferences > Android SDK）
- [ ] 已勾选并安装 Android 14.0 (API 34)
- [ ] 已勾选并安装 Android SDK Build-Tools 34.0.0
- [ ] 已勾选并安装 Android SDK Platform-Tools
- [ ] 已运行配置脚本：`bash AndroidStudio配置脚本.sh`
- [ ] 已执行 `source ~/.zshrc`
- [ ] 已验证环境变量
- [ ] 已成功编译 APK

---

**现在请按照步骤 1 在 Android Studio 中安装 SDK 组件！** 🚀
