# Makefile
.PHONY: setup up down logs

setup:
	@echo "🔐 A gerar certificados e chaves de desenvolvimento..."
	@mkdir -p secrets/certs
	
	# 1. Certificado SSL Self-Signed para o HAProxy (HTTPS)
	@openssl req -x509 -newkey rsa:2048 -keyout secrets/certs/gt-vision.key -out secrets/certs/gt-vision.crt -days 365 -nodes -subj "/CN=localhost"
	@cat secrets/certs/gt-vision.crt secrets/certs/gt-vision.key > secrets/certs/gt-vision.pem
	
	# 2. Par de chaves JWT (RS256) para o Kong/Django
	@openssl genrsa -out secrets/jwt-private.pem 2048
	@openssl rsa -in secrets/jwt-private.pem -pubout -out secrets/jwt-public.pem
	
	# 3. Chave Fernet para encriptação de URLs RTSP
	@python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())" > secrets/fernet.key
	
	@echo "✅ Setup concluído. Agora execute 'make up'."

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f