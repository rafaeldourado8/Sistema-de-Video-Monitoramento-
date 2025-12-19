# GT-Vision - Sistema de Monitoramento Urbano Inteligente

**Status:** 🟢 Em Desenvolvimento (MVP - Jan/2025)  
**Versão:** 2.0 (Revisado em 19/Dez/2024)  
**Licença:** Proprietário (Prefeitura Municipal)

---

## 📋 Visão Geral

GT-Vision é um sistema de **video management (VMS)** para monitoramento urbano com **detecção inteligente de veículos e leitura de placas (LPR)**. Projetado para suportar **100 câmeras RTSP** simultâneas com latência inferior a 8 segundos.

### Principais Funcionalidades

- 🎥 **Streaming de Vídeo:** Ingestão RTSP → Transcodificação HLS com baixa latência
- 🤖 **IA Integrada:** Detecção de veículos (YOLO v8) + OCR de placas brasileiras
- 🔍 **Busca Inteligente:** Localizar veículos por placa em segundos
- 📊 **Dashboard Operacional:** Grid de 4, 9 ou 16 câmeras em tempo real
- 🔐 **Segurança B2G:** Criptografia TLS 1.3, JWT RS256, conformidade LGPD
- ⚡ **Alta Disponibilidade:** Uptime > 98%, reconexão automática

---

## 🏗️ Arquitetura (High-Level)

```
┌─────────────────────────────────────────────────────────────┐
│                      Operadores (CCO)                        │
│          React Frontend (Dashboard + Busca de Placas)       │
└────────────────────────────┬────────────────────────────────┘
                             │ HTTPS (443)
                             ▼
┌─────────────────────────────────────────────────────────────┐
│  Edge Layer: HAProxy (SSL) → Kong Gateway (JWT + RL)        │
└──────────────┬──────────────────────────┬───────────────────┘
               │                          │
        Django API (8000)           MediaMTX (8554 RTSP)
               │                          │
        ┌──────┴──────┐          ┌────────▼────────┐
        │   Postgres  │          │  FFmpeg Wrapper │
        │  PgBouncer  │          │  (Frame Extract)│
        │    Redis    │          └─────────┬───────┘
        └─────────────┘                    │
                                           ▼
                            ┌──────────────────────────┐
                            │  RabbitMQ (Vision Queue) │
                            └───────────┬──────────────┘
                                        │
                            ┌───────────▼──────────────┐
                            │  AI Workers (YOLO + OCR) │
                            │  → MinIO (Snapshots)     │
                            └──────────────────────────┘
```

### Stack Tecnológico

| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| **Edge** | HAProxy + Kong Gateway | 2.8 + 3.4 |
| **Streaming** | MediaMTX + FFmpeg | 1.3 + 6.1 |
| **Backend** | Django + DRF | 4.2 |
| **IA** | FastAPI + YOLO v8 + EasyOCR | 0.104 + 8.0 |
| **Database** | PostgreSQL 15 + PgBouncer | 15.5 |
| **Cache/Broker** | Redis 7 + RabbitMQ 3.12 | 7.2 + 3.12 |
| **Storage** | MinIO (S3-compatible) | Latest |
| **Frontend** | React 18 + TypeScript + HLS.js | 18.2 |
| **Monitoring** | Prometheus + Grafana + Loki | Latest |

---

## 📚 Documentação

### Estrutura de Documentos

```
docs/
├── 01-product/
│   ├── personas.md           # Usuários e suas necessidades
│   └── requirements.md       # Requisitos funcionais e não-funcionais
├── 02-architecture/
│   ├── components.md         # Detalhamento de cada componente
│   └── database.md           # Modelagem de dados + índices
├── 03-management/
│   └── roadmap.md            # Cronograma de sprints (19/Dez - 30/Jan)
├── 04-infrastructure/
│   └── deployment.md         # Guia de deploy e configs Docker
├── 05-security/
│   └── security-guidelines.md # Hardening e compliance LGPD
└── README.md                 # Este arquivo
```

### Início Rápido

