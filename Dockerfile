# Multi-stage Dockerfile for Chefli Backend + Webapp

# Stage 1: Build webapp
FROM node:20-alpine AS webapp-builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy webapp source
COPY . .

# Build webapp
RUN npm run build

# Stage 2: Production server
FROM node:20-alpine

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production

# Copy backend files
COPY backend/ ./backend/

# Copy built webapp from builder stage
COPY --from=webapp-builder /app/dist ./dist

# Expose port
EXPOSE 3000

# Set production environment
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start server
CMD ["node", "backend/server.js"]
