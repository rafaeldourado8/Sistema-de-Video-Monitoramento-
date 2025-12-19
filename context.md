# Contexto do Projeto: GT-Vision (MVP)

## 🎯 Objetivo
Sistema de monitoramento urbano (VMS) para **100 câmeras RTSP** simultâneas com **LPR (Leitura de Placas)** e baixa latência (< 8s).
**Prazo MVP:** 30/Jan/2025.

## 🏗️ Arquitetura & Stack
- **Padrão:** Clean Architecture (DDD) + Microsserviços
- **Infra:** Docker Compose (3 Redes Isoladas: `edge`, `backend`, `data`)
- **Edge Layer:** HAProxy (SSL/TLS 1.3) -> Kong Gateway (JWT Auth) -> MediaMTX (Streaming RTSP/HLS)
- **Backend Layer:** Django 4.2 (API Monolito Modular) + FastAPI (Ingestão IA)
- **Data Layer:** PostgreSQL 15 (c/ PgBouncer), Redis 7, RabbitMQ 3.12, MinIO (S3)
- **IA:** YOLOv8 + EasyOCR (Workers assíncronos)

## 📍 Estado Atual (19/Dez/2024)
- **Sprint:** 1 (Infraestrutura) -> Transição para Sprint 2 (Core Dev).
- **Status da Infra:**
  - `docker-compose.yml` configurado e validado.
  - Certificados SSL e chaves JWT/Fernet gerados em `secrets/`.
  - Configurações de HAProxy, Kong e MediaMTX aplicadas em `config/`.
  - Esqueleto do Backend criado em `services/backend/` (Dockerfile, requirements.txt, entrypoint.sh).
- **Última Ação:** Correção do build do container `backend` criando os arquivos que faltavam via script PowerShell.

## 📂 Estrutura de Pastas (DDD)
```text
vms-mvp/
├── docker-compose.yml          # Orquestração
├── services/
│   ├── backend/                # Django API
│   │   ├── core/               # Domínio (Entidades, UseCases) - PURO PYTHON
│   │   ├── infrastructure/     # Adaptadores (Django Views, Repositories, Mensageria)
│   │   └── gt_vision/          # Settings do Django
│   ├── ai-service/             # FastAPI Ingest
│   └── ai-worker/              # Consumers RabbitMQ
├── config/                     # Configs de Infra (HAProxy, Kong, etc)
└── secrets/                    # Chaves (GitIgnore)