1. **Entender o Produto:**
   - Leia [`01-product/personas.md`](./docs/01-product/personas.md) para entender os usuários
   - Consulte [`01-product/requirements.md`](./docs/01-product/requirements.md) para requisitos completos

2. **Arquitetura:**
   - [`02-architecture/components.md`](./docs/02-architecture/components.md): Detalhes de cada serviço
   - [`02-architecture/database.md`](./docs/02-architecture/database.md): Schema SQL e queries otimizadas

3. **Desenvolvimento:**
   - [`03-management/roadmap.md`](./docs/03-management/roadmap.md): Sprints e tarefas

4. **Deploy:**
   - [`04-infrastructure/deployment.md`](./docs/04-infrastructure/deployment.md): Guia completo de produção

5. **Segurança:**
   - [`05-security/security-guidelines.md`](./docs/05-security/security-guidelines.md): Checklist de hardening

---

## 🚀 Quick Start (Desenvolvimento)

### Pré-requisitos

```bash
# Sistema Operacional
Ubuntu 22.04 LTS (ou 24.04)

# Software
Docker 24+
Docker Compose 2.20+
Python 3.11+
Node.js 20+
Git
```

### Setup Local

```bash
# 1. Clone o repositório
git clone https://github.com/prefeitura/gt-vision.git
cd gt-vision

# 2. Configure variáveis de ambiente
cp .env.example .env
# Edite .env com suas credenciais

# 3. Gere secrets
./scripts/generate_secrets.sh

# 4. Suba os containers
docker-compose up -d

# 5. Rode migrations
docker-compose exec django python manage.py migrate

# 6. Crie superuser
docker-compose exec django python manage.py createsuperuser

# 7. Acesse
# Frontend: http://localhost:3000
# API: http://localhost:8000/api
# Admin: http://localhost:8000/admin
```

### Rodando Testes

```bash
# Testes Unitários (Django)
docker-compose exec django pytest tests/unit/ -v

# Testes de Integração
docker-compose exec django pytest tests/integration/ -v

# Testes E2E (Frontend)
cd frontend && npm run test:e2e

# Cobertura de Código
docker-compose exec django pytest --cov=. --cov-report=html
```

---

## 📊 Capacidade e Performance

### Especificações do MVP

| Métrica | Meta | Status Atual |
|---------|------|--------------|
| **Câmeras Simultâneas** | 100 | 🔶 Em teste (20) |
| **Latência de Streaming** | < 8s | 🔶 10s (otimizando) |
| **Taxa de Acerto LPR** | > 85% | 🔶 82% (treinando) |
| **Uptime** | > 98% | ✅ 99.2% (staging) |
| **Busca de Placas** | < 3s | ✅ 1.8s |
| **Resposta API (P95)** | < 200ms | ✅ 150ms |

### Recursos Necessários (100 Câmeras)

```yaml
Servidor de Streaming:
  CPU: 32 cores (64 threads)
  RAM: 64 GB
  Storage: 2 TB NVMe SSD
  Network: 10 Gbps

Servidor de IA:
  CPU: 16 cores
  RAM: 32 GB
  GPU: 2× NVIDIA RTX 3060 (12 GB VRAM)
  Storage: 1 TB SSD

Servidor de Banco:
  CPU: 16 cores
  RAM: 32 GB
  Storage: 2 TB SSD
  
Estimativa de Custo:
  Bare-Metal: R$ 70.000 - 120.000 (one-time)
  Cloud (AWS): R$ 25.000 - 35.000/mês
```

---

## 🛡️ Segurança

### Conformidade

- ✅ **LGPD:** Criptografia de dados pessoais, retenção de 7-30 dias, logs de auditoria
- ✅ **Marco Civil:** Retenção de logs de acesso por 6 meses
- 🔶 **ISO 27001:** Em progresso (certificação planejada para 2025)

### Principais Controles

