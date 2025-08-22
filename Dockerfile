# Arcadia Black — WhatsApp AI Bot (Dockerfile)
FROM node:18-alpine
WORKDIR /app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm install --only=production

# Copy source (expects server.js in repo root — use the v1.1 from canvas)
COPY . .

ENV PORT=8080
EXPOSE 8080

CMD ["node", "server.js"]
