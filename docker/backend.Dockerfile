FROM node:22-alpine AS dependencies

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev && \
    npm cache clean --force


FROM node:22-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8080

COPY --from=dependencies /app/node_modules ./node_modules
COPY package*.json ./
COPY server.js ./

USER node

EXPOSE 8080

HEALTHCHECK --interval=30s \
            --timeout=5s \
            --start-period=10s \
            --retries=3 \
            CMD wget --no-verbose \
                --tries=1 \
                --spider \
                http://127.0.0.1:8080/health || exit 1

CMD ["node", "server.js"]