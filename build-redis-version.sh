#!/bin/bash

set -e

echo "=================================================="
echo "Building PHP 8.3 + RoadRunner with Redis Jobs"
echo "=================================================="
echo ""

# Build for linux/amd64 (your production platform)
echo "Building for linux/amd64..."
docker build --platform linux/amd64 \
    -t pjabadesco/php8-roadrunner:1.2-redis \
    -t pjabadesco/php8-roadrunner:latest \
    .

echo ""
echo "✅ Build complete!"
echo ""
echo "Verifying Redis plugin..."
docker run --rm --platform linux/amd64 pjabadesco/php8-roadrunner:1.2-redis rr --version

echo ""
echo "=================================================="
echo "To push to Docker Hub:"
echo "  docker push pjabadesco/php8-roadrunner:1.2-redis"
echo "  docker push pjabadesco/php8-roadrunner:latest"
echo ""
echo "To update API Dockerfile, change:"
echo "  FROM pjabadesco/php8-roadrunner:1.1"
echo "To:"
echo "  FROM pjabadesco/php8-roadrunner:1.2-redis"
echo "=================================================="
