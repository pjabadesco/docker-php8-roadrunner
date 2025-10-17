# RoadRunner with Redis Jobs Plugin

## Problem

The default `spiralscout/roadrunner:2025.1.3` Docker image does not include the Redis jobs driver plugin, causing this error:

```
ERROR jobs can't find driver constructor for the pipeline {"driver": "redis", "pipeline": "face-comparison"}
```

## Solution

Build a custom RoadRunner binary with the Redis jobs plugin using Velox (RoadRunner's build tool).

## Dockerfile Changes

### Multi-stage Build

**Stage 1: Build RoadRunner with Redis**
```dockerfile
FROM golang:1.23-alpine AS roadrunner-builder

RUN apk add --no-cache git
RUN go install github.com/roadrunner-server/velox/v2025@latest

WORKDIR /build
RUN /go/bin/velox build \
    -o /usr/bin/rr \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3 \
    github.com/roadrunner-server/redis/jobs/v5@latest
```

**Stage 2: Copy custom RoadRunner to PHP image**
```dockerfile
COPY --from=roadrunner-builder /usr/bin/rr /usr/local/bin/rr
```

## How to Build

```bash
cd /Users/pjabadesco/Documents/Sites/GITHUB/pjabadesco/docker-php8-roadrunner

# Build the Docker image
docker build -t pjabadesco/php8-roadrunner:redis .

# Tag for your registry
docker tag pjabadesco/php8-roadrunner:redis pjabadesco/php8-roadrunner:latest

# Push to registry
docker push pjabadesco/php8-roadrunner:redis
docker push pjabadesco/php8-roadrunner:latest
```

## Rebuild and Deploy

After building the new image, you need to rebuild your API container:

```bash
cd /Users/pjabadesco/Documents/Sites/GITHUB/malayanbank/api-v1.manilamalayanbank.com

# Pull the new image
docker pull pjabadesco/php8-roadrunner:latest

# Rebuild and restart
docker-compose down
docker-compose up -d --build
```

## Verify Redis Plugin

After deployment, verify the Redis plugin is loaded:

```bash
# SSH into container
docker exec -it <container-name> /bin/bash

# Check RoadRunner plugins
rr --version
```

You should see the Redis jobs plugin listed in the output.

## Configuration

Your `.rr.yaml` is already correctly configured for Redis:

```yaml
jobs:
  drivers:
    redis:
      addr: "docker01.manilamalayanbank.com:6379"
      db: 0
      timeout: 60s

  pipelines:
    face-comparison:
      driver: redis
      config:
        queue: "face-comparison"
        priority: 10

  consume:
    - face-comparison
```

## What This Fixes

✅ RoadRunner binary now includes Redis jobs driver
✅ Jobs can be dispatched to Redis queue
✅ Jobs worker can consume from Redis queue
✅ Face comparison jobs will process asynchronously
✅ Job persistence across RoadRunner restarts

## Build Time

The custom build adds ~2-3 minutes to Docker build time due to compiling RoadRunner from source with Go.

## Alternative: Pre-built Binary

If you prefer not to build from source, you can download a pre-built RoadRunner binary with all plugins:

```bash
# Download RoadRunner with all plugins
wget https://github.com/roadrunner-server/roadrunner/releases/download/v2025.1.3/roadrunner-2025.1.3-linux-amd64.tar.gz

# Extract
tar -xzf roadrunner-2025.1.3-linux-amd64.tar.gz

# Copy to Dockerfile directory
cp roadrunner-2025.1.3-linux-amd64/rr ./rr-custom

# Update Dockerfile to use local binary
```

Then modify Dockerfile:
```dockerfile
COPY ./rr-custom /usr/local/bin/rr
RUN chmod +x /usr/local/bin/rr
```
