# 🚨 Registro de Riscos Técnicos - GT-Vision

**Última revisão:** 19/Dez/2025  
**Próxima revisão:** 22/Dez/2025

---

## 📊 Matriz de Riscos (Probabilidade × Impacto)

```
        BAIXO      MÉDIO      ALTO
ALTA    │  R08   │  R05   │  R01  │
        │        │  R06   │  R02  │
        ├────────┼────────┼───────┤
MÉDIA   │  R10   │  R04   │  R03  │
        │        │  R07   │       │
        ├────────┼────────┼───────┤
BAIXA   │  R09   │        │       │
        │        │        │       │
        └────────┴────────┴───────┘
```

---

## 🔴 RISCOS CRÍTICOS (Prioridade 1)

### R01: MediaMTX Não Escala para 100 Câmeras

**Categoria:** Arquitetura / Performance  
**Probabilidade:** 🔴 Alta (70%)  
**Impacto:** 🔴 Crítico  
**Status:** 🟡 Em Avaliação

#### Descrição do Problema
MediaMTX é projetado para cenários médios (10-30 streams). Em 100 câmeras:
- **CPU:** 100 processos FFmpeg = 500-1000% CPU (5-10 cores saturados)
- **RAM:** 100 streams × 100MB = 10GB só para buffers
- **I/O:** 400 Mbps de rede inbound + 400 Mbps outbound (HLS)

#### Evidências
```bash
# Teste preliminar com 10 câmeras:
docker stats mediamtx
# RESULTADO: CPU 180%, RAM 1.2GB
# PROJEÇÃO: 100 câmeras = CPU 1800% (18 cores), RAM 12GB
```

#### Soluções Propostas

**Opção A: Otimizar MediaMTX**
- **Ação:** Configurar `runOnDemandCloseAfter` para matar streams ociosos
- **Prós:** Mantém stack atual
- **Contras:** Limita a ~30 streams simultâneos
- **Custo:** 0
- **Prazo:** 2 dias

**Opção B: Migrar para SRS**
- **Ação:** Substituir MediaMTX por SRS (Simple Realtime Server)
- **Prós:** Suporta 500+ streams, cluster nativo
- **Contras:** Requer reescrita de configs, 5 dias de trabalho
- **Custo:** 0 (open source)
- **Prazo:** 5-7 dias

**Opção C: Sharding (Múltiplas Instâncias)**
- **Ação:** 4 servidores MediaMTX (25 câmeras cada)
- **Prós:** Escala horizontal
- **Contras:** Complexidade de roteamento, custos
- **Custo:** 3× servidores (R$ 1.5k/mês)
- **Prazo:** 3 dias

#### Decisão Recomendada
**OPÇÃO B** - Migrar para SRS até 25/Dez.  
Justificativa: Investimento inicial compensa para escalabilidade futura.

#### Plano de Ação
| Etapa | Responsável | Prazo | Status |
|:------|:------------|:------|:-------|
| Testar SRS com 20 câmeras | DevOps | 22/Dez | 🟡 Pendente |
| Comparar métricas vs MediaMTX | DevOps | 23/Dez | ⚪ Não Iniciado |
| Decisão GO/NO-GO | Arquiteto | 24/Dez | ⚪ Não Iniciado |
| Migração (se aprovado) | DevOps | 25/Dez | ⚪ Não Iniciado |

---

### R02: Falta de Estratégia de Storage (LPR)

**Categoria:** Arquitetura / Dados  
**Probabilidade:** 🔴 Alta (90%)  
**Impacto:** 🔴 Crítico  
**Status:** 🔴 Bloqueador Ativo

#### Descrição do Problema
Requisito **RF03** exige LPR, mas não há definição de onde armazenar:
- **Volume:** 100 câmeras × 1 frame/seg × 500KB × 86400s = **4.3TB/dia**
- **Retenção:** 7 dias (LGPD mínimo) = **30TB**
- **Busca:** Indexação por placa exige banco otimizado

#### Análise de Opções

**Opção 1: MinIO (S3-compatible local)**
| Aspecto | Avaliação |
|:--------|:----------|
| **Custo** | R$ 0 (hardware próprio) |
| **Latência** | < 50ms (rede local) |
| **Escalabilidade** | Até 500TB com cluster |
| **Complexidade** | Média (requer gerenciamento) |
| **Backup** | Manual (rsync para NAS) |

**Opção 2: AWS S3 (Cloud)**
| Aspecto | Avaliação |
|:--------|:----------|
| **Custo** | R$ 800-2k/mês (Standard) ou R$ 400/mês (Glacier Instant) |
| **Latência** | 100-200ms (internet) |
| **Escalabilidade** | Ilimitada |
| **Complexidade** | Baixa (gerenciado) |
| **Backup** | Automático (versionamento) |

