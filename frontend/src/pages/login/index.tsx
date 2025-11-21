import React, { useState, useEffect } from 'react';
import { Form, Input, Button, Card, message } from 'antd';
import { UserOutlined, LockOutlined, LoginOutlined } from '@ant-design/icons';
import { history } from '@umijs/max';
import { isAuthenticated } from '@/utils/auth';
import './index.less';

const LoginPage: React.FC = () => {
  const [loading, setLoading] = useState(false);

  // 如果已登录，跳转到首页
  useEffect(() => {
    if (isAuthenticated()) {
      history.push('/device/list');
    }
  }, []);

  // 生成粒子样式
  useEffect(() => {
    const style = document.createElement('style');
    let css = '';
    for (let i = 1; i <= 50; i++) {
      const left = Math.random() * 100;
      const top = Math.random() * 100;
      const delay = Math.random() * 15;
      const duration = 10 + Math.random() * 10;
      css += `.particle:nth-child(${i}) {
        left: ${left}%;
        top: ${top}%;
        animation-delay: ${delay}s;
        animation-duration: ${duration}s;
      }`;
    }
    style.textContent = css;
    document.head.appendChild(style);
    return () => {
      document.head.removeChild(style);
    };
  }, []);

  const onFinish = async (values: { username: string; password: string }) => {
    setLoading(true);
    try {
      // 简单的认证逻辑
      if (values.username === 'admin' && values.password === '123') {
        // 保存登录状态
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('username', values.username);
        message.success('登录成功！');
        // 延迟跳转，让用户看到成功消息
        setTimeout(() => {
          history.push('/device/list');
        }, 500);
      } else {
        message.error('用户名或密码错误！');
      }
    } catch (error) {
      message.error('登录失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-background">
        <div className="login-particles">
          {Array.from({ length: 50 }).map((_, i) => (
            <div key={i} className="particle" />
          ))}
        </div>
      </div>
      <Card className="login-card">
        <div className="login-header">
          <div className="login-logo">
            <div className="logo-icon">
              <UserOutlined />
            </div>
            <h1>手机App远程控制系统</h1>
            <p>Mobile App Remote Control System</p>
          </div>
        </div>
        <Form
          name="login"
          onFinish={onFinish}
          autoComplete="off"
          size="large"
        >
          <Form.Item
            name="username"
            rules={[{ required: true, message: '请输入用户名!' }]}
          >
            <Input
              prefix={<UserOutlined className="input-icon" />}
              placeholder="用户名"
              className="login-input"
            />
          </Form.Item>
          <Form.Item
            name="password"
            rules={[{ required: true, message: '请输入密码!' }]}
          >
            <Input.Password
              prefix={<LockOutlined className="input-icon" />}
              placeholder="密码"
              className="login-input"
            />
          </Form.Item>
          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              loading={loading}
              block
              className="login-button"
              icon={<LoginOutlined />}
            >
              登录
            </Button>
          </Form.Item>
        </Form>
        <div className="login-footer">
          <p>默认账号：admin / 123</p>
        </div>
      </Card>
    </div>
  );
};

export default LoginPage;
