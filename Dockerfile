# ─────────────────────────────────────────────────────────
# Stage 1: Build Flutter web assets
# ─────────────────────────────────────────────────────────
FROM gmeligio/flutter-web:3.47.4 AS builder

WORKDIR /app

COPY --chown=flutter:flutter pubspec.* ./
RUN flutter pub get

COPY --chown=flutter:flutter . .

# Read the semantic version from pubspec (e.g. "0.1.0+1" -> "0.1.0")
RUN VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1) && \
    echo "Building version: $VERSION" && \
    flutter build web --release \
        --base-href /$VERSION/ \
        --dart-define=APP_VERSION=$VERSION \
        --pwa-strategy=none && \
    # Remove the empty SW stub
    rm -f /app/build/web/flutter_service_worker.js && \
    # Restructure into /<version>/ + root index.html + version.json
    mkdir -p /app/web_output/$VERSION && \
    mv /app/build/web/* /app/web_output/$VERSION/ && \
    cp /app/web_output/$VERSION/index.html /app/web_output/index.html && \
    echo "{\"version\":\"$VERSION\"}" > /app/web_output/version.json && \
    rm -rf /app/build/web && \
    mv /app/web_output /app/build/web

# ─────────────────────────────────────────────────────────
# Stage 2: Serve with Nginx
# ─────────────────────────────────────────────────────────
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]