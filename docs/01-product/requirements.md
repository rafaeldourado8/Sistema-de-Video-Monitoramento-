# Requisitos do Sistema (MVP - 100 Câmeras RTSP)

## Meta do MVP
**Suportar 100 câmeras RTSP simultâneas com latência < 8s e uptime > 98%**

---

## 1. Requisitos Funcionais (Core)

### 1.1 Ingestão e Streaming

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RF01** | **Ingestão Resiliente:** Reconexão automática de streams RTSP com Circuit Breaker (após 5 falhas, aguarda 60s). | Sistema reconecta câmera offline em < 30s. Não trava todo o sistema se 1 câmera falhar. | 🔴 P0 |
| **RF02** | **Streaming Otimizado:** Transcodificação H.264 → HLS com segmentos de 2s. Suportar 100 streams simultâneos. | CPU < 70% com 100 câmeras ativas. Latência end-to-end < 8s. | 🔴 P0 |
| **RF03** | **Watchdog Inteligente:** Detectar FFmpeg travado (não só morto) via análise de output. | Se stream não produz frames por 15s, reinicia processo automaticamente. | 🔴 P0 |
| **RF04** | **Throttling de IA:** Enviar apenas 1 frame/segundo para análise (não 25 fps). | Reduz carga da GPU em 96%. Detecção ainda ocorre em tempo útil. | 🔴 P0 |

### 1.2 Visualização (Frontend)

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RF05** | **Mosaico Dinâmico:** Visualização de 4, 9 ou 16 câmeras simultâneas com HLS.js. | Operador troca layout sem reload. Grid não trava ao adicionar/remover câmera. | 🔴 P0 |
| **RF06** | **Indicadores Visuais:** Status de câmera (Online=Verde, Offline=Vermelho Pulsante, Conectando=Amarelo). | Status atualiza em < 5s após mudança real. | 🔴 P0 |
| **RF07** | **Zoom Digital:** Ampliar região do player (2x, 4x) via pinch/scroll. | Zoom mantém qualidade aceitável (não pixelizado). | 🟡 P1 |
| **RF08** | **Modo Tela Cheia:** Player individual em fullscreen com tecla de atalho (F). | Funciona em Chrome/Firefox/Safari. | 🟡 P1 |

### 1.3 Detecção por IA

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RF09** | **Detecção de Veículos:** YOLO v8 identifica carros/motos/caminhões em frames. | Precisão > 85% em condições normais (dia claro). | 🔴 P0 |
| **RF10** | **LPR (Leitura de Placas):** OCR extrai texto de placas brasileiras (Mercosul/Cinza). | Taxa de acerto > 90% para placas frontais nítidas. | 🔴 P0 |
| **RF11** | **Fila de Processamento:** IA consome frames via RabbitMQ. Prioriza câmeras críticas (vias principais). | Latência de processamento < 500ms por frame. Fila não cresce indefinidamente. | 🔴 P0 |
| **RF12** | **Fallback CPU:** Se GPU não disponível, modelo Lite roda em CPU (menor precisão). | Sistema não trava se GPU falhar. | 🟡 P1 |

### 1.4 Busca e Histórico

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RF13** | **Busca por Placa:** Operador busca "ABC-1234" e vê lista de detecções (foto + timestamp + câmera). | Resultado em < 3s para busca em 7 dias. Suporta wildcard (ABC-*). | 🔴 P0 |
| **RF14** | **Timeline de Detecções:** Visualizar linha do tempo de onde veículo passou. | Ordena por horário. Permite download de evidências (ZIP). | 🟡 P1 |
| **RF15** | **Armazenamento de Snapshots:** Frames com detecção salvos em MinIO (S3-compatible). Retenção configurável (7/30/90 dias). | Conformidade LGPD. Limpeza automática após período. | 🔴 P0 |

