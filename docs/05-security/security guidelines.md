# Security Guidelines & Hardening Checklist

## 1. Security Principles

### 1.1 Core Tenets

```
🔐 Defense in Depth: Múltiplas camadas de segurança
🚫 Least Privilege: Menor privilégio necessário
🔒 Zero Trust: Nunca confie, sempre verifique
📊 Audit Everything: Logs de todas as ações sensíveis
🔄 Fail Secure: Em caso de erro, bloqueie acesso
```

### 1.2 Compliance

- **LGPD (Lei 13.709/2018):** Proteção de dados pessoais
- **Marco Civil da Internet (Lei 12.965/2014):** Retenção de logs
- **ISO 27001:** Gestão de segurança da informação (aspiracional)

---

## 2. Network Security

### 2.1 Segmentação de Rede

```
┌─────────────────────────────────────────────┐
│  DMZ (Edge Layer)                           │
│  - HAProxy (443/tcp)                        │
│  - Kong (8000/tcp)                          │
│  - MediaMTX (8554/tcp RTSP)                 │
└────────────────┬────────────────────────────┘
                 │ Firewall (iptables)
                 ▼
┌─────────────────────────────────────────────┐
│  Application Layer (10.0.1.0/24)            │
│  - Django, FastAPI, Workers                 │
│  - SEM acesso à internet (internal: true)  │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│  Data Layer (10.0.2.0/24)                   │
│  - Postgres, Redis, RabbitMQ                │
│  - SEM acesso externo                       │
└─────────────────────────────────────────────┘
```

### 2.2 Firewall Rules (iptables)

```bash
#!/bin/bash
# /etc/iptables/rules.sh

# Flush todas as regras
iptables -F
iptables -X

# Policy padrão: DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Loopback
iptables -A INPUT -i lo -j ACCEPT

# Conexões estabelecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH (apenas de IPs da prefeitura)
iptables -A INPUT -p tcp --dport 22 -s 200.100.50.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix "SSH_DENIED: "
iptables -A INPUT -p tcp --dport 22 -j DROP

# HTTPS (público)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# RTSP (apenas de câmeras)
iptables -A INPUT -p tcp --dport 8554 -s 10.20.30.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 8554 -j DROP

# Rate Limiting (anti-DDoS básico)
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m recent --update --seconds 60 --hitcount 20 -j DROP

# Bloquear acesso direto ao banco
iptables -A INPUT -p tcp --dport 5432 -s 10.0.1.0/24 -j ACCEPT  # Apenas app layer
iptables -A INPUT -p tcp --dport 5432 -j DROP

# Bloquear acesso direto ao Redis
iptables -A INPUT -p tcp --dport 6379 -s 10.0.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 6379 -j DROP

# Log de pacotes descartados
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables_INPUT_denied: " --log-level 7

# Salvar regras
iptables-save > /etc/iptables/rules.v4

# Persistir após reboot
apt-get install -y iptables-persistent
```

### 2.3 Fail2Ban (Proteção contra Força Bruta)

```ini
# /etc/fail2ban/jail.local

[DEFAULT]
bantime  = 1h
findtime  = 10m
maxretry = 3

[sshd]
enabled = true
port    = 22
logpath = /var/log/auth.log

[nginx-limit-req]
enabled = true
filter  = nginx-limit-req
logpath = /var/log/nginx/error.log

[kong-auth]
enabled  = true
port     = 443
filter   = kong-auth
logpath  = /var/log/kong/error.log
maxretry = 5
```

```ini
# /etc/fail2ban/filter.d/kong-auth.conf

[Definition]
failregex = ^\[error\] .* client: <HOST>, .* "Unauthorized"
ignoreregex =
```

---

## 3. Application Security

### 3.1 Django Security Settings

```python
# settings/production.py

# HTTPS Enforcement
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# HSTS (HTTP Strict Transport Security)
SECURE_HSTS_SECONDS = 31536000  # 1 ano
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# Cookies
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Strict'
SESSION_COOKIE_AGE = 3600  # 1 hora

CSRF_COOKIE_SECURE = True
CSRF_COOKIE_HTTPONLY = True
CSRF_COOKIE_SAMESITE = 'Strict'

# Content Security Policy
CSP_DEFAULT_SRC = ("'self'",)
CSP_SCRIPT_SRC = ("'self'", "'unsafe-inline'")  # Evitar unsafe-inline em produção
CSP_STYLE_SRC = ("'self'", "'unsafe-inline'")
CSP_IMG_SRC = ("'self'", "data:", "https://minio:9000")
CSP_CONNECT_SRC = ("'self'", "wss://gt-vision.prefeitura.gov.br")

# XSS Protection
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# Password Validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {'min_length': 12}
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
]

# Logging Seguro (não logar senhas)
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'secure': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        }
    },
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse',
        },
    },
    'handlers': {
        'file': {
            'level': 'WARNING',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/django/security.log',
            'maxBytes': 10 * 1024 * 1024,  # 10 MB
            'backupCount': 5,
            'formatter': 'secure',
        },
    },
    'loggers': {
        'django.security': {
            'handlers': ['file'],
            'level': 'WARNING',
            'propagate': False,
        },
    },
}

# Rate Limiting (Django Ratelimit)
RATELIMIT_ENABLE = True
RATELIMIT_USE_CACHE = 'default'

# Allowed Hosts
ALLOWED_HOSTS = [
    'gt-vision.prefeitura.gov.br',
    'localhost',
    '10.0.1.10',  # IP interno
]

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'OPTIONS': {
            'sslmode': 'require',  # Força SSL
            'connect_timeout': 10,
            'options': '-c statement_timeout=30000',
        }
    }
}
```

