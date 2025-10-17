# RoadRunner Kafka Jobs Driver Setup

## Overview

RoadRunner uses Apache Kafka as a persistent, distributed job queue for face comparison jobs.

## Why Kafka?

✅ **Persistent** - Jobs survive restarts
✅ **Distributed** - Multiple workers can consume from the same topic
✅ **Scalable** - Handle high throughput
✅ **Reliable** - Built-in replication and fault tolerance
✅ **Officially Supported** - Native RoadRunner plugin

## Configuration

### 1. velox.toml

The Kafka plugin is included in the RoadRunner build:

```toml
[github.plugins]
# Core plugins
logger = { owner = "roadrunner-server", repository = "logger", ref = "v5.0.3" }
rpc = { owner = "roadrunner-server", repository = "rpc", ref = "v5.1.9" }
server = { owner = "roadrunner-server", repository = "server", ref = "v5.2.4" }
http = { owner = "roadrunner-server", repository = "http", ref = "v5.2.8" }
jobs = { owner = "roadrunner-server", repository = "jobs", ref = "v5.1.6" }

# Kafka jobs driver
kafka = { owner = "roadrunner-server", repository = "kafka", ref = "v5.2.3" }

# Optional plugins
lock = { owner = "roadrunner-server", repository = "lock", ref = "v5.0.4" }
metrics = { owner = "roadrunner-server", repository = "metrics", ref = "v5.0.3" }
```

### 2. .rr.yaml

Configure Kafka as the jobs driver:

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
      driver: kafka
      config:
        priority: 10
        prefetch: 10000
        topic: face-comparison
        consumer_group: face-comparison-workers

# Kafka broker configuration
kafka:
  brokers:
    - "docker01.manilamalayanbank.com:9092"
  disable_idempotent: false
  max_message_bytes: 1000000
  timeout: 10s
```

### 3. jobs-worker.php

No changes needed! The PHP worker uses the standard Consumer:

```php
<?php

declare(strict_types=1);

use Spiral\RoadRunner\Jobs\Consumer;
use Spiral\RoadRunner\Jobs\Task\ReceivedTaskInterface;

require __DIR__ . '/vendor/autoload.php';

// Load environment
if (file_exists(__DIR__ . '/.env')) {
    $dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
    $dotenv->load();
}

// Initialize job handlers
$faceComparisonJob = new Services\FaceComparisonJob();

// Create consumer - RoadRunner handles Kafka connection
$consumer = new Consumer();

error_log("[Jobs Worker] Started and waiting for jobs...");

// Main loop
while ($task = $consumer->waitTask()) {
    try {
        $taskName = $task->getName();
        $payload = json_decode($task->getPayload(), true);

        switch ($taskName) {
            case 'face-comparison':
                handleFaceComparison($task, $payload, $faceComparisonJob);
                break;

            default:
                error_log("[Jobs Worker] Unknown job type: {$taskName}");
                $task->fail("Unknown job type: {$taskName}");
        }

    } catch (\Throwable $e) {
        error_log(sprintf(
            "[Jobs Worker ERROR] %s in %s:%d",
            $e->getMessage(),
            $e->getFile(),
            $e->getLine()
        ));

        $task->fail($e->getMessage());
    }
}

function handleFaceComparison(
    ReceivedTaskInterface $task,
    array $payload,
    Services\FaceComparisonJob $handler
): void {
    try {
        $result = $handler->handle($payload);
        if ($result['success']) {
            $task->complete();
        } else {
            $task->fail($result['error'] ?? 'Unknown error');
        }
    } catch (\Exception $e) {
        $task->fail($e->getMessage());
    }
}
```

## Kafka Server Setup

### Prerequisites

You need a running Kafka broker. If you don't have one, here's a quick Docker setup:

```yaml
# docker-compose.yml for Kafka
version: '3.8'

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    hostname: zookeeper
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    hostname: kafka
    container_name: kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "9101:9101"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://docker01.manilamalayanbank.com:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'
      KAFKA_JMX_PORT: 9101
      KAFKA_JMX_HOSTNAME: localhost
```

Start Kafka:

```bash
docker-compose up -d
```

### Verify Kafka is Running

```bash
# Check if Kafka is listening
telnet docker01.manilamalayanbank.com 9092

# Or use kafkacat
kafkacat -L -b docker01.manilamalayanbank.com:9092
```

## Building RoadRunner with Kafka

```bash
cd /Users/pjabadesco/Documents/Sites/GITHUB/pjabadesco/docker-php8-roadrunner

# Build the image with Kafka support
docker build --platform linux/amd64 \
    -t pjabadesco/php8-roadrunner:1.2-kafka \
    -t pjabadesco/php8-roadrunner:latest \
    .

# Verify build
docker run --rm --platform linux/amd64 \
    pjabadesco/php8-roadrunner:1.2-kafka \
    rr --version

