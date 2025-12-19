    # Deployment & Infrastructure Guide

## 1. Requisitos de Hardware (Produção)

### 1.1 Servidor de Streaming (MediaMTX + FFmpeg)

```yaml
Especificações Mínimas:
  CPU: AMD EPYC 7443P (32 cores / 64 threads) @ 2.85 GHz
  RAM: 64 GB DDR4 ECC
  Storage: 2 TB NVMe SSD (Samsung 980 PRO ou superior)
  Network: 10 Gbps (ou 2× 1 Gbps bonding LACP)
  
Recomendado para Produção:
  CPU: AMD EPYC 7543 (64 cores / 128 threads)
  RAM: 128 GB DDR4 ECC
  Storage: 4 TB NVMe SSD RAID 10
  Network: 10 Gbps redundante (2 interfaces)
  
Estimativa de Custo:
  Bare-Metal: R$ 35.000 - 50.000 (one-time)
  Cloud (AWS c6i.16xlarge): R$ 8.000/mês
```

### 1.2 Servidor de IA (Workers YOLO + OCR)

```yaml
Especificações Mínimas:
  CPU: Intel Xeon Silver 4314 (16 cores)
  RAM: 32 GB DDR4
  GPU: 2× NVIDIA RTX 3060 (12 GB VRAM cada)
  Storage: 1 TB SSD
  
Recomendado:
  CPU: AMD Threadripper PRO 3955WX (16 cores)
  RAM: 64 GB DDR4
  GPU: 2× NVIDIA RTX 4090 (24 GB VRAM cada)
  Storage: 2 TB NVMe SSD
  
Estimativa de Custo:
  Bare-Metal: R$ 25.000 - 40.000
  Cloud (AWS p3.8xlarge): R$ 15.000/mês
```

### 1.3 Servidor de Banco de Dados

```yaml
Especificações:
  CPU: 16 cores
  RAM: 32 GB DDR4 (mínimo para Postgres com 258M registros)
  Storage: 2 TB SSD (1 TB dados + 1 TB backups)
  Network: 1 Gbps
  
Estimativa de Custo:
  Bare-Metal: R$ 15.000
  Cloud (AWS r6i.4xlarge): R$ 4.000/mês
```

---

## 2. Arquitetura de Rede

### 2.1 Topologia

```
Internet
    │
    ▼
┌─────────────────────────────────────────────┐
│  Edge Layer (DMZ)                           │
│  ┌─────────┐       ┌──────┐                │
│  │ HAProxy │──────▶│ Kong │                │
│  └─────────┘       └──────┘                │
└────────────────┬────────────────────────────┘
                 │ Firewall
                 ▼
┌─────────────────────────────────────────────┐
│  Application Layer (Private VLAN 10.0.1.0)  │
│  ┌────────┐  ┌─────────┐  ┌─────────┐      │
│  │ Django │  │ FastAPI │  │MediaMTX │      │
│  └────────┘  └─────────┘  └─────────┘      │
└────────────────┬────────────────────────────┘
                 │ Internal Network
                 ▼
┌─────────────────────────────────────────────┐
│  Data Layer (Private VLAN 10.0.2.0)        │
│  ┌──────────┐  ┌───────┐  ┌────────┐       │
│  │ Postgres │  │ Redis │  │RabbitMQ│       │
│  └──────────┘  └───────┘  └────────┘       │
└─────────────────────────────────────────────┘
```

### 2.2 Firewall Rules (iptables)

```bash
# /etc/iptables/rules.v4

# Permitir loopback
-A INPUT -i lo -j ACCEPT

# Permitir conexões estabelecidas
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH (apenas de IPs da prefeitura)
-A INPUT -p tcp --dport 22 -s 200.100.50.0/24 -j ACCEPT

# HTTPS (público)
-A INPUT -p tcp --dport 443 -j ACCEPT

# RTSP (apenas de câmeras - range de IPs)
-A INPUT -p tcp --dport 8554 -s 10.20.30.0/24 -j ACCEPT

# Bloquear acesso direto ao Postgres (apenas via PgBouncer interno)
-A INPUT -p tcp --dport 5432 -s 0.0.0.0/0 -j DROP
-A INPUT -p tcp --dport 6432 -s 10.0.1.0/24 -j ACCEPT  # Apenas app layer

# Negar todo o resto
-A INPUT -j DROP

# Aplicar:
sudo iptables-restore < /etc/iptables/rules.v4
```

