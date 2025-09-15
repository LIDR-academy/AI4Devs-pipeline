module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3010/'],
      startServerCommand: 'npm start',
      startServerReadyPattern: 'Server is running',
      startServerReadyTimeout: 30000,
      numberOfRuns: 1,
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.7 }],
        'categories:accessibility': ['warn', { minScore: 0.8 }],
        'categories:best-practices': ['warn', { minScore: 0.7 }],
        'categories:seo': ['warn', { minScore: 0.7 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
