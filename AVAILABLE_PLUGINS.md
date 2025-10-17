# RoadRunner Available Plugins for Velox Build

Complete list of plugins you can include when building RoadRunner with Velox.

## ⚠️ Default Plugins in `github.com/roadrunner-server/roadrunner/v2025@v2025.1.3`

The base RoadRunner package includes these **core plugins by default**:

### ✅ Included by Default (Core Plugins)

1. **Server** - Worker pool management and process lifecycle
2. **RPC** - Inter-service communication and control plane
3. **HTTP** - HTTP/HTTPS/HTTP2/HTTP3 web server
4. **Logger** - Logging infrastructure
5. **Metrics** - Prometheus metrics collection
6. **Status** (HealthChecks) - Health monitoring endpoints
7. **Reload** - File watcher for development (as of 2025, use `pool.debug=true` instead)
8. **Endure** - Dependency injection container (internal)

### ❌ NOT Included by Default (Must Build with Velox)

These plugins **require explicit inclusion** when building with Velox:

#### Job Queue Drivers
- ❌ **Redis Jobs** - `github.com/roadrunner-server/redis/jobs/v5`
- ❌ **Beanstalk Jobs** - `github.com/roadrunner-server/beanstalk/jobs/v5`
- ❌ **AMQP Jobs** - `github.com/roadrunner-server/amqp/jobs/v5`
- ❌ **SQS Jobs** - `github.com/roadrunner-server/sqs/jobs/v5`
- ❌ **NATS Jobs** - `github.com/roadrunner-server/nats/jobs/v5`
- ❌ **Kafka Jobs** - `github.com/roadrunner-server/kafka/jobs/v5`
- ✅ **Memory Jobs** - Included with base Jobs plugin

#### Key-Value Storage Drivers
- ❌ **Redis KV** - `github.com/roadrunner-server/redis/kv/v5`
- ❌ **Memcached KV** - `github.com/roadrunner-server/memcached/v5`
- ❌ **BoltDB KV** - `github.com/roadrunner-server/boltdb/v5`
- ✅ **Memory KV** - Included with base KV plugin

#### Other Plugins
- ❌ **gRPC** - `github.com/roadrunner-server/grpc/v5`
- ❌ **TCP** - `github.com/roadrunner-server/tcp/v5`
- ❌ **Centrifuge** - `github.com/roadrunner-server/centrifuge/v5`
- ❌ **Temporal** - `github.com/roadrunner-server/temporal/v5`
- ❌ **Locks** - `github.com/roadrunner-server/lock/v5`
- ❌ **OpenTelemetry** - `github.com/roadrunner-server/otel/v5`
- ❌ **Broadcast** - `github.com/roadrunner-server/broadcast/v5`
- ❌ **Service** - `github.com/roadrunner-server/service/v5`
- ❌ **Fileserver** - Excluded since v2025.1.3 (security concerns with GoFiber dependency)

### 🔴 Important Notes for v2025.1.3

1. **Fileserver Plugin Removed**: Due to CVE issues with GoFiber dependency, the fileserver plugin is no longer included in standard builds but can be built separately with Velox if needed.

2. **Jobs Plugin**: The base `Jobs` plugin may be included, but **all queue drivers (except Memory)** require explicit installation.

3. **KV Plugin**: The base `KV` plugin may be included, but **all storage drivers (except Memory)** require explicit installation.

---

## Core Server & Communication

### 1. **HTTP**
- **Purpose**: Efficient and scalable HTTP/HTTPS/HTTP2/HTTP3 server
- **Use Case**: Web server, REST APIs, PSR-7/PSR-17 compatible
- **GitHub**: `github.com/roadrunner-server/http/v5`
- **Required**: Yes (core functionality)

### 2. **gRPC**
- **Purpose**: High-performance gRPC server implementation
- **Use Case**: Microservices, API services with protobuf
- **GitHub**: `github.com/roadrunner-server/grpc/v5`
- **Required**: No

### 3. **TCP**
- **Purpose**: High-performance TCP server for custom networking
- **Use Case**: Custom protocols, socket servers
- **GitHub**: `github.com/roadrunner-server/tcp/v5`
- **Required**: No

### 4. **Server**
- **Purpose**: Core server functionality and lifecycle management
- **Use Case**: Worker pool management, process lifecycle
- **GitHub**: `github.com/roadrunner-server/server/v5`
- **Required**: Yes (core dependency)

## Job Queue Plugins

### 5. **Jobs (Core)**
- **Purpose**: Background job processing and queue management
- **Use Case**: Async tasks, deferred processing
- **GitHub**: `github.com/roadrunner-server/jobs/v5`
- **Required**: For async job processing

### Job Queue Drivers:

#### **Redis Jobs Driver** ⭐
- **Purpose**: Persistent job queue using Redis
- **Use Case**: Production-grade distributed queue
- **GitHub**: `github.com/roadrunner-server/redis/jobs/v5`
- **Config**: Requires Redis server connection