---

## 3. Docker Compose (Produção)

### 3.1 Arquivo Principal

```yaml
# docker-compose.prod.yml
version: '3.9'

networks:
  edge:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # Sem acesso à internet
  data:
    driver: bridge
    internal: true

volumes:
  postgres_data:
  redis_data:
  minio_data:
  hls_cache:

services:
  # Edge Layer
  haproxy:
    image: haproxy:2.8-alpine
    container_name: haproxy
    restart: always
    ports:
      - "443:443"
      - "8404:8404"  # Stats (apenas localhost)
    volumes:
      - ./config/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
      - /etc/ssl/certs:/etc/ssl/certs:ro
    networks:
      - edge
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8404/stats"]
      interval: 10s
      timeout: 5s
      retries: 3

  kong:
    image: kong:3.4-alpine
    container_name: kong
    restart: always
    environment:
      KONG_DATABASE: "off"
      KONG_DECLARATIVE_CONFIG: /kong.yml
      KONG_PROXY_LISTEN: 0.0.0.0:8000
      KONG_ADMIN_LISTEN: 127.0.0.1:8001  # Apenas localhost
      KONG_LOG_LEVEL: notice
    volumes:
      - ./config/kong.yml:/kong.yml:ro
    networks:
      - edge
      - backend
    healthcheck:
      test: ["CMD", "kong", "health"]
      interval: 10s
      timeout: 5s
      retries: 5

  mediamtx:
    image: bluenviron/mediamtx:latest
    container_name: mediamtx
    restart: always
    volumes:
      - ./config/mediamtx.yml:/mediamtx.yml:ro
      - hls_cache:/tmp/hls
    networks:
      - edge
      - backend
    ports:
      - "8554:8554"  # RTSP
      - "8888:8888"  # HLS
    deploy:
      resources:
        limits:
          cpus: '16'
          memory: 32G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8889/metrics"]
      interval: 15s
      timeout: 5s
      retries: 3

  # Application Layer
  django:
    image: gt-vision/django:latest
    container_name: django
    restart: always
    user: "1000:1000"  # Non-root
    command: gunicorn gt_vision.wsgi:application --workers 16 --bind 0.0.0.0:8000
    environment:
      DATABASE_URL: postgresql://postgres:${DB_PASSWORD}@pgbouncer:6432/gt_vision
      REDIS_URL: redis://redis:6379/0
      RABBITMQ_URL: amqp://rabbitmq:5672
      SECRET_KEY: ${DJANGO_SECRET_KEY}
      ALLOWED_HOSTS: "localhost,gt-vision.prefeitura.gov.br"
    volumes:
      - /secrets:/secrets:ro
    networks:
      - backend
      - data
    depends_on:
      - pgbouncer
      - redis
      - rabbitmq
    deploy:
      resources:
        limits:
          cpus: '8'
          memory: 16G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  ai-service:
    image: gt-vision/ai-service:latest
    container_name: ai-service
    restart: always
    user: "1000:1000"
    command: uvicorn main:app --host 0.0.0.0 --port 8001 --workers 4
    networks:
      - backend
      - data
    depends_on:
      - rabbitmq
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G

  ai-worker:
    image: gt-vision/ai-worker:latest
    restart: always
    user: "1000:1000"
    environment:
      YOLO_MODEL: yolov8n.pt
      GPU_ENABLED: "true"
    networks:
      - data
    depends_on:
      - rabbitmq
      - minio
    deploy:
      replicas: 2  # Horizontal scaling
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  watchdog:
    image: gt-vision/watchdog:latest
    container_name: watchdog
    restart: always
    environment:
      CHECK_INTERVAL: "15"
    networks:
      - backend
      - data
    depends_on:
      - redis

  # Data Layer
  postgres:
    image: postgres:15-alpine
    container_name: postgres
    restart: always
    environment:
      POSTGRES_DB: gt_vision
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./config/postgresql.conf:/etc/postgresql/postgresql.conf:ro
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
    networks:
      - data
    deploy:
      resources:
        limits:
          cpus: '8'
          memory: 16G
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgbouncer:
    image: pgbouncer/pgbouncer:1.21
    container_name: pgbouncer
    restart: always
    environment:
      DATABASES_HOST: postgres
      DATABASES_PORT: 5432
      DATABASES_USER: postgres
      DATABASES_PASSWORD: ${DB_PASSWORD}
      DATABASES_DBNAME: gt_vision
      PGBOUNCER_POOL_MODE: session
      PGBOUNCER_MAX_CLIENT_CONN: 200
      PGBOUNCER_DEFAULT_POOL_SIZE: 25
    networks:
      - data
    depends_on:
      - postgres
    healthcheck:
      test: ["CMD", "psql", "-h", "localhost", "-p", "6432", "-U", "postgres", "-c", "SELECT 1"]
      interval: 10s
      timeout: 5s
      retries: 3

  redis:
    image: redis:7-alpine
    container_name: redis
    restart: always
    command: redis-server --maxmemory 4gb --maxmemory-policy allkeys-lru --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - data
    deploy:
      resources:
        limits:
          memory: 4G
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

  rabbitmq:
    image: rabbitmq:3.12-management-alpine
    container_name: rabbitmq
    restart: always
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}
    networks:
      - data
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

  minio:
    image: minio/minio:latest
    container_name: minio
    restart: always
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_USER}
      MINIO_ROOT_PASSWORD: ${MINIO_PASSWORD}
    volumes:
      - minio_data:/data
    networks:
      - data
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 10s
      timeout: 5s
      retries: 3

  # Observabilidade
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: always
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    networks:
      - backend
    ports:
      - "127.0.0.1:9090:9090"  # Apenas localhost

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: always
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
    volumes:
      - ./config/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
    networks:
      - backend
    ports:
      - "127.0.0.1:3000:3000"

  loki:
    image: grafana/loki:latest
    container_name: loki
    restart: always
    volumes:
      - ./config/loki.yml:/etc/loki/local-config.yaml:ro
    networks:
      - backend
    ports:
      - "127.0.0.1:3100:3100"
```

