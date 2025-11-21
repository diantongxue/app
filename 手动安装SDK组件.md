# 📱 手动安装 Android SDK 组件

## ⚠️ 当前问题

由于网络连接问题，无法自动下载 Android SDK Command Line Tools。需要手动安装 SDK 组件。

---

## 🚀 解决方案

### 方案1：使用 Android Studio（推荐）⭐⭐⭐

1. **下载并安装 Android Studio**
   - 访问：https://developer.android.com/studio
   - 下载并安装

2. **打开 Android Studio**
   - 首次启动会自动安装 Android SDK 和所有组件
   - 或手动打开：`Tools → SDK Manager`

3. **安装 SDK 组件**
   - 在 SDK Manager 中勾选：
     - Android SDK Platform 34
     - Android SDK Build-Tools 34.0.0
   - 点击 Apply 安装

### 方案2：手动下载并安装

#### 步骤1：下载 Command Line Tools

在浏览器中访问并下载：
```
https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip
```

#### 步骤2：解压并安装

```bash
cd ~/Library/Android/sdk/cmdline-tools
# 将下载的 zip 文件放到这里
unzip commandlinetools-mac-11076708_latest.zip
mv cmdline-tools latest
```

#### 步骤3：使用 sdkmanager 安装组件

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# 接受许可证
yes | sdkmanager --licenses

# 安装组件
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### 方案3：修改项目使用已安装的 SDK 版本

如果系统已有其他版本的 Android SDK，可以修改 `build.gradle` 使用已安装的版本。

---

## 📋 当前状态

- ✅ OpenJDK 17: 已安装
- ✅ Gradle: 已安装
- ✅ Android SDK: 已安装
- ✅ Gradle Wrapper: 已创建
- ❌ Android SDK 组件: 需要安装（platform-tools, platforms;android-34, build-tools;34.0.0）

---

## 💡 我的建议

**推荐使用方案1（Android Studio）**，因为：
- ✅ 自动安装所有组件
- ✅ 图形界面，操作简单
- ✅ 一次安装，长期使用

---

## 🔨 安装完成后

安装完 SDK 组件后，运行：

```bash
cd /Users/mac/Desktop/故乡食品/app/android-app
./gradlew assembleDebug
```

---

**需要帮助？** 告诉我你选择哪个方案，我会继续协助你！
