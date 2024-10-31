# step1: Build deps
FROM node:20-alpine AS base

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

# step2: build code
FROM base AS builder
ARG REACT_APP_API_BASE_URL
ENV REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN yarn run build

# step3: serve production
# FROM base AS serve

# WORKDIR /app
# COPY --from=builder /app/build /app/build
# RUN yarn global add serve
# EXPOSE 80
# CMD ["serve", "-s", "build", "-l", "80"]

FROM nginx:alpine
#copies React to the container directory
# Set working directory to nginx resources directory
WORKDIR /usr/share/nginx/html
# Remove default nginx static resources
RUN rm /etc/nginx/conf.d/default.conf
# Copies static resources from builder stage
COPY --from=builder /app/build /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
# Containers run nginx with global directives and daemon off