### 1.5 Gestão de Câmeras

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RF16** | **CRUD Seguro:** Criar/Editar/Deletar câmeras via API REST. RTSP URLs criptografadas no banco. | Apenas usuários autorizados (role=admin). | 🔴 P0 |
| **RF17** | **Test Connection:** Testar RTSP URL antes de salvar (valida credenciais e codec). | Retorna erro claro: "Auth Failed", "Network Timeout", "Unsupported Codec". | 🟡 P1 |
| **RF18** | **Provisionamento Assíncrono:** Ao salvar câmera, Signal dispara job no RabbitMQ para configurar MediaMTX. | Câmera aparece no grid em < 30s após salvar. | 🔴 P0 |
| **RF19** | **Health Check:** Endpoint `/cameras/{id}/health` retorna métricas (bitrate, fps, uptime). | Usado por Grafana para dashboards. | 🟡 P1 |

---

## 2. Requisitos Não-Funcionais (Performance & Reliability)

### 2.1 Performance

| ID | Descrição | Métrica | Prioridade |
|----|-----------|---------|------------|
| **RNF01** | **Latência de Streaming:** Delay end-to-end (câmera → operador). | < 8s (HLS LL) | 🔴 P0 |
| **RNF02** | **Throughput de Ingestão:** Suportar 100 câmeras @ 1080p/4Mbps. | 400 Mbps de tráfego de entrada | 🔴 P0 |
| **RNF03** | **Resposta de API:** Endpoints CRUD devem responder rápido. | P95 < 200ms | 🟡 P1 |
| **RNF04** | **Busca de Placas:** Query em banco com milhões de registros. | < 3s para range de 7 dias | 🔴 P0 |
| **RNF05** | **Uso de Recursos:** Limites de CPU/RAM por componente. | CPU < 80%, RAM < 90% em carga máxima | 🔴 P0 |

### 2.2 Confiabilidade

| ID | Descrição | Métrica | Prioridade |
|----|-----------|---------|------------|
| **RNF06** | **Disponibilidade:** Sistema deve estar operacional 24/7. | Uptime > 98% (SLA) | 🔴 P0 |
| **RNF07** | **MTTR (Mean Time To Repair):** Tempo para resolver incidente. | < 15 minutos | 🟡 P1 |
| **RNF08** | **Isolamento de Falhas:** Falha em 1 câmera não afeta outras. | Circuit Breaker por câmera | 🔴 P0 |
| **RNF09** | **Backup de Banco:** Backup automático diário com retenção de 30 dias. | RTO < 1h, RPO < 24h | 🟡 P1 |

### 2.3 Segurança

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RNF10** | **Autenticação JWT:** RS256 com rotação de chaves a cada 90 dias. | Tokens expiram em 15min. Refresh tokens em 24h. | 🔴 P0 |
| **RNF11** | **Criptografia de Dados:** RTSP URLs criptografadas (Fernet). TLS 1.3 em trânsito. | Nenhuma senha em plain text. | 🔴 P0 |
| **RNF12** | **Rate Limiting:** Proteção anti-DDoS no Kong Gateway. | 100 req/min por IP na rota de login. | 🔴 P0 |
| **RNF13** | **Auditoria:** Logs de acesso a vídeos (quem, quando, qual câmera). | Conformidade LGPD Art. 46. | 🟡 P1 |
| **RNF14** | **Hardening de Containers:** Rodar como non-root user. Remover shells desnecessários. | Security scan (Trivy) sem vulnerabilidades HIGH/CRITICAL. | 🟡 P1 |

### 2.4 Escalabilidade

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RNF15** | **Horizontal Scaling:** Adicionar workers de IA sem downtime. | Docker Compose Scale + Load Balancer. | 🟡 P1 |
| **RNF16** | **Database Pooling:** PgBouncer em Session Mode (não Transaction). | Suportar 200 conexões simultâneas. | 🔴 P0 |
| **RNF17** | **Cache de Metadados:** Redis para status de câmeras (TTL 10s). | Reduz load no Postgres em 70%. | 🔴 P0 |

