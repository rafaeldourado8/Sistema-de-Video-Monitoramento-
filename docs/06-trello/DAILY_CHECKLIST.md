# ✅ Daily Checklist - GT-Vision

> **Instruções:** Copiar este template diariamente para acompanhar progresso.

---

## 📅 Data: ____ / ____ / 2025

**Sprint Atual:** Sprint ____  
**Dias restantes até MVP:** ____  
**Bloqueadores Ativos:** ____

---

## 🌅 Morning Standup (9h00)

### 👤 [Nome do Desenvolvedor 1]
- **Ontem:** 
  - [ ] _[O que foi concluído]_
- **Hoje:** 
  - [ ] _[O que será feito]_
- **Bloqueios:** 
  - [ ] _[Nenhum / Descrever]_

### 👤 [Nome do Desenvolvedor 2]
- **Ontem:** 
  - [ ] _[O que foi concluído]_
- **Hoje:** 
  - [ ] _[O que será feito]_
- **Bloqueios:** 
  - [ ] _[Nenhum / Descrever]_

### 👤 [Nome do Desenvolvedor 3]
- **Ontem:** 
  - [ ] _[O que foi concluído]_
- **Hoje:** 
  - [ ] _[O que será feito]_
- **Bloqueios:** 
  - [ ] _[Nenhum / Descrever]_

---

## 🎯 Objetivos do Dia (Prioridade 1)

### Crítico (Deve ser concluído hoje)
- [ ] **[CARD-XXX]** _[Descrição curta]_ - @responsável
- [ ] **[CARD-XXX]** _[Descrição curta]_ - @responsável

### Importante (Desejável concluir)
- [ ] **[CARD-XXX]** _[Descrição curta]_ - @responsável
- [ ] **[CARD-XXX]** _[Descrição curta]_ - @responsável

---

## 🧪 Testes Executados Hoje

### Testes Manuais
- [ ] Teste 1: _[Descrição]_
  - **Resultado:** ✅ Passou / ❌ Falhou
  - **Evidência:** _[Screenshot/Log]_

### Testes Automatizados
```bash
# Comando executado:
pytest tests/ -v

# Resultado:
# X passed, Y failed
```

- [ ] Todos os testes passaram?
  - ✅ Sim
  - ❌ Não → **Action:** _[Criar card para correção]_

---

## 📊 Health Check de Infraestrutura

### Serviços Críticos
- [ ] **Postgres:** ✅ Online / ❌ Offline
  ```bash
  docker ps | grep postgres
  # Status: _______
  ```

- [ ] **Redis:** ✅ Online / ❌ Offline
  ```bash
  redis-cli ping
  # Response: _______
  ```

- [ ] **RabbitMQ:** ✅ Online / ❌ Offline
  ```bash
  curl -u admin:pass http://localhost:15672/api/healthchecks/node
  # Status: _______
  ```

- [ ] **MediaMTX/SRS:** ✅ Online / ❌ Offline
  ```bash
  curl http://localhost:8554/
  # Status: _______
  ```

### Métricas de Performance
```bash
# Uso de recursos (docker stats):
CONTAINER       CPU %    MEM USAGE / LIMIT     NET I/O
postgres        ____%    _____ / _____         _____ / _____
mediamtx        ____%    _____ / _____         _____ / _____
django          ____%    _____ / _____         _____ / _____
```

- [ ] Algum container acima de 80% CPU? 
  - ❌ Sim → **Action:** _[Investigar]_
  - ✅ Não

---

## 🚨 Bloqueadores Novos (Identificados Hoje)

| ID | Descrição | Impacto | Responsável | Prazo |
|:---|:----------|:--------|:------------|:------|
| B-___ | _[Descrever bloqueio]_ | 🔴/🟡/🟢 | @nome | __/__/__ |

---

## 🔍 Code Review

### PRs Abertos
- [ ] **PR #___:** _[Título]_ - @autor
  - **Status:** 🟡 Aguardando Review / 🟢 Aprovado / 🔴 Mudanças Solicitadas
  - **Reviewer:** @nome

### PRs Mergeados Hoje
- [x] **PR #___:** _[Título]_ - Mergeado às __:__

---

## 📦 Deploys / Releases

### Ambiente de Desenvolvimento
- [ ] Deploy realizado?
  - ✅ Sim - Commit: `______`
  - ❌ Não

### Ambiente de Staging
- [ ] Deploy realizado?
  - ✅ Sim - Commit: `______`
  - ❌ Não

---

## 🐛 Bugs Identificados Hoje

| ID | Descrição | Severidade | Status |
|:---|:----------|:-----------|:-------|
| BUG-___ | _[Descrever bug]_ | 🔴/🟡/🟢 | 🟡 Investigando / 🔵 Corrigido |

---

## 💡 Aprendizados / Decisões Técnicas

### O que aprendemos hoje?
- _[Exemplo: "FFmpeg com -c:v copy reduz CPU em 70%"]_

### Decisões tomadas:
- **Decisão:** _[Exemplo: "Migrar de MediaMTX para SRS"]_
- **Motivo:** _[Justificativa]_
- **Responsável pela execução:** @nome

---

## 📌 Dependências Externas

### Aguardando Terceiros
- [ ] **Hardware:** Servidor 4TB - Previsão: __/__/__
- [ ] **Acesso:** Credenciais VPN - Previsão: __/__/__

---

## 🎉 Vitórias do Dia (Wins)

- 🏆 _[Exemplo: "Primeiro teste de 20 câmeras simultâneas bem-sucedido!"]_
- 🏆 _[Exemplo: "Reduzimos latência de 12s para 8s"]_

---

## 🔔 Lembretes para Amanhã

- [ ] _[Exemplo: "Validar com PO sobre latência HLS"]_
- [ ] _[Exemplo: "Atualizar documentação da API"]_

---

## 📸 Evidências / Screenshots

_[Anexar prints de testes, gráficos de performance, logs relevantes]_

---

## 🕐 End of Day Summary

**Progresso Geral da Sprint:**
```
████████░░ 80% (Meta: 85% até sexta)
```

**Moral da Equipe:**
- 😄 Alto
- 😐 Médio
- 😟 Baixo → **Motivo:** _[Descrever se aplicável]_

**Observações finais:**
_[Comentários gerais sobre o dia, clima da equipe, urgências]_

---

**Checklist completado por:** @nome  
**Horário:** __:__

---

## 📋 Template Rápido (Copy/Paste)

```markdown
## 📅 Data: 20/Dez/2025
**Sprint:** Sprint 1
**Dias restantes:** 42
**Bloqueadores:** 2 ativos

### Daily Standup
**@desenvolvedor1**
- Ontem: Finalizou docker-compose base
- Hoje: Configurar HAProxy
- Bloqueios: Nenhum

**@desenvolvedor2**
- Ontem: Documentação de API
- Hoje: Implementar Auth UseCase
- Bloqueios: Aguardando decisão sobre Storage (R02)

### Objetivos do Dia
- [x] CARD-101: Docker Compose Base
- [ ] CARD-102: HAProxy SSL

### Testes
✅ 15 passed, 0 failed

### Health Check
✅ Todos serviços online
CPU médio: 35% | RAM: 8GB/32GB

### Bloqueadores Novos
Nenhum

### Vitórias
🏆 Primeiro Hello World via Kong funcionando!

### Moral da Equipe
😄 Alto - Time engajado e focado
```

---

**Última atualização:** 19/Dez/2025
