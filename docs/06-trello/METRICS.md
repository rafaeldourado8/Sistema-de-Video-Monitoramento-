# 📊 Métricas e KPIs - GT-Vision

**Período:** Sprint 1 (19/Dez - 25/Dez)  
**Atualização:** Diária

---

## 🎯 Objetivos Mensuráveis do Projeto

| KPI | Meta MVP | Atual | Status |
|:----|:---------|:------|:-------|
| **Câmeras Simultâneas** | 100 | 0 | ⚪ 0% |
| **Latência Live View** | < 5s | N/A | ⚪ Não testado |
| **Uptime Sistema** | > 99% | N/A | ⚪ Não aplicável |
| **Acurácia LPR** | > 90% | N/A | ⚪ Não aplicável |
| **Tempo de Reconexão** | < 10s | N/A | ⚪ Não testado |

---

## 📈 Progresso de Desenvolvimento

### Velocity da Equipe (Story Points)

```
Sprint | Planejado | Concluído | % Atingido
-------|-----------|-----------|------------
   1   |    25     |     0     |    0%
   2   |    30     |     -     |    -
   3   |    35     |     -     |    -
   4   |    30     |     -     |    -
   5   |    25     |     -     |    -
-------|-----------|-----------|------------
TOTAL  |   145     |     0     |    0%
```

### Burn Down Chart (Sprint 1)

```
Story Points
25 ┤           ○ (Ideal)
   │          ○
20 │         ○
   │        ○
15 │       ○
   │      ○
10 │     ○
   │    ○
 5 │   ○
   │  ○
 0 └──────────────────
   19  20  21  22  23  24  25 (Dez)
   
● Atual: 25 pontos restantes
○ Ideal: Linha reta até 0
```

**Análise:**
- 🔴 **Status:** No prazo / 🟡 Risco / 🟢 Adiantado
- **Comentário:** _[Preencher diariamente]_

---

## 🧪 Qualidade de Código

### Cobertura de Testes

```
Tipo            | Atual | Meta  | Status
----------------|-------|-------|--------
Unitários       |   0%  |  80%  | 🔴
Integração      |   0%  |  60%  | 🔴
E2E             |   0%  |  40%  | 🔴
----------------|-------|-------|--------
TOTAL           |   0%  |  65%  | 🔴
```

### Métricas de Código (SonarQube / CodeClimate)

| Métrica | Atual | Meta | Status |
|:--------|:------|:-----|:-------|
| **Bugs** | - | 0 | ⚪ |
| **Vulnerabilidades** | - | 0 | ⚪ |
| **Code Smells** | - | < 50 | ⚪ |
| **Duplicação** | - | < 5% | ⚪ |
| **Complexidade Ciclomática** | - | < 10 (média) | ⚪ |

---

## ⚡ Performance do Sistema

### Métricas de Streaming (Objetivo: 100 câmeras)

| Câmeras Ativas | CPU (%) | RAM (GB) | Rede In (Mbps) | Rede Out (Mbps) | Latência (s) |
|:---------------|:--------|:---------|:---------------|:----------------|:-------------|
| 0 | - | - | - | - | - |
| 10 | - | - | - | - | - |
| 20 | - | - | - | - | - |
| 50 | - | - | - | - | - |
| 100 | - | - | - | - | - |

**Meta para 100 câmeras:**
- CPU: < 60%
- RAM: < 24GB (de 32GB)
- Latência: < 5s

### Métricas de API (Backend)

| Endpoint | Req/s | P50 (ms) | P95 (ms) | P99 (ms) | Erros (%) |
|:---------|:------|:---------|:---------|:---------|:----------|
| `GET /cameras` | - | - | - | - | - |
| `POST /auth/login` | - | - | - | - | - |
| `GET /detections` | - | - | - | - | - |

**Meta:**
- P95 < 200ms
- Erros < 1%

---

## 🐛 Qualidade e Bugs

### Bugs por Severidade

```
Severidade    | Abertos | Resolvidos | Total
--------------|---------|------------|-------
🔴 Críticos   |    0    |     0      |   0
🟡 Médios     |    0    |     0      |   0
🟢 Baixos     |    0    |     0      |   0
--------------|---------|------------|-------
TOTAL         |    0    |     0      |   0
```

### Taxa de Resolução de Bugs

```
Semana | Abertos | Fechados | Taxa
-------|---------|----------|------
  1    |    -    |    -     |  -%
  2    |    -    |    -     |  -%
  3    |    -    |    -     |  -%
```

**Meta:** Taxa > 90% (Fechar mais bugs do que abre)

---

## 🚀 Deployment e Releases

### Deploy Frequency

| Ambiente | Deploys Esta Semana | Deploys Total |
|:---------|:-------------------|:--------------|
| Dev | 0 | 0 |
| Staging | 0 | 0 |
| Produção | 0 | 0 |

### Lead Time (Tempo de Entrega)

```
Card → Dev → Review → Merge → Deploy

Média Atual: - dias
Meta: < 2 dias
```

### Change Failure Rate

```
Deploys com Rollback / Total Deploys

Atual: - %
Meta: < 5%
```

---

## 👥 Métricas de Equipe

### Capacidade da Sprint

