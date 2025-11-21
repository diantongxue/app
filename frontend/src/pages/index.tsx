import React from 'react';
import { PageContainer } from '@ant-design/pro-components';
import { Card, Row, Col, Statistic, Button } from 'antd';
import { 
  MobileOutlined, 
  DatabaseOutlined, 
  ControlOutlined,
  ArrowRightOutlined 
} from '@ant-design/icons';

const HomePage: React.FC = () => {
  return (
    <PageContainer
      title="手机App远程控制系统"
      subTitle="欢迎使用设备管理和数据采集系统"
    >
      <Row gutter={[16, 16]}>
        <Col xs={24} sm={12} lg={8}>
          <Card
            hoverable
            onClick={() => window.location.href = '/device/list'}
            style={{ cursor: 'pointer' }}
          >
            <Statistic
              title="设备管理"
              value={0}
              prefix={<MobileOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
            <div style={{ marginTop: 16 }}>
              <Button 
                type="link" 
                icon={<ArrowRightOutlined />}
                onClick={(e) => {
                  e.stopPropagation();
                  window.location.href = '/device/list';
                }}
              >
                进入设备管理
              </Button>
            </div>
          </Card>
        </Col>

        <Col xs={24} sm={12} lg={8}>
          <Card
            hoverable
            onClick={() => window.location.href = '/data/list'}
            style={{ cursor: 'pointer' }}
          >
            <Statistic
              title="数据采集"
              value={0}
              prefix={<DatabaseOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
            <div style={{ marginTop: 16 }}>
              <Button 
                type="link" 
                icon={<ArrowRightOutlined />}
                onClick={(e) => {
                  e.stopPropagation();
                  window.location.href = '/data/list';
                }}
              >
                进入数据采集
              </Button>
            </div>
          </Card>
        </Col>

        <Col xs={24} sm={12} lg={8}>
          <Card
            hoverable
            onClick={() => window.location.href = '/data/visualization'}
            style={{ cursor: 'pointer' }}
          >
            <Statistic
              title="数据可视化"
              value={0}
              prefix={<ControlOutlined />}
              valueStyle={{ color: '#722ed1' }}
            />
            <div style={{ marginTop: 16 }}>
              <Button 
                type="link" 
                icon={<ArrowRightOutlined />}
                onClick={(e) => {
                  e.stopPropagation();
                  window.location.href = '/data/visualization';
                }}
              >
                进入数据可视化
              </Button>
            </div>
          </Card>
        </Col>
      </Row>

      <Card 
        title="系统功能" 
        style={{ marginTop: 24 }}
      >
        <Row gutter={[16, 16]}>
          <Col xs={24} md={12}>
            <h3>设备管理</h3>
            <ul>
              <li>查看在线设备列表</li>
              <li>远程控制设备</li>
              <li>实时监控设备状态</li>
              <li>设备日志查看</li>
            </ul>
          </Col>
          <Col xs={24} md={12}>
            <h3>数据采集</h3>
            <ul>
              <li>数据列表查看</li>
              <li>数据统计分析</li>
              <li>数据可视化展示</li>
              <li>数据导出功能</li>
            </ul>
          </Col>
        </Row>
      </Card>
    </PageContainer>
  );
};

export default HomePage;
