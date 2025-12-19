# 📊 Status do Projeto GT-Vision

**Última atualização:** 19/Dez/2025  
**Prazo MVP:** 30/Jan/2026 (42 dias)  
**Status Geral:** 🟡 **EM RISCO** - Requer ajustes críticos na arquitetura

---

## 🎯 Objetivo do MVP
Sistema de VMS capaz de:
- Ingerir e exibir **100 câmeras RTSP** simultaneamente
- Processar LPR (Leitura de Placas) em tempo real
- Interface de operação para CCO (Centro de Controle)
- Latência < 5 segundos no live view

---

## 📈 Progresso Geral

```
Sprint 1: ████░░░░░░ 40% - Em Andamento
Sprint 2: ░░░░░░░░░░  0% - Aguardando
Sprint 3: ░░░░░░░░░░  0% - Aguardando
Sprint 4: ░░░░░░░░░░  0% - Aguardando
Sprint 5: ░░░░░░░░░░  0% - Aguardando

Progresso Total: 8% (42 dias restantes)
```

---

## 🚨 Riscos Críticos Identificados

### 🔴 BLOQUEADORES (Ação Imediata)

| ID | Risco | Impacto | Mitigação | Responsável | Prazo |
|:---|:------|:--------|:----------|:------------|:------|
| **R01** | MediaMTX não escala para 100 câmeras | 🔴 ALTO | Validar capacidade ou migrar para SRS | DevOps | 22/Dez |
| **R02** | Falta definição de Storage (Snapshots LPR) | 🔴 ALTO | Decidir: MinIO local ou S3 | Arquiteto | 20/Dez |
| **R03** | PgBouncer Transaction Mode incompatível com Django ORM | 🟡 MÉDIO | Mudar para Session Mode | Backend | 23/Dez |

### 🟡 ATENÇÃO (Próximos 7 dias)

| ID | Risco | Impacto | Mitigação |
|:---|:------|:--------|:----------|
| **R04** | RTSP URLs sem criptografia no banco | 🟡 MÉDIO | Implementar django-cryptography |
| **R05** | Ausência de teste de carga precoce | 🟡 MÉDIO | Criar Sprint 1.5 com 10 câmeras fake |
| **R06** | Latência HLS (6-10s) vs Requisito (<5s) | 🟡 MÉDIO | Avaliar LL-HLS ou WebRTC |

---

## ✅ Entregas Concluídas

### Sprint 1 (19/Dez - 25/Dez) - 40% Completo
- [x] Estrutura inicial de documentação
- [x] Definição de Personas e Requisitos
- [ ] Docker Compose Base (Em Progresso)
- [ ] Configuração HAProxy + Kong
- [ ] Teste de Conectividade

---

## 📅 Próximas Ações (Esta Semana)

### Prioridade 1 - Decisões Arquiteturais
- [ ] **[20/Dez]** Definir estratégia de Storage (MinIO vs S3)
- [ ] **[22/Dez]** Teste de capacidade MediaMTX (20 streams fake)
- [ ] **[23/Dez]** Revisar configuração PgBouncer

### Prioridade 2 - Setup de Ambiente
- [ ] **[24/Dez]** Finalizar docker-compose.yml
- [ ] **[25/Dez]** Smoke Test: Curl → HAProxy → Kong → Django

---

## 📊 Métricas de Qualidade

### Cobertura de Testes
```
Unitários:    0% (Meta: 80%)
Integração:   0% (Meta: 60%)
E2E:          0% (Meta: 40%)
```

### Dívida Técnica
- 🔴 **3 Bloqueadores** não resolvidos
- 🟡 **3 Itens** de atenção
- ⚪ **0 Melhorias** planejadas

---

## 🎯 Marcos (Milestones)

| Marco | Data Prevista | Status |
|:------|:-------------|:-------|
| Infra Rodando (Hello World) | 25/Dez | 🟡 Em Progresso |
| API Core + Auth | 05/Jan | ⚪ Não Iniciado |
| Streaming + IA Pipeline | 15/Jan | ⚪ Não Iniciado |
| Frontend Grid | 25/Jan | ⚪ Não Iniciado |
| Deploy Staging | 30/Jan | ⚪ Não Iniciado |

---

## 👥 Time e Responsabilidades

| Papel | Nome | Responsabilidades Atuais |
|:------|:-----|:------------------------|
| Arquiteto | [Nome] | Decisões técnicas, R01, R02 |
| Backend | [Nome] | Django, R03, R04 |
| DevOps | [Nome] | Infra, R01, R05 |
| Frontend | [Nome] | React (Sprint 4) |
| QA | [Nome] | Automação de testes (Sprint 2+) |

---

## 📞 Canais de Comunicação

- **Daily Standup:** 9h (15 min)
- **Sprint Review:** Sexta 16h
- **Retrospectiva:** Sexta 17h
- **Trello Board:** [Link]
- **Slack:** #gt-vision

---

## 🔄 Histórico de Mudanças

| Data | Mudança | Motivo |
|:-----|:--------|:-------|
| 19/Dez | Análise inicial de riscos | Revisão técnica profunda |
| 19/Dez | Identificados 6 riscos críticos | Auditoria de viabilidade |

---

## 📝 Notas da Última Reunião

**Data:** 19/Dez/2025  
**Participantes:** [Definir]

**Decisões:**
1. Criar Sprint 1.5 focada em validação de capacidade
2. Priorizar decisão de Storage antes do Natal
3. Revisar roadmap considerando riscos identificados

**Action Items:**
- [ ] Agendar reunião técnica sobre MediaMTX (20/Dez)
- [ ] Provisionar servidor de testes (21/Dez)
