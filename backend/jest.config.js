module.exports = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    testMatch: ['**/src/**/*.test.ts'],
    collectCoverageFrom: [
        'src/**/*.ts',
        '!src/**/*.test.ts',
        '!src/**/*.spec.ts'
    ],
    coverageDirectory: 'coverage',
    coverageReporters: ['text', 'lcov', 'html']
  };