### 3.2 Variáveis de Ambiente (.env)

```bash
# .env.production (NUNCA commitar no Git!)

# Database
DB_PASSWORD=<senha_forte_32_chars>

# Django
DJANGO_SECRET_KEY=<django_secret_key_50_chars>

# RabbitMQ
RABBITMQ_PASSWORD=<senha_forte>

# MinIO
MINIO_USER=admin
MINIO_PASSWORD=<senha_forte>

# Grafana
GRAFANA_PASSWORD=<senha_forte>

# Gerar senhas:
# openssl rand -base64 32
```

---

## 4. Deployment Procedure

### 4.1 Setup Inicial

```bash
#!/bin/bash
# scripts/setup_production.sh

set -e  # Para em qualquer erro

echo "🚀 GT-Vision Production Setup"

# 1. Validar pré-requisitos
command -v docker >/dev/null 2>&1 || { echo "Docker não instalado"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose não instalado"; exit 1; }

# 2. Criar diretórios
mkdir -p /opt/gt-vision/{config,secrets,backups,logs}
cd /opt/gt-vision

# 3. Gerar certificados SSL
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/gt-vision.key \
  -out /etc/ssl/certs/gt-vision.crt \
  -subj "/CN=gt-vision.prefeitura.gov.br"

# 4. Gerar par de chaves JWT (RS256)
ssh-keygen -t rsa -b 4096 -m PEM -f /opt/gt-vision/secrets/jwt-private.pem -N ""
openssl rsa -in /opt/gt-vision/secrets/jwt-private.pem -pubout -out /opt/gt-vision/secrets/jwt-public.pem

# 5. Gerar chave Fernet (criptografia RTSP URLs)
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())" > /opt/gt-vision/secrets/fernet.key

# 6. Configurar permissões
chown -R 1000:1000 /opt/gt-vision
chmod 600 /opt/gt-vision/secrets/*

# 7. Baixar imagens Docker
docker-compose -f docker-compose.prod.yml pull

# 8. Criar networks
docker network create gt-vision-edge
docker network create gt-vision-backend
docker network create gt-vision-data

# 9. Iniciar banco primeiro (migrations)
docker-compose -f docker-compose.prod.yml up -d postgres pgbouncer redis
sleep 10

# 10. Rodar migrations
docker-compose -f docker-compose.prod.yml run --rm django python manage.py migrate

# 11. Criar superuser
docker-compose -f docker-compose.prod.yml run --rm django python manage.py createsuperuser --noinput \
  --username admin --email admin@prefeitura.gov.br

# 12. Subir todos os serviços
docker-compose -f docker-compose.prod.yml up -d

# 13. Aguardar health checks
echo "⏳ Aguardando serviços ficarem healthy..."
for i in {1..30}; do
  if docker-compose -f docker-compose.prod.yml ps | grep -q "unhealthy"; then
    echo "Tentativa $i/30..."
    sleep 10
  else
    echo "✅ Todos os serviços estão healthy!"
    break
  fi
done

# 14. Teste de smoke
curl -k https://localhost/api/health
echo ""
echo "🎉 Setup concluído! Acesse https://$(hostname)/dashboard"
```

