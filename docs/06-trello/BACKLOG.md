# 📋 Backlog GT-Vision - Pronto para Trello

## 🎨 Estrutura de Boards Sugerida

```
Board: GT-Vision MVP
├── Lista: 🔴 BLOQUEADORES
├── Lista: 📥 BACKLOG
├── Lista: 🚀 SPRINT ATUAL
├── Lista: 👷 EM PROGRESSO
├── Lista: 🧪 EM TESTES
├── Lista: ✅ CONCLUÍDO
└── Lista: 🗄️ ARQUIVO
```

---

## 🔴 BLOQUEADORES (Cartões Urgentes)

### CARD-001: Validar Capacidade MediaMTX
**Labels:** `BLOQUEADOR` `Infra` `Sprint-1`  
**Prazo:** 22/Dez  
**Responsável:** DevOps

**Descrição:**
Validar se MediaMTX suporta 100 streams RTSP simultâneos.

**Critérios de Aceite:**
- [ ] Subir 20 câmeras fake em loop
- [ ] Medir CPU, RAM, Rede por 1 hora
- [ ] Documentar métricas: CPU < 60%, RAM < 16GB
- [ ] Decisão: Seguir com MediaMTX ou migrar para SRS

**Checklist:**
```bash
# 1. Criar docker-compose-test.yml
docker-compose -f docker-compose-test.yml up

# 2. Executar script de carga
python scripts/stress_test_rtsp.py --cameras=20

# 3. Monitorar
docker stats mediamtx
```

**Anexos:**
- [ ] Script: `stress_test_rtsp.py`
- [ ] Resultado: `metrics_report.csv`

---

### CARD-002: Definir Estratégia de Storage
**Labels:** `BLOQUEADOR` `Arquitetura` `Sprint-1`  
**Prazo:** 20/Dez  
**Responsável:** Arquiteto

**Descrição:**
Decidir onde armazenar snapshots de LPR (100 câmeras × 1 frame/seg × 500KB = 50MB/s).

**Opções:**
| Solução | Prós | Contras | Custo/mês |
|---------|------|---------|-----------|
| **MinIO Local** | Baixa latência, controle total | Requer backup manual | R$ 0 |
| **AWS S3** | Escalável, backup automático | Latência, custos variáveis | R$ 800-2k |
| **NFS Local** | Simples | Não escala, ponto único de falha | R$ 0 |

**Critérios de Decisão:**
- [ ] Retenção: 7 dias (LGPD mínimo) ou 30 dias?
- [ ] Volume: 50MB/s × 86400s × 7 dias = **30TB**
- [ ] Budget disponível?

**Decisão Final:**
_[A preencher após reunião]_

---

### CARD-003: Corrigir Configuração PgBouncer
**Labels:** `BLOQUEADOR` `Backend` `Sprint-1`  
**Prazo:** 23/Dez  
**Responsável:** Backend

**Descrição:**
PgBouncer em Transaction Mode quebra prepared statements do Django ORM.

**Solução:**
```ini
# pgbouncer.ini
pool_mode = session  # EM VEZ DE transaction
max_client_conn = 200
default_pool_size = 25
```

**Testes:**
```python
# test_db_pooling.py
def test_pgbouncer_session_mode():
    # Abrir 50 conexões simultâneas
    # Verificar que queries ORM funcionam
    pass
```

---

## 📥 BACKLOG (Cartões Priorizados)

### SPRINT 1: Muralha de Infra (19/Dez - 25/Dez)

#### CARD-101: Setup Docker Compose Base
**Labels:** `Infra` `Sprint-1`  
**Story Points:** 5  
**Responsável:** DevOps

**Tasks:**
- [ ] Criar `docker-compose.yml` com redes isoladas
- [ ] Configurar serviços:
  - [ ] Postgres 15
  - [ ] PgBouncer
  - [ ] Redis 7
  - [ ] HAProxy
  - [ ] Kong (DB-less)
- [ ] Definir variáveis de ambiente (`.env.example`)
- [ ] Documentar comandos de inicialização

**Critérios de Aceite:**
```bash
docker-compose up -d
# Todos containers saudáveis em < 30s
docker-compose ps
```

---

#### CARD-102: Configurar HAProxy (SSL + Hardening)
**Labels:** `Segurança` `Infra` `Sprint-1`  
**Story Points:** 3

**Tasks:**
- [ ] Gerar certificado self-signed
- [ ] Configurar redirect HTTP → HTTPS
- [ ] Ocultar versão do servidor
- [ ] Habilitar HSTS

**Código:**
```haproxy
# haproxy.cfg
frontend https_front
    bind *:443 ssl crt /etc/ssl/certs/cert.pem
    http-response set-header Strict-Transport-Security "max-age=31536000"
    http-response del-header Server
```

