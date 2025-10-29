# ------------------------------
# 🏗️  Build Stage
# ------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build


# ------------------------------
# 🚀  Production Runtime Stage
# ------------------------------
FROM node:20-alpine AS runner

# Set NODE_ENV to production
ENV NODE_ENV=production

WORKDIR /app

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY package*.json ./

# Install only production deps
RUN npm ci --omit=dev

# Set non-root user for security
RUN addgroup -S nodejs && adduser -S nodeuser -G nodejs
USER nodeuser

# Expose app port
EXPOSE 3000

# Start the app
CMD ["node", "dist/app.js"]

