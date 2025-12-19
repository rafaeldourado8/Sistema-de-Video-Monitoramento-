# Modelagem de Dados

Diagrama ER focado no MVP. Simplificado para evitar migrações complexas.

```mermaid
erDiagram
    USERS ||--o{ CAMERAS : "gerencia"
    CAMERAS ||--o{ DETECTIONS : "gera"
    
    USERS {
        uuid id PK
        string username
        string password_hash
        string role "admin|operator"
    }

    CAMERAS {
        uuid id PK
        string name
        string rtsp_url "encrypted"
        string status "online|offline"
        string location_code "ex: ZN-01"
        datetime last_ping
    }

    DETECTIONS {
        uuid id PK
        uuid camera_id FK
        datetime timestamp
        string type "car|person|plate"
        float confidence
        string snapshot_path
    }