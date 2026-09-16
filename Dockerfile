# Stage 1: Build Flutter web assets
FROM gmeligio/flutter-web:3.47.4 AS builder

WORKDIR /app

# Copy pubspec files first for dependency caching
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build the web app in release mode
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default Nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy built web assets from builder
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom Nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]