**📅 Roadmap GT-Vision (Blindado com Testes & Segurança)**

**Sprint 1: A Muralha de Infra (19/Dez - 25/Dez)**
*Objetivo: Ambiente rodando. "Hello World" passando por HAProxy -> Kong -> Django.*

- [ ] **Infra Base:**
  - [ ] `docker-compose.yml` com redes isoladas.
  - [ ] Postgres + PgBouncer (Transaction Mode).
  - [ ] Redis (Cache/Broker).
- [ ] **Segurança (Edge):**
  - [ ] HAProxy: Configurar SSL (Self-signed) e esconder versão.
  - [ ] Kong: Configurar Rate Limiting (Anti-DDoS) e modo DB-less.
- [ ] **QA:**
  - [ ] Teste de Conectividade (Script Python que testa conexões de banco/redis).

**Sprint 2: O Core & Dados (26/Dez - 05/Jan)**
*Objetivo: Cadastro de Câmeras e Autenticação robusta.*

- [ ] **Backend Django:**
  - [ ] Estrutura de pastas limpa (Core/Infra).
  - [ ] Auth UseCase (JWT RS256).
  - [ ] CRUD Câmeras + Signal (Post-save) para RabbitMQ.
- [ ] **Segurança (App):**
  - [ ] Secure Headers no Django (HSTS, XSS protection).
  - [ ] Proteção SQL Injection (Uso estrito do ORM).
- [ ] **QA:**
  - [ ] Teste Unitário de Auth.
  - [ ] Teste de Integração: Acessar rota sem token e receber 401 do Kong.

**Sprint 3: O Pipeline de Vídeo e IA (06/Jan - 15/Jan)**
*Objetivo: Vídeo fluindo e IA detectando.*

- [ ] **Streaming:**
  - [ ] MediaMTX com `runOnDemand`.
  - [ ] Script FFmpeg Otimizado (Vídeo Copy + Frame via HTTP POST).
- [ ] **IA Service:**
  - [ ] FastAPI para ingestão de frames -> RabbitMQ.
  - [ ] Worker Python (YOLO/Mock) consumindo fila.
- [ ] **QA:**
  - [ ] "Câmera Fake": Container transmitindo vídeo em loop para testes estáveis.

**Sprint 4: Frontend & Integração (16/Jan - 25/Jan)**
*Objetivo: Operador visualizando o Grid.*

- [ ] **React:**
  - [ ] Login integrado ao Kong.
  - [ ] Dashboard Grid (4/9 câmeras) com HLS.js.
  - [ ] Tratamento de Erro visual ("Sinal Perdido").
- [ ] **QA:**
  - [ ] Teste de Reconexão: Derrubar a câmera fake e ver se o player volta sozinho.

**Sprint 5: Code Freeze & Deploy (26/Jan - 30/Jan)**
*Objetivo: Estabilidade.*

- [ ] **Stress Test:** Simular 20 conexões RTSP (Locust).
- [ ] **Deploy:** Subir em ambiente de Staging.
- [ ] **Documentação:** Gerar PDF final.