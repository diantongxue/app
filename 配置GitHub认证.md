# 🔐 配置 GitHub 认证

## ❌ 当前问题

推送失败，需要 GitHub 认证。

---

## ✅ 解决方案（选择一种）

### 方法 1：使用 Personal Access Token（推荐）

#### 步骤 1：创建 Personal Access Token

1. **访问**：https://github.com/settings/tokens
2. **点击 "Generate new token"** > **"Generate new token (classic)"**
3. **填写信息**：
   - **Note**（备注）：`Git Push Token`
   - **Expiration**（过期时间）：选择 "90 days" 或 "No expiration"
   - **Select scopes**（权限）：勾选 **`repo`**（完整仓库权限）
4. **点击 "Generate token"**
5. **复制生成的 token**（只显示一次，请保存好！）

#### 步骤 2：使用 Token 推送

在终端中运行（替换 `YOUR_TOKEN` 为你的 token）：

```bash
cd /Users/mac/Desktop/故乡食品/app

# 使用 token 推送
git push -u https://YOUR_TOKEN@github.com/diantongxue/app.git main
```

**或者配置远程仓库使用 token**：

```bash
cd /Users/mac/Desktop/故乡食品/app

# 设置远程仓库 URL（包含 token）
git remote set-url origin https://YOUR_TOKEN@github.com/diantongxue/app.git

# 推送
git push -u origin main
```

---

### 方法 2：使用 GitHub Desktop（最简单）

1. **打开 GitHub Desktop**
2. **确保已登录 GitHub 账户**
3. **在 GitHub Desktop 中点击 "Push origin"**
4. **如果提示登录，按照提示操作**

---

### 方法 3：使用 SSH（最安全，但需要配置）

#### 步骤 1：生成 SSH 密钥

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

按 Enter 使用默认位置，设置密码（可选）。

#### 步骤 2：复制公钥

```bash
cat ~/.ssh/id_ed25519.pub
```

复制输出的内容。

#### 步骤 3：添加到 GitHub

1. **访问**：https://github.com/settings/keys
2. **点击 "New SSH key"**
3. **填写**：
   - **Title**：`Mac Cursor`
   - **Key**：粘贴刚才复制的公钥
4. **点击 "Add SSH key"**

#### 步骤 4：更改远程仓库地址

```bash
cd /Users/mac/Desktop/故乡食品/app
git remote set-url origin git@github.com:diantongxue/app.git
git push -u origin main
```

---

## 🚀 推荐操作流程

**最简单的方法**：

1. **在 GitHub Desktop 中**：
   - 确保已登录
   - 点击 "Push origin"
   - 如果提示，输入 GitHub 用户名和密码（或 token）

2. **或者使用 Personal Access Token**（见方法 1）

---

## 📋 快速命令（使用 Token）

如果你已经创建了 Personal Access Token，运行：

```bash
cd /Users/mac/Desktop/故乡食品/app

# 替换 YOUR_TOKEN 为你的实际 token
git remote set-url origin https://YOUR_TOKEN@github.com/diantongxue/app.git
git push -u origin main
```

---

**现在请选择一种方法配置认证，然后推送代码！** 🚀
