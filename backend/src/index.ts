import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import { logger } from './utils/logger';
import { WebSocketHandler } from './services/websocket/handler';
import { DeviceService } from './services/device/device-service';
import { DataService } from './services/data/data-service';
import { DeviceConnectionManager } from './services/adb/device-connection';
import deviceRoutes from './api/device';
import dataRoutes from './api/data';
import operationRoutes from './api/operation';
import { OperationService } from './services/operation/operation-service';

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

const PORT = process.env.PORT || 3001;

// 初始化服务
const deviceService = new DeviceService();
const dataService = new DataService();
const operationService = new OperationService();
const deviceConnectionManager = new DeviceConnectionManager(deviceService);
const wsHandler = new WebSocketHandler(deviceService);
wsHandler.setIO(io);
wsHandler.setDataService(dataService);

// 初始化设备连接管理
deviceConnectionManager.initialize().then(success => {
  if (success) {
    logger.info('设备连接管理器初始化成功', 'Server');
  }
});

// 中间件
app.use(cors());
app.use(express.json());

// 日志中间件
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, 'HTTP');
  next();
});

// REST API 路由
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/logs', (req, res) => {
  res.json({ logs: logger.getLogs() });
});

app.post('/api/logs/clear', (req, res) => {
  logger.clearLogs();
  res.json({ success: true });
});

// 设备管理API
app.use('/api/device', deviceRoutes(deviceService, wsHandler, operationService, deviceConnectionManager));
// 数据管理API
app.use('/api/data', dataRoutes(dataService));
// 操作日志API
app.use('/api/operation', operationRoutes(operationService));

// WebSocket 连接处理
io.on('connection', (socket) => {
  // 判断连接类型
  const deviceId = socket.handshake.query.deviceId as string;
  
  if (deviceId) {
    // 设备连接
    wsHandler.handleDeviceConnection(socket, deviceId);
  } else {
    // 前端连接
    wsHandler.handleFrontendConnection(socket);
  }
});

// 启动服务器
httpServer.listen(PORT, () => {
  logger.info(`服务器启动成功，端口: ${PORT}`, 'Server');
  logger.info(`WebSocket服务: ws://localhost:${PORT}`, 'Server');
  logger.info(`HTTP API: http://localhost:${PORT}/api`, 'Server');
});

