# 🚀 GitHub Actions 编译 Android APK - 超简单指南

## ✅ 优势

- ✅ **无需安装任何工具**（Java、Android SDK、Gradle 都不需要）
- ✅ **自动编译**（GitHub 云端自动完成）
- ✅ **自动下载 APK**（编译完成后直接下载）
- ✅ **完全免费**（GitHub Actions 免费额度足够使用）

---

## 📋 使用步骤（3 步完成）

### 步骤 1：将代码推送到 GitHub

如果你还没有 GitHub 仓库，需要：

1. **在 GitHub 上创建新仓库**
   - 访问：https://github.com/new
   - 创建新仓库（可以是私有的）

2. **将代码推送到 GitHub**

在 Mac 终端中运行：

```bash
cd /Users/mac/Desktop/故乡食品/app

# 如果还没有初始化 git
git init
git add .
git commit -m "Initial commit"

# 添加 GitHub 远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/你的仓库名.git
git branch -M main
git push -u origin main
```

**或者使用 GitHub Desktop**（更简单）：
- 下载：https://desktop.github.com/
- 打开 GitHub Desktop
- 添加本地仓库
- 发布到 GitHub

---

### 步骤 2：触发编译

有两种方式触发编译：

#### 方式 A：手动触发（推荐）

1. **打开你的 GitHub 仓库页面**
2. **点击 "Actions" 标签页**
3. **在左侧选择 "Build Android APK" 工作流**
4. **点击 "Run workflow" 按钮**
5. **选择分支（通常是 main）**
6. **点击绿色的 "Run workflow" 按钮**

#### 方式 B：自动触发

当你推送代码到 `main` 或 `master` 分支，并且修改了 `android-app/` 目录下的文件时，会自动触发编译。

---

### 步骤 3：下载 APK

1. **等待编译完成**（通常需要 3-5 分钟）
   - 在 Actions 页面可以看到编译进度
   - 绿色 ✅ 表示成功，红色 ❌ 表示失败

2. **下载 APK**
   - 点击编译完成的 workflow run
   - 在页面底部找到 "Artifacts" 部分
   - 点击 "app-debug-apk" 下载

3. **安装到手机**
   - 将下载的 APK 文件传输到手机
   - 在手机上允许安装未知来源应用
   - 点击 APK 文件安装

---

## 📱 完整操作流程

```
1. 推送代码到 GitHub
   ↓
2. 打开 GitHub 仓库 > Actions
   ↓
3. 点击 "Build Android APK" > "Run workflow"
   ↓
4. 等待编译完成（3-5 分钟）
   ↓
5. 下载 APK 文件
   ↓
6. 安装到手机
```

---

## 🆘 常见问题

### 问题 1：找不到 "Actions" 标签页

**解决方案**：
- 确保仓库已启用 GitHub Actions
- 如果仓库是新的，Actions 可能需要几分钟才能显示
- 检查仓库设置中是否禁用了 Actions

### 问题 2：编译失败

**可能原因**：
- 代码有错误
- Gradle 配置问题
- 依赖下载失败

**解决方案**：
- 查看 Actions 日志，找到错误信息
- 修复代码问题
- 重新触发编译

### 问题 3：找不到 "Run workflow" 按钮

**解决方案**：
- 确保工作流文件 `.github/workflows/build-android.yml` 已提交到仓库
- 刷新页面
- 检查是否有权限运行工作流

---

## 📝 工作流文件位置

工作流文件已创建在：
```
.github/workflows/build-android.yml
```

这个文件已经配置好了，你不需要修改它。

---

## ✅ 检查清单

- [ ] 代码已推送到 GitHub
- [ ] 可以看到 `.github/workflows/build-android.yml` 文件
- [ ] 在 GitHub 仓库中可以看到 "Actions" 标签页
- [ ] 可以点击 "Run workflow" 触发编译
- [ ] 编译完成后可以下载 APK

---

## 🎯 快速开始

**最快的方法**：

1. 使用 GitHub Desktop 将代码推送到 GitHub
2. 在 GitHub 网页上点击 Actions > Build Android APK > Run workflow
3. 等待 3-5 分钟
4. 下载 APK

**就这么简单！** 🚀

---

## 💡 提示

- 每次修改代码后，可以重新触发编译
- APK 文件会保留 30 天
- 编译过程完全在云端，不占用本地资源
- 可以同时编译多个版本

---

**现在就去 GitHub 上试试吧！** 🎉
