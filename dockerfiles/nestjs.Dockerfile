FROM node:20-alpine AS base

# 1. Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache linux-headers libc6-compat build-base libusb-dev python3 py3-pip eudev-dev curl
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  else echo "Lockfile not found." && exit 1; \
  fi

# 2. Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# 3. Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN apk add --no-cache linux-headers libc6-compat build-base libusb-dev python3 py3-pip eudev-dev curl
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001
COPY --from=builder --chown=nestjs:nodejs /app/dist dist
COPY --from=builder --chown=nestjs:nodejs /app/package.json .
COPY --from=builder --chown=nestjs:nodejs /app/package-lock.json .
RUN npm install --only=production
USER nestjs
ENV PORT=3000

# grant permission in app folder
USER root
RUN chown -R nestjs:nodejs /app
USER nestjs

EXPOSE 3000

LABEL traefik.enable="true"
LABEL traefik.http.routers.api.entrypoints="web, websecure"
LABEL traefik.http.routers.api.rule="Host(`URL`)"
LABEL traefik.http.routers.api.tls="true"
LABEL traefik.http.routers.api.tls.certresolver="production"