| Desenvolvedor | Disponibilidade | Story Points |
|:--------------|:----------------|:-------------|
| Dev 1 | 8h/dia × 5 dias = 40h | 10 pts |
| Dev 2 | 8h/dia × 5 dias = 40h | 10 pts |
| Dev 3 | 6h/dia × 5 dias = 30h | 5 pts |
| **TOTAL** | **110h** | **25 pts** |

### Distribuição de Trabalho

```
          Dev 1    Dev 2    Dev 3
Backend    ████     ██       ░
Frontend   ░        ████     ██
DevOps     ██       ░        ████
```

### Code Review Metrics

| Métrica | Atual | Meta |
|:--------|:------|:-----|
| **Tempo Médio de Review** | - | < 4h |
| **PRs Abertos** | 0 | < 5 |
| **PRs Mergeados Hoje** | 0 | - |

---

## 🔐 Segurança

### Vulnerabilidades (OWASP Top 10)

| Tipo | Identificadas | Corrigidas | Status |
|:-----|:-------------|:-----------|:-------|
| SQL Injection | 0 | 0 | ✅ |
| XSS | 0 | 0 | ✅ |
| CSRF | 0 | 0 | ✅ |
| Auth Broken | 0 | 0 | ✅ |
| Sensitive Data Exposure | 0 | 0 | ✅ |

### Dependências com CVEs

```bash
# Executar semanalmente:
pip-audit
npm audit

Críticas: 0
Altas: 0
Médias: 0
```

---

## 💰 Custos (Orçamento)

### Infraestrutura

| Recurso | Custo Mensal | Custo Acumulado |
|:--------|:-------------|:----------------|
| Servidor Bare-Metal | R$ 0 (próprio) | R$ 0 |
| Storage (MinIO) | R$ 0 | R$ 0 |
| Rede (IP fixo) | R$ 150 | R$ 0 |
| **TOTAL** | **R$ 150** | **R$ 0** |

**Budget MVP:** R$ 5.000  
**Gasto Atual:** R$ 0 (0%)

---

## 🎯 OKRs (Objectives & Key Results)

### Objective 1: Sistema Estável e Escalável
- **KR1:** Suportar 100 câmeras simultâneas com < 60% CPU
  - **Atual:** 0/100 câmeras (0%)
- **KR2:** Uptime > 99% em Staging
  - **Atual:** N/A
- **KR3:** Tempo de reconexão < 10s
  - **Atual:** N/A

### Objective 2: Alta Qualidade de Código
- **KR1:** Cobertura de testes > 65%
  - **Atual:** 0%
- **KR2:** 0 bugs críticos em produção
  - **Atual:** 0 (✅)
- **KR3:** Code Review em < 4h
  - **Atual:** N/A

### Objective 3: Entrega no Prazo
- **KR1:** Todas as Sprints concluídas com > 80% de Story Points
  - **Sprint 1:** 0% (🔴)
- **KR2:** Deploy em Staging até 30/Jan
  - **Status:** No prazo (⚪)

---

## 📊 Dashboard Resumido (Copiar para Trello)

```
┌─────────────────────────────────────────────┐
│  GT-VISION MVP - STATUS DASHBOARD           │
├─────────────────────────────────────────────┤
│  Progresso Geral:        ████░░░░░░  8%    │
│  Dias Restantes:         42 dias            │
│  Bloqueadores Ativos:    2 🔴              │
│  Bugs Críticos:          0 ✅              │
│  Cobertura de Testes:    0% 🔴             │
│  Moral da Equipe:        😄 Alto           │
├─────────────────────────────────────────────┤
│  Próximo Marco: Infra Rodando (25/Dez)     │
│  Status: 🟡 Em Risco                       │
└─────────────────────────────────────────────┘
```

---

## 📈 Gráficos (Atualizar Semanalmente)

### Cumulative Flow Diagram

```
Story Points
150 ┤
    │                                    BACKLOG
120 │                               ░░░░░░░░░░░░
    │                          ░░░░░
 90 │                     ░░░░░       EM PROGRESSO
    │                ░░░░░       ████
 60 │           ░░░░░       ████       CONCLUÍDO
    │      ░░░░░       ████
 30 │ ░░░░░       ████
    │ ████
  0 └────────────────────────────────────────────
    19   22   25   28   31   03   06   09   12
    Dez  Dez  Dez  Dez  Dez  Jan  Jan  Jan  Jan
```

---

## 🔄 Histórico de Métricas

| Data | Sprint | Velocity | Bugs | Cobertura |
|:-----|:-------|:---------|:-----|:----------|
| 19/Dez | 1 | 0 pts | 0 | 0% |
| 20/Dez | 1 | - | - | - |
| 21/Dez | 1 | - | - | - |

---

## 📝 Notas sobre Coleta de Dados

### Automação de Métricas

```bash
# Script para coletar métricas diariamente
#!/bin/bash

# CPU/RAM
docker stats --no-stream --format "{{.Container}},{{.CPUPerc}},{{.MemUsage}}"

# Cobertura de testes
pytest --cov=. --cov-report=term

# Bugs abertos
curl -X GET "http://jira/api/bugs?status=open"

# Output para CSV
echo "$(date),CPU,RAM,Coverage,Bugs" >> metrics.csv
```

### Responsável pela Atualização
- **Diária:** QA Lead (09h00)
- **Semanal:** Scrum Master (Sexta 17h)

---

**Última atualização:** 19/Dez/2025 00:00
