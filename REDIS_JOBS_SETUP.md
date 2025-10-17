# RoadRunner Redis Jobs Driver Setup

## Overview

This document explains how the RoadRunner image is built with Redis jobs support using Velox.

## Current Configuration

### velox.toml

The `velox.toml` file configures which plugins to include in the RoadRunner build:

```toml
[roadrunner]
ref = "v2025.1.4"

[build]
output = "rr"

[github.plugins]

# Core RR plugins
logger = { owner = "roadrunner-server", repository = "logger", ref = "v5.0.3" }
rpc = { owner = "roadrunner-server", repository = "rpc", ref = "v5.1.9" }
server = { owner = "roadrunner-server", repository = "server", ref = "v5.2.4" }
http = { owner = "roadrunner-server", repository = "http", ref = "v5.2.8" }
jobs = { owner = "roadrunner-server", repository = "jobs", ref = "v5.1.6" }

# Redis plugin - provides BOTH KV and Jobs drivers
redis = { owner = "roadrunner-server", repository = "redis", ref = "v5.1.5" }

# Optional but useful plugins
lock = { owner = "roadrunner-server", repository = "lock", ref = "v5.0.4" }
metrics = { owner = "roadrunner-server", repository = "metrics", ref = "v5.0.3" }
centrifuge = { owner = "roadrunner-server", repository = "centrifuge", ref = "v5.0.4" }
otel = { owner = "roadrunner-server", repository = "otel", ref = "v5.0.0" }
gzip = { owner = "roadrunner-server", repository = "gzip", ref = "v5.0.2" }
```

## Key Points

### Redis Plugin Provides Multiple Drivers

The `roadrunner-server/redis` plugin includes:
- ✅ **KV Driver** - Redis as Key-Value storage
- ✅ **Jobs Driver** - Redis as Job queue

When you include `redis = { owner = "roadrunner-server", repository = "redis", ref = "v5.1.5" }` in velox.toml, BOTH drivers are compiled into the RoadRunner binary.

### Dockerfile Build Process

The Dockerfile uses velox to build RoadRunner with all specified plugins:

```dockerfile
# Stage 1: Build RoadRunner with Velox
FROM golang:1.25.3-alpine3.22 AS roadrunner-builder

RUN apk add --no-cache git
RUN go install github.com/roadrunner-server/velox/v2025/cmd/vx@latest

WORKDIR /build
COPY velox.toml .

# Build RoadRunner with all plugins from velox.toml
RUN GOOS=linux GOARCH=amd64 /go/bin/vx build -c velox.toml -o /usr/bin/ && \
    chmod +x /usr/bin/rr && \
    /usr/bin/rr --version

# Stage 2: Copy to PHP image
FROM php:8.3-cli

COPY --from=roadrunner-builder /usr/bin/rr /usr/local/bin/rr
```

## .rr.yaml Configuration

Once RoadRunner is built with Redis support, configure it in `.rr.yaml`:

```yaml
jobs:
  pool:
    command: "php jobs-worker.php"
    num_workers: 2
    allocate_timeout: 60s
    destroy_timeout: 60s
    supervisor:
      max_worker_memory: 256

  consume:
    - face-comparison

  pipelines:
    face-comparison:
      driver: redis
      config:
        priority: 10
        prefetch: 10000

# Global Redis configuration
redis:
  addrs:
    - "docker01.manilamalayanbank.com:6379"
  db: 0
  username: ""
  password: ""
  dial_timeout: 5s
  read_timeout: 3s
  write_timeout: 3s
```

## Building the Image

```bash
cd /Users/pjabadesco/Documents/Sites/GITHUB/pjabadesco/docker-php8-roadrunner

# Build the image
docker build --platform linux/amd64 \
    -t pjabadesco/php8-roadrunner:1.2-redis \
    -t pjabadesco/php8-roadrunner:latest \
    .

# Verify Redis plugin is included
docker run --rm --platform linux/amd64 \
    pjabadesco/php8-roadrunner:1.2-redis \
    rr --version

# Push to registry
docker push pjabadesco/php8-roadrunner:1.2-redis
docker push pjabadesco/php8-roadrunner:latest
```

## Verifying Redis Jobs Driver

After building, you can verify the Redis jobs driver is available by:

1. **Check RoadRunner version output** - should show Redis plugin
2. **Test .rr.yaml** - RoadRunner should start without "can't find driver constructor" error
3. **Dispatch a test job** - Job should be stored in Redis

## Troubleshooting

### Error: "can't find driver constructor for the pipeline"

**Cause**: RoadRunner binary doesn't have Redis jobs driver compiled in.

**Solution**:
1. Verify `velox.toml` includes redis plugin
2. Rebuild RoadRunner image
3. Update API Dockerfile to use new image version

### Error: "dial tcp ... connection refused"

**Cause**: Redis server not accessible or wrong address.

**Solution**:
1. Verify Redis is running: `redis-cli -h docker01.manilamalayanbank.com ping`
2. Check `.rr.yaml` redis.addrs configuration
3. Verify network connectivity from container to Redis

### Jobs not persisting across restarts

**Cause**: Using memory driver instead of Redis.

**Solution**: Verify `.rr.yaml` has `driver: redis` not `driver: memory`

## Redis Data Structures

RoadRunner stores jobs in Redis using these keys:

- `rr:jobs:{pipeline}:queue` - Active jobs queue
- `rr:jobs:{pipeline}:delayed` - Delayed jobs (if enabled)
- `rr:jobs:{pipeline}:reserved` - Jobs being processed

You can inspect these with:

```bash
redis-cli -h docker01.manilamalayanbank.com
> KEYS rr:jobs:*
> LLEN rr:jobs:face-comparison:queue
```

## Performance Tuning

### Redis Configuration

```yaml
redis:
  addrs:
    - "docker01.manilamalayanbank.com:6379"
  db: 0
  pool_size: 10          # Connection pool size
  min_idle_conns: 5      # Minimum idle connections
  read_timeout: 3s       # Read timeout
  write_timeout: 3s      # Write timeout
  dial_timeout: 5s       # Connection timeout
```

### Jobs Configuration

```yaml
jobs:
  pool:
    num_workers: 2       # Number of worker processes

  pipelines:
    face-comparison:
      config:
        priority: 10     # Higher = higher priority
        prefetch: 10000  # Jobs to prefetch from Redis
```

## References

- [RoadRunner Redis Plugin](https://github.com/roadrunner-server/redis)
- [RoadRunner Jobs Plugin](https://github.com/roadrunner-server/jobs)
- [Velox Build Tool](https://github.com/roadrunner-server/velox)
- [RoadRunner Documentation](https://docs.roadrunner.dev)
