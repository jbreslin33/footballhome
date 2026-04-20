FROM node:22-bookworm-slim

# Install Chromium and its dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    curl \
    ca-certificates \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    NODE_ENV=production

WORKDIR /app
COPY package.json .
RUN npm install --omit=dev

COPY server.js .

EXPOSE 3010
CMD ["node", "server.js"]
