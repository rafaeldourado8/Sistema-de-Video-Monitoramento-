# Personas (Foco: Monitoramento Urbano/Trânsito)

## 1. Tenente Carlos, o Operador de CCO (Usuário Final)
> "Preciso identificar um acidente na Avenida Principal agora para enviar a viatura. Se a câmera travar, o trânsito para."

### Perfil
- **Cargo:** Agente de Trânsito / Operador de Monitoramento
- **Ambiente:** Sala de Controle (CCO) com Videowall 4K
- **Contexto:** Monitora 20-30 câmeras simultaneamente em turnos de 6h
- **Tecnologia:** Desktop com 3 monitores, Chrome/Firefox

### Dores (Pain Points)
1. **Latência Crítica:** Se ele vê um acidente com 30s de atraso, o caos já se instalou. Tempo de resposta define sucesso da operação.
2. **Estabilidade > Qualidade:** Prefere 720p fluido do que 4K travando a cada 30s.
3. **Cansaço Visual:** Após 2h olhando telas, precisa de interface escura (Dark Mode) e indicadores visuais claros (vermelho/verde).
4. **Sobrecarga Cognitiva:** Com 25 câmeras ativas, não pode perder tempo tentando entender se câmera está offline ou com problema de rede.
5. **Busca Rápida:** Quando recebe denúncia de placa, precisa localizar veículo em < 60 segundos.

### Objetivos
- Visualizar Mosaico (Grid) de 4, 9 ou 16 câmeras sem travamentos
- Identificar rapidamente câmeras offline (indicador visual vermelho pulsante)
- Fazer zoom digital sem precisar abrir nova aba
- Buscar histórico de placas e ver resultado em tempo real
- Receber alertas sonoros quando IA detectar evento crítico (bloqueio de via)

### Métricas de Sucesso
- Tempo para identificar incidente: < 15 segundos
- Taxa de disponibilidade de vídeo: > 98%
- Satisfação com interface (SUS Score): > 80/100

---

## 2. Jorge, o Técnico de Campo (Infraestrutura)
> "Estou em cima de uma escada a 5 metros de altura. Preciso saber se a câmera conectou no servidor agora."

### Perfil
- **Cargo:** Técnico de Manutenção de Rede
- **Ambiente:** Externo (Ruas), usando 4G/Rádio instável (50-200ms latência)
- **Dispositivo:** Tablet ruggedizado (Android) ou Celular
- **Contexto:** Instala/mantém 3-5 câmeras por dia

### Dores (Pain Points)
1. **Conectividade Oscilante:** Redes municipais oscilam entre 1-10 Mbps. O sistema não pode "desistir" de reconectar a câmera após 3 tentativas.
2. **Debug Impossível:** Precisa saber SE o erro é:
   - "Senha Errada" (erro de configuração)
   - "Sem Rede" (problema ISP)
   - "RTSP Port Blocked" (firewall)
   - "Câmera Offline" (hardware)
3. **Interface Desktop-First:** Maioria dos sistemas não funciona bem em mobile (botões pequenos, scroll infinito).
4. **Falta de Feedback:** Após adicionar câmera, não sabe se precisa esperar 10s ou 5min para o status mudar.

### Objetivos
- Adicionar câmera e ver o status "Online" em < 30 segundos
- Ver logs de erro em linguagem clara (não stack traces)
- Testar RTSP URL antes de salvar (botão "Test Connection")
- Receber notificação push quando câmera que ele instalou ficar offline

### Métricas de Sucesso
- Tempo de provisionamento: < 2 minutos por câmera
- Taxa de sucesso na primeira tentativa: > 85%
- Redução de chamados "câmera não aparece": -70%

---

## 3. Sargento Ana, a Gestora de Operações (Stakeholder)
> "Preciso justificar a compra de mais servidores. Me mostre quantas câmeras estão offline por causa de hardware vs. rede."

### Perfil
- **Cargo:** Coordenadora de Tecnologia da Guarda Municipal
- **Ambiente:** Escritório, reuniões com Secretaria
- **Contexto:** Toma decisões sobre budget e contratações
- **Tecnologia:** Usa sistema via navegador (Chrome), Excel para relatórios