```
🔐 Criptografia:
   - TLS 1.3 (em trânsito)
   - Fernet (RTSP URLs em repouso)
   - JWT RS256 (autenticação)

🚪 Controle de Acesso:
   - RBAC (Admin, Operator, Viewer)
   - Rate Limiting (anti-DDoS)
   - Fail2Ban (força bruta)

📝 Auditoria:
   - Logs estruturados (JSON)
   - Correlation IDs (rastreabilidade)
   - Retenção de 6 meses

🎯 Vulnerability Management:
   - Scan automático (Trivy)
   - Patch mensal
   - Dependency updates
```

Consulte [**Security Guidelines**](./docs/05-security/security-guidelines.md) para checklist completo.

---

## 📅 Roadmap

### Fase MVP (19/Dez/2024 - 30/Jan/2025)

| Sprint | Data | Objetivo | Status |
|--------|------|----------|--------|
| **Sprint 0** | 16-18/Dez | Validação de Arquitetura | ✅ Completo |
| **Sprint 1** | 19-25/Dez | Infra + Gateway + Segurança | 🔶 Em Andamento |
| **Sprint 2** | 26/Dez - 05/Jan | Django Core + Auth + CRUD | ⏳ Pendente |
| **Sprint 3** | 06-15/Jan | Streaming + IA Pipeline | ⏳ Pendente |
| **Sprint 4** | 16-25/Jan | Frontend React + UX | ⏳ Pendente |
| **Sprint 5** | 26-30/Jan | Code Freeze + Hardening | ⏳ Pendente |

**Go-Live:** 30/Jan/2025

### Fase 2 (Fev-Mar/2025)

- Dashboard Executivo (KPIs de Uptime)
- Alertas no Telegram/WhatsApp
- Integração com CAD (Computer-Aided Dispatch)
- Auditoria de Acesso (Compliance LGPD)

### Backlog (Q2/2025)

- App Mobile Nativo (Android/iOS)
- Reconhecimento Facial (após adequação LGPD)
- Multi-tenancy (SaaS para outras prefeituras)

Consulte [**Roadmap Detalhado**](./docs/03-management/roadmap.md) para cronograma completo.

---

## 🧪 Testing Strategy

### Pirâmide de Testes

```
         ┌─────────────┐
         │  E2E Tests  │  10% (Playwright)
         └─────────────┘
       ┌───────────────────┐
       │ Integration Tests │  30% (pytest + requests)
       └───────────────────┘
    ┌──────────────────────────┐
    │     Unit Tests           │  60% (pytest + mock)
    └──────────────────────────┘
```

### Cobertura de Código

- **Meta:** > 80%
- **Atual:** 78% (Django), 65% (React)
- **Bloqueio de PR:** Se cobertura < 75%

### Testes de Carga

```bash
# Simular 100 operadores por 8 horas
locust -f tests/load/locustfile.py --users 100 --run-time 8h

# Critérios de Aceitação:
# - 0 erros HTTP 500
# - P95 latência < 500ms
# - CPU < 80%, RAM < 90%
```

---

## 🐛 Troubleshooting

### Problemas Comuns

**1. Container não inicia:**
```bash
docker logs <container_name> --tail 100
docker inspect <container_name> | grep Health
```

**2. Câmera não aparece no grid:**
```bash
# Verificar se stream está ativo no MediaMTX
curl http://localhost:8889/metrics | grep mediamtx_paths

# Verificar logs do FFmpeg
docker logs ffmpeg-wrapper-<camera_id>
```

**3. Banco de dados lento:**
```bash
# Ver queries lentas
docker exec postgres psql -U postgres -c "
  SELECT query, calls, total_time 
  FROM pg_stat_statements 
  ORDER BY total_time DESC LIMIT 10;
"
```

**4. GPU não detectada nos workers de IA:**
```bash
# Verificar driver NVIDIA
nvidia-smi

# Verificar dentro do container
docker exec ai-worker nvidia-smi
```

Consulte [**Deployment Guide**](./docs/04-infrastructure/deployment.md) para mais troubleshooting.

---

## 👥 Time