---

#### CARD-103: Configurar Kong Gateway
**Labels:** `Gateway` `Infra` `Sprint-1`  
**Story Points:** 5

**Tasks:**
- [ ] Configurar modo DB-less (`kong.yml`)
- [ ] Criar rota `/api` → Django
- [ ] Configurar plugins:
  - [ ] Rate Limiting (100 req/min)
  - [ ] JWT Auth
  - [ ] CORS
- [ ] Testar rota protegida

**Teste de Fumaça:**
```bash
# Sem token = 401
curl -X GET http://localhost:8000/api/cameras

# Com token = 200
curl -H "Authorization: Bearer $TOKEN" \
     http://localhost:8000/api/cameras
```

---

#### CARD-104: Teste de Conectividade (Health Check)
**Labels:** `QA` `Sprint-1`  
**Story Points:** 2

**Descrição:**
Script Python que valida conectividade entre containers.

**Código:**
```python
# scripts/health_check.py
import psycopg2
import redis

def check_postgres():
    conn = psycopg2.connect(
        host="pgbouncer",
        database="gt_vision",
        user="admin",
        password="secret"
    )
    return conn.status == psycopg2.extensions.STATUS_READY

def check_redis():
    r = redis.Redis(host='redis', port=6379)
    return r.ping()

if __name__ == "__main__":
    assert check_postgres(), "Postgres FAIL"
    assert check_redis(), "Redis FAIL"
    print("✅ ALL SERVICES OK")
```

---

### SPRINT 1.5: Validação de Capacidade (26/Dez - 28/Dez)

#### CARD-105: Criar Câmeras Fake para Testes
**Labels:** `Infra` `Sprint-1.5`  
**Story Points:** 3

**Tasks:**
- [ ] Container com `rtsp-simple-server`
- [ ] 20 streams transmitindo vídeo em loop
- [ ] Script para simular câmeras ligando/desligando

**Docker Compose:**
```yaml
services:
  fake_camera_01:
    image: aler9/rtsp-simple-server
    volumes:
      - ./videos/sample.mp4:/stream.mp4
    environment:
      RTSP_PROTOCOLS: tcp
```

---

#### CARD-106: Teste de Carga Streaming
**Labels:** `QA` `Performance` `Sprint-1.5`  
**Story Points:** 5

**Descrição:**
Validar que o sistema aguenta 20 streams sem degradação.

**Métricas Esperadas:**
- CPU MediaMTX: < 60%
- RAM: < 8GB
- Latência HLS: < 10s
- Packet Loss: < 1%

**Tools:**
```bash
# Monitoramento
docker stats mediamtx
htop

# Rede
iftop -i eth0

# Logs
docker logs -f mediamtx | grep ERROR
```

---

### SPRINT 2: Core & Dados (29/Dez - 05/Jan)

#### CARD-201: Estrutura Django (Clean Architecture)
**Labels:** `Backend` `Sprint-2`  
**Story Points:** 8

**Estrutura:**
```
backend/
├── core/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── camera.py
│   │   │   └── user.py
│   │   └── use_cases/
│   │       ├── auth_use_case.py
│   │       └── camera_crud_use_case.py
│   └── infra/
│       ├── django_app/
│       │   ├── models.py
│       │   ├── serializers.py
│       │   └── views.py
│       └── repositories/
│           └── camera_repository.py
└── tests/
    ├── unit/
    └── integration/
```

---

#### CARD-202: Implementar Auth UseCase (JWT RS256)
**Labels:** `Backend` `Segurança` `Sprint-2`  
**Story Points:** 5

**Tasks:**
- [ ] Instalar `djangorestframework-simplejwt`
- [ ] Gerar par de chaves RSA
- [ ] Configurar JWT com RS256
- [ ] Endpoint `/auth/login`
- [ ] Endpoint `/auth/refresh`

**Testes:**
```python
# tests/unit/test_auth_use_case.py
def test_login_success():
    token = auth_use_case.login("admin", "senha123")
    assert token is not None

def test_login_invalid_password():
    with pytest.raises(UnauthorizedError):
        auth_use_case.login("admin", "errada")
```

---

#### CARD-203: CRUD de Câmeras + Signal RabbitMQ
**Labels:** `Backend` `Sprint-2`  
**Story Points:** 8

**Tasks:**
- [ ] Model `Camera` com campos:
  - [ ] `rtsp_url` (criptografado)
  - [ ] `status` (online/offline)
  - [ ] `last_ping`
- [ ] Signal `post_save` → Publicar no RabbitMQ
- [ ] Serializer DRF
- [ ] ViewSet (CRUD)