### Dores (Pain Points)
1. **Falta de Visibilidade:** Não sabe se o investimento em câmeras está trazendo ROI (quantos incidentes foram resolvidos por causa do vídeo?).
2. **Downtime Invisível:** Descobre que 10 câmeras estão offline há 3 dias só quando operador reclama.
3. **Relatórios Manuais:** Precisa compilar dados de múltiplas fontes (Excel, emails, WhatsApp) para reuniões mensais.
4. **LGPD/Compliance:** Precisa garantir que imagens não fiquem armazenadas além do permitido por lei.

### Objetivos
- Dashboard executivo com KPIs:
  - % Uptime por região
  - Top 10 câmeras com mais falhas
  - Custo de manutenção por câmera
- Relatórios automáticos (PDF) enviados por email toda segunda-feira
- Alertas via Telegram quando > 15% das câmeras ficam offline
- Auditoria de acesso: Quem visualizou qual câmera e quando

### Métricas de Sucesso
- Tempo para gerar relatório mensal: De 8h → 5 minutos
- Transparência de custos: 100% rastreável
- Conformidade LGPD: 0 multas

---

## 4. DevOps Márcio, o Mantenedor do Sistema (Persona Técnica)
> "3h da manhã, 50 câmeras offline. Preciso saber se é o banco, a rede ou o MediaMTX."

### Perfil
- **Cargo:** Engenheiro de Infraestrutura (terceirizado)
- **Ambiente:** Remoto (home office), plantão 24/7
- **Contexto:** Responsável por manter SLA de 99.5% uptime
- **Tecnologia:** SSH, Grafana, Prometheus, PagerDuty

### Dores (Pain Points)
1. **Falta de Observabilidade:** Logs espalhados em 5 containers diferentes.
2. **Debugging no Escuro:** Não sabe qual componente está causando lentidão (banco? streaming? IA?).
3. **Deploys Arriscados:** Sem rollback automático, cada atualização é uma roleta-russa.
4. **Escalabilidade Reativa:** Só descobre que precisa de mais recursos quando sistema já caiu.

### Objetivos
- **Logs Centralizados:** ELK Stack ou Loki com busca por correlation_id
- **Metrics Granulares:**
  - Latência P95 por endpoint
  - Fila de IA: Tamanho da fila e processing time
  - FFmpeg: Memória/CPU por stream
- **Alertas Inteligentes:** Não acordar para falso positivo (ex: 1 câmera offline é normal, 20 é crítico)
- **Disaster Recovery:** Backup automatizado do banco + procedure de restore testada

### Métricas de Sucesso
- MTTD (Mean Time To Detect): < 2 minutos
- MTTR (Mean Time To Repair): < 15 minutos
- Falsos positivos de alerta: < 5%
- Cobertura de testes: > 80%

---

## Matriz de Priorização (MVP)

| Persona | Funcionalidade | Impacto | Esforço | Prioridade |
|---------|---------------|---------|---------|------------|
| Tenente Carlos | Mosaico 9 câmeras | 🔴 Alto | Médio | **P0** |
| Tenente Carlos | Busca por placa | 🔴 Alto | Alto | **P0** |
| Jorge | Status em tempo real | 🔴 Alto | Baixo | **P0** |
| Jorge | Test RTSP Connection | 🟡 Médio | Baixo | **P1** |
| Sargento Ana | Dashboard KPIs | 🟡 Médio | Médio | **P2** |
| Sargento Ana | Relatório PDF | 🟢 Baixo | Alto | **P3** |
| DevOps Márcio | Logs centralizados | 🔴 Alto | Médio | **P0** |
| DevOps Márcio | Métricas Grafana | 🔴 Alto | Baixo | **P1** |

**Legenda:**
- **P0:** Crítico (MVP não funciona sem)
- **P1:** Alta (Entregar na Sprint 4)
- **P2:** Média (Post-MVP, Fase 2)
- **P3:** Baixa (Backlog)