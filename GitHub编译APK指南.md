# 🚀 使用 GitHub Actions 编译 Android APK

## ✅ 优势

- ✅ **无需本地配置**：不需要安装 Java、Android SDK、Gradle 等
- ✅ **云端自动编译**：GitHub 服务器自动完成所有编译工作
- ✅ **简单快速**：只需推送代码到 GitHub，点击按钮即可编译
- ✅ **自动下载**：编译完成后直接下载 APK 文件

---

## 📋 使用步骤

### 步骤 1：将代码推送到 GitHub

如果你的代码还没有推送到 GitHub：

```bash
cd /Users/mac/Desktop/故乡食品/app

# 初始化 Git（如果还没有）
git init

# 添加所有文件
git add .

# 提交
git commit -m "准备编译 Android APK"

# 添加 GitHub 远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/你的仓库名.git

# 推送到 GitHub
git push -u origin main
```

**如果代码已经在 GitHub 上**，直接跳到步骤 2。

---

### 步骤 2：触发编译

有两种方式触发编译：

#### 方法 A：手动触发（推荐）

1. **打开 GitHub 仓库页面**
2. **点击 "Actions" 标签页**
3. **在左侧选择 "Build Android APK" 工作流**
4. **点击 "Run workflow" 按钮**
5. **选择分支（通常是 main 或 master）**
6. **点击绿色的 "Run workflow" 按钮**

#### 方法 B：自动触发

当你推送代码到 `main` 或 `master` 分支，并且修改了 `android-app/**` 目录下的文件时，会自动触发编译。

---

### 步骤 3：查看编译进度

1. **在 "Actions" 标签页中**，点击正在运行的工作流
2. **查看编译日志**，可以看到：
   - ✅ 代码检出
   - ✅ Java 环境设置
   - ✅ Android SDK 设置
   - ✅ Gradle 编译
   - ✅ APK 上传

3. **等待编译完成**（通常需要 5-10 分钟）

---

### 步骤 4：下载 APK

编译完成后：

1. **在 "Actions" 标签页中**，点击已完成的工作流
2. **滚动到页面底部**，找到 "Artifacts"（工件）部分
3. **点击 "app-debug-apk"** 下载 APK 文件

或者：

- 如果配置了 Release，可以在 **"Releases"** 标签页下载

---

## 📱 APK 文件位置

下载的 APK 文件：
- **文件名**：`app-debug.apk`
- **位置**：在下载的 ZIP 文件中：`android-app/app/build/outputs/apk/debug/app-debug.apk`

---

## 🔧 工作流配置说明

工作流文件位置：`.github/workflows/build-android.yml`

**自动执行的操作**：
1. ✅ 设置 Java 17 环境
2. ✅ 设置 Android SDK
3. ✅ 创建 Gradle Wrapper（如果需要）
4. ✅ 编译 Debug APK
5. ✅ 上传 APK 作为工件

---

## ⚠️ 注意事项

1. **首次编译可能需要更长时间**（下载依赖）
2. **确保代码已推送到 GitHub**
3. **如果编译失败**，查看日志中的错误信息
4. **APK 文件会保留 30 天**，之后自动删除

---

## 🆘 常见问题

### 问题 1：找不到 "Actions" 标签页

**解决方案**：
- 确保仓库是公开的，或者你有 GitHub Pro/Team 账户
- 私有仓库需要付费账户才能使用 GitHub Actions

### 问题 2：编译失败

**解决方案**：
1. 点击失败的工作流，查看错误日志
2. 检查 `android-app` 目录下的文件是否完整
3. 确保 `gradlew` 文件存在且有执行权限

### 问题 3：找不到 APK 下载

**解决方案**：
- 确保编译成功（绿色 ✓ 标记）
- 在 "Artifacts" 部分查找
- 如果配置了 Release，在 "Releases" 标签页查找

---

## 🚀 快速开始

**最简单的流程**：

1. **推送代码到 GitHub**（如果还没有）
2. **打开 GitHub 仓库** > **Actions** 标签页
3. **点击 "Build Android APK"** > **"Run workflow"**
4. **等待编译完成**
5. **下载 APK**

---

**就这么简单！不需要任何本地配置！** 🎉

