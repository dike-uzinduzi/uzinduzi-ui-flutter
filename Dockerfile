# Stage 1: Build Flutter web assets
FROM gmeligio/flutter-web:3.47.4 AS builder

WORKDIR /app

# Copy pubspec files first for dependency caching.
# --chown avoids the need for a separate `chown` step.
COPY --chown=flutter:flutter pubspec.* ./
RUN flutter pub get

# Copy the rest of the source with the same ownership
COPY --chown=flutter:flutter . .

# Build the web app in release mode.
# --pwa-strategy=none disables the Flutter service worker,
# which otherwise caches main.dart.js and serves stale builds.
RUN flutter build web --release --pwa-strategy=none

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default Nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy built web assets from builder
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom Nginx config for SPA routing + Firebase auth proxy
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]