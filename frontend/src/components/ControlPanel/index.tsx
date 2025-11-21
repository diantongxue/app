import React, { useState } from 'react';
import { Card, Button, Space, Input, Slider, Row, Col } from 'antd';
import { wsService } from '@/services/websocket';
import { logger } from '@/utils/logger';
import './index.less';

interface ControlPanelProps {
  deviceId: string;
  onScreenClick?: (x: number, y: number) => void;
}

const ControlPanel: React.FC<ControlPanelProps> = ({ deviceId }) => {
  const [inputText, setInputText] = useState('');
  const [swipeDuration, setSwipeDuration] = useState(500);

  // 发送滑动指令
  const handleSwipe = (startX: number, startY: number, endX: number, endY: number) => {
    logger.info(`滑动: (${startX}, ${startY}) -> (${endX}, ${endY})`);
    wsService.sendCommand(deviceId, {
      type: 'swipe',
      startX,
      startY,
      endX,
      endY,
      duration: swipeDuration,
    });
  };

  // 发送文本输入
  const handleInput = () => {
    if (!inputText) {
      logger.warn('输入文本为空');
      return;
    }
    logger.info(`输入文本: ${inputText}`);
    wsService.sendCommand(deviceId, {
      type: 'input',
      text: inputText,
    });
    setInputText('');
  };

  // 返回
  const handleBack = () => {
    logger.info('返回');
    wsService.sendCommand(deviceId, {
      type: 'back',
    });
  };

  // 主页
  const handleHome = () => {
    logger.info('主页');
    wsService.sendCommand(deviceId, {
      type: 'home',
    });
  };

  // 最近任务
  const handleRecent = () => {
    logger.info('最近任务');
    wsService.sendCommand(deviceId, {
      type: 'recent',
    });
  };

  return (
    <Card title="控制面板">
      <Space direction="vertical" style={{ width: '100%' }} size="large">
        {/* 系统按键 */}
        <Row gutter={16}>
          <Col span={8}>
            <Button block onClick={handleBack}>
              返回
            </Button>
          </Col>
          <Col span={8}>
            <Button block onClick={handleHome}>
              主页
            </Button>
          </Col>
          <Col span={8}>
            <Button block onClick={handleRecent}>
              最近任务
            </Button>
          </Col>
        </Row>

        {/* 文本输入 */}
        <div>
          <Input.Group compact>
            <Input
              style={{ width: 'calc(100% - 80px)' }}
              placeholder="输入文本"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              onPressEnter={handleInput}
            />
            <Button type="primary" onClick={handleInput}>
              发送
            </Button>
          </Input.Group>
        </div>

        {/* 滑动设置 */}
        <div>
          <div>滑动时长: {swipeDuration}ms</div>
          <Slider
            min={100}
            max={2000}
            step={100}
            value={swipeDuration}
            onChange={setSwipeDuration}
          />
        </div>

        {/* 快捷操作 */}
        <div>
          <div style={{ marginBottom: 8 }}>快捷操作:</div>
          <Space wrap>
            <Button
              onClick={() => handleSwipe(500, 1000, 500, 500)}
              size="small"
            >
              向上滑动
            </Button>
            <Button
              onClick={() => handleSwipe(500, 500, 500, 1000)}
              size="small"
            >
              向下滑动
            </Button>
            <Button
              onClick={() => handleSwipe(100, 500, 900, 500)}
              size="small"
            >
              向右滑动
            </Button>
            <Button
              onClick={() => handleSwipe(900, 500, 100, 500)}
              size="small"
            >
              向左滑动
            </Button>
          </Space>
        </div>
      </Space>
    </Card>
  );
};

export default ControlPanel;

