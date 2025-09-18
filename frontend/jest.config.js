module.exports = {
  // Entorno de pruebas
  testEnvironment: 'jsdom',
  
  // Archivos de configuración de pruebas
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
  
  // Patrones de archivos de prueba
  testMatch: [
    '<rootDir>/src/**/__tests__/**/*.{js,jsx,ts,tsx}',
    '<rootDir>/src/**/*.(test|spec).{js,jsx,ts,tsx}'
  ],
  
  // Extensiones de archivos que Jest debe procesar
  moduleFileExtensions: ['js', 'jsx', 'ts', 'tsx', 'json'],
  
  // Transformaciones para diferentes tipos de archivos
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest',
    '^.+\\.css$': 'jest-transform-css',
    '^(?!.*\\.(js|jsx|ts|tsx|css|json)$)': 'jest-transform-file'
  },
  
  // Módulos que no deben ser transformados
  transformIgnorePatterns: [
    'node_modules/(?!(react-beautiful-dnd|@babel/runtime)/)'
  ],
  
  // Mapeo de rutas para módulos
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
    '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$': 'jest-transform-file'
  },
  
  // Configuración de cobertura
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.tsx',
    '!src/reportWebVitals.ts'
  ],
  
  // Umbral de cobertura
  coverageThreshold: {
    global: {
      branches: 50,
      functions: 50,
      lines: 50,
      statements: 50
    }
  },
  
  // Directorio de reportes de cobertura
  coverageDirectory: 'coverage',
  
  // Reportes de cobertura
  coverageReporters: ['text', 'lcov', 'html'],
  
  // Directorios a ignorar
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/build/',
    '<rootDir>/cypress/'
  ],
  
  // Variables de entorno para las pruebas
  testEnvironmentOptions: {
    url: 'http://localhost'
  }
};