### 2.5 Observabilidade

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RNF18** | **Logs Estruturados:** JSON com correlation_id, timestamp, level. | Centralizados no Loki/ELK. | 🔴 P0 |
| **RNF19** | **Métricas de Negócio:** Dashboards Grafana com KPIs (uptime por câmera, detecções/hora). | Atualização em tempo real. | 🟡 P1 |
| **RNF20** | **Alertas Proativos:** PagerDuty/Telegram quando > 10% de câmeras offline. | Reduz MTTD para < 2 minutos. | 🟡 P1 |
| **RNF21** | **Health Checks:** Endpoints `/health` e `/ready` para k8s/Docker. | Usado por load balancer. | 🔴 P0 |

### 2.6 Usabilidade

| ID | Descrição | Aceitação | Prioridade |
|----|-----------|-----------|------------|
| **RNF22** | **Mobile First:** Interface responsiva (Bootstrap/Tailwind). | Funciona em tablets 10" para técnicos de campo. | 🟡 P1 |
| **RNF23** | **Dark Mode:** Tema escuro padrão para operadores de CCO. | Reduz cansaço visual em turnos de 6h. | 🟡 P1 |
| **RNF24** | **Acessibilidade:** Contraste WCAG AA. Atalhos de teclado. | Screen reader friendly. | 🟢 P2 |

---

## 3. Capacidade e Recursos (Dimensionamento)

### 3.1 Servidor de Streaming

```yaml
Carga: 100 câmeras @ 1080p/25fps/4Mbps

Recursos Mínimos:
  CPU: 32 cores (AMD EPYC ou Intel Xeon)
  RAM: 64 GB DDR4
  Storage: 2 TB NVMe SSD (para buffer HLS)
  Rede: 10 Gbps (ou 2x 1Gbps bonding)

Recursos Recomendados (Produção):
  CPU: 64 cores
  RAM: 128 GB
  Storage: 4 TB NVMe RAID 10
  Rede: 10 Gbps redundante
```

### 3.2 Servidor de IA

```yaml
Carga: 100 frames/segundo (1 por câmera)

GPU:
  Mínimo: 2x NVIDIA RTX 3060 (12GB VRAM)
  Recomendado: 2x NVIDIA RTX 4090 (24GB VRAM)

CPU: 16 cores (fallback mode)
RAM: 32 GB
```

### 3.3 Banco de Dados

```yaml
Carga: 
  - 100 câmeras gerando 8.6M detecções/dia
  - Retenção de 30 dias = 258M registros

Postgres:
  RAM: 16 GB (shared_buffers = 4GB)
  Storage: 1 TB SSD
  Connection Pool: 200 (via PgBouncer)
```

### 3.4 Armazenamento de Mídia (MinIO)

```yaml
Carga:
  - 100 câmeras × 1 snapshot/segundo = 100 frames/s
  - Tamanho médio: 500 KB/frame
  - 30 dias retenção

Storage Necessário:
  100 frames/s × 500 KB × 86400s/dia × 30 dias = 129.6 TB

Prática (com LGPD):
  - Retenção de 7 dias: 30.2 TB
  - Com compressão (JPEG 80%): ~20 TB
```

---

## 4. Fora do Escopo (MVP)

| Funcionalidade | Motivo | Previsão |
|----------------|--------|----------|
| **Gravação Contínua 24/7** | Storage proibitivo (100 câmeras × 4Mbps × 30 dias = 1.3 PB). Foco é detecção, não DVR. | Fase 2 (Q2 2025) |
| **App Nativo (Android/iOS)** | MVP é web-first. Mobile via PWA. | Fase 3 (Q3 2025) |
| **Multi-tenancy (SaaS)** | Arquitetura single-tenant para prefeitura. | Não planejado |
| **Reconhecimento Facial** | Requer adequação à LGPD (consentimento). Complexidade alta. | Backlog |
| **Integração com CAD (Computer-Aided Dispatch)** | APIs externas fora do controle. | Fase 2 |
| **Streaming em 4K** | Bandwidth e storage proibitivos. 1080p suficiente para LPR. | Não planejado |

