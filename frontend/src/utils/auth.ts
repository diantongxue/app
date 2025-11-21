// 认证工具函数

export const isAuthenticated = (): boolean => {
  return localStorage.getItem('isAuthenticated') === 'true';
};

export const getUsername = (): string | null => {
  return localStorage.getItem('username');
};

export const login = (username: string): void => {
  localStorage.setItem('isAuthenticated', 'true');
  localStorage.setItem('username', username);
};

export const logout = (): void => {
  localStorage.removeItem('isAuthenticated');
  localStorage.removeItem('username');
};
