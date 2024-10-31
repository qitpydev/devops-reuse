FROM node:20-alpine AS base

# 1. Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
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
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
RUN apk add --no-cache curl
USER nextjs
EXPOSE 3000
ENV PORT=3000
LABEL traefik.enable="true"
LABEL traefik.http.routers.app.entrypoints="web, websecure"
LABEL traefik.http.routers.app.rule="Host(`URL`)"
LABEL traefik.http.routers.app.tls="true"
LABEL traefik.http.routers.app.tls.certresolver="production"