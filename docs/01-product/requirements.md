# Requisitos do Sistema (MVP Jan/30)

## 1. Requisitos Funcionais (Core)
| ID | Descrição | Prioridade |
| :--- | :--- | :--- |
| **RF01** | **Ingestão Resiliente:** Reconexão automática de streams RTSP (Watchdog). | Crítica |
| **RF02** | **Mosaico CCO:** Visualização de 4 a 9 câmeras simultâneas (Grid). | Alta |
| **RF03** | **Zoom Digital:** Permitir zoom no player (Frontend) para ver detalhes. | Média |
| **RF04** | **Detecção IA:** Identificar presença de veículos em frames (Ingestão via FFmpeg). | Alta |
| **RF03** | **LPR (Leitura de Placas):** O sistema deve detectar veículos e extrair o texto da placa (OCR). | Crítica | Apenas placas brasileiras (Mercosul/Cinza). |
| **RF04** | **Busca por Placa:** O operador deve poder buscar "ABC-1234" e ver onde o carro passou. | Alta | Retornar lista com foto e horário. |

## 2. Requisitos Não-Funcionais (Performance & Security)
| ID | Descrição |
| :--- | :--- |
| **RNF01** | **Baixa Latência:** Delay < 5 segundos (HLS Low Latency). |
| **RNF02** | **Segurança B2G:** Autenticação via JWT, HTTPS forçado e proteção contra força bruta. |
| **RNF03** | **Mobile First:** Interface de configuração responsiva para técnicos de campo. |

## 3. Fora do Escopo (MVP)
- Gravação na Nuvem (Foco é Live View).
- App Nativo (Android/iOS).
- Multi-tenancy (SaaS Residencial).

