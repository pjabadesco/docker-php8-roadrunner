# Use Golang to build RoadRunner with all plugins including Redis
FROM golang:1.23-alpine AS roadrunner-builder

# Install git and build dependencies
RUN apk add --no-cache git

# Install Velox (RoadRunner build tool)
RUN go install github.com/roadrunner-server/velox/v2025@latest

# Build RoadRunner with Redis jobs plugin
WORKDIR /build
RUN /go/bin/velox build \
    -o /usr/bin/rr \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3 \
    github.com/roadrunner-server/redis/jobs/v5@latest

# Main PHP image
FROM php:8.3-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libcurl4-openssl-dev \
    libssl-dev \
    libxslt1-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libpq-dev \
    gnupg \
    apt-transport-https \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver and SQL Server tools
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools18 \
    && apt-get install -y unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    && docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mysqli \
    pgsql \
    mbstring \
    opcache \
    curl \
    xml \
    dom \
    simplexml \
    soap \
    xsl \
    zip \
    gd

# Install PECL extensions (without grpc for now to speed up build)
RUN pecl install redis mongodb protobuf \
    && docker-php-ext-enable redis mongodb protobuf

# Install SQL Server PHP drivers
RUN pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

# Install grpc separately with optimizations
RUN pecl install grpc-1.65.2 \
    && docker-php-ext-enable grpc

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy RoadRunner from custom builder with Redis support
COPY --from=roadrunner-builder /usr/bin/rr /usr/local/bin/rr
RUN chmod +x /usr/local/bin/rr

# Install sockets extension if not present
RUN docker-php-ext-install sockets 2>/dev/null || true

# Copy custom php.ini
COPY php.ini /usr/local/etc/php/php.ini

# Create log directory for PHP
RUN mkdir -p /var/log/php && chmod 755 /var/log/php

# Set working directory
WORKDIR /app

# Create a simple test script
RUN echo '<?php phpinfo();' > /app/test.php

# Expose RoadRunner default ports
EXPOSE 8080
EXPOSE 6001
EXPOSE 2112

# Default command
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app"]