**Opção 3: Filesystem Local (NFS)**
| Aspecto | Avaliação |
|:--------|:----------|
| **Custo** | R$ 0 |
| **Latência** | < 10ms |
| **Escalabilidade** | Limitada (disco físico) |
| **Complexidade** | Baixíssima |
| **Backup** | Manual (RAID 1 recomendado) |

#### Requisitos Técnicos Adicionais

**Indexação de Placas:**
```sql
-- PostgreSQL com pg_trgm para busca fuzzy
CREATE INDEX idx_plate_search ON detections 
USING gin (plate_text gin_trgm_ops);

-- Busca: "ABC-1234" retorna em < 100ms
SELECT * FROM detections 
WHERE plate_text % 'ABC-1234'  -- Similaridade
ORDER BY similarity(plate_text, 'ABC-1234') DESC;
```

**Lifecycle de Dados:**
```python
# Política de retenção
RETENTION_DAYS = 7

# Cron diário
def cleanup_old_snapshots():
    cutoff = datetime.now() - timedelta(days=RETENTION_DAYS)
    old_detections = Detection.objects.filter(timestamp__lt=cutoff)
    
    for detection in old_detections:
        # Deletar do S3/MinIO
        storage.delete(detection.snapshot_path)
        # Deletar metadados
        detection.delete()
```

#### Decisão Recomendada
**OPÇÃO 1** - MinIO com 4TB NVMe + Backup NAS.  
Justificativa: Controle total, latência baixa, custo zero de operação.

#### Plano de Ação
| Etapa | Responsável | Prazo | Status |
|:------|:------------|:------|:-------|
| Provisionar servidor com 4TB | Infra | 20/Dez | 🔴 URGENTE |
| Instalar MinIO cluster (3 nodes) | DevOps | 21/Dez | ⚪ Aguardando R01 |
| Configurar bucket policies | Backend | 22/Dez | ⚪ Não Iniciado |
| Testar upload de 1000 frames | QA | 23/Dez | ⚪ Não Iniciado |

---

### R03: PgBouncer Transaction Mode vs Django ORM

**Categoria:** Backend / Performance  
**Probabilidade:** 🔴 Alta (80%)  
**Impacto:** 🟡 Médio  
**Status:** 🟡 Mitigável

#### Descrição do Problema
```ini
# Configuração atual (roadmap):
pool_mode = transaction

# PROBLEMA: Django ORM usa prepared statements por padrão
# Resultado: Queries ficam 2-3× mais lentas
```

#### Evidências
```python
# Teste de benchmark:
import time
from django.db import connection

# Com Transaction Mode:
start = time.time()
Camera.objects.all()[:100]
print(f"Tempo: {time.time() - start}s")  # 0.8s

# Com Session Mode:
# Tempo esperado: 0.3s (2.6× mais rápido)
```

#### Soluções

**Opção A: Mudar para Session Mode**
```ini
# pgbouncer.ini
pool_mode = session
max_client_conn = 200
default_pool_size = 25
```
**Prós:** Simples, sem mudanças no Django  
**Contras:** Menos eficiente no pool (mais conexões abertas)

**Opção B: Desabilitar Prepared Statements**
```python
# settings.py
DATABASES = {
    'default': {
        'OPTIONS': {
            'prepared_statements': False
        }
    }
}
```
**Prós:** Mantém Transaction Mode  
**Contras:** Queries ficam ligeiramente mais lentas

#### Decisão Recomendada
**OPÇÃO A** - Session Mode.  
Justificativa: Performance > Eficiência de pool no cenário de leitura intensiva.

---

## 🟡 RISCOS DE ATENÇÃO (Prioridade 2)

### R04: RTSP URLs Sem Criptografia

**Categoria:** Segurança  
**Probabilidade:** 🟡 Média (50%)  
**Impacto:** 🟡 Médio  
**Status:** 🟢 Mitigável

#### Descrição
```python
# Cenário atual:
Camera.objects.create(
    rtsp_url="rtsp://admin:Senha@123@192.168.1.50:554/stream"
)
# Senha visível em:
# - Logs do Django
# - Backups do Postgres
# - SQL dumps
```

#### Solução
```python
# Usar django-cryptography
from django_cryptography.fields import encrypt

class Camera(models.Model):
    rtsp_url = encrypt(models.CharField(max_length=500))
    # Criptografado com Fernet (AES-128)
```

#### Plano de Ação
- [ ] Instalar `pip install django-cryptography`
- [ ] Gerar chave: `python manage.py generate_encryption_key`
- [ ] Adicionar `ENCRYPTION_KEY` no `.env`
- [ ] Migração: Criptografar URLs existentes

**Prazo:** 24/Dez  
**Responsável:** Backend

---

### R05: Latência HLS vs Requisito (<5s)

**Categoria:** Performance  
**Probabilidade:** 🔴 Alta (90%)  
**Impacto:** 🟡 Médio  
**Status:** 🟡 Trade-off Aceito