**Signal:**
```python
# signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
import pika

@receiver(post_save, sender=Camera)
def provision_camera(sender, instance, created, **kwargs):
    connection = pika.BlockingConnection(
        pika.ConnectionParameters('rabbitmq')
    )
    channel = connection.channel()
    channel.basic_publish(
        exchange='',
        routing_key='camera_provision',
        body=json.dumps({
            'id': str(instance.id),
            'rtsp_url': instance.rtsp_url,
            'action': 'create' if created else 'update'
        })
    )
```

**Teste Crítico:**
```python
def test_signal_publishes_to_rabbitmq(mocker):
    mock_publish = mocker.patch('pika.channel.basic_publish')
    Camera.objects.create(name="Cam 01", rtsp_url="rtsp://...")
    
    assert mock_publish.called
    assert "create" in mock_publish.call_args[1]['body']
```

---

#### CARD-204: Criptografia de RTSP URLs
**Labels:** `Backend` `Segurança` `Sprint-2`  
**Story Points:** 3

**Solução:**
```python
# Install
pip install django-cryptography

# models.py
from django_cryptography.fields import encrypt

class Camera(models.Model):
    rtsp_url = encrypt(models.CharField(max_length=500))
    # Automaticamente criptografado no banco
```

---

#### CARD-205: Teste de Integração Kong + Django
**Labels:** `QA` `Sprint-2`  
**Story Points:** 3

**Cenário:**
```python
# tests/integration/test_kong_jwt.py
def test_protected_route_without_token():
    response = requests.get("http://localhost:8000/api/cameras")
    assert response.status_code == 401

def test_protected_route_with_valid_token():
    token = get_jwt_token()
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(
        "http://localhost:8000/api/cameras",
        headers=headers
    )
    assert response.status_code == 200
```

---

### SPRINT 3: Pipeline de Vídeo (06/Jan - 15/Jan)

#### CARD-301: Configurar MediaMTX com runOnDemand
**Labels:** `Streaming` `Sprint-3`  
**Story Points:** 5

**Config:**
```yaml
# mediamtx.yml
paths:
  cam_{id}:
    runOnDemand: ffmpeg -rtsp_transport tcp -i {rtsp_url} -c copy -f rtsp rtsp://localhost:8554/cam_{id}
    runOnDemandRestart: yes
```

---

#### CARD-302: Script FFmpeg Otimizado
**Labels:** `Streaming` `Sprint-3`  
**Story Points:** 5

**Tasks:**
- [ ] FFmpeg com `-c:v copy` (sem transcodificação)
- [ ] Extrair 1 frame/seg via filtro `-vf fps=1`
- [ ] POST frame para API de IA

**Script:**
```bash
#!/bin/bash
CAMERA_ID=$1
RTSP_URL=$2

ffmpeg -rtsp_transport tcp -i "$RTSP_URL" \
  -c:v copy -f rtsp rtsp://mediamtx:8554/cam_$CAMERA_ID \
  -vf "fps=1" -q:v 2 -f image2pipe -vcodec mjpeg pipe:1 | \
  while read frame; do
    curl -X POST http://ai-service:8000/ingest \
         -H "Content-Type: image/jpeg" \
         --data-binary "@-"
  done
```

---

#### CARD-303: FastAPI para Ingestão de Frames
**Labels:** `IA` `Sprint-3`  
**Story Points:** 5

**Tasks:**
- [ ] Endpoint `POST /ingest`
- [ ] Validar imagem (tamanho, formato)
- [ ] Publicar na fila RabbitMQ

**Código:**
```python
# ai_service/main.py
from fastapi import FastAPI, UploadFile
import pika

app = FastAPI()

@app.post("/ingest")
async def ingest_frame(file: UploadFile):
    # Validar
    if file.content_type != "image/jpeg":
        return {"error": "Invalid format"}, 400
    
    # Publicar na fila
    channel.basic_publish(
        exchange='',
        routing_key='frames_queue',
        body=await file.read()
    )
    return {"status": "queued"}
```

---

#### CARD-304: Worker YOLO (Mock Inicial)
**Labels:** `IA` `Sprint-3`  
**Story Points:** 8

**Tasks:**
- [ ] Consumir fila `frames_queue`
- [ ] Mock: Detectar "Carro" aleatoriamente
- [ ] Salvar detecção no Postgres

**Worker:**
```python
# ai_worker/worker.py
import pika
import random

def callback(ch, method, properties, body):
    # Mock IA
    has_car = random.choice([True, False])
    
    if has_car:
        Detection.objects.create(
            camera_id="cam_01",
            type="car",
            confidence=0.85
        )
    
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(
    queue='frames_queue',
    on_message_callback=callback
)
channel.start_consuming()
```