### 3.2 SQL Injection Prevention

**❌ NUNCA FAÇA:**

```python
# VULNERÁVEL A SQL INJECTION
def get_camera(camera_id):
    cursor.execute(f"SELECT * FROM cameras WHERE id = '{camera_id}'")
    # Ataque: camera_id = "1' OR '1'='1"
```

**✅ SEMPRE FAÇA:**

```python
# SEGURO (Django ORM)
def get_camera(camera_id):
    return Camera.objects.get(id=camera_id)

# OU com raw SQL (parametrizado)
def get_camera_raw(camera_id):
    cursor.execute("SELECT * FROM cameras WHERE id = %s", [camera_id])
```

### 3.3 XSS Prevention

```python
# Django escapa automaticamente no template
# {{ camera.name }}  → Safe

# Se precisar renderizar HTML (cuidado!):
from django.utils.html import escape

def render_camera_name(name):
    return escape(name)
```

```javascript
// React também escapa por padrão
const CameraName = ({ name }) => {
  return <div>{name}</div>;  // Safe
};

// Se precisar renderizar HTML (cuidado!):
import DOMPurify from 'dompurify';

const SafeHTML = ({ html }) => {
  return <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />;
};
```

### 3.4 CSRF Protection

```python
# Django: Automático em forms
<form method="post">
  {% csrf_token %}
  ...
</form>

# React: Incluir token em headers
axios.defaults.headers.common['X-CSRFToken'] = getCookie('csrftoken');
```

---

## 4. Authentication & Authorization

### 4.1 JWT Security (RS256)

```python
# settings.py
SIMPLE_JWT = {
    'ALGORITHM': 'RS256',  # Assimétrico (mais seguro que HS256)
    'SIGNING_KEY': open('/secrets/jwt-private.pem').read(),
    'VERIFYING_KEY': open('/secrets/jwt-public.pem').read(),
    
    # Tokens de curta duração
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(hours=24),
    
    # Rotação de refresh tokens
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    
    # Claims obrigatórios
    'REQUIRED_CLAIMS': ['exp', 'iat', 'sub'],
    
    # Validações
    'VERIFY_EXP': True,
    'VERIFY_IAT': True,
    'LEEWAY': 0,
}
```

**Rotação de Chaves (a cada 90 dias):**

```bash
#!/bin/bash
# scripts/rotate_jwt_keys.sh

# 1. Gerar novo par de chaves
ssh-keygen -t rsa -b 4096 -m PEM -f /secrets/jwt-private-new.pem -N ""
openssl rsa -in /secrets/jwt-private-new.pem -pubout -out /secrets/jwt-public-new.pem

# 2. Atualizar config (manter chave antiga por 24h para tokens em uso)
# ... (deploy com ambas as chaves)

# 3. Após 24h, remover chave antiga
rm /secrets/jwt-private-old.pem /secrets/jwt-public-old.pem
```

### 4.2 Role-Based Access Control (RBAC)

```python
# core/domain/permissions.py

class Permission(Enum):
    VIEW_CAMERAS = "view_cameras"
    MANAGE_CAMERAS = "manage_cameras"
    VIEW_DETECTIONS = "view_detections"
    DOWNLOAD_EVIDENCE = "download_evidence"
    MANAGE_USERS = "manage_users"

ROLE_PERMISSIONS = {
    'admin': [
        Permission.VIEW_CAMERAS,
        Permission.MANAGE_CAMERAS,
        Permission.VIEW_DETECTIONS,
        Permission.DOWNLOAD_EVIDENCE,
        Permission.MANAGE_USERS,
    ],
    'operator': [
        Permission.VIEW_CAMERAS,
        Permission.VIEW_DETECTIONS,
        Permission.DOWNLOAD_EVIDENCE,
    ],
    'viewer': [
        Permission.VIEW_CAMERAS,
    ],
}

def has_permission(user, permission):
    return permission in ROLE_PERMISSIONS.get(user.role, [])
```

