# 📱 在 Android Studio 中安装 SDK 组件 - 详细步骤

## ✅ 当前状态

你已经成功打开了 Android SDK 设置页面！

**SDK 位置**：`/Users/mac/Library/Android/sdk` ✅

---

## 📋 安装步骤

### 步骤 1：安装 Android SDK Platform 34

1. **当前在 "SDK Platforms" 标签页**（你已经在这里了）

2. **勾选 Android 14.0 (API 34)**：
   - 在列表中查找 **"Android 14.0"** 或 **"API 34"**
   - 如果看不到，可能需要：
     - 取消勾选 **"Hide Obsolete Packages"**（隐藏过时包）
     - 或者勾选 **"Show Package Details"**（显示包详情）来展开查看

3. **找到后勾选**：
   - 在 "Android 14.0" 或 "API 34" 前面的复选框打勾 ✅

---

### 步骤 2：切换到 "SDK Tools" 标签页

1. **点击 "SDK Tools" 标签页**（在 "SDK Platforms" 旁边）

2. **在 "SDK Tools" 标签页中勾选**：
   - ✅ **Android SDK Build-Tools 34.0.0**
     - 如果看不到，勾选 **"Show Package Details"** 展开查看
     - 找到 "Android SDK Build-Tools" 并展开
     - 勾选 "34.0.0" 版本
   
   - ✅ **Android SDK Platform-Tools**
     - 通常已经默认勾选，如果没有则勾选

   - （可选）**Android SDK Command-line Tools (latest)**
     - 推荐勾选，用于命令行操作

---

### 步骤 3：开始安装

1. **点击右下角的 "Apply" 或 "OK" 按钮**

2. **确认安装**：
   - 会弹出确认对话框，显示要安装的组件列表
   - 点击 **"OK"** 确认

3. **等待下载和安装**：
   - 会显示下载进度
   - 可能需要几分钟到十几分钟，取决于网络速度
   - 请耐心等待，不要关闭窗口

---

### 步骤 4：验证安装

安装完成后：

1. **在 "SDK Platforms" 标签页**：
   - 应该能看到 "Android 14.0" 或 "API 34" 的状态显示为 **"Installed"** ✅

2. **在 "SDK Tools" 标签页**：
   - "Android SDK Build-Tools 34.0.0" 的状态显示为 **"Installed"** ✅
   - "Android SDK Platform-Tools" 的状态显示为 **"Installed"** ✅

---

## 🚀 安装完成后

安装完成后，关闭设置窗口，然后在 Mac 终端中运行：

```bash
cd /Users/mac/Desktop/故乡食品/app
bash AndroidStudio配置脚本.sh
```

这个脚本会：
- ✅ 自动检测 SDK 路径（`/Users/mac/Library/Android/sdk`）
- ✅ 验证所有组件是否已安装
- ✅ 配置环境变量
- ✅ 准备编译环境

---

## ⚠️ 注意事项

1. **如果找不到 Android 14.0 (API 34)**：
   - 确保 **"Hide Obsolete Packages"** 未勾选
   - 勾选 **"Show Package Details"** 查看所有可用版本
   - 可能需要滚动列表查找

2. **如果下载很慢**：
   - 检查网络连接
   - 如果有代理，确保 Android Studio 使用代理
   - 可以分步安装，先安装 Platform，再安装 Build Tools

3. **如果安装失败**：
   - 检查网络连接
   - 重试安装
   - 或使用命令行方式（参考其他安装脚本）

---

## 📋 快速检查清单

- [ ] 在 "SDK Platforms" 标签页勾选了 "Android 14.0 (API 34)"
- [ ] 切换到 "SDK Tools" 标签页
- [ ] 勾选了 "Android SDK Build-Tools 34.0.0"
- [ ] 勾选了 "Android SDK Platform-Tools"
- [ ] 点击了 "Apply" 或 "OK"
- [ ] 等待安装完成
- [ ] 验证所有组件状态为 "Installed"
- [ ] 运行配置脚本：`bash AndroidStudio配置脚本.sh`

---

**现在请按照步骤 1-3 安装组件！** 🚀
