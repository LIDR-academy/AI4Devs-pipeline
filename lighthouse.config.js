module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3010/'],
      startServerCommand: 'docker run -d --name lti-backend-test -p 3010:3010 --env-file /home/ec2-user/lti-backend/.env --network host ${{ needs.build.outputs.image }}',
      startServerReadyPattern: 'Server is running',
      startServerReadyTimeout: 30000,
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.8 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'categories:best-practices': ['warn', { minScore: 0.8 }],
        'categories:seo': ['warn', { minScore: 0.8 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
