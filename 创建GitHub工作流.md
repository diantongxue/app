# 🔧 创建 GitHub Actions 工作流

## ❌ 当前问题

在 GitHub Actions 页面搜索 "Build Android APK" 显示 **"发现 0 个工作流程"**（Found 0 workflows）。

这说明工作流文件还没有被推送到 GitHub。

---

## ✅ 解决方案

### 方法 1：确保工作流文件已提交并推送

工作流文件应该位于：`.github/workflows/build-android.yml`

**检查步骤**：

1. **在 GitHub Desktop 中**：
   - 查看左侧文件列表
   - 找到 `.github/workflows/build-android.yml` 文件
   - 确保它被勾选（在提交列表中）

2. **如果文件未显示**：
   - 点击 **"Show in Finder"**（在 Finder 中显示）
   - 或手动添加文件到 Git

3. **提交并推送**：
   - 勾选 `.github/workflows/build-android.yml`
   - 填写提交信息：`添加 GitHub Actions 工作流`
   - 点击 **"Commit to main"**
   - 点击 **"Push origin"**

4. **刷新 GitHub 网页**：
   - 等待推送完成
   - 刷新 Actions 页面
   - 应该能看到 "Build Android APK" 工作流

---

### 方法 2：如果文件不存在，创建它

如果 `.github/workflows/build-android.yml` 文件不存在：

1. **在项目根目录创建目录**：
   ```bash
   mkdir -p .github/workflows
   ```

2. **创建工作流文件**：
   - 文件路径：`.github/workflows/build-android.yml`
   - 文件内容（已为你准备好，见下方）

3. **在 GitHub Desktop 中**：
   - 文件会自动出现在提交列表中
   - 勾选并提交
   - 推送到 GitHub

---

## 📋 工作流文件内容

工作流文件应该包含以下内容（我已经为你创建好了）：

```yaml
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
```

---

## 🚀 快速操作步骤

### 步骤 1：检查文件是否存在

在终端中运行：
```bash
cd /Users/mac/Desktop/故乡食品/app
ls -la .github/workflows/build-android.yml
```

### 步骤 2：如果文件存在但未提交

1. **在 GitHub Desktop 中**：
   - 查看左侧文件列表
   - 找到 `.github` 文件夹
   - 展开查看 `workflows/build-android.yml`
   - 确保勾选

2. **提交并推送**：
   - 填写提交信息
   - 点击 "Commit to main"
   - 点击 "Push origin"

### 步骤 3：如果文件不存在

运行我创建的脚本自动创建：
```bash
cd /Users/mac/Desktop/故乡食品/app
bash 创建GitHub工作流.sh
```

### 步骤 4：刷新 GitHub 页面

1. **等待推送完成**
2. **刷新 GitHub Actions 页面**
3. **应该能看到 "Build Android APK" 工作流**

---

## ✅ 验证

推送完成后：

1. **在 GitHub 网页上**：
   - 进入你的仓库
   - 点击 **"代码"**（Code）标签页
   - 查看 `.github/workflows/build-android.yml` 文件是否存在

2. **在 Actions 页面**：
   - 刷新页面
   - 应该能看到 **"Build Android APK"** 工作流
   - 点击它，然后点击 **"Run workflow"**

---

**现在请检查工作流文件是否已提交并推送！** 🚀
