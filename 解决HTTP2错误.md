# 🔧 解决 Git HTTP2 错误

## ❌ 当前错误

**错误信息**：`fatal: unable to access 'https://github.com/diantongxue/app.git/': Error in the HTTP2 framing layer`

这是一个 Git HTTP2 协议问题，通常由网络或代理配置引起。

---

## ✅ 解决方案

### 方法 1：禁用 Git HTTP2（推荐，最简单）

在终端中运行：

```bash
cd /Users/mac/Desktop/故乡食品/app

# 禁用 HTTP2
git config --global http.version HTTP/1.1

# 验证设置
git config --global http.version
```

然后**重新在 GitHub Desktop 中推送**。

---

### 方法 2：配置代理（如果你使用代理）

```bash
# 设置 HTTP 代理（根据你的代理修改端口）
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 如果不需要代理，可以取消设置
# git config --global --unset http.proxy
# git config --global --unset https.proxy
```

---

### 方法 3：使用 SSH 代替 HTTPS

1. **生成 SSH 密钥**（如果还没有）：
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. **复制公钥**：
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. **添加到 GitHub**：
   - 访问：https://github.com/settings/keys
   - 点击 "New SSH key"
   - 粘贴公钥内容

4. **更改远程仓库地址为 SSH**：
   ```bash
   cd /Users/mac/Desktop/故乡食品/app
   git remote set-url origin git@github.com:diantongxue/app.git
   ```

---

### 方法 4：使用命令行推送（绕过 GitHub Desktop）

如果 GitHub Desktop 一直失败，可以使用命令行：

```bash
cd /Users/mac/Desktop/故乡食品/app

# 禁用 HTTP2
git config --global http.version HTTP/1.1

# 提交（如果还没有提交）
git commit -m "添加 Android 项目和 GitHub Actions 工作流"

# 推送到 GitHub
git push -u origin main
```

---

## ⚠️ 重要提示：文件数量异常

你准备提交 **91499 个文件**，这个数量非常大！

**可能的原因**：
- `node_modules/` 目录被包含（不应该提交）
- `frontend/node_modules/` 和 `backend/node_modules/` 被包含
- 其他构建产物被包含

**解决方案**：检查并更新 `.gitignore` 文件，确保排除：
- `node_modules/`
- `dist/`
- `build/`
- `.idea/`（可选，Android Studio 配置）

---

## 🚀 推荐操作步骤

### 步骤 1：修复 HTTP2 错误

在终端中运行：
```bash
cd /Users/mac/Desktop/故乡食品/app
git config --global http.version HTTP/1.1
```

### 步骤 2：检查 .gitignore

确保 `.gitignore` 包含：
```
node_modules/
dist/
build/
*.log
.DS_Store
```

### 步骤 3：重新提交（如果需要）

如果文件太多，可能需要：
1. 取消当前提交
2. 更新 `.gitignore`
3. 重新添加文件
4. 重新提交

### 步骤 4：推送

在 GitHub Desktop 中重新点击 "Push origin"，或使用命令行推送。

---

## 📋 快速修复命令

**一键修复 HTTP2 错误**：

```bash
cd /Users/mac/Desktop/故乡食品/app
git config --global http.version HTTP/1.1
echo "✅ HTTP2 已禁用，现在可以重新推送了"
```

---

**现在请在终端中运行上面的命令禁用 HTTP2，然后重新在 GitHub Desktop 中推送！** 🚀
