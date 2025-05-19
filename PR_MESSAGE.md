# Pipeline CI/CD para Backend - Entrega Final

## 🎯 Objetivo
Implementación de un pipeline completo de CI/CD en GitHub Actions para automatizar las pruebas, build y despliegue de un backend Node.js en AWS EC2.

## 🔄 Flujo del Pipeline
El pipeline se activa en dos situaciones:
1. Al crear/actualizar un Pull Request
2. Al hacer push a cualquier rama

### Pipeline Steps:
1. **Job: Pruebas de Backend**
   - ✅ Configuración de PostgreSQL para testing
   - ✅ Configuración de Node.js 18
   - ✅ Instalación de dependencias
   - ✅ Migraciones de Prisma
   - ✅ Ejecución de pruebas

2. **Job: Build y Despliegue**
   - ✅ Generación del build
   - ✅ Configuración de SSH para EC2
   - ✅ Transferencia de archivos
   - ✅ Despliegue con PM2
   - ✅ Manejo automático de dependencias (pm2)

## 🔐 Seguridad
Se han configurado todos los secretos necesarios en GitHub:
- AWS_ACCESS_ID
- AWS_ACCESS_KEY
- EC2_INSTANCE
- EC2_SSH_PRIVATE_KEY
- EC2_USER

## 📝 Documentación
- Pipeline configurado en `.github/workflows/pipeline.yml`
- Prompts documentados en `prompts/prompts-ACBG.md`

## ✨ Mejoras Implementadas
1. Instalación automática de pm2 si no está presente
2. Manejo robusto de errores en el despliegue
3. Limpieza automática de despliegues anteriores
4. Configuración de variables de entorno segura

## 🧪 Testing
El pipeline incluye pruebas automatizadas que:
- Utilizan PostgreSQL como base de datos
- Ejecutan migraciones de Prisma
- Validan la funcionalidad del backend

## 🚀 Instrucciones de Uso
1. Crear un PR o hacer push a una rama
2. El pipeline se ejecutará automáticamente
3. Verificar el progreso en la pestaña "Actions"
4. Una vez completado, la aplicación estará desplegada en EC2

## 🔍 Validación
- ✅ Pipeline ejecutado exitosamente
- ✅ Pruebas pasando
- ✅ Despliegue funcionando
- ✅ Documentación completa 