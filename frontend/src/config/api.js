const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3010';

export const apiUrl = (path) => {
  const normalizedBaseUrl = API_BASE_URL.replace(/\/$/, '');
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;

  return `${normalizedBaseUrl}${normalizedPath}`;
};