### 4.2 Deploy de Atualizações (Zero Downtime)

```bash
#!/bin/bash
# scripts/deploy.sh

SERVICE=$1  # django, ai-worker, etc.
VERSION=$2  # v1.2.3

echo "🔄 Deploying $SERVICE:$VERSION"

# 1. Build da nova imagem
docker build -t gt-vision/$SERVICE:$VERSION ./services/$SERVICE

# 2. Tag como latest
docker tag gt-vision/$SERVICE:$VERSION gt-vision/$SERVICE:latest

# 3. Rolling update (um por vez)
docker-compose -f docker-compose.prod.yml up -d --no-deps --scale $SERVICE=2 $SERVICE
sleep 30  # Aguarda health check

# 4. Remove versão antiga
docker-compose -f docker-compose.prod.yml up -d --no-deps --scale $SERVICE=1 $SERVICE

echo "✅ Deploy concluído"
```

### 4.3 Rollback

```bash
#!/bin/bash
# scripts/rollback.sh

SERVICE=$1
PREVIOUS_VERSION=$2

echo "⏪ Rolling back $SERVICE to $PREVIOUS_VERSION"

docker tag gt-vision/$SERVICE:$PREVIOUS_VERSION gt-vision/$SERVICE:latest
docker-compose -f docker-compose.prod.yml up -d --no-deps $SERVICE

echo "✅ Rollback concluído"
```

---

## 5. Backup & Disaster Recovery

### 5.1 Script de Backup Automático

```bash
#!/bin/bash
# scripts/backup.sh

BACKUP_DIR="/opt/gt-vision/backups"
DATE=$(date +%Y-%m-%d)

echo "💾 Iniciando backup - $DATE"

# 1. Backup do Postgres
docker exec postgres pg_dump -U postgres gt_vision | gzip > $BACKUP_DIR/postgres-$DATE.sql.gz

# 2. Backup do MinIO (apenas metadados, snapshots são muito grandes)
docker exec minio mc mirror /data $BACKUP_DIR/minio-$DATE --json > /dev/null

# 3. Backup das configs
tar -czf $BACKUP_DIR/config-$DATE.tar.gz /opt/gt-vision/config

# 4. Upload para S3 (offsite backup)
aws s3 sync $BACKUP_DIR s3://gt-vision-backups/ --storage-class GLACIER

# 5. Limpar backups locais > 30 dias
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

echo "✅ Backup concluído"
```

