import React, { useEffect, useRef, useState } from 'react';
import { Card, Button, Space, Typography, message as antdMessage } from 'antd';
import { CopyOutlined, ClearOutlined } from '@ant-design/icons';
import './index.less';

const { Text } = Typography;

export interface LogEntry {
  timestamp: string;
  level: 'info' | 'warn' | 'error';
  message: string;
}

interface LogViewerProps {
  logs: LogEntry[];
  title?: string;
  height?: number;
  onClear?: () => void;
}

const LogViewer: React.FC<LogViewerProps> = ({ 
  logs, 
  title = '日志', 
  height = 400,
  onClear
}) => {
  const logContainerRef = useRef<HTMLDivElement>(null);
  const [autoScroll, setAutoScroll] = useState(true);

  // 自动滚动到底部
  useEffect(() => {
    if (autoScroll && logContainerRef.current) {
      logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
    }
  }, [logs, autoScroll]);

  // 处理滚动事件
  const handleScroll = () => {
    if (logContainerRef.current) {
      const { scrollTop, scrollHeight, clientHeight } = logContainerRef.current;
      // 如果滚动到底部附近，启用自动滚动
      setAutoScroll(scrollHeight - scrollTop - clientHeight < 50);
    }
  };

  // 复制所有日志
  const handleCopy = async () => {
    const logText = logs
      .map(log => `[${log.timestamp}] [${log.level.toUpperCase()}] ${log.message}`)
      .join('\n');
    
    try {
      await navigator.clipboard.writeText(logText);
      antdMessage.success('日志已复制到剪贴板');
    } catch (err) {
      antdMessage.error('复制失败，请手动复制');
    }
  };

  // 清空日志
  const handleClear = () => {
    if (onClear) {
      onClear();
      antdMessage.success('日志已清空');
    } else {
      antdMessage.warning('未提供清空回调函数');
    }
  };

  const getLevelColor = (level: string) => {
    switch (level) {
      case 'error':
        return '#ff4d4f';
      case 'warn':
        return '#faad14';
      case 'info':
      default:
        return '#1890ff';
    }
  };

  return (
    <Card
      title={title}
      extra={
        <Space>
          <Button
            icon={<CopyOutlined />}
            size="small"
            onClick={handleCopy}
          >
            复制
          </Button>
          <Button
            icon={<ClearOutlined />}
            size="small"
            danger
            onClick={handleClear}
          >
            清空
          </Button>
        </Space>
      }
    >
      <div
        ref={logContainerRef}
        className="log-viewer-container"
        style={{ height: `${height}px` }}
        onScroll={handleScroll}
      >
        {logs.length === 0 ? (
          <div className="log-empty">暂无日志</div>
        ) : (
          logs.map((log, index) => (
            <div key={index} className="log-entry">
              <Text type="secondary" style={{ fontSize: '12px' }}>
                [{log.timestamp}]
              </Text>
              <Text
                strong
                style={{
                  color: getLevelColor(log.level),
                  marginLeft: '8px',
                  marginRight: '8px',
                }}
              >
                [{log.level.toUpperCase()}]
              </Text>
              <Text>{log.message}</Text>
            </div>
          ))
        )}
      </div>
    </Card>
  );
};

export default LogViewer;

