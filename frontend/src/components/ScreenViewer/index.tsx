import React, { useEffect, useRef, useState } from 'react';
import { Card, Button, Space } from 'antd';
import { FullscreenOutlined, ReloadOutlined } from '@ant-design/icons';
import { wsService } from '@/services/websocket';
import { logger } from '@/utils/logger';
import './index.less';

interface ScreenViewerProps {
  deviceId: string;
}

const ScreenViewer: React.FC<ScreenViewerProps> = ({ deviceId }) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [screenSize, setScreenSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    if (!deviceId) return;

    logger.info(`初始化屏幕显示，设备ID: ${deviceId}`);

    // 订阅设备
    wsService.subscribeDevice(deviceId);

    // 监听屏幕画面
    const unsubscribe = wsService.on('screen_frame', (message: any) => {
      if (message.deviceId === deviceId && message.data) {
        renderScreen(message.data);
      }
    });

    return () => {
      unsubscribe();
      wsService.unsubscribeDevice(deviceId);
    };
  }, [deviceId]);

  // 渲染屏幕画面
  const renderScreen = (imageData: string) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const img = new Image();
    img.onload = () => {
      // 设置canvas尺寸
      if (screenSize.width === 0 || screenSize.height === 0) {
        setScreenSize({ width: img.width, height: img.height });
        canvas.width = img.width;
        canvas.height = img.height;
      }
      ctx.drawImage(img, 0, 0);
    };
    img.src = imageData; // 假设是base64格式
  };

  // 全屏
  const handleFullscreen = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    if (!isFullscreen) {
      canvas.requestFullscreen?.();
      setIsFullscreen(true);
    } else {
      document.exitFullscreen?.();
      setIsFullscreen(false);
    }
  };

  // 刷新
  const handleRefresh = () => {
    logger.info('刷新屏幕画面');
    // 请求新的画面
    wsService.sendCommand(deviceId, { type: 'request_screen' });
  };

  return (
    <Card
      title="屏幕显示"
      extra={
        <Space>
          <Button
            icon={<ReloadOutlined />}
            size="small"
            onClick={handleRefresh}
          >
            刷新
          </Button>
          <Button
            icon={<FullscreenOutlined />}
            size="small"
            onClick={handleFullscreen}
          >
            全屏
          </Button>
        </Space>
      }
    >
      <div className="screen-viewer-container">
        <canvas
          ref={canvasRef}
          className="screen-canvas"
          style={{
            maxWidth: '100%',
            height: 'auto',
            border: '1px solid #ddd',
            backgroundColor: '#000',
          }}
        />
        {screenSize.width === 0 && (
          <div className="screen-placeholder">
            等待屏幕画面...
          </div>
        )}
      </div>
    </Card>
  );
};

export default ScreenViewer;