# Push to registry
docker push pjabadesco/php8-roadrunner:1.2-kafka
docker push pjabadesco/php8-roadrunner:latest
```

## Deploying

### Update API Dockerfile

```dockerfile
FROM --platform=linux/amd64 pjabadesco/php8-roadrunner:1.2-kafka
```

### Build and Deploy API

```bash
cd /Users/pjabadesco/Documents/Sites/GITHUB/malayanbank/api-v1.manilamalayanbank.com

# Build API image
docker build --platform linux/amd64 \
    -t 192.168.90.99:5000/api-v1.manilamalayanbank.com \
    .

# Push to registry
docker push 192.168.90.99:5000/api-v1.manilamalayanbank.com

# Restart Kubernetes deployment
kubectl rollout restart deployment/api-v1-manilamalayanbank-com \
    -n api-v1-manilamalayanbank-com
```

## Monitoring Kafka Jobs

### Using kafkacat

```bash
# List topics
kafkacat -L -b docker01.manilamalayanbank.com:9092

# Monitor face-comparison topic
kafkacat -C -b docker01.manilamalayanbank.com:9092 \
    -t face-comparison \
    -o beginning

# Check consumer group lag
kafkacat -b docker01.manilamalayanbank.com:9092 \
    -L -G face-comparison-workers face-comparison
```

### Using Kafka Console Tools

```bash
# List topics
kafka-topics --bootstrap-server docker01.manilamalayanbank.com:9092 --list

# Describe topic
kafka-topics --bootstrap-server docker01.manilamalayanbank.com:9092 \
    --describe --topic face-comparison

# Monitor consumer group
kafka-consumer-groups --bootstrap-server docker01.manilamalayanbank.com:9092 \
    --describe --group face-comparison-workers
```

## Advanced Configuration

### High Throughput

```yaml
kafka:
  brokers:
    - "docker01.manilamalayanbank.com:9092"
  disable_idempotent: false
  max_message_bytes: 10000000  # 10MB
  timeout: 30s
  compression: snappy  # or gzip, lz4, zstd

jobs:
  pipelines:
    face-comparison:
      config:
        priority: 10
        prefetch: 50000  # Prefetch more messages
```

### Consumer Groups

Multiple workers can consume from the same topic:

```yaml
jobs:
  pool:
    num_workers: 4  # 4 workers in same consumer group

  pipelines:
    face-comparison:
      config:
        consumer_group: face-comparison-workers  # All share work
```

### Topic Configuration

Create topic with specific settings:

```bash
kafka-topics --bootstrap-server docker01.manilamalayanbank.com:9092 \
    --create \
    --topic face-comparison \
    --partitions 3 \
    --replication-factor 1 \
    --config retention.ms=604800000  # 7 days
```

## Troubleshooting

### Error: "can't find driver constructor"

**Cause**: Kafka plugin not compiled into RoadRunner binary.

**Solution**: Rebuild RoadRunner image with Kafka plugin in velox.toml

### Error: "dial tcp ... connection refused"

**Cause**: Kafka broker not accessible.

**Solution**:
1. Verify Kafka is running: `telnet docker01.manilamalayanbank.com 9092`
2. Check broker address in `.rr.yaml`
3. Verify network connectivity

### Jobs not being consumed

**Cause**: Topic or consumer group issue.

**Solution**:
1. Check if topic exists: `kafka-topics --list`
2. Verify consumer group: `kafka-consumer-groups --describe --group face-comparison-workers`
3. Check RoadRunner logs for errors

### Messages accumulating in topic

**Cause**: Workers not processing fast enough.

**Solution**:
1. Increase `num_workers` in `.rr.yaml`
2. Scale horizontally (more pods/containers)
3. Optimize job handler code

## Performance

### Kafka Benefits

- **High Throughput**: Can handle millions of messages/sec
- **Low Latency**: Sub-millisecond message delivery
- **Persistence**: Messages retained based on retention policy
- **Scalability**: Horizontal scaling via partitions
- **Reliability**: Replication ensures no data loss

### Recommended Settings for eKYC

```yaml
kafka:
  brokers:
    - "docker01.manilamalayanbank.com:9092"
  max_message_bytes: 5000000  # 5MB (enough for job metadata)
  timeout: 15s

jobs:
  pool:
    num_workers: 2  # Start with 2, scale as needed

  pipelines:
    face-comparison:
      config:
        priority: 10
        prefetch: 10000
        topic: face-comparison
        consumer_group: face-comparison-workers
```

## References

- [RoadRunner Kafka Plugin](https://github.com/roadrunner-server/kafka)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [RoadRunner Jobs Documentation](https://docs.roadrunner.dev/docs/queues-and-jobs/overview-queues)
- [Confluent Kafka Docker Images](https://hub.docker.com/r/confluentinc/cp-kafka)
