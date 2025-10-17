#!/bin/bash

set -e

echo "🔨 Building PHP 8.3 + RoadRunner with Redis Jobs Plugin..."
echo ""

# Build the image
docker build -t pjabadesco/php8-roadrunner:redis .

# Tag as latest
docker tag pjabadesco/php8-roadrunner:redis pjabadesco/php8-roadrunner:latest

echo ""
echo "✅ Build complete!"
echo ""
echo "Images created:"
echo "  - pjabadesco/php8-roadrunner:redis"
echo "  - pjabadesco/php8-roadrunner:latest"
echo ""
echo "To push to Docker Hub:"
echo "  docker push pjabadesco/php8-roadrunner:redis"
echo "  docker push pjabadesco/php8-roadrunner:latest"
echo ""
echo "To test locally:"
echo "  docker run --rm pjabadesco/php8-roadrunner:redis rr --version"
echo ""