**Agendar via cron:**

```cron
# /etc/cron.d/gt-vision-backup
0 2 * * * root /opt/gt-vision/scripts/backup.sh >> /var/log/gt-vision-backup.log 2>&1
```

### 5.2 Procedure de Restore

```bash
#!/bin/bash
# scripts/restore.sh

BACKUP_FILE=$1  # postgres-2025-01-15.sql.gz

echo "🔄 Restaurando backup: $BACKUP_FILE"

# 1. Parar aplicação (manutenção)
docker-compose -f docker-compose.prod.yml stop django ai-service ai-worker

# 2. Restaurar banco
gunzip < /opt/gt-vision/backups/$BACKUP_FILE | docker exec -i postgres psql -U postgres gt_vision

# 3. Reiniciar aplicação
docker-compose -f docker-compose.prod.yml start django ai-service ai-worker

echo "✅ Restore concluído. Validar integridade:"
echo "SELECT COUNT(*) FROM cameras;"
```

---

## 6. Monitoring & Alerting

### 6.1 Dashboards Grafana

```yaml
# config/grafana/dashboards/main.json
{
  "dashboard": {
    "title": "GT-Vision Operational Dashboard",
    "panels": [
      {
        "title": "Câmeras Online",
        "targets": [{
          "expr": "count(camera_status{status='online'})"
        }]
      },
      {
        "title": "Latência de Streaming (P95)",
        "targets": [{
          "expr": "histogram_quantile(0.95, streaming_latency_seconds)"
        }]
      },
      {
        "title": "Fila de IA (Tamanho)",
        "targets": [{
          "expr": "rabbitmq_queue_messages{queue='vision_events'}"
        }]
      }
    ]
  }
}
```

### 6.2 Alertas (Prometheus)

```yaml
# config/prometheus/alerts.yml
groups:
  - name: gt_vision
    interval: 30s
    rules:
      - alert: HighOfflineCameras
        expr: (count(camera_status{status="offline"}) / count(camera_status)) > 0.10
        for: 5m
        annotations:
          summary: "Mais de 10% das câmeras estão offline"
          
      - alert: HighAPILatency
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 0.5
        for: 2m
        annotations:
          summary: "API com latência P95 > 500ms"
      
      - alert: AIQueueBacklog
        expr: rabbitmq_queue_messages{queue="vision_events"} > 10000
        for: 10m
        annotations:
          summary: "Fila de IA com mais de 10k mensagens pendentes"
```

### 6.3 Integração com Telegram

```python
# scripts/telegram_alert.py
import requests
import os

def send_alert(message):
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    chat_id = os.getenv('TELEGRAM_CHAT_ID')
    
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    requests.post(url, json={
        'chat_id': chat_id,
        'text': f"🚨 GT-Vision Alert:\n{message}",
        'parse_mode': 'Markdown'
    })

# Configurar no Prometheus Alertmanager:
# receivers:
#   - name: telegram
#     webhook_configs:
#       - url: http://alertmanager-bot:8080/alert
```

---

## 7. Troubleshooting

### 7.1 Container não inicia

```bash
# Ver logs
docker logs django --tail 100

# Verificar health check
docker inspect django | grep Health

# Entrar no container
docker exec -it django /bin/bash
```

### 7.2 Alto consumo de CPU

```bash
# Identificar processo
docker stats

# Se for MediaMTX:
# Verificar número de streams ativas
curl http://localhost:8889/metrics | grep mediamtx_paths_total

# Reduzir bitrate das câmeras ou aumentar recursos
```

### 7.3 Banco de dados lento

```bash
# Verificar conexões ativas
docker exec postgres psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Ver queries lentas
docker exec postgres psql -U postgres -c "SELECT query, calls, total_time FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"

# Se PgBouncer estiver saturado:
# Aumentar pool_size no pgbouncer.ini
```

---

**Versão:** 1.0  
**Autor:** DevOps Márcio  
**Última Revisão:** 19/Dez/2024