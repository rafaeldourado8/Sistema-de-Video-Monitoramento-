# 📅 Roadmap GT-Vision MVP (Blindado)

**Objetivo:** Entregar sistema de monitoramento de 100 câmeras RTSP com LPR em **30/Jan/2025**.

**Princípios:**
- ✅ **Test-First:** Todo código tem teste antes de ser commitado
- 🔒 **Security-First:** Sem vulnerabilidades HIGH/CRITICAL
- 📊 **Metrics-Driven:** Decisões baseadas em dados, não achismos
- 🚫 **No Heroísmo:** Se algo está travado, escalona, não vira a madrugada

---

## 🎯 Milestones Críticos

| Milestone | Data | Gate de Qualidade |
|-----------|------|-------------------|
| **M0: Infra Validada** | 22/Dez | 20 câmeras simultâneas sem travar |
| **M1: Core MVP** | 05/Jan | CRUD + Auth funcionando |
| **M2: Streaming + IA** | 15/Jan | LPR com 85% acurácia |
| **M3: Frontend Completo** | 25/Jan | Grid de 9 câmeras fluido |
| **M4: Code Freeze** | 28/Jan | 100 câmeras 8h estável |
| **M5: Go-Live** | 30/Jan | Aprovação do Product Owner |

---

## Sprint 0: Validação de Arquitetura (16-18/Dez)

**Objetivo:** Provar que a stack aguenta 100 câmeras ANTES de codar.

### Tarefas

#### Infra Base
- [ ] **Provisionar Servidor:** 32 cores, 64 GB RAM, 2 TB SSD
- [ ] **Instalar Docker + Docker Compose:** Versão 24+
- [ ] **Configurar Redes Isoladas:**
  ```yaml
  networks:
    edge:     # HAProxy, Kong, MediaMTX
    backend:  # Django, FastAPI, Workers
    data:     # Postgres, Redis, RabbitMQ
  ```

#### Teste de Carga Precoce (CRÍTICO)
- [ ] **Stress Test MediaMTX:**
  ```bash
  # Subir 20 "câmeras fake" (rtsp-simple-server)
  docker-compose up -d fake-cameras
  
  # Medir: CPU, RAM, Latência
  docker stats mediamtx
  ```
- [ ] **Critério de Sucesso:**
  - 20 streams @ 1080p/25fps → CPU < 60%
  - Latência end-to-end < 10s
  - RAM < 8 GB
  
- [ ] **Plano B (se falhar):** Migrar para SRS (Simple Realtime Server)

#### Ferramentas de Debug
- [ ] Instalar htop, iotop, nethogs
- [ ] Configurar Prometheus + Grafana (dashboards básicos)
- [ ] Script de saúde:
  ```python
  # healthcheck.py
  import psycopg2, redis, requests
  
  def check_postgres():
      conn = psycopg2.connect("host=pgbouncer port=6432")
      conn.close()
      return "OK"
  
  def check_redis():
      r = redis.Redis(host='redis')
      r.ping()
      return "OK"
  
  print(check_postgres(), check_redis())
  ```

### Definition of Done
- [ ] Servidor com Docker funcionando
- [ ] 20 câmeras fake rodando por 1 hora sem crash
- [ ] Dashboard Grafana mostrando métricas
- [ ] **GATE:** Se CPU > 70%, PARAR e repensar stack

**Duração:** 3 dias  
**Responsável:** DevOps Márcio

---

## Sprint 1: A Muralha de Infra (19-25/Dez)

**Objetivo:** Ambiente completo com segurança de produção.

### Tarefas

#### 1.1 Docker Compose Completo
- [ ] **Criar `docker-compose.yml`:**
  ```yaml
  version: '3.9'
  services:
    haproxy:
      image: haproxy:2.8-alpine
      ports: [443:443, 8404:8404]
      volumes: [./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg]
    
    kong:
      image: kong:3.4
      environment:
        KONG_DATABASE: "off"  # DB-less
        KONG_DECLARATIVE_CONFIG: /kong.yml
    
    postgres:
      image: postgres:15-alpine
      environment:
        POSTGRES_DB: gt_vision
        POSTGRES_PASSWORD: ${DB_PASSWORD}
    
    pgbouncer:
      image: pgbouncer/pgbouncer:1.21
      environment:
        POOL_MODE: session  # NÃO transaction!
    
    redis:
      image: redis:7-alpine
      command: redis-server --maxmemory 2gb --maxmemory-policy allkeys-lru
    
    rabbitmq:
      image: rabbitmq:3.12-management
      ports: [15672:15672]
    
    mediamtx:
      image: bluenviron/mediamtx:latest
      volumes: [./mediamtx.yml:/mediamtx.yml]
    
    minio:
      image: minio/minio:latest
      command: server /data --console-address ":9001"
      environment:
        MINIO_ROOT_USER: admin
        MINIO_ROOT_PASSWORD: ${MINIO_PASSWORD}
  ```

