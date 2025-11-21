import { Socket, Server } from 'socket.io';
import { logger } from '../../utils/logger';
import { DeviceService } from '../device/device-service';
import { DataService } from '../data/data-service';

export interface WebSocketMessage {
  type: string;
  deviceId?: string;
  data?: any;
  timestamp?: number;
}

export class WebSocketHandler {
  private deviceService: DeviceService;
  private dataService?: DataService;
  private io?: Server;
  private frontendSockets: Map<string, Socket> = new Map();
  private deviceSockets: Map<string, Socket> = new Map();

  constructor(deviceService: DeviceService) {
    this.deviceService = deviceService;
  }

  setIO(io: Server) {
    this.io = io;
  }

  setDataService(dataService: DataService) {
    this.dataService = dataService;
  }

  // 处理前端连接
  handleFrontendConnection(socket: Socket) {
    const clientId = socket.id;
    this.frontendSockets.set(clientId, socket);
    logger.info(`前端客户端连接: ${clientId}`, 'WebSocket');

    // 发送设备列表
    this.sendDeviceList(socket);

    // 监听消息
    socket.on('message', (msg: WebSocketMessage) => {
      this.handleFrontendMessage(socket, msg);
    });

    // 监听断开
    socket.on('disconnect', () => {
      this.frontendSockets.delete(clientId);
      logger.info(`前端客户端断开: ${clientId}`, 'WebSocket');
    });

    // 订阅设备
    socket.on('subscribe_device', (deviceId: string) => {
      logger.info(`前端订阅设备: ${deviceId}`, 'WebSocket');
      socket.join(`device:${deviceId}`);
    });

    // 取消订阅设备
    socket.on('unsubscribe_device', (deviceId: string) => {
      logger.info(`前端取消订阅设备: ${deviceId}`, 'WebSocket');
      socket.leave(`device:${deviceId}`);
    });
  }

  // 处理设备连接
  handleDeviceConnection(socket: Socket, deviceId: string) {
    this.deviceSockets.set(deviceId, socket);
    logger.info(`设备连接: ${deviceId}`, 'WebSocket');

    // 更新设备状态
    this.deviceService.updateDeviceStatus(deviceId, 'online');

    // 监听消息
    socket.on('message', (msg: WebSocketMessage) => {
      this.handleDeviceMessage(deviceId, msg);
    });

    // 监听断开
    socket.on('disconnect', () => {
      this.deviceSockets.delete(deviceId);
      this.deviceService.updateDeviceStatus(deviceId, 'offline');
      logger.info(`设备断开: ${deviceId}`, 'WebSocket');
    });

    // 设备注册
    socket.on('register', (data: any) => {
      this.deviceService.registerDevice(deviceId, data);
      logger.info(`设备注册: ${deviceId}`, 'WebSocket');
    });

    // 屏幕画面
    socket.on('screen_frame', (data: any) => {
      this.broadcastToFrontend(deviceId, {
        type: 'screen_frame',
        deviceId,
        data,
        timestamp: Date.now(),
      });
    });

    // 采集数据
    socket.on('captured_data', (data: any) => {
      // 保存数据
      if (this.dataService) {
        this.dataService.saveData(deviceId, data.type || 'unknown', data);
      }
      
      // 广播给前端
      this.broadcastToFrontend(deviceId, {
        type: 'captured_data',
        deviceId,
        data,
        timestamp: Date.now(),
      });
    });
  }

  // 处理前端消息
  private handleFrontendMessage(socket: Socket, msg: WebSocketMessage) {
    logger.info(`收到前端消息: ${JSON.stringify(msg)}`, 'WebSocket');

    if (!msg.deviceId) {
      socket.emit('error', { message: '缺少deviceId' });
      return;
    }

    const deviceSocket = this.deviceSockets.get(msg.deviceId);
    if (!deviceSocket) {
      socket.emit('error', { message: '设备未连接' });
      return;
    }

    // 转发消息给设备
    deviceSocket.emit('message', msg);
    logger.info(`消息已转发给设备: ${msg.deviceId}`, 'WebSocket');
  }

  // 处理设备消息
  private handleDeviceMessage(deviceId: string, msg: WebSocketMessage) {
    logger.info(`收到设备消息: ${deviceId} - ${JSON.stringify(msg)}`, 'WebSocket');
    // 转发给订阅该设备的前端
    this.broadcastToFrontend(deviceId, {
      ...msg,
      deviceId,
      timestamp: Date.now(),
    });
  }

  // 发送设备列表给前端
  private sendDeviceList(socket: Socket) {
    const devices = this.deviceService.getDevices();
    socket.emit('device_list', { devices });
  }

  // 广播给订阅设备的前端
  private broadcastToFrontend(deviceId: string, message: WebSocketMessage) {
    if (this.io) {
      const room = `device:${deviceId}`;
      this.io.to(room).emit('message', message);
      logger.info(`广播消息给设备 ${deviceId} 的订阅者`, 'WebSocket');
    }
  }

  // 发送控制指令给设备
  sendCommandToDevice(deviceId: string, command: any) {
    const deviceSocket = this.deviceSockets.get(deviceId);
    if (deviceSocket) {
      deviceSocket.emit('command', command);
      logger.info(`发送指令给设备: ${deviceId}`, 'WebSocket');
      return true;
    }
    logger.warn(`设备未连接: ${deviceId}`, 'WebSocket');
    return false;
  }

  // 获取所有连接的设备
  getConnectedDevices(): string[] {
    return Array.from(this.deviceSockets.keys());
  }
}