#### **Beanstalk Jobs Driver**
- **Purpose**: Job queue using Beanstalkd
- **Use Case**: Simple, fast queue with priorities
- **GitHub**: `github.com/roadrunner-server/beanstalk/jobs/v5`
- **Config**: Requires Beanstalkd server

#### **AMQP Jobs Driver**
- **Purpose**: RabbitMQ/AMQP job queue
- **Use Case**: Enterprise messaging, complex routing
- **GitHub**: `github.com/roadrunner-server/amqp/jobs/v5`
- **Config**: Requires RabbitMQ

#### **SQS Jobs Driver**
- **Purpose**: AWS SQS job queue
- **Use Case**: AWS cloud-native applications
- **GitHub**: `github.com/roadrunner-server/sqs/jobs/v5`
- **Config**: Requires AWS credentials

#### **NATS Jobs Driver**
- **Purpose**: NATS messaging system for jobs
- **Use Case**: Cloud-native, high-performance messaging
- **GitHub**: `github.com/roadrunner-server/nats/jobs/v5`
- **Config**: Requires NATS server

#### **Kafka Jobs Driver**
- **Purpose**: Apache Kafka for job streaming
- **Use Case**: Event streaming, big data pipelines
- **GitHub**: `github.com/roadrunner-server/kafka/jobs/v5`
- **Config**: Requires Kafka cluster

#### **Memory Jobs Driver**
- **Purpose**: In-memory job queue (no persistence)
- **Use Case**: Development, testing, temporary queues
- **GitHub**: Built-in (no external package needed)
- **Config**: No external dependencies

## Key-Value Storage Plugins

### 6. **KV (Core)**
- **Purpose**: Key-value store interface
- **Use Case**: Caching, session storage, temporary data
- **GitHub**: `github.com/roadrunner-server/kv/v5`
- **Required**: For KV operations

### KV Storage Drivers:

#### **Redis KV Driver** ⭐
- **Purpose**: Redis as key-value store
- **Use Case**: Distributed caching, sessions
- **GitHub**: `github.com/roadrunner-server/redis/kv/v5`
- **Config**: Requires Redis server

#### **Memcached KV Driver**
- **Purpose**: Memcached for caching
- **Use Case**: High-performance caching
- **GitHub**: `github.com/roadrunner-server/memcached/v5`
- **Config**: Requires Memcached server

#### **BoltDB KV Driver**
- **Purpose**: Embedded key-value database
- **Use Case**: Local persistence, no external dependencies
- **GitHub**: `github.com/roadrunner-server/boltdb/v5`
- **Config**: File-based (no server needed)

#### **Memory KV Driver**
- **Purpose**: In-memory storage (no persistence)
- **Use Case**: Development, temporary data
- **GitHub**: Built-in
- **Config**: No external dependencies

## Real-Time Communication

### 7. **Centrifuge**
- **Purpose**: WebSocket messaging and broadcasting (Centrifugo integration)
- **Use Case**: Real-time notifications, chat, live updates
- **GitHub**: `github.com/roadrunner-server/centrifuge/v5`
- **Required**: No

### 8. **Broadcast**
- **Purpose**: Server-sent events and broadcasting
- **Use Case**: Push notifications, event streaming
- **GitHub**: `github.com/roadrunner-server/broadcast/v5`
- **Required**: No

## Workflow & Orchestration

### 9. **Temporal**
- **Purpose**: Workflow and task orchestration engine
- **Use Case**: Complex workflows, saga patterns, durable execution
- **GitHub**: `github.com/roadrunner-server/temporal/v5`
- **Required**: No
- **Config**: Requires Temporal server

## Distributed Systems

### 10. **Locks**
- **Purpose**: Distributed locking mechanisms
- **Use Case**: Concurrency control, critical sections
- **GitHub**: `github.com/roadrunner-server/lock/v5`
- **Required**: No

## Monitoring & Observability

### 11. **Metrics**
- **Purpose**: Prometheus metrics collection and exposure
- **Use Case**: Application monitoring, performance metrics
- **GitHub**: `github.com/roadrunner-server/metrics/v5`
- **Required**: No

### 12. **Logger / App-Logger**
- **Purpose**: Robust logging to various outputs
- **Use Case**: Application logs, debugging, auditing
- **GitHub**: `github.com/roadrunner-server/logger/v5`
- **Required**: Yes (recommended)

### 13. **OpenTelemetry (OTEL)**
- **Purpose**: Distributed tracing and observability
- **Use Case**: Microservices tracing, performance analysis
- **GitHub**: `github.com/roadrunner-server/otel/v5`
- **Required**: No
- **Supports**: gRPC, HTTP, Jaeger exporters

### 14. **HealthChecks**
- **Purpose**: Health monitoring and readiness checks
- **Use Case**: Kubernetes probes, load balancer health checks
- **GitHub**: `github.com/roadrunner-server/status/v5`
- **Required**: No