```python
# infrastructure/api/permissions.py
from rest_framework.permissions import BasePermission

class CanManageCameras(BasePermission):
    def has_permission(self, request, view):
        if request.method in ['GET', 'HEAD', 'OPTIONS']:
            return True
        return has_permission(request.user, Permission.MANAGE_CAMERAS)
```

---

## 5. Data Protection

### 5.1 Encryption at Rest

**RTSP URLs (Fernet):**

```python
# infrastructure/security/encryption.py
from cryptography.fernet import Fernet

class EncryptionService:
    def __init__(self):
        with open('/secrets/fernet.key', 'rb') as f:
            self.cipher = Fernet(f.read())
    
    def encrypt_rtsp_url(self, url: str) -> str:
        return self.cipher.encrypt(url.encode()).decode()
    
    def decrypt_rtsp_url(self, encrypted_url: str) -> str:
        return self.cipher.decrypt(encrypted_url.encode()).decode()
```

```python
# infrastructure/persistence/models.py
from django_cryptography.fields import encrypt

class CameraModel(models.Model):
    rtsp_url = encrypt(models.TextField())  # Automático
```

**Database (TDE - Transparent Data Encryption):**

```sql
-- PostgreSQL + pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Criptografar coluna sensível
ALTER TABLE cameras 
ADD COLUMN rtsp_url_encrypted BYTEA;

UPDATE cameras 
SET rtsp_url_encrypted = pgp_sym_encrypt(rtsp_url, 'master_key_from_env');
```

### 5.2 Encryption in Transit

**TLS 1.3 Only:**

```nginx
# haproxy.cfg
global
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    ssl-default-bind-options ssl-min-ver TLSv1.3

frontend https_in
    bind *:443 ssl crt /etc/ssl/certs/gt-vision.pem alpn h2,http/1.1
```

**Database Connections:**

```python
# Django settings
DATABASES = {
    'default': {
        'OPTIONS': {
            'sslmode': 'require',
            'sslrootcert': '/etc/ssl/certs/ca-certificates.crt',
        }
    }
}
```

---

## 6. Secrets Management

### 6.1 Docker Secrets

```yaml
# docker-compose.prod.yml
secrets:
  db_password:
    file: /secrets/db_password.txt
  jwt_private_key:
    file: /secrets/jwt-private.pem

services:
  django:
    secrets:
      - db_password
      - jwt_private_key
    environment:
      DB_PASSWORD_FILE: /run/secrets/db_password
```

```python
# Ler secret no código
def get_db_password():
    with open('/run/secrets/db_password', 'r') as f:
        return f.read().strip()
```

### 6.2 Vault (Produção Enterprise)

```python
# infrastructure/security/vault_client.py
import hvac

class VaultClient:
    def __init__(self):
        self.client = hvac.Client(url='https://vault:8200', token=os.getenv('VAULT_TOKEN'))
    
    def get_secret(self, path):
        return self.client.secrets.kv.v2.read_secret_version(path=path)['data']['data']

# Uso:
vault = VaultClient()
db_password = vault.get_secret('database/postgres')['password']
```

---

## 7. Audit Logging

### 7.1 Structured Logging

```python
# infrastructure/logging/audit_logger.py
import logging
import json
from datetime import datetime

class AuditLogger:
    def __init__(self):
        self.logger = logging.getLogger('audit')
    
    def log_access(self, user_id, action, resource_type, resource_id, ip_address, metadata=None):
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'user_id': str(user_id),
            'action': action,
            'resource_type': resource_type,
            'resource_id': str(resource_id),
            'ip_address': ip_address,
            'metadata': metadata or {},
        }
        self.logger.info(json.dumps(event))
```

**Uso:**

```python
# infrastructure/api/views.py
class CameraViewSet(viewsets.ModelViewSet):
    def retrieve(self, request, pk=None):
        camera = self.get_object()
        
        audit_logger.log_access(
            user_id=request.user.id,
            action='view_camera',
            resource_type='camera',
            resource_id=camera.id,
            ip_address=get_client_ip(request),
            metadata={'camera_name': camera.name}
        )
        
        return Response(CameraSerializer(camera).data)
```

### 7.2 Logs Imutáveis (WORM - Write Once Read Many)

```bash
# Enviar logs para sistema externo (Splunk, ELK)
# Logs locais podem ser deletados/modificados

# Usar syslog para enviar logs para servidor central
logger.addHandler(logging.handlers.SysLogHandler(address=('10.0.0.100', 514)))
```

---

## 8. Vulnerability Management

### 8.1 Dependency Scanning