| Papel | Responsável | Contato |
|-------|-------------|---------|
| **Product Owner** | Sargento Ana | ana@prefeitura.gov.br |
| **Tech Lead** | Carlos Dev | carlos@prefeitura.gov.br |
| **DevOps** | Márcio | marcio@prefeitura.gov.br |
| **Frontend** | Julia | julia@prefeitura.gov.br |
| **QA** | Roberto | roberto@prefeitura.gov.br |

### Comunicação

- **Daily Standup:** 9h (15 min)
- **Sprint Planning:** Segunda-feira, 14h (2h)
- **Sprint Review:** Sexta-feira, 15h (1h)
- **Retrospectiva:** Sexta-feira, 16h (1h)

**Canais:**
- Slack: #gt-vision-dev
- Email: gt-vision@prefeitura.gov.br
- On-Call: +55 11 99999-0000 (24/7)

---

## 📝 Licença

Copyright © 2024 Prefeitura Municipal. Todos os direitos reservados.

Este software é proprietário e seu uso é restrito aos órgãos da administração pública municipal.

---

## 🆘 Suporte

### Para Operadores (CCO)

- **Manual do Usuário:** `docs/user-manual.pdf`
- **Vídeos Tutoriais:** https://youtube.com/gt-vision-tutorials
- **Suporte Técnico:** suporte@prefeitura.gov.br | (11) 3000-0000

### Para Desenvolvedores

- **Wiki Técnico:** https://wiki.prefeitura.gov.br/gt-vision
- **API Docs (Swagger):** https://gt-vision.prefeitura.gov.br/api/docs
- **Code Review Guidelines:** `docs/contributing.md`

### Reportar Bugs

```bash
# Template de Issue
Título: [BUG] Descrição curta do problema

**Descrição:**
O que aconteceu? O que era esperado?

**Passos para Reproduzir:**
1. Faça login como operador
2. Acesse dashboard
3. ...

**Ambiente:**
- Versão: v1.2.3
- Browser: Chrome 120
- SO: Windows 10

**Logs:**
```
[Cole logs relevantes aqui]
```

**Screenshots:**
[Se aplicável]
```

---

## 🎯 Métricas de Sucesso

### KPIs Operacionais

| Indicador | Meta | Como Medir |
|-----------|------|------------|
| **Uptime** | > 98% | Grafana Dashboard |
| **MTTD** (Mean Time To Detect) | < 2 min | Prometheus Alerts |
| **MTTR** (Mean Time To Repair) | < 15 min | Incident Logs |
| **Satisfação do Usuário (SUS)** | > 80/100 | Survey trimestral |

### KPIs de Negócio

| Indicador | Meta | Como Medir |
|-----------|------|------------|
| **Incidentes Resolvidos** | +30% | Sistema vs. Baseline |
| **Tempo de Resposta** | -20% | CCO Logs |
| **Veículos Localizados** | +50% | Busca de Placas |
| **ROI** | Positivo em 12 meses | Análise Financeira |

---

## 🔗 Links Úteis

- **Repositório Git:** https://github.com/prefeitura/gt-vision
- **CI/CD Pipeline:** https://jenkins.prefeitura.gov.br/gt-vision
- **Monitoring (Grafana):** https://grafana.prefeitura.gov.br/gt-vision
- **Staging Environment:** https://staging.gt-vision.prefeitura.gov.br
- **Production:** https://gt-vision.prefeitura.gov.br

---

## 📖 Changelog

### v2.0 (19/Dez/2024) - Revisão Arquitetural
- ✅ Documentação completa revisada (100+ páginas)
- ✅ Roadmap blindado com testes e gates de qualidade
- ✅ Segurança endurecida (LGPD compliance)
- ✅ Particionamento de banco para 258M registros
- ✅ Circuit Breaker para resiliência
- ✅ Estratégia de storage (MinIO + lifecycle)

### v1.0 (01/Dez/2024) - MVP Inicial
- ✅ Estrutura de projeto Django
- ✅ Docker Compose básico
- ✅ Proof of Concept com 5 câmeras

---

**🚀 Vamos construir o melhor sistema de monitoramento urbano do Brasil!**

Para dúvidas ou contribuições, entre em contato com o time via Slack (#gt-vision-dev).