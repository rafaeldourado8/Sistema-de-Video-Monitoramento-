# 📁 Documentação de Gerenciamento do Projeto GT-Vision

Esta pasta contém todos os documentos necessários para acompanhamento, planejamento e gestão do projeto GT-Vision.

---

## 📋 Índice de Documentos

| Documento | Descrição | Atualização | Uso |
|:----------|:----------|:------------|:----|
| **[STATUS.md](./STATUS.md)** | Visão geral do status do projeto | Diária | Reuniões, Reports Executivos |
| **[BACKLOG.md](./BACKLOG.md)** | Backlog completo pronto para Trello | Semanal | Planejamento de Sprints |
| **[RISKS.md](./RISKS.md)** | Registro de riscos técnicos | Semanal | Tomada de Decisões |
| **[DAILY_CHECKLIST.md](./DAILY_CHECKLIST.md)** | Template para acompanhamento diário | Diária | Daily Standups |
| **[METRICS.md](./METRICS.md)** | KPIs e métricas do projeto | Diária/Semanal | Dashboards, Relatórios |

---

## 🎯 Como Usar Esta Documentação

### Para o Scrum Master / PO
1. **Daily (9h):** Abrir `DAILY_CHECKLIST.md` e preencher durante standup
2. **Semanal (Sexta):** Atualizar `STATUS.md` com progresso da sprint
3. **Mensal:** Revisar `RISKS.md` e atualizar mitigações

### Para Desenvolvedores
1. **Início do Dia:** Consultar `STATUS.md` para ver prioridades
2. **Antes de Codificar:** Checar `BACKLOG.md` para detalhes do card
3. **Encontrou Bloqueio:** Adicionar em `DAILY_CHECKLIST.md` seção "Bloqueadores"

### Para Stakeholders / Cliente
1. **Status Rápido:** Ler seção "Progresso Geral" em `STATUS.md`
2. **Riscos:** Revisar matriz de riscos em `RISKS.md`
3. **Qualidade:** Verificar cobertura de testes em `METRICS.md`

---

## 🔄 Fluxo de Atualização

```
┌─────────────────────────────────────────────────────┐
│  Daily Standup (9h)                                 │
│  └─> Preencher DAILY_CHECKLIST.md                  │
│      └─> Identificar bloqueadores                   │
│          └─> Adicionar em STATUS.md se crítico     │
└─────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│  Durante o Dia                                      │
│  └─> Métricas coletadas automaticamente            │
│      └─> Atualizar METRICS.md ao fim do dia        │
└─────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│  Fim da Sprint (Sexta 16h)                         │
│  └─> Sprint Review                                  │
│      └─> Atualizar STATUS.md com conclusões        │
│          └─> Atualizar BACKLOG.md para próxima     │
│              └─> Revisar RISKS.md                   │
└─────────────────────────────────────────────────────┘
```

---

## 📊 Integração com Trello

### Estrutura de Boards Recomendada

```
Board: GT-Vision MVP
│
├─ Lista: 🔴 BLOQUEADORES
│  └─ Cards de RISKS.md marcados como "Críticos"
│
├─ Lista: 📥 BACKLOG
│  └─ Cards de BACKLOG.md ordenados por prioridade
│
├─ Lista: 🚀 SPRINT ATUAL
│  └─ Cards da sprint em andamento
│
├─ Lista: 👷 EM PROGRESSO
│  └─ Cards sendo desenvolvidos
│
├─ Lista: 🧪 EM TESTES
│  └─ Cards em QA
│
└─ Lista: ✅ CONCLUÍDO
   └─ Cards finalizados
```

### Sincronização Bidirecional

**Do Trello para Docs:**
- Após mover card para "CONCLUÍDO" → Atualizar `STATUS.md`
- Novo bloqueador no Trello → Adicionar em `RISKS.md`

**Dos Docs para Trello:**
- Novo risco em `RISKS.md` → Criar card na lista "BLOQUEADORES"
- Card de `BACKLOG.md` → Copiar para Trello com labels corretas

---

## 🎨 Convenções e Padrões

### Status Emoji
- ✅ Concluído
- 🟢 Saudável / No prazo
- 🟡 Atenção / Risco
- 🔴 Crítico / Atrasado
- ⚪ Não iniciado
- 🔵 Em progresso

### Prioridades
- **P0:** Bloqueador - Precisa ser resolvido AGORA
- **P1:** Crítico - Resolver em 1-2 dias
- **P2:** Alta - Resolver esta semana
- **P3:** Média - Resolver esta sprint
- **P4:** Baixa - Backlog

### Story Points (Fibonacci)
- **1 pt:** Trivial (< 1h)
- **2 pts:** Simples (1-2h)
- **3 pts:** Médio (3-4h)
- **5 pts:** Complexo (1 dia)
- **8 pts:** Muito Complexo (2 dias)
- **13 pts:** Épico (3+ dias - considerar quebrar)

---

## 🚨 Alertas e Escalações

### Quando Escalar?