```bash
# Python (Bandit + Safety)
bandit -r . -ll
safety check --json

# Node.js (npm audit)
npm audit --production

# Docker (Trivy)
trivy image gt-vision/django:latest --severity HIGH,CRITICAL
```

### 8.2 Patch Management

```bash
#!/bin/bash
# scripts/security_updates.sh

# Atualizar sistema operacional
apt-get update && apt-get upgrade -y

# Atualizar dependências Python
pip list --outdated | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U

# Atualizar dependências Node
npm update --save

# Rebuild imagens Docker
docker-compose build --no-cache
```

---

## 9. Incident Response

### 9.1 Security Incident Playbook

**Fase 1: Detecção (0-15 min)**

1. Alerta recebido (Grafana, Telegram, Sentry)
2. Validar se é incidente real ou falso positivo
3. Classificar severidade (P1: Crítico, P2: Alto, P3: Médio)

**Fase 2: Contenção (15-60 min)**

1. Isolar sistema comprometido:
   ```bash
   # Desconectar da rede
   docker network disconnect gt-vision-backend django
   
   # Ou parar container
   docker stop django
   ```

2. Preservar evidências:
   ```bash
   # Coletar logs
   docker logs django > /var/tmp/incident-$(date +%s).log
   
   # Snapshot do sistema
   lxc snapshot gt-vision snap-incident-$(date +%s)
   ```

**Fase 3: Erradicação (1-4h)**

1. Identificar causa raiz
2. Aplicar patch ou correção
3. Validar em ambiente de teste

**Fase 4: Recuperação (4-24h)**

1. Restaurar sistema limpo
2. Monitorar por 24h
3. Comunicar stakeholders

**Fase 5: Post-Mortem (1 semana)**

1. Documentar incidente
2. Identificar melhorias
3. Atualizar playbook

### 9.2 Contatos de Emergência

```yaml
Escalation Chain:
  L1 (DevOps): Márcio (+55 11 99999-0001)
  L2 (Infra Manager): João (+55 11 99999-0002)
  L3 (CISO): Maria (+55 11 99999-0003)
  
External:
  CERT.br: cert@cert.br
  ANPD (LGPD): anpd@anpd.gov.br
```

---

## 10. Security Checklist

### 10.1 Deployment Security Review

- [ ] **Network:**
  - [ ] Firewall configurado (iptables)
  - [ ] Portas desnecessárias fechadas
  - [ ] Fail2Ban habilitado
  - [ ] Redes isoladas (Docker networks)

- [ ] **Application:**
  - [ ] Django settings hardened (SECURE_*)
  - [ ] CSRF protection ativo
  - [ ] XSS protection ativo
  - [ ] SQL injection: 100% ORM
  - [ ] Senhas com validação forte (12+ chars)

- [ ] **Authentication:**
  - [ ] JWT com RS256
  - [ ] Tokens de curta duração (15 min)
  - [ ] Rate limiting no login (5 tentativas)
  - [ ] MFA habilitado para admins (futuro)

- [ ] **Data:**
  - [ ] RTSP URLs criptografadas (Fernet)
  - [ ] TLS 1.3 em todas as conexões
  - [ ] Backup criptografado (GPG)
  - [ ] Retenção conforme LGPD (7-30 dias)

- [ ] **Monitoring:**
  - [ ] Logs estruturados (JSON)
  - [ ] Audit logs de acesso
  - [ ] Alertas de segurança (Prometheus)
  - [ ] Vulnerabilidades scaneadas (Trivy)

- [ ] **Incident Response:**
  - [ ] Playbook documentado
  - [ ] Contatos atualizados
  - [ ] Backup testado (restore < 1h)
  - [ ] Rollback procedure validada

---

## 11. Compliance Checklist (LGPD)

- [ ] **Art. 6º (Princípios):**
  - [ ] Finalidade: Apenas segurança pública
  - [ ] Adequação: Sistema projetado para este fim
  - [ ] Necessidade: Apenas dados essenciais
  - [ ] Transparência: Política de privacidade publicada

- [ ] **Art. 7º (Base Legal):**
  - [ ] Execução de políticas públicas (segurança)

- [ ] **Art. 46 (Segurança):**
  - [ ] Criptografia TLS 1.3
  - [ ] Controle de acesso (RBAC)
  - [ ] Logs de auditoria (6 meses)

- [ ] **Art. 48 (Incidentes):**
  - [ ] Playbook de resposta
  - [ ] Notificação à ANPD em < 72h

- [ ] **Art. 50 (DPO):**
  - [ ] Indicar Encarregado de Dados
  - [ ] Publicar contato (dpo@prefeitura.gov.br)

---

**Versão:** 1.0  
**Autor:** CISO Maria  
**Última Revisão:** 19/Dez/2024  
**Próxima Revisão:** Trimestral