---

### SPRINT 4: Frontend (16/Jan - 25/Jan)

#### CARD-401: Setup React + HLS.js
**Labels:** `Frontend` `Sprint-4`  
**Story Points:** 5

**Stack:**
- React 18 + TypeScript
- HLS.js para player
- Tailwind CSS

---

#### CARD-402: Página de Login + JWT
**Labels:** `Frontend` `Sprint-4`  
**Story Points:** 3

**Tasks:**
- [ ] Form com validação
- [ ] Armazenar token no localStorage
- [ ] Interceptor Axios para injetar token

---

#### CARD-403: Dashboard Grid (4/9 câmeras)
**Labels:** `Frontend` `Sprint-4`  
**Story Points:** 8

**Layout:**
```
┌─────────┬─────────┐
│ Cam 01  │ Cam 02  │
│ [LIVE]  │ [LIVE]  │
├─────────┼─────────┤
│ Cam 03  │ Cam 04  │
│ [OFFLINE] [LIVE]  │
└─────────┴─────────┘
```

---

#### CARD-404: Player com Tratamento de Erro
**Labels:** `Frontend` `Sprint-4`  
**Story Points:** 5

**Comportamento:**
- Stream OK: Mostra vídeo
- Stream Offline: Ícone "Sinal Perdido"
- Reconexão: Tentar novamente a cada 10s

---

### SPRINT 5: Deploy & Stress Test (26/Jan - 30/Jan)

#### CARD-501: Teste de Carga com Locust
**Labels:** `QA` `Performance` `Sprint-5`  
**Story Points:** 5

**Cenários:**
1. 100 usuários acessando API de câmeras
2. 20 streams RTSP simultâneos
3. IA processando 50 frames/seg

---

#### CARD-502: Deploy em Staging
**Labels:** `DevOps` `Sprint-5`  
**Story Points:** 8

**Tasks:**
- [ ] Configurar servidor (16 cores, 32GB RAM)
- [ ] Deploy via Docker Swarm ou Kubernetes
- [ ] Configurar SSL válido (Let's Encrypt)
- [ ] Monitoramento (Prometheus + Grafana)

---

## 🏷️ Labels Sugeridas no Trello

| Label | Cor | Uso |
|:------|:----|:----|
| `BLOQUEADOR` | 🔴 Vermelho | Impede progresso de outros cards |
| `Infra` | 🔵 Azul | DevOps, Docker, Rede |
| `Backend` | 🟢 Verde | Django, API |
| `Frontend` | 🟡 Amarelo | React |
| `IA` | 🟣 Roxo | YOLO, Processamento |
| `QA` | 🟠 Laranja | Testes |
| `Segurança` | ⚫ Preto | Autenticação, Criptografia |
| `Sprint-1` | ⬜ Branco | Identificador de Sprint |

---

## 📊 Automações Recomendadas

### Regra 1: Mover Bloqueadores para o Topo
```
Quando: Card recebe label "BLOQUEADOR"
Ação: Mover para o topo da lista atual
```

### Regra 2: Notificar no Slack
```
Quando: Card movido para "✅ CONCLUÍDO"
Ação: Postar no #gt-vision: "🎉 [Nome] concluiu [Card]"
```

### Regra 3: Alertar Prazo
```
Quando: Data de vencimento em 2 dias
Ação: Adicionar label "URGENTE"
```

---

## 📝 Template de Card (Copy/Paste)

```markdown
## [CARD-XXX] Título Claro

**Labels:** `Sprint-X` `Categoria`  
**Story Points:** X  
**Responsável:** @nome  
**Prazo:** DD/MMM

### Descrição
[O que precisa ser feito e por quê]

### Critérios de Aceite
- [ ] Critério 1
- [ ] Critério 2

### Tasks Técnicas
- [ ] Task 1
- [ ] Task 2

### Testes
```bash
# Como validar
comando_de_teste
```

### Dependências
- Depende de: CARD-YYY
- Bloqueia: CARD-ZZZ

### Notas
[Contexto adicional, links, screenshots]
```

---

## 🎯 Métricas para Acompanhar

### Dashboard no Trello (Power-Up)
- **Velocity Chart:** Story Points por Sprint
- **Burn Down:** Tasks restantes vs dias
- **Lead Time:** Tempo médio de conclusão de cards

### Reuniões
- **Daily:** 9h (15 min) - O que fiz, farei, bloqueios
- **Review:** Sexta 16h - Demo de entregas
- **Retro:** Sexta 17h - O que melhorar

---

**Próxima Atualização:** 22/Dez/2025
