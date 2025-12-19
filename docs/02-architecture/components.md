# Componentes do Sistema (Level 3)

## 1. Container: Streamer Engine
**Responsabilidade:** Ingerir RTSP, gerar HLS e extrair frames para IA.

| Componente | Tipo | Responsabilidade |
| :--- | :--- | :--- |
| **MediaMTX** | Server | Servidor RTSP/HLS. Gerencia o ciclo de vida (`runOnDemand`). |
| **FFmpeg Wrapper** | Script | Processo que transmuxa vídeo (copy) e envia frames para API de IA. |
| **Watchdog** | Daemon | Monitora se o FFmpeg travou e reinicia o processo. |

## 2. Container: API Core (Django)
**Responsabilidade:** Regras de negócio, gestão de câmeras e usuários.

| Componente | Tipo | Responsabilidade |
| :--- | :--- | :--- |
| **Auth UseCase** | Service | Lógica de Login e geração de JWT (RS256). |
| **Camera Controller** | View | CRUD de Câmeras. Dispara Signal ao criar/editar. |
| **Provisioning Signal** | Async | Ao salvar Câmera -> Publica msg no RabbitMQ para config do MediaMTX. |

## 3. Container: AI Pipeline
**Responsabilidade:** Detecção de objetos em frames estáticos.

| Componente | Tipo | Responsabilidade |
| :--- | :--- | :--- |
| **FastAPI Ingest** | API | Recebe `POST /frame` do FFmpeg. Valida imagem e joga na fila. |
| **YOLO Worker** | Worker | Consome fila, roda inferência (CPU/GPU) e salva metadados. |