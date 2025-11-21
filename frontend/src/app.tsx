import React from 'react';
import { ConfigProvider, App } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import './global.less';

export const rootContainer = (container: any) => {
  return (
    <ConfigProvider
      locale={zhCN}
      theme={{
        token: {
          colorPrimary: '#3979FE',
          colorBgContainer: 'rgba(15, 25, 45, 0.95)',
          colorBgElevated: 'rgba(15, 25, 45, 0.95)',
          colorBorder: 'rgba(57, 121, 254, 0.3)',
          colorText: '#ffffff',
          colorTextSecondary: 'rgba(255, 255, 255, 0.6)',
          borderRadius: 8,
        },
        components: {
          Layout: {
            bodyBg: 'transparent',
            headerBg: 'rgba(15, 25, 45, 0.95)',
            siderBg: 'rgba(15, 25, 45, 0.95)',
          },
          Menu: {
            itemBg: 'transparent',
            itemHoverBg: 'rgba(57, 121, 254, 0.1)',
            itemSelectedBg: 'rgba(57, 121, 254, 0.2)',
            itemActiveBg: 'rgba(57, 121, 254, 0.15)',
          },
          Card: {
            headerBg: 'transparent',
            actionsBg: 'transparent',
          },
        },
      }}
    >
      <App>
      {container}
      </App>
    </ConfigProvider>
  );
};

