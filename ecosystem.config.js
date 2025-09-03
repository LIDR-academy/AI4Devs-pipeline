module.exports = {
  apps: [
    {
      name: 'backend-app',
      script: './backend/dist/index.js',
      cwd: '/home/ec2-user/app', // Cambiar por el usuario correspondiente (ubuntu si es Ubuntu)
      instances: 1,
      exec_mode: 'fork',
      
      // Variables de entorno
      env: {
        NODE_ENV: 'production',
        PORT: 8080
      },
      
      // Configuración de logs
      log_file: './logs/app.log',
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      
      // Configuración de reinicio automático
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      
      // Configuración de reinicio en caso de error
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000,
      
      // Configuración de tiempo de espera
      kill_timeout: 5000,
      listen_timeout: 3000,
      
      // Configuración adicional
      merge_logs: true,
      time: true,
      
      // Script de post-deploy (opcional)
      post_update: ['npm install --production', 'npx prisma generate'],
      
      // Variables de entorno específicas para producción
      env_production: {
        NODE_ENV: 'production',
        PORT: 8080,
        PM2_SERVE_PATH: './backend/dist',
        PM2_SERVE_PORT: 8080,
        PM2_SERVE_SPA: false,
        PM2_SERVE_HOMEPAGE: '/health'
      }
    }
  ],
  
  // Configuración de despliegue (opcional para uso con pm2 deploy)
  deploy: {
    production: {
      user: 'ec2-user', // Cambiar por 'ubuntu' si es Ubuntu
      host: ['your-ec2-host.amazonaws.com'], // Reemplazar con tu host real
      ref: 'origin/main',
      repo: 'git@github.com:your-username/your-repo.git', // Reemplazar con tu repo
      path: '/home/ec2-user/app',
      'post-deploy': 'npm install --production && npx prisma generate && pm2 reload ecosystem.config.js --env production && pm2 save'
    }
  }
};
