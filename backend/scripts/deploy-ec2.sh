#!/usr/bin/env bash
# Script de post-deploy en EC2 (idempotente).
# El workflow CI ya copia artefactos; este script sirve para ejecución manual
# o como SCRIPT_AFTER del action ssh-deploy si se prefiere.
set -e
cd "${TARGET_DIR:-.}"
npm ci --omit=dev
npx prisma generate
sudo systemctl restart lti-backend 2>/dev/null || true
sudo systemctl enable lti-backend 2>/dev/null || true
sleep 3
curl -sf http://localhost:3010/health || exit 1
