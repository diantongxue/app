# 🖥️ 使用 GitHub Desktop 编译 Android APK

## ✅ 第一步：在 GitHub Desktop 中打开项目

### 方法 1：添加现有仓库

1. **打开 GitHub Desktop**
2. **点击 "File" > "Add Local Repository"**（或 **文件** > **添加本地仓库**）
3. **点击 "Choose..." 按钮**
4. **选择项目文件夹**：`/Users/mac/Desktop/故乡食品/app`
5. **点击 "Add Repository"**

### 方法 2：如果项目已经是 Git 仓库

如果项目已经初始化了 Git，GitHub Desktop 会自动检测到。

---

## ✅ 第二步：创建 GitHub 仓库（如果还没有）

### 方法 1：在 GitHub Desktop 中创建

1. **点击 "Publish repository"**（发布仓库）按钮
2. **输入仓库名称**（例如：`remote-control-app`）
3. **选择是否公开**：
   - ✅ **Public**（公开）- 免费使用 GitHub Actions
   - ❌ **Private**（私有）- 需要付费账户才能使用 GitHub Actions
4. **点击 "Publish Repository"**

### 方法 2：在 GitHub 网站上创建

1. **访问** https://github.com/new
2. **输入仓库名称**
3. **选择 Public**
4. **不要**勾选 "Initialize this repository with a README"
5. **点击 "Create repository"**
6. **回到 GitHub Desktop**，点击 "Repository" > "Repository Settings" > "Remote"
7. **输入仓库 URL**（例如：`https://github.com/你的用户名/仓库名.git`）

---

## ✅ 第三步：提交并推送代码

### 在 GitHub Desktop 中：

1. **查看更改**：
   - 左侧会显示所有更改的文件
   - 勾选要提交的文件（通常全选）

2. **填写提交信息**：
   - 在底部输入框输入：`准备编译 Android APK`
   - 或使用默认信息

3. **点击 "Commit to main"**（提交到 main 分支）

4. **推送代码**：
   - 点击右上角的 **"Push origin"** 按钮
   - 或点击 **"Repository" > "Push"**

5. **等待推送完成** ✅

---

## ✅ 第四步：在 GitHub 上触发编译

### 方法 1：通过网页（推荐）

1. **打开浏览器**，访问你的 GitHub 仓库页面
   - 地址格式：`https://github.com/你的用户名/仓库名`

2. **点击 "Actions" 标签页**（在仓库顶部）

3. **在左侧选择 "Build Android APK" 工作流**

4. **点击 "Run workflow" 按钮**（右侧）

5. **选择分支**（通常是 `main`）

6. **点击绿色的 "Run workflow" 按钮**

7. **等待编译完成**（约 5-10 分钟）

### 方法 2：通过推送自动触发

如果你修改了 `android-app/**` 目录下的文件并推送到 `main` 分支，编译会自动触发。

---

## ✅ 第五步：下载 APK

编译完成后：

1. **在 "Actions" 标签页中**，点击已完成的工作流（绿色 ✓）

2. **滚动到页面底部**，找到 **"Artifacts"**（工件）部分

3. **点击 "app-debug-apk"** 下载 ZIP 文件

4. **解压 ZIP 文件**，找到 `app-debug.apk`

---

## 📋 完整操作流程

```
1. 打开 GitHub Desktop
   ↓
2. File > Add Local Repository > 选择项目文件夹
   ↓
3. 点击 "Publish repository" 创建 GitHub 仓库
   ↓
4. 勾选所有文件 > 填写提交信息 > Commit
   ↓
5. 点击 "Push origin" 推送到 GitHub
   ↓
6. 打开 GitHub 网页 > Actions 标签页
   ↓
7. 选择 "Build Android APK" > Run workflow
   ↓
8. 等待编译完成 > 下载 APK
```

---

## 🆘 常见问题

### 问题 1：找不到 "Actions" 标签页

**原因**：仓库是私有的，需要付费账户

**解决方案**：
- 将仓库改为 **Public**（公开）
- 或升级到 GitHub Pro/Team 账户

### 问题 2：推送失败

**原因**：需要 GitHub 认证

**解决方案**：
1. 在 GitHub Desktop 中登录 GitHub 账户
2. 或使用 Personal Access Token

### 问题 3：找不到 "Run workflow" 按钮

**原因**：工作流文件可能有问题

**解决方案**：
- 确保 `.github/workflows/build-android.yml` 文件存在
- 检查文件内容是否正确

### 问题 4：编译失败

**解决方案**：
1. 点击失败的工作流，查看错误日志
2. 检查 `android-app` 目录是否完整
3. 确保所有文件都已提交

---

## 🚀 快速检查清单

- [ ] GitHub Desktop 已安装并登录
- [ ] 项目已添加到 GitHub Desktop
- [ ] 已创建 GitHub 仓库（Public）
- [ ] 所有文件已提交
- [ ] 代码已推送到 GitHub
- [ ] 在 GitHub 网页上打开了 Actions 标签页
- [ ] 已触发 "Build Android APK" 工作流
- [ ] 编译已完成
- [ ] 已下载 APK 文件

---

**现在请按照步骤 1-3 在 GitHub Desktop 中添加项目并推送代码！** 🚀