| Situação | Ação | Responsável |
|:---------|:-----|:------------|
| **Bloqueador > 2 dias** | Enviar email para PO + Arquiteto | Scrum Master |
| **Sprint < 50% na Quarta** | Reunião de emergência | Scrum Master |
| **Risco Crítico novo** | Atualizar `RISKS.md` e avisar no Slack | Quem identificou |
| **Bug em Produção** | Criar card P0 no Trello | QA Lead |

### Canais de Comunicação

- **Urgente (< 1h):** Telefone / Slack DM
- **Importante (< 4h):** Slack #gt-vision-alerts
- **Normal:** Trello / Email
- **Informativo:** Slack #gt-vision-general

---

## 📅 Calendário de Rituais

| Ritual | Frequência | Horário | Duração | Participantes |
|:-------|:-----------|:--------|:--------|:--------------|
| **Daily Standup** | Segunda-Sexta | 9h00 | 15 min | Todo time |
| **Sprint Planning** | Segunda (início sprint) | 14h00 | 2h | Todo time |
| **Sprint Review** | Sexta (fim sprint) | 16h00 | 1h | Time + Stakeholders |
| **Retrospectiva** | Sexta (fim sprint) | 17h00 | 1h | Todo time |
| **Revisão de Riscos** | Quarta | 15h00 | 30 min | Arquiteto + Scrum |

---

## 🛠️ Ferramentas Utilizadas

| Ferramenta | Propósito | Acesso |
|:-----------|:----------|:-------|
| **Trello** | Gestão de Tarefas | [Link] |
| **Slack** | Comunicação | #gt-vision |
| **GitHub** | Versionamento | [Link] |
| **Google Drive** | Documentos | [Link] |
| **Grafana** | Monitoramento | [Link] |

---

## 📖 Templates Úteis

### Template de Card para Trello

```markdown
## [CARD-XXX] Título Claro

**Labels:** `Sprint-X` `Categoria`  
**Story Points:** X  
**Responsável:** @nome  

### Descrição
[O que precisa ser feito]

### Critérios de Aceite
- [ ] Critério 1
- [ ] Critério 2

### Checklist Técnica
- [ ] Task 1
- [ ] Task 2
- [ ] Testes escritos
- [ ] Code review aprovado
```

### Template de Bug Report

```markdown
## 🐛 BUG-XXX: Título Descritivo

**Severidade:** 🔴/🟡/🟢  
**Ambiente:** Dev/Staging/Prod  

### Descrição
[O que aconteceu]

### Reproduzir
1. Passo 1
2. Passo 2
3. Resultado esperado vs obtido

### Logs
```
[Cole logs relevantes]
```

### Evidências
[Screenshot/Video]
```

### Template de Decisão Técnica

```markdown
## 🤔 Decisão: [Título]

**Data:** DD/MMM/YYYY  
**Contexto:** [Por que estamos decidindo isso?]

### Opções Consideradas
1. **Opção A:** ...
   - Prós: ...
   - Contras: ...
2. **Opção B:** ...
   - Prós: ...
   - Contras: ...

### Decisão Final
**Escolhemos:** Opção X  
**Motivo:** [Justificativa]  
**Responsável pela execução:** @nome

### Consequências
- Impacto 1
- Impacto 2
```

---

## 🔍 FAQ - Perguntas Frequentes

### P: Preciso atualizar todos os documentos diariamente?
**R:** Não. Apenas `DAILY_CHECKLIST.md` é diário. Os demais são semanais ou sob demanda.

### P: E se eu encontrar um risco novo?
**R:** Adicione imediatamente em `RISKS.md` e avise no Slack. Se for crítico (P0), escale para o Scrum Master.

### P: Como sei o que fazer hoje?
**R:** Consulte `STATUS.md` seção "Próximas Ações" ou abra seus cards no Trello.

### P: Posso editar o `BACKLOG.md`?
**R:** Sim, mas coordene com o Scrum Master para evitar conflitos. Idealmente, edições acontecem após Planning.

### P: Onde documento decisões técnicas?
**R:** Crie uma seção "Decisões Técnicas" em `DAILY_CHECKLIST.md` ou adicione nota no card relevante do Trello.

---

## 📞 Contatos

| Papel | Nome | Email | Telefone |
|:------|:-----|:------|:---------|
| **Product Owner** | [Nome] | [email] | [tel] |
| **Scrum Master** | [Nome] | [email] | [tel] |
| **Tech Lead** | [Nome] | [email] | [tel] |
| **Arquiteto** | [Nome] | [email] | [tel] |

---

## 🔄 Histórico de Versões

| Versão | Data | Autor | Mudanças |
|:-------|:-----|:------|:---------|
| 1.0 | 19/Dez/2025 | Claude | Criação inicial da estrutura |

---

## 📝 Contribuindo

Para adicionar novos documentos ou melhorar os existentes:

1. Discuta a mudança no Slack #gt-vision
2. Faça a edição localmente
3. Commit com mensagem descritiva: `docs(management): adiciona template X`
4. PR para revisão do Scrum Master

---

**Documentação mantida por:** Equipe GT-Vision  
**Última revisão:** 19/Dez/2025
