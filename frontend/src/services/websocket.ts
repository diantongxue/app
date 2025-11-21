import { io, Socket } from 'socket.io-client';
import { logger } from '@/utils/logger';

export interface WebSocketMessage {
  type: string;
  deviceId?: string;
  data?: any;
  timestamp?: number;
}

class WebSocketService {
  private socket: Socket | null = null;
  private url: string;
  private listeners: Map<string, Set<(data: any) => void>> = new Map();

  constructor(url: string = 'http://localhost:3001') {
    this.url = url;
  }

  // 连接
  connect() {
    if (this.socket?.connected) {
      logger.warn('WebSocket已连接');
      return;
    }

    // 延迟logger调用，避免在初始化时触发状态更新
    setTimeout(() => {
    logger.info(`正在连接WebSocket: ${this.url}`);
    }, 0);

    this.socket = io(this.url, {
      transports: ['websocket', 'polling'],
    });

    this.socket.on('connect', () => {
      setTimeout(() => {
      logger.info('WebSocket连接成功');
      }, 0);
    });

    this.socket.on('disconnect', () => {
      setTimeout(() => {
      logger.warn('WebSocket连接断开');
      }, 0);
    });

    this.socket.on('connect_error', (error) => {
      setTimeout(() => {
      logger.error(`WebSocket连接错误: ${error.message}`);
      }, 0);
    });

    // 监听服务器消息
    this.socket.on('message', (message: WebSocketMessage) => {
      this.handleMessage(message);
    });

    // 监听设备列表更新
    this.socket.on('device_list', (data: any) => {
      this.emit('device_list', data);
    });
  }

  // 断开连接
  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
      logger.info('WebSocket已断开');
    }
  }

  // 发送消息
  send(message: WebSocketMessage) {
    if (this.socket?.connected) {
      this.socket.emit('message', message);
      logger.info(`发送消息: ${message.type}`);
    } else {
      logger.error('WebSocket未连接');
    }
  }

  // 订阅设备
  subscribeDevice(deviceId: string) {
    if (this.socket?.connected) {
      this.socket.emit('subscribe_device', deviceId);
      logger.info(`订阅设备: ${deviceId}`);
    }
  }

  // 取消订阅设备
  unsubscribeDevice(deviceId: string) {
    if (this.socket?.connected) {
      this.socket.emit('unsubscribe_device', deviceId);
      logger.info(`取消订阅设备: ${deviceId}`);
    }
  }

  // 处理消息
  private handleMessage(message: WebSocketMessage) {
    const listeners = this.listeners.get(message.type);
    if (listeners) {
      listeners.forEach(listener => listener(message));
    }
  }

  // 监听消息
  on(type: string, callback: (data: any) => void) {
    if (!this.listeners.has(type)) {
      this.listeners.set(type, new Set());
    }
    this.listeners.get(type)!.add(callback);

    // 返回取消监听的函数
    return () => {
      const listeners = this.listeners.get(type);
      if (listeners) {
        listeners.delete(callback);
      }
    };
  }

  // 触发事件
  private emit(type: string, data: any) {
    const listeners = this.listeners.get(type);
    if (listeners) {
      listeners.forEach(listener => listener(data));
    }
  }

  // 发送控制指令
  sendCommand(deviceId: string, command: { type: string; [key: string]: any }) {
    this.send({
      type: 'command',
      deviceId,
      data: command,
      timestamp: Date.now(),
    });
  }

  // 获取连接状态
  isConnected(): boolean {
    return this.socket?.connected || false;
  }
}

// 创建单例
export const wsService = new WebSocketService();