## Service Management

### 15. **Service**
- **Purpose**: Service manager (supervisor-like)
- **Use Case**: Run and monitor long-running services
- **GitHub**: `github.com/roadrunner-server/service/v5`
- **Required**: No

### 16. **Reload**
- **Purpose**: File watcher for auto-reload during development
- **Use Case**: Development workflow, automatic restarts
- **GitHub**: `github.com/roadrunner-server/reload/v5`
- **Required**: No (dev only)

## Infrastructure

### 17. **RPC**
- **Purpose**: RPC communication between services
- **Use Case**: Inter-service communication, control plane
- **GitHub**: `github.com/roadrunner-server/rpc/v5`
- **Required**: Yes (core dependency)

### 18. **Endure**
- **Purpose**: Dependency injection container
- **Use Case**: Plugin management, DI
- **GitHub**: `github.com/roadrunner-server/endure/v2`
- **Required**: Yes (core dependency)

### 19. **File Server**
- **Purpose**: Static file serving
- **Use Case**: Serve static assets, SPA hosting
- **GitHub**: Part of HTTP plugin
- **Required**: No

## Building with Velox

### Minimal Build (HTTP only)
```bash
velox build \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3
```

### Production Build (with Redis Jobs + KV)
```bash
velox build \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3 \
    github.com/roadrunner-server/redis/jobs/v5@latest \
    github.com/roadrunner-server/redis/kv/v5@latest
```

### Full Featured Build
```bash
velox build \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3 \
    github.com/roadrunner-server/redis/jobs/v5@latest \
    github.com/roadrunner-server/redis/kv/v5@latest \
    github.com/roadrunner-server/centrifuge/v5@latest \
    github.com/roadrunner-server/metrics/v5@latest \
    github.com/roadrunner-server/otel/v5@latest \
    github.com/roadrunner-server/lock/v5@latest
```

### eKYC Recommended Build
```bash
velox build \
    -o /usr/bin/rr \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3 \
    github.com/roadrunner-server/redis/jobs/v5@latest \
    github.com/roadrunner-server/redis/kv/v5@latest \
    github.com/roadrunner-server/metrics/v5@latest \
    github.com/roadrunner-server/lock/v5@latest
```

**Why these plugins?**
- **Redis Jobs**: Persistent face comparison queue
- **Redis KV**: Session caching, liveness session storage
- **Metrics**: Monitor job processing performance
- **Locks**: Prevent duplicate face comparison jobs

## Plugin Versioning

### Latest Stable
```bash
github.com/roadrunner-server/redis/jobs/v5@latest
```

### Specific Version
```bash
github.com/roadrunner-server/redis/jobs/v5@v5.2.1
```

### Main Branch (Development)
```bash
github.com/roadrunner-server/redis/jobs/v5@main
```

## Checking Installed Plugins

After building, verify installed plugins:

```bash
rr --version
```

Output will show all compiled plugins:
```
RoadRunner 2025.1.3
Plugins:
  - http
  - jobs
  - redis (jobs, kv)
  - metrics
  - logger
  - rpc
  ...
```

## Summary: What You Need to Add

Since the base `github.com/roadrunner-server/roadrunner/v2025@v2025.1.3` **does NOT include Redis**:

### For Your eKYC Project, You MUST Build With:

```dockerfile
RUN /go/bin/velox build \
    -o /usr/bin/rr \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3 \
    github.com/roadrunner-server/redis/jobs/v5@latest
```

This adds:
- ✅ **Redis Jobs Driver** - Required for persistent face comparison queue

### Recommended Additional Plugins:

```dockerfile
RUN /go/bin/velox build \
    -o /usr/bin/rr \
    github.com/roadrunner-server/roadrunner/v2025@v2025.1.3 \
    github.com/roadrunner-server/redis/jobs/v5@latest \
    github.com/roadrunner-server/redis/kv/v5@latest \
    github.com/roadrunner-server/metrics/v5@latest \
    github.com/roadrunner-server/lock/v5@latest
```

This adds:
- ✅ **Redis KV** - Cache liveness sessions, document metadata
- ✅ **Metrics** - Monitor job processing performance
- ✅ **Locks** - Prevent duplicate face comparison jobs

### What You Get for Free:

From the base package, you already have:
- ✅ HTTP server (for REST API)
- ✅ RPC (for job dispatching)
- ✅ Logger (for application logs)
- ✅ Metrics (Prometheus integration)
- ✅ Status/Health checks
- ✅ Memory driver for Jobs (but not persistent!)

## References

- [Official RoadRunner Docs](https://docs.roadrunner.dev)
- [Velox GitHub](https://github.com/roadrunner-server/velox)
- [RoadRunner Plugins GitHub](https://github.com/roadrunner-server)
- [Velox Builder](https://build.roadrunner.dev)
- [RoadRunner 2025.1.3 Release](https://github.com/roadrunner-server/roadrunner/releases/tag/v2025.1.3)
