import React, { useState, useEffect } from 'react';
import { PageContainer } from '@ant-design/pro-components';
import { Row, Col } from 'antd';
import { useParams } from 'react-router-dom';
import LogViewer, { LogEntry } from '@/components/LogViewer';
import ScreenViewer from '@/components/ScreenViewer';
import ControlPanel from '@/components/ControlPanel';
import OperationHistory from '@/components/OperationHistory';
import { logger } from '@/utils/logger';
import { wsService } from '@/services/websocket';

const DeviceControl: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [logs, setLogs] = useState<LogEntry[]>([]);

  useEffect(() => {
    if (!id) return;

    // 订阅日志
    const unsubscribe = logger.subscribe((newLogs) => {
      setLogs(newLogs);
    });

    // 连接WebSocket
    if (!wsService.isConnected()) {
      wsService.connect();
    }

    logger.info(`进入设备控制页面，设备ID: ${id}`);
    logger.info('正在连接设备...');

    return () => {
      unsubscribe();
    };
  }, [id]);

  const handleScreenClick = (x: number, y: number) => {
    logger.info(`屏幕点击: (${x}, ${y})`);
  };

  if (!id) {
    return <PageContainer title="远程控制">设备ID不存在</PageContainer>;
  }

  return (
    <PageContainer title={`远程控制 - 设备 ${id}`}>
      <Row gutter={16}>
        <Col span={16}>
          <ScreenViewer deviceId={id} />
        </Col>
        <Col span={8}>
          <ControlPanel deviceId={id} onScreenClick={handleScreenClick} />
        </Col>
      </Row>
      
      <div style={{ marginTop: 24 }}>
        <Row gutter={16}>
          <Col span={12}>
            <LogViewer 
              logs={logs} 
              title="控制日志"
              onClear={() => logger.clearLogs()}
            />
          </Col>
          <Col span={12}>
            <OperationHistory deviceId={id} />
          </Col>
        </Row>
      </div>
    </PageContainer>
  );
};

export default DeviceControl;

