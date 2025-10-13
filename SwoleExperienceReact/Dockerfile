# Multi-stage build for Expo React Native web app
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Build stage
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY app.json ./
COPY app/ ./app/
COPY components/ ./components/
COPY lib/ ./lib/
COPY hooks/ ./hooks/
COPY index.js ./
COPY babel.config.js ./
COPY tsconfig.json ./
COPY jest.setup.js ./

# Build the web version
RUN npx expo export --platform web

# Production image
FROM nginx:alpine AS runner
WORKDIR /usr/share/nginx/html

# Copy built assets
COPY --from=builder /app/dist ./

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 (nginx default)
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
