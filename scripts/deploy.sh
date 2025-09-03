#!/bin/bash

# Script de despliegue para automatizar tareas en EC2
# Este script es opcional y puede ser usado como referencia o para despliegues manuales

set -e  # Salir en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
APP_DIR="/home/ec2-user/app"
BACKEND_DIR="$APP_DIR/backend"
LOG_FILE="$APP_DIR/deploy.log"

# Función para logging
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Función para crear backup
create_backup() {
    log "Creando backup del despliegue actual..."
    
    if [ -d "$BACKEND_DIR" ]; then
        BACKUP_DIR="$APP_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        cp -r "$BACKEND_DIR" "$BACKUP_DIR"
        success "Backup creado en: $BACKUP_DIR"
    else
        warning "No existe despliegue previo para hacer backup"
    fi
}

# Función para limpiar backups antiguos
cleanup_backups() {
    log "Limpiando backups antiguos..."
    
    cd "$APP_DIR"
    # Mantener solo los últimos 3 backups
    ls -t backup-* 2>/dev/null | tail -n +4 | xargs -r rm -rf
    
    success "Limpieza de backups completada"
}

# Función para verificar dependencias del sistema
check_system_dependencies() {
    log "Verificando dependencias del sistema..."
    
    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js no está instalado"
    fi
    
    # Verificar npm
    if ! command -v npm &> /dev/null; then
        error "npm no está instalado"
    fi
    
    # Verificar PM2
    if ! command -v pm2 &> /dev/null; then
        log "PM2 no está instalado, instalando..."
        npm install -g pm2
    fi
    
    success "Dependencias del sistema verificadas"
}

# Función para instalar dependencias de la aplicación
install_dependencies() {
    log "Instalando dependencias de la aplicación..."
    
    cd "$BACKEND_DIR"
    
    # Instalar dependencias de producción
    npm ci --only=production --prefer-offline --no-audit
    
    # Generar cliente de Prisma
    npx prisma generate
    
    success "Dependencias instaladas correctamente"
}

# Función para configurar variables de entorno
setup_environment() {
    log "Configurando variables de entorno..."
    
    cd "$BACKEND_DIR"
    
    # Verificar que DATABASE_URL esté configurada
    if [ -z "$DATABASE_URL" ]; then
        error "La variable DATABASE_URL no está configurada"
    fi
    
    # Crear archivo .env
    cat > .env << EOL
DATABASE_URL="$DATABASE_URL"
NODE_ENV=production
PORT=8080
EOL
    
    success "Variables de entorno configuradas"
}

# Función para iniciar/reiniciar la aplicación con PM2
restart_application() {
    log "Reiniciando aplicación con PM2..."
    
    cd "$APP_DIR"
    
    # Verificar si la aplicación ya está ejecutándose
    if pm2 list | grep -q "backend-app"; then
        log "Reiniciando aplicación existente..."
        pm2 restart backend-app
    else
        log "Iniciando nueva aplicación..."
        pm2 start ecosystem.config.js
    fi
    
    # Guardar configuración de PM2
    pm2 save
    
    success "Aplicación reiniciada correctamente"
}

# Función para verificar el estado de la aplicación
health_check() {
    log "Verificando estado de la aplicación..."
    
    # Verificar que PM2 esté ejecutando la aplicación
    if ! pm2 list | grep -q "online.*backend-app"; then
        error "La aplicación no está ejecutándose en PM2"
    fi
    
    # Verificar que la aplicación responda
    max_attempts=5
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log "Intento $attempt/$max_attempts - Verificando endpoint..."
        
        if curl -f -s http://localhost:8080/health > /dev/null 2>&1 || \
           curl -f -s http://localhost:8080/ > /dev/null 2>&1; then
            success "Aplicación respondiendo correctamente"
            return 0
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            error "La aplicación no responde después de $max_attempts intentos"
        fi
        
        log "Esperando 10 segundos antes del siguiente intento..."
        sleep 10
        attempt=$((attempt + 1))
    done
}

# Función para rollback
rollback() {
    log "Ejecutando rollback..."
    
    cd "$APP_DIR"
    
    # Buscar el backup más reciente
    latest_backup=$(ls -t backup-* 2>/dev/null | head -n 1)
    
    if [ -n "$latest_backup" ]; then
        log "Restaurando desde backup: $latest_backup"
        
        # Hacer backup del despliegue fallido
        if [ -d "$BACKEND_DIR" ]; then
            mv "$BACKEND_DIR" "backend-failed-$(date +%Y%m%d-%H%M%S)"
        fi
        
        # Restaurar desde backup
        cp -r "$latest_backup" "$BACKEND_DIR"
        
        # Reiniciar PM2
        cd "$BACKEND_DIR"
        pm2 restart backend-app
        
        success "Rollback completado exitosamente"
    else
        error "No se encontraron backups para rollback"
    fi
}

# Función principal de despliegue
deploy() {
    log "=== INICIANDO DESPLIEGUE ==="
    
    # Crear directorio de logs si no existe
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Verificar dependencias del sistema
    check_system_dependencies
    
    # Crear backup del despliegue actual
    create_backup
    
    # Crear estructura de directorios
    mkdir -p "$BACKEND_DIR"
    
    # Instalar dependencias
    install_dependencies
    
    # Configurar variables de entorno
    setup_environment
    
    # Reiniciar aplicación
    restart_application
    
    # Verificar que todo esté funcionando
    health_check
    
    # Limpiar backups antiguos
    cleanup_backups
    
    success "=== DESPLIEGUE COMPLETADO EXITOSAMENTE ==="
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  deploy     - Ejecutar despliegue completo"
    echo "  rollback   - Rollback al despliegue anterior"
    echo "  health     - Verificar estado de la aplicación"
    echo "  backup     - Crear backup manual"
    echo "  cleanup    - Limpiar backups antiguos"
    echo "  help       - Mostrar esta ayuda"
    echo ""
}

# Función principal
main() {
    case "${1:-deploy}" in
        "deploy")
            deploy
            ;;
        "rollback")
            rollback
            ;;
        "health")
            health_check
            ;;
        "backup")
            create_backup
            ;;
        "cleanup")
            cleanup_backups
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            error "Comando desconocido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal con todos los argumentos
main "$@"
