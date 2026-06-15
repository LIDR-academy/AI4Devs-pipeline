# ── Stage 1: Build ───────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app

# REACT_APP_API_URL se bake en el bundle en build time
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ── Stage 2: Production (Nginx) ───────────────────────────────────────────────
FROM nginx:1.25-alpine AS production

# Copia el build estático de React
COPY --from=builder /app/build /usr/share/nginx/html

# Config de Nginx con SPA routing, proxy y headers de seguridad
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]
