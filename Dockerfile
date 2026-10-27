# Step 1: Build the website using Bun
FROM oven/bun:1-alpine AS builder
WORKDIR /app

# Copy package files and install dependencies
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

# Copy source code and build the static assets
COPY . .
RUN bun run build

# Step 2: Serve the static files using Nginx
FROM nginx:alpine
# Copy built static files from Step 1 to Nginx public folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Configure Nginx to serve on port 8080 for Cloud Run
RUN echo 'server { \
    listen 8080; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
