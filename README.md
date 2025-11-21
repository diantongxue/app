# 手机App远程控制系统

## 项目结构

```
app/
├── frontend/          # 前端项目（React 19 + Umi 4 + Ant Design Pro）
├── backend/           # 后端项目（Node.js + Express + Socket.io）
├── android-app/       # 手机App项目（Android + Kotlin）
└── 开发文档.md        # 开发文档
```

## 快速开始

### 前端开发

```bash
cd frontend
npm install
npm run dev
```

访问: http://localhost:8000

### 后端开发

```bash
cd backend
npm install
npm run dev
```

后端服务: http://localhost:3001
WebSocket: ws://localhost:3001

## 功能特性

1. **远程操控**：实时查看手机画面，执行点击、滑动等操作
2. **数据抓包**：采集手机App的页面数据
3. **数据可视化**：将数据整理成可视化图表
4. **日志调试**：每个模块都提供日志框，支持复制、清空

## 开发日志

所有功能模块都集成了日志查看功能，方便调试：
- 前端：每个页面都有日志框组件
- 后端：控制台输出 + API接口获取日志
- 支持复制日志、清空日志

## 技术栈

- 前端：React 19 + Umi 4 + Ant Design Pro 5 + TypeScript
- 后端：Node.js 20+ + Express + Socket.io 4
- 手机App：Kotlin + Android SDK 34

