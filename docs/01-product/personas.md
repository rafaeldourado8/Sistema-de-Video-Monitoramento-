# Personas (Foco: Monitoramento Urbano/Trânsito)

## 1. Tenente Carlos, o Operador de CCO (Usuário Final)
> "Preciso identificar um acidente na Avenida Principal agora para enviar a viatura. Se a câmera travar, o trânsito para."

### Perfil
- **Cargo:** Agente de Trânsito / Operador de Monitoramento.
- **Ambiente:** Sala de Controle (CCO) com Videowall.
- **Contexto:** Monitora fluxo e incidentes em tempo real.

### Dores (Pain Points)
1. **Latência:** Se ele vê um acidente com 30s de atraso, o caos já se instalou.
2. **Estabilidade:** Prefere imagem fluida (mesmo que pixelada) do que 4K travando.
3. **Cansaço Visual:** Interface precisa ser escura (Dark Mode) e de alto contraste.

### Objetivos
- Visualizar Mosaico (Grid) de 4 a 9 câmeras sem travamentos.
- Identificar rapidamente câmeras offline (indicador visual vermelho).

---

## 2. Jorge, o Técnico de Campo (Infraestrutura)
> "Estou em cima de uma escada a 5 metros de altura. Preciso saber se a câmera conectou no servidor agora."

### Perfil
- **Cargo:** Técnico de Manutenção.
- **Ambiente:** Externo (Ruas), usando 4G/Rádio instável.
- **Dispositivo:** Celular ou Tablet.

### Dores (Pain Points)
1. **Conectividade:** Redes municipais oscilam. O sistema não pode "desistir" de reconectar a câmera.
2. **Debug:** Precisa saber se o erro é "Senha Errada" ou "Sem Rede".

### Objetivos
- Adicionar câmera e ver o status "Online" em < 10 segundos.