#### Descrição do Problema
```
Requisito (RNF01): Latência < 5 segundos
Realidade HLS: 6-10 segundos (mínimo)

Causas:
- Segmento HLS = 2s (padrão)
- Buffer do player = 3 segmentos = 6s
- Rede + processing = +2-4s
```

#### Análise de Alternativas

**Opção A: LL-HLS (Low Latency HLS)**
- **Latência:** 2-3s
- **Prós:** Compatível com HLS.js
- **Contras:** Requer encoder específico, complexo
- **Viabilidade:** Baixa para MVP

**Opção B: WebRTC**
- **Latência:** < 1s
- **Prós:** Real-time verdadeiro
- **Contras:** Complexidade alta, problemas de NAT
- **Viabilidade:** Média (Sprint 6+)

**Opção C: Aceitar Trade-off**
- **Latência:** 6-10s (HLS padrão)
- **Prós:** Simples, estável
- **Contras:** Não atende requisito estrito
- **Viabilidade:** Alta

#### Decisão Recomendada
**OPÇÃO C** - Aceitar 6-10s para MVP.  
**Ação:** Validar com stakeholder se latência é hard requirement.

---

### R06: Ausência de Circuit Breaker

**Categoria:** Resiliência  
**Probabilidade:** 🔴 Alta (70%)  
**Impacto:** 🟡 Médio  
**Status:** 🟡 Mitigável

#### Descrição do Problema
```python
# Cenário: 10 câmeras ficam offline
# Sistema atual vai ficar tentando reconectar infinitamente
# Resultado: Consumo de CPU/RAM desnecessário
```

#### Solução
```python
from circuitbreaker import circuit

@circuit(failure_threshold=5, recovery_timeout=60)
def connect_rtsp(camera_url):
    """
    Após 5 falhas consecutivas:
    - Para de tentar por 60 segundos
    - Marca câmera como "suspended"
    """
    pass
```

**Prazo:** Sprint 3  
**Responsável:** Backend

---

### R07: JWT Sem Rotação de Chaves

**Categoria:** Segurança  
**Probabilidade:** 🟡 Média (40%)  
**Impacto:** 🟡 Médio  
**Status:** 🟢 Mitigável

#### Problema
```python
# Se a chave privada vazar, TODOS os tokens ficam comprometidos
# Sem rotação, sistema precisa ser derrubado para trocar chave
```

#### Solução
```python
# settings.py
SIMPLE_JWT = {
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'SIGNING_KEY_ROTATION_INTERVAL': timedelta(days=30)
}
```

**Prazo:** Sprint 2  
**Responsável:** Backend

---

## ⚪ RISCOS BAIXOS (Monitoramento)

### R08: Falta de Testes E2E

**Probabilidade:** 🟡 Média  
**Impacto:** 🟢 Baixo  
**Status:** Planejado para Sprint 4

#### Ação
- Implementar Cypress/Playwright para testar fluxo completo:
  - Login → Grid → Reproduzir Câmera

---

### R09: Documentação Desatualizada

**Probabilidade:** 🟢 Baixa  
**Impacto:** 🟢 Baixo  
**Status:** Processo Contínuo

#### Ação
- Code Freeze diário (22/Dez+): Atualizar README.md

---

### R10: Falta de Monitoramento em Produção

**Probabilidade:** 🟡 Média  
**Impacto:** 🟡 Médio  
**Status:** Planejado para Sprint 5

#### Ação
- Configurar Prometheus + Grafana
- Alertas: CPU > 80%, Câmera offline > 5 min

---

## 📊 Resumo Executivo

| Categoria | Críticos | Atenção | Baixos | Total |
|:----------|:---------|:--------|:-------|:------|
| Arquitetura | 2 | 1 | 0 | **3** |
| Segurança | 0 | 2 | 0 | **2** |
| Performance | 1 | 1 | 0 | **2** |
| Qualidade | 0 | 1 | 2 | **3** |
| **TOTAL** | **3** | **5** | **2** | **10** |

---

## 🎯 Ações Imediatas (Esta Semana)

| Prioridade | Risco | Ação | Deadline |
|:-----------|:------|:-----|:---------|
| 🔴 P0 | R02 | Provisionar servidor 4TB | 20/Dez |
| 🔴 P0 | R01 | Testar SRS com 20 câmeras | 22/Dez |
| 🟡 P1 | R03 | Mudar PgBouncer para Session Mode | 23/Dez |
| 🟡 P1 | R04 | Implementar criptografia RTSP | 24/Dez |
| 🟢 P2 | R05 | Validar latência com stakeholder | 24/Dez |

---

## 📞 Contato para Escalação

| Risco Relacionado | Responsável | Contato |
|:------------------|:------------|:--------|
| R01, R02 | Arquiteto | @arquiteto |
| R03, R04, R06, R07 | Tech Lead Backend | @backend |
| R05 | Product Owner | @po |
| R08, R10 | QA Lead | @qa |

---

**Próxima Revisão:** 22/Dez/2025 (Daily Standup)