#### 1.2 Segurança (Edge Layer)
- [ ] **HAProxy:**
  - [ ] Gerar certificado SSL self-signed (ou Let's Encrypt)
  - [ ] Forçar HTTPS (redirect 80 → 443)
  - [ ] Configurar HSTS header
  - [ ] Ocultar versão do servidor (remover header `Server`)
  
- [ ] **Kong Gateway:**
  - [ ] Configurar JWT plugin (RS256)
  - [ ] Rate Limiting: 100 req/min por IP na rota `/api/auth/login`
  - [ ] Correlation ID plugin
  - [ ] Prometheus metrics
  
- [ ] **Firewall:**
  ```bash
  ufw allow 22/tcp   # SSH
  ufw allow 443/tcp  # HTTPS
  ufw deny 5432/tcp  # Postgres (bloquear acesso externo)
  ufw enable
  ```

#### 1.3 Testes de Conectividade
- [ ] **Script Python:**
  ```python
  # tests/integration/test_connectivity.py
  import pytest
  import requests
  
  def test_haproxy_https():
      r = requests.get('https://localhost', verify=False)
      assert r.status_code in [200, 401]  # 401 = sem token, OK
  
  def test_kong_jwt_required():
      r = requests.get('https://localhost/api/cameras')
      assert r.status_code == 401
      assert 'Unauthorized' in r.text
  
  def test_postgres_via_pgbouncer():
      import psycopg2
      conn = psycopg2.connect(
          host='localhost', port=6432,
          database='gt_vision', user='postgres'
      )
      cursor = conn.cursor()
      cursor.execute('SELECT 1')
      assert cursor.fetchone()[0] == 1
  
  def test_redis_ping():
      import redis
      r = redis.Redis(host='localhost', port=6379)
      assert r.ping()
  ```

- [ ] **Smoke Test (Curl):**
  ```bash
  # Rota sem auth deve retornar 401
  curl -k https://localhost/api/cameras
  # Esperado: {"error": "Unauthorized"}
  
  # Stats do HAProxy
  curl http://localhost:8404/stats
  ```

### Definition of Done
- [ ] `docker-compose up` sobe todos os containers sem erros
- [ ] Testes de conectividade passando (pytest)
- [ ] Kong retorna 401 em rotas protegidas
- [ ] Grafana mostrando métricas de todos os containers
- [ ] **GATE:** Scan de segurança (Trivy) sem vulnerabilidades HIGH

**Duração:** 7 dias  
**Responsável:** DevOps Márcio + Dev Backend

---

## Sprint 2: O Core & Autenticação (26/Dez - 05/Jan)

**Objetivo:** Django API com CRUD seguro e JWT funcionando.

### Tarefas

#### 2.1 Estrutura Django (Clean Architecture)
- [ ] **Criar projeto:**
  ```bash
  django-admin startproject gt_vision
  cd gt_vision
  python manage.py startapp core
  python manage.py startapp infrastructure
  ```

- [ ] **Configurar `settings.py`:**
  ```python
  INSTALLED_APPS = [
      'django.contrib.admin',
      'rest_framework',
      'corsheaders',
      'django_cryptography',
      'core',
      'infrastructure',
  ]
  
  REST_FRAMEWORK = {
      'DEFAULT_AUTHENTICATION_CLASSES': [
          'rest_framework_simplejwt.authentication.JWTAuthentication',
      ],
      'DEFAULT_PERMISSION_CLASSES': [
          'rest_framework.permissions.IsAuthenticated',
      ],
  }
  
  # JWT Config
  SIMPLE_JWT = {
      'ALGORITHM': 'RS256',
      'SIGNING_KEY': open('/secrets/jwt-private.pem').read(),
      'VERIFYING_KEY': open('/secrets/jwt-public.pem').read(),
      'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
      'REFRESH_TOKEN_LIFETIME': timedelta(hours=24),
      'ROTATE_REFRESH_TOKENS': True,
  }
  
  # Security Headers
  SECURE_SSL_REDIRECT = True
  SECURE_HSTS_SECONDS = 31536000
  SESSION_COOKIE_SECURE = True
  CSRF_COOKIE_SECURE = True
  ```

#### 2.2 Domain Layer
- [ ] **Entidades:**
  ```python
  # core/domain/entities.py
  from dataclasses import dataclass
  from uuid import UUID
  
  @dataclass
  class Camera:
      id: UUID
      name: str
      rtsp_url: str
      status: str
      location_code: str
  
  @dataclass
  class User:
      id: UUID
      username: str
      role: str  # admin, operator, viewer
  ```

- [ ] **Value Objects:**
  ```python
  # core/domain/value_objects.py
  class RTSPURL:
      def __init__(self, url: str):
          if not url.startswith('rtsp://'):
              raise ValueError("Invalid RTSP URL")
          self.url = url
  ```

#### 2.3 Use Cases
- [ ] **AuthUseCase:**
  ```python
  # core/usecases/auth_usecase.py
  class AuthUseCase:
      def login(self, username: str, password: str) -> dict:
          user = self.user_repo.find_by_username(username)
          if not user.check_password(password):
              raise AuthenticationError()
          return self._generate_jwt(user)
  ```

- [ ] **CameraUseCase:**
  ```python
  # core/usecases/camera_usecase.py
  class CameraUseCase:
      def create_camera(self, data: dict) -> Camera:
          # 1. Valida RTSP URL (test connection)
          # 2. Criptografa URL
          # 3. Salva no banco
          # 4. Publica evento no RabbitMQ
          pass
  ```

#### 2.4 API Endpoints
- [ ] **POST /api/auth/login:**
  ```python
  # infrastructure/api/views.py
  from rest_framework.views import APIView
  
  class LoginView(APIView):
      permission_classes = []  # Rota pública
      
      def post(self, request):
          auth_usecase = AuthUseCase(UserRepository())
          result = auth_usecase.login(
              request.data['username'],
              request.data['password']
          )
          return Response(result)
  ```

- [ ] **GET/POST/PUT/DELETE /api/cameras:**
  ```python
  class CameraViewSet(viewsets.ModelViewSet):
      permission_classes = [IsAuthenticated, IsAdminOrOperator]
      serializer_class = CameraSerializer
      queryset = Camera.objects.all()
  ```

#### 2.5 Signal de Provisionamento
- [ ] **Post-Save Hook:**
  ```python
  # infrastructure/signals.py
  @receiver(post_save, sender=CameraModel)
  def on_camera_saved(sender, instance, created, **kwargs):
      if created:
          rabbitmq_client.publish(
              exchange='camera_events',
              routing_key='camera.created',
              message={
                  'camera_id': str(instance.id),
                  'rtsp_url': decrypt(instance.rtsp_url),
                  'action': 'start_stream'
              }
          )
  ```

#### 2.6 Testes (Obrigatórios)
- [ ] **Teste Unitário de Auth:**
  ```python
  # tests/unit/test_auth_usecase.py
  def test_login_success():
      usecase = AuthUseCase(MockUserRepo())
      result = usecase.login('admin', 'senha123')
      assert 'access_token' in result
  
  def test_login_wrong_password():
      with pytest.raises(AuthenticationError):
          usecase.login('admin', 'errada')
  ```

- [ ] **Teste de Integração (Kong + Django):**
  ```python
  # tests/integration/test_api_auth.py
  def test_protected_route_without_token():
      r = requests.get('https://localhost/api/cameras')
      assert r.status_code == 401
  
  def test_protected_route_with_valid_token():
      token = login_and_get_token()
      r = requests.get(
          'https://localhost/api/cameras',
          headers={'Authorization': f'Bearer {token}'}
      )
      assert r.status_code == 200
  ```

- [ ] **Teste de Signal:**
  ```python
  # tests/unit/test_camera_signal.py
  @mock.patch('infrastructure.rabbitmq_client.publish')
  def test_signal_publishes_to_rabbitmq(mock_publish):
      Camera.objects.create(name='Test', rtsp_url='rtsp://...')
      assert mock_publish.called
      assert mock_publish.call_args[1]['routing_key'] == 'camera.created'
  ```

- [ ] **Teste de Carga (PgBouncer):**
  ```python
  # tests/load/test_db_pool.py
  import concurrent.futures
  
  def stress_test_db():
      def query():
          with connection.cursor() as cursor:
              cursor.execute('SELECT COUNT(*) FROM cameras')
      
      with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
          futures = [executor.submit(query) for _ in range(100)]
          concurrent.futures.wait(futures)
      # Deve completar sem erros de "too many connections"
  ```

### Definition of Done
- [ ] API responde em < 200ms (P95)
- [ ] JWT com RS256 funcionando
- [ ] Testes unitários: > 80% cobertura
- [ ] Testes de integração passando
- [ ] Migrations aplicadas no banco
- [ ] **GATE:** Security scan sem SQL injection (SQLMap test)

**Duração:** 11 dias  
**Responsável:** Dev Backend

---

## Sprint 3: Streaming + IA Pipeline (06-15/Jan)

**Objetivo:** Vídeo fluindo e IA detectando placas.

### Tarefas

#### 3.1 MediaMTX + FFmpeg
- [ ] **Configurar MediaMTX:**
  ```yaml
  # mediamtx.yml
  paths:
    camera_~id~:
      runOnDemand: python3 /scripts/stream_processor.py ${id}
      runOnDemandRestart: yes
      runOnDemandCloseAfter: 30s
  ```

- [ ] **Script FFmpeg Wrapper:**
  ```python
  # scripts/stream_processor.py
  import sys
  import subprocess
  
  camera_id = sys.argv[1]
  rtsp_url = fetch_rtsp_url_from_db(camera_id)
  
  cmd = [
      'ffmpeg',
      '-rtsp_transport', 'tcp',
      '-i', rtsp_url,
      '-c:v', 'copy',
      '-f', 'hls',
      f'/tmp/hls/{camera_id}.m3u8',
      
      # Paralelo: extrai frames
      '-vf', 'fps=1',
      '-f', 'image2pipe',
      'pipe:1'
  ]
  
  process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
  for frame in read_frames(process.stdout):
      post_to_ai_service(frame, camera_id)
  ```

- [ ] **Watchdog:**
  ```python
  # scripts/watchdog.py
  from apscheduler.schedulers.blocking import BlockingScheduler
  
  def check_streams():
      for camera in get_active_cameras():
          last_frame = redis.get(f"camera:{camera.id}:last_frame")
          if is_stale(last_frame):
              restart_stream(camera.id)
  
  scheduler = BlockingScheduler()
  scheduler.add_job(check_streams, 'interval', seconds=15)
  scheduler.start()
  ```

#### 3.2 FastAPI (AI Ingest Service)
- [ ] **Endpoint de Ingestão:**
  ```python
  # ai_service/main.py
  @app.post("/ingest")
  async def ingest_frame(camera_id: str = Form(...), frame: UploadFile = File(...)):
      # Valida imagem
      content = await frame.read()
      if len(content) > 5 * 1024 * 1024:
          raise HTTPException(413, "Frame too large")
      
      # Publica na fila
      await rabbitmq.publish('vision_events', content, headers={'camera_id': camera_id})
      return {"status": "queued"}
  ```

#### 3.3 AI Workers
- [ ] **Detector de Veículos (YOLO v8):**
  ```python
  # ai_worker/detector.py
  class VehicleDetector:
      def __init__(self):
          self.model = YOLO('yolov8n.pt')  # Nano = rápido
          self.ocr = easyocr.Reader(['pt'], gpu=True)
      
      def process(self, frame_bytes, camera_id):
          image = decode_image(frame_bytes)
          results = self.model(image, classes=[2, 3, 5, 7])  # car, bike, bus, truck
          
          for box in results[0].boxes:
              vehicle_crop = crop_image(image, box.xyxy)
              plate_text = self.extract_plate(vehicle_crop)
              snapshot_path = save_to_minio(vehicle_crop, camera_id)
              
              save_detection_to_db({
                  'camera_id': camera_id,
                  'plate_text': plate_text,
                  'snapshot_path': snapshot_path,
                  'confidence': box.conf
              })
  ```

- [ ] **Consumer Loop:**
  ```python
  # ai_worker/main.py
  def main():
      connection = pika.BlockingConnection(pika.ConnectionParameters('rabbitmq'))
      channel = connection.channel()
      
      def callback(ch, method, properties, body):
          detector.process(body, properties.headers['camera_id'])
          ch.basic_ack(delivery_tag=method.delivery_tag)
      
      channel.basic_consume('vision_events', callback)
      channel.start_consuming()
  ```

#### 3.4 Testes (Críticos)
- [ ] **Câmera Fake para Testes:**
  ```bash
  # Usar rtsp-simple-server para servir vídeo em loop
  docker run -d --name fake-camera \
    -v $(pwd)/test.mp4:/test.mp4 \
    bluenviron/rtsp-simple-server
  
  # Configurar path:
  # paths:
  #   test: source: /test.mp4
  ```

- [ ] **Teste de Ingestão:**
  ```python
  # tests/integration/test_ingest.py
  def test_ingest_valid_frame():
      with open('tests/fixtures/frame.jpg', 'rb') as f:
          r = requests.post(
              'http://localhost:8001/ingest',
              files={'frame': f},
              data={'camera_id': 'cam_01'}
          )
      assert r.status_code == 200
  
  def test_ingest_corrupted_frame():
      r = requests.post(
          'http://localhost:8001/ingest',
          files={'frame': b'\x00\x00'},  # Imagem corrompida
          data={'camera_id': 'cam_01'}
      )
      assert r.status_code == 400
  ```

- [ ] **Teste de IA (Mock):**
  ```python
  # tests/unit/test_detector.py
  @mock.patch.object(VehicleDetector, '_run_yolo')
  def test_detection_flow(mock_yolo):
      mock_yolo.return_value = [MockDetection(plate='ABC1D23')]
      
      detector = VehicleDetector()
      result = detector.process(frame_bytes, 'cam_01')
      
      assert len(result) == 1
      assert result[0]['plate_text'] == 'ABC1D23'
  ```

- [ ] **Teste de Stress (Latência):**
  ```python
  # tests/load/test_streaming_latency.py
  import time
  
  def test_end_to_end_latency():
      # 1. Inicia stream
      start_time = time.time()
      
      # 2. Aguarda primeiro frame no HLS
      while not hls_playlist_exists(camera_id):
          time.sleep(0.1)
      
      # 3. Mede latência
      latency = time.time() - start_time
      assert latency < 8  # Requisito: < 8s
  ```

### Definition of Done
- [ ] 20 câmeras fake rodando simultaneamente
- [ ] Latência end-to-end < 8s (medida)
- [ ] LPR com > 85% acurácia (teste com 100 placas conhecidas)
- [ ] CPU < 70% com 20 streams
- [ ] **GATE:** Watchdog reinicia stream travado em < 30s

**Duração:** 10 dias  
**Responsável:** Dev Backend + DevOps

---

## Sprint 4: Frontend & UX (16-25/Jan)

**Objetivo:** Operador consegue visualizar grid e buscar placas.

### Tarefas

#### 4.1 Setup React
- [ ] **Criar projeto:**
  ```bash
  npx create-react-app gt-vision-frontend --template typescript
  cd gt-vision-frontend
  npm install hls.js axios react-router-dom zustand
  ```

#### 4.2 Autenticação
- [ ] **Login Page:**
  ```tsx
  // src/pages/Login.tsx
  const Login = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    
    const handleLogin = async () => {
      const response = await axios.post('/api/auth/login', { username, password });
      localStorage.setItem('access_token', response.data.access_token);
      navigate('/dashboard');
    };
    
    return (
      <form onSubmit={handleLogin}>
        <input type="text" value={username} onChange={e => setUsername(e.target.value)} />
        <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
        <button>Login</button>
      </form>
    );
  };
  ```

- [ ] **Interceptor Axios (JWT):**
  ```ts
  // src/api/client.ts
  axios.interceptors.request.use(config => {
    const token = localStorage.getItem('access_token');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  });
  
  axios.interceptors.response.use(
    response => response,
    error => {
      if (error.response.status === 401) {
        localStorage.removeItem('access_token');
        window.location.href = '/login';
      }
      return Promise.reject(error);
    }
  );
  ```

#### 4.3 Dashboard (Grid de Câmeras)
- [ ] **Componente Player:**
  ```tsx
  // src/components/Player.tsx
  import Hls from 'hls.js';
  
  const Player = ({ cameraId }: { cameraId: string }) => {
    const videoRef = useRef<HTMLVideoElement>(null);
    
    useEffect(() => {
      const hls = new Hls({
        lowLatencyMode: true,
        backBufferLength: 30,
      });
      
      hls.loadSource(`/stream/${cameraId}.m3u8`);
      hls.attachMedia(videoRef.current!);
      
      hls.on(Hls.Events.ERROR, (event, data) => {
        if (data.fatal) {
          console.error('HLS error', data);
          // Mostrar ícone "Sinal Perdido"
        }
      });
      
      return () => hls.destroy();
    }, [cameraId]);
    
    return <video ref={videoRef} autoPlay muted />;
  };
  ```

- [ ] **Grid Layout:**
  ```tsx
  // src/pages/Dashboard.tsx
  const Dashboard = () => {
    const [cameras, setCameras] = useState([]);
    const [gridSize, setGridSize] = useState(9);  // 4, 9 ou 16
    
    useEffect(() => {
      axios.get('/api/cameras').then(r => setCameras(r.data));
    }, []);
    
    return (
      <div className={`grid grid-cols-${Math.sqrt(gridSize)}`}>
        {cameras.slice(0, gridSize).map(camera => (
          <div key={camera.id} className="relative">
            <Player cameraId={camera.id} />
            <div className={`status-badge ${camera.status}`}>
              {camera.name}
            </div>
          </div>
        ))}
      </div>
    );
  };
  ```

#### 4.4 Busca de Placas
- [ ] **Search Bar:**
  ```tsx
  // src/pages/Search.tsx
  const Search = () => {
    const [plate, setPlate] = useState('');
    const [results, setResults] = useState([]);
    
    const handleSearch = async () => {
      const r = await axios.get(`/api/detections/search?plate=${plate}`);
      setResults(r.data);
    };
    
    return (
      <>
        <input value={plate} onChange={e => setPlate(e.target.value)} />
        <button onClick={handleSearch}>Buscar</button>
        
        <div className="results">
          {results.map(det => (
            <div key={det.id}>
              <img src={det.snapshot_url} alt={det.plate_text} />
              <p>{det.detected_at} - {det.camera.name}</p>
            </div>
          ))}
        </div>
      </>
    );
  };
  ```

#### 4.5 Testes de Frontend
- [ ] **Teste de Reconexão:**
  ```js
  // tests/e2e/player.spec.js (Playwright)
  test('player reconecta automaticamente', async ({ page }) => {
    await page.goto('/dashboard');
    
    // 1. Aguarda player carregar
    await page.waitForSelector('video');
    
    // 2. Simula queda de câmera (stop container)
    await stopCameraContainer('cam_01');
    
    // 3. Aguarda ícone "Sinal Perdido"
    await page.waitForSelector('.signal-lost');
    
    // 4. Religamento da câmera
    await startCameraContainer('cam_01');
    
    // 5. Verifica se player volta a tocar
    await page.waitForSelector('video[data-playing="true"]', { timeout: 15000 });
  });
  ```

- [ ] **Teste de Tratamento de Erro:**
  ```js
  test('mostra erro se token expirado', async ({ page }) => {
    // 1. Login
    await page.goto('/login');
    await page.fill('#username', 'admin');
    await page.fill('#password', 'senha123');
    await page.click('button[type=submit]');
    
    // 2. Expira token (mock)
    await page.evaluate(() => {
      localStorage.setItem('access_token', 'token_invalido');
    });
    
    // 3. Tenta acessar rota protegida
    await page.goto('/dashboard');
    
    // 4. Deve redirecionar para login
    await page.waitForURL('/login');
  });
  ```

### Definition of Done
- [ ] Grid de 9 câmeras renderiza sem lag
- [ ] Status de câmera atualiza em < 5s
- [ ] Busca por placa retorna resultados em < 3s
- [ ] Testes E2E passando (Playwright)
- [ ] **GATE:** SUS Score > 70 (teste de usabilidade com 3 operadores)

**Duração:** 10 dias  
**Responsável:** Dev Frontend

---

## Sprint 5: Code Freeze & Hardening (26-30/Jan)

**Objetivo:** Estabilidade, segurança e documentação.

### Tarefas

#### 5.1 Testes de Carga (Locust)
- [ ] **Script de Stress:**
  ```python
  # tests/load/locustfile.py
  from locust import HttpUser, task, between
  
  class OperatorUser(HttpUser):
      wait_time = between(1, 3)
      
      def on_start(self):
          self.client.post('/api/auth/login', json={
              'username': 'operator1',
              'password': 'senha123'
          })
      
      @task(3)
      def view_cameras(self):
          self.client.get('/api/cameras')
      
      @task(1)
      def search_plate(self):
          self.client.get('/api/detections/search?plate=ABC1D23')
  ```

- [ ] **Executar Teste:**
  ```bash
  # Simular 100 operadores por 8 horas
  locust -f tests/load/locustfile.py --users 100 --run-time 8h
  
  # Critério de Sucesso:
  # - 0 erros HTTP 500
  # - P95 latência < 500ms
  # - CPU < 80%, RAM < 90%
  ```

#### 5.2 Teste de Resiliência (Chaos Monkey)
- [ ] **Matar Containers Aleatoriamente:**
  ```bash
  # tests/chaos/chaos.sh
  while true; do
    CONTAINER=$(docker ps --format '{{.Names}}' | shuf -n 1)
    echo "Killing $CONTAINER"
    docker kill $CONTAINER
    sleep 300  # 5 min
  done
  ```

- [ ] **Validar:**
  - Workers de IA se recuperam automaticamente (Docker restart policy)
  - Câmeras reconectam via Watchdog
  - Frontend mostra mensagem amigável

#### 5.3 Security Audit
- [ ] **Scan de Vulnerabilidades:**
  ```bash
  # Scan de imagens Docker
  trivy image gt-vision/django:latest
  trivy image gt-vision/ai-worker:latest
  
  # Scan de código
  bandit -r . -ll  # Python
  npm audit --production  # React
  ```

- [ ] **Teste de Penetração (OWASP):**
  ```bash
  # SQL Injection
  sqlmap -u "https://localhost/api/cameras?id=1" --cookie="token=..."
  
  # XSS
  zaproxy -quickurl https://localhost
  ```

- [ ] **Correções:**
  - Atualizar dependências com CVEs
  - Adicionar sanitização de inputs
  - Configurar CSP headers

#### 5.4 Documentação
- [ ] **README.md (Operacional):**
  ```markdown
  # GT-Vision - Guia de Operação
  
  ## Como Adicionar Câmera
  1. Acessar /dashboard
  2. Clicar em "Adicionar Câmera"
  3. Preencher Nome, RTSP URL, Localização
  4. Clicar "Test Connection" → Verde = OK
  5. Salvar
  
  ## Troubleshooting
  - Câmera offline: Verificar firewall, senha RTSP
  - Vídeo travando: CPU > 80%? Contatar DevOps
  ```

- [ ] **Runbook (DevOps):**
  ```markdown
  # Runbook GT-Vision
  
  ## Incidente: 50% das Câmeras Offline
  
  1. Verificar MediaMTX:
     docker logs mediamtx | grep ERROR
  
  2. Verificar rede:
     ping <IP_da_camera>
  
  3. Reiniciar Watchdog:
     docker restart watchdog
  
  4. Se persistir: Escalar para N3
  ```

- [ ] **Swagger (OpenAPI):**
  ```yaml
  # docs/api.yml
  openapi: 3.0.0
  paths:
    /api/cameras:
      get:
        summary: Listar câmeras
        security:
          - bearerAuth: []
        responses:
          200:
            description: Lista de câmeras
  ```

#### 5.5 Deploy em Staging
- [ ] **Ambiente de Staging:**
  - Provisionar servidor idêntico ao de produção
  - Subir stack completa
  - Configurar 10 câmeras reais (não fake)

- [ ] **Smoke Test em Staging:**
  ```bash
  # tests/staging/smoke.sh
  curl -k https://staging.gt-vision.com.br/api/health
  # Esperado: {"status": "healthy"}
  
  curl -k https://staging.gt-vision.com.br/stream/cam_01.m3u8
  # Esperado: #EXTM3U
  ```

#### 5.6 Aprovação do Product Owner
- [ ] **Demo ao Vivo:**
  - Grid de 9 câmeras funcionando
  - Busca de placa retornando resultado
  - Dashboard de uptime

- [ ] **Critérios de Go-Live:**
  - [ ] 100 câmeras simultâneas por 8h sem crash
  - [ ] LPR com 85% acurácia (teste com 100 placas)
  - [ ] Latência < 8s (medida em 10 câmeras aleatórias)
  - [ ] Zero vulnerabilidades CRITICAL
  - [ ] Aprovação formal do PO (email ou documento assinado)

### Definition of Done
- [ ] Teste de carga 8h concluído sem erros
- [ ] Security audit aprovado (0 HIGH/CRITICAL)
- [ ] Documentação completa (README + Runbook + Swagger)
- [ ] Demo ao PO realizada e aprovada
- [ ] **GATE:** GO/NO-GO Decision → Se falhar, atrasa lançamento

**Duração:** 5 dias  
**Responsável:** Time completo

---

## Fase Pós-MVP (Fev-Mar 2025)

### Backlog Priorizado

| Funcionalidade | Justificativa | Esforço |
|----------------|---------------|---------|
| **Dashboard Executivo (Sargento Ana)** | KPIs de uptime, custo por câmera | 2 semanas |
| **Alertas no Telegram** | Notificação proativa de falhas | 1 semana |
| **Auditoria de Acesso (LGPD)** | Compliance Art. 46 | 1 semana |
| **Integração com CAD** | Dispatch automático de viaturas | 4 semanas |
| **App Mobile Nativo** | Técnicos de campo usam celular | 6 semanas |

---

## 📊 Métricas de Acompanhamento

### Daily Standup (9h)
```markdown
**O que fiz ontem?**
**O que farei hoje?**
**Tenho algum impedimento?**
```

### KPIs Semanais (Dashboard Notion/Jira)

| Métrica | Meta | Status Atual |
|---------|------|--------------|
| **Testes Passando** | 100% | ![95%](green) |
| **Cobertura de Código** | > 80% | 78% |
| **Vulnerabilidades** | 0 HIGH | 2 MEDIUM |
| **Latência API** | < 200ms | 150ms |
| **Uptime Staging** | > 99% | 99.2% |

### Retrospectiva (Fim de Cada Sprint)

**Template:**
```markdown
## O que funcionou bem? 🎉
- Testes automatizados economizaram tempo

## O que pode melhorar? 🔧
- Comunicação com DevOps sobre infra

## Ações para próxima sprint:
- [ ] Criar canal #infra-alerts no Slack
```

---

## 🚨 Plano de Contingência

### Riscos Críticos

| Risco | Probabilidade | Mitigação |
|-------|---------------|-----------|
| **MediaMTX não aguenta 100 streams** | 🟡 Média | Sprint 0 valida com 20. Se falhar → migra para SRS |
| **GPU trava em produção** | 🟢 Baixa | Fallback CPU + Circuit Breaker |
| **Atraso na Sprint 3** | 🟡 Média | Buffer de 2 dias embutido no roadmap |
| **PO não aprova MVP** | 🟢 Baixa | Demos incrementais a cada sprint |

### Comunicação de Crise

**Se algo der MUITO errado:**
1. **Comunicar imediatamente:** Slack #gt-vision-critical
2. **War Room:** Reunião de emergência (todos online)
3. **Log de Decisões:** Documentar no Notion tudo que foi decidido
4. **Post-Mortem:** Após resolver, fazer análise de causa raiz

---

## ✅ Checklist Final (28/Jan)

Antes de declarar "MVP Completo":

- [ ] **Funcionalidades:**
  - [ ] 100 câmeras simultâneas rodando
  - [ ] LPR com 85% acurácia
  - [ ] Busca de placas em < 3s
  - [ ] Grid de 9 câmeras sem lag

- [ ] **Performance:**
  - [ ] Latência end-to-end < 8s
  - [ ] CPU < 80%, RAM < 90%
  - [ ] Uptime > 98% (7 dias em staging)

- [ ] **Segurança:**
  - [ ] 0 vulnerabilidades HIGH/CRITICAL
  - [ ] JWT RS256 configurado
  - [ ] HTTPS forçado
  - [ ] Logs de auditoria habilitados

- [ ] **Testes:**
  - [ ] Cobertura > 80%
  - [ ] Testes de carga 8h aprovados
  - [ ] E2E tests passando

- [ ] **Documentação:**
  - [ ] README operacional
  - [ ] Runbook de incidentes
  - [ ] Swagger publicado

- [ ] **Aprovação:**
  - [ ] Demo ao PO realizada
  - [ ] Sign-off formal recebido

---

**Status:** 🟢 ON TRACK  
**Última Atualização:** 19/Dez/2024  
**Próxima Revisão:** Daily Standup (9h)

---

**Contatos de Emergência:**
- **DevOps Márcio:** +55 11 99999-0001
- **Product Owner (Sargento Ana):** ana@prefeitura.gov.br
- **On-Call (24/7):** +55 11 99999-0000