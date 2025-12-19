**📅 Roadmap GT-Vision (Blindado com Testes)**

**Sprint 1: A Muralha de Infra (19/Dez - 25/Dez)**
Foco do Teste: Conectividade. Garantir que os containers "conversam" entre si.

[ ] Docker Compose Base:
[ ] Criar docker-compose.yml com as redes isoladas.
[ ] Configurar Postgres, PgBouncer e Redis.
[ ] [TEST] Script de Check-Health: Criar um script simples (Python ou Shell) que tenta conectar no PgBouncer e no Redis e retorna "OK" ou "Erro". (Evita descobrir que a senha do banco está errada só na Sprint 2).
[ ] Gateway & Edge:
[ ] Configurar HAProxy e Kong (DB-less).
[ ] Teste de Fumaça (Smoke Test):
[ ] [TEST] Rota de Ponta a Ponta: O teste Curl -> HAProxy -> Kong -> Django é obrigatório. Se falhar, nada mais importa.

Segurança:

HAProxy:
    [ ] Forçar HTTPS (HSTS): Impedir qualquer conexão HTTP insegura. O HAProxy deve rejeitar porta 80 ou redirecionar.
    [ ] Ocultar Versões: Remover headers que dizem Server: HAProxy/2.4. Hacker ama saber a versão para buscar CVEs (vulnerabilidades conhecidas).

No Kong (Gateway):
    [ ] Rate Limiting (Anti-DDoS Básico): Configurar plugin para limitar requisições (ex: 100 req/min por IP) na rota de Login. Isso mitiga ataques de força bruta.
    [ ] IP Whitelist (Opcional): Se a prefeitura tem IP fixo, configure o Kong para aceitar conexões na /admin apenas desse IP.

No Docker:
    [ ] Não usar Root: Garantir que os containers do Django e Workers rodem com um usuário limitado (ex: user: 1000:1000 no docker-compose). Se invadirem o container, não ganham acesso ao servidor host.

**Sprint 2: O Core & Dados (26/Dez - 05/Jan)**
Foco do Teste: Regra de Negócio e Integridade de Dados.

[ ] Arquitetura Django:
[ ] Configurar pytest no Django.
[ ] [TEST] Conexão com Pool: Criar um teste que abre 50 conexões simultâneas no Django para garantir que o PgBouncer segura a onda (e não o Postgres).
[ ] Autenticação:
[ ] Implementar AuthUseCase.
[ ] [TEST] Unitário Auth: Testar Login com sucesso, senha errada e token expirado.
[ ] [TEST] Integração Kong: Tentar acessar uma rota protegida sem Token via Curl e garantir que recebe 401 Unauthorized direto do Gateway (antes de bater no Django).
[ ] Domínio de Câmeras:
[ ] Criar Model e CRUD.
[ ] [TEST] Signal (Crítico): Criar um teste que salva uma câmera no banco e verifica (Mock) se o método send_to_rabbitmq foi chamado com os dados certos. Se isso falhar, o vídeo não liga.

Segurança:
No Django (settings.py endurecido):
    [ ] Senha Forte: Configurar validadores de senha (mínimo 12 caracteres, não comum).
    [ ] Secure Headers: Adicionar middlewares de segurança.
    [ ] Proteção SQL Injection: NUNCA use raw SQL (cursor.execute("SELECT * FROM cameras WHERE id = " + id)). Use sempre o ORM (Camera.objects.get(id=id)).

No Kong (JWT):
    [ ] Algoritmo Forte: Use RS256 (Chave Pública/Privada) em vez de HS256 se possível, ou garanta que o segredo do HS256 tenha 64 caracteres aleatórios.
    [ ] Expiração Curta: Tokens de acesso duram 15 min. Refresh tokens duram 24h.
    
**Sprint 3: O Pipeline de Vídeo e IA (06/Jan - 15/Jan)**
Foco do Teste: Fluxo de Dados e Performance.

[ ] Streaming (MediaMTX):
[ ] [TEST] Simulação RTSP: Subir um container com o rtsp-simple-server transmitindo um vídeo em loop (arquivo .mp4) para servir de "Câmera Fake" estável para testes. Não dependa de câmeras reais nesta fase.
[ ] Serviço de Ingestão (FastAPI):
[ ] [TEST] Ingestão de Frame: Testar o endpoint POST /ingest enviando uma imagem .jpg corrompida (deve falhar) e uma válida (deve ir para a fila).
[ ] Workers de IA:
[ ] [TEST] Consumo de Fila: Publicar manualmente uma mensagem na fila vision_events e verificar nos logs se o Worker processou.
[ ] [TEST] Mock da IA: Para testar o fluxo sem GPU, criar uma flag MOCK_AI=True onde o worker apenas diz "Carro Detectado" sem rodar o modelo pesado. Isso acelera o desenvolvimento.

**Sprint 4: Frontend & Integração (16/Jan - 25/Jan)**
Foco do Teste: Usabilidade e Tratamento de Erros.

[ ] Integração no React:
[ ] [TEST] Tratamento de 401/403: Se o token expirar, o front deve redirecionar para Login automaticamente. Testar isso forçando um token inválido.
[ ] Dashboard e Player:
[ ] [TEST] Componente Player: Teste visual/manual rigoroso: O que acontece se a URL do vídeo estiver errada? O player deve mostrar um ícone de "Sinal Perdido" e não uma tela branca ou crashar a página.
[ ] [TEST] Reconexão: Desligue a "Câmera Fake" (Sprint 3) e ligue de novo. O player do React deve voltar a tocar sozinho em até 10 segundos? (Requisito de resiliência).

**Sprint 5: Code Freeze & Deploy (26/Jan - 30/Jan)**
Foco do Teste: Estabilidade sob Pressão.

[ ] Testes de Carga (Locust):
[ ] [TEST] Stress API: Simular 100 usuários batendo na API de status das câmeras simultaneamente.
[ ] [TEST] Stress Vídeo: Simular 20 conexões RTSP ativas. Verificar consumo de CPU/RAM do servidor.
[ ] Watchdog e Deploy:
[ ] [TEST] Chaos Monkey: Com o sistema rodando, mate o container do Worker (docker kill). Verifique se ele sobe sozinho e volta a consumir a fila.