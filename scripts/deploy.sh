#!/bin/bash

# AI4Devs Backend Deployment Script
# Usage: ./scripts/deploy.sh [environment]

set -e

ENVIRONMENT=${1:-production}
APP_NAME="ai4devs-backend"
APP_DIR="/opt/ai4devs-backend"
BACKUP_DIR="$APP_DIR/backups"
CURRENT_DIR="$APP_DIR/current"

echo "🚀 Starting deployment for environment: $ENVIRONMENT"

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 is not installed. Please install it first:"
    echo "npm install -g pm2"
    exit 1
fi

# Create directories if they don't exist
mkdir -p $APP_DIR
mkdir -p $BACKUP_DIR
mkdir -p $CURRENT_DIR/logs

# Stop the application
echo "⏹️  Stopping application..."
pm2 stop $APP_NAME || true
pm2 delete $APP_NAME || true

# Backup current version
if [ -d "$CURRENT_DIR" ] && [ "$(ls -A $CURRENT_DIR)" ]; then
    echo "💾 Creating backup..."
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
    cp -r $CURRENT_DIR $BACKUP_DIR/$BACKUP_NAME
    echo "✅ Backup created: $BACKUP_NAME"
fi

# Clean current directory
echo "🧹 Cleaning current directory..."
rm -rf $CURRENT_DIR/*

# Copy new files (assuming they're in the current directory)
echo "📦 Copying new files..."
cp -r dist/* $CURRENT_DIR/
cp package*.json $CURRENT_DIR/

# Install dependencies
echo "📥 Installing dependencies..."
cd $CURRENT_DIR
npm ci --only=production

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

# Set environment
if [ "$ENVIRONMENT" = "production" ]; then
    echo "🔧 Setting production environment..."
    pm2 start ecosystem.config.js --env production
else
    echo "🔧 Setting development environment..."
    pm2 start ecosystem.config.js --env development
fi

# Save PM2 configuration
pm2 save

# Health check
echo "🏥 Performing health check..."
sleep 10

if curl -f http://localhost:3010/health > /dev/null 2>&1; then
    echo "✅ Health check passed!"
    echo "🎉 Deployment successful!"
    echo "📊 Application status:"
    pm2 status
else
    echo "❌ Health check failed!"
    echo "🔄 Attempting rollback..."
    
    # Find latest backup
    LATEST_BACKUP=$(ls -t $BACKUP_DIR/backup-* | head -n1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        echo "🔄 Rolling back to: $LATEST_BACKUP"
        rm -rf $CURRENT_DIR/*
        cp -r $LATEST_BACKUP/* $CURRENT_DIR/
        cd $CURRENT_DIR
        pm2 start ecosystem.config.js --env $ENVIRONMENT
        pm2 save
        
        if curl -f http://localhost:3010/health > /dev/null 2>&1; then
            echo "✅ Rollback successful!"
        else
            echo "❌ Rollback failed! Manual intervention required."
            exit 1
        fi
    else
        echo "❌ No backup found for rollback!"
        exit 1
    fi
fi

echo "🏁 Deployment process completed!"