---

## 5. Compliance e Regulamentação

### 5.1 LGPD (Lei Geral de Proteção de Dados)

| Requisito Legal | Implementação Técnica |
|-----------------|------------------------|
| **Art. 6º - Finalidade:** Dados coletados apenas para segurança pública. | Sistema não processa dados fora do escopo (ex: reconhecimento facial sem consentimento). |
| **Art. 15 - Minimização:** Apenas imagens necessárias são armazenadas. | Snapshots só quando há detecção de veículo (não grava tudo). |
| **Art. 16 - Qualidade:** Dados devem ser exatos e atualizados. | OCR de placas validado com tabela de veículos roubados (API SINESP). |
| **Art. 46 - Segurança:** Medidas técnicas para evitar acesso não autorizado. | Criptografia TLS 1.3, JWT, Audit Logs. |
| **Art. 48 - Incidentes:** Notificar ANPD em caso de vazamento. | Playbook de resposta a incidentes (< 72h). |

### 5.2 Marco Civil da Internet

- **Art. 11:** Retenção de logs de acesso por 6 meses (compliance com requisições judiciais).
- **Art. 15:** Segredo de telecomunicações (RTSP URLs não podem vazar).

---

## 6. Definição de Pronto (DoD)

Uma funcionalidade está PRONTA quando:

- [ ] **Código:** Pull Request aprovado com > 80% cobertura de testes.
- [ ] **Testes:** Unitários + Integração + E2E passando.
- [ ] **Documentação:** README atualizado + Swagger (OpenAPI).
- [ ] **Performance:** Load test validou que atende RNF.
- [ ] **Segurança:** Scan de vulnerabilidades (Trivy) sem issues HIGH/CRITICAL.
- [ ] **Deploy:** Funcionalidade testada em Staging.
- [ ] **Aprovação:** Product Owner (Sargento Ana) validou.

---

## 7. Critérios de Aceitação do MVP (Go/No-Go)

Para considerar MVP completo em **30/Jan/2025**:

### Obrigatórios (Red Flags se Falhar)

- [ ] **100 câmeras simultâneas:** Sistema estável por 8h com carga máxima.
- [ ] **Latência < 8s:** Medida em 10 câmeras aleatórias.
- [ ] **LPR funcionando:** Taxa de acerto > 85% em teste com 100 placas conhecidas.
- [ ] **Busca de placas < 3s:** Query em banco com 1M de registros.
- [ ] **Uptime > 98%:** Medido em staging por 7 dias.
- [ ] **Zero vulnerabilidades críticas:** Scan de segurança aprovado.

### Desejáveis (Não Bloqueantes)

- [ ] Dashboard de métricas (Grafana)
- [ ] Alertas no Telegram
- [ ] Dark Mode no frontend
- [ ] Auditoria de acesso (logs)

---

## 8. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| **MediaMTX não aguenta 100 streams** | 🟡 Média | 🔴 Alto | Sprint 0: Stress test com 20 câmeras. Se falhar, migrar para SRS. |
| **GPU travando em produção** | 🟢 Baixa | 🟡 Médio | Implementar fallback CPU + Circuit Breaker. |
| **Storage de 20 TB muito caro** | 🟡 Média | 🟡 Médio | Reduzir retenção para 7 dias. Comprimir JPEGs (80% quality). |
| **Latência > 8s inaceitável** | 🟢 Baixa | 🔴 Alto | Otimizar segmentos HLS (2s) + LL-HLS. Usar CDN local. |
| **LGPD não compliance** | 🟢 Baixa | 🔴 Alto | Contratar consultoria jurídica. Implementar DPO procedures. |

---

**Versão:** 2.0 (Revisada em 19/Dez/2024)  
**Aprovado por:** [Product Owner]  
**Próxima Revisão:** Sprint 2 (05/Jan/2025)