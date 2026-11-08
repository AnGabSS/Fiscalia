# Fiscália — Inteligência Tributária Multi-Setorial (Reforma Tributária LC 214)

```text
  ╭──────────────────────────────────────────────────────────────────────╮
  │  F I S C Á L I A  —  T A X   R E F O R M   I N T E L L I G E N C E   │
  │  n8n · postgres 16 + pgvector · google gemini · slack & telegram     │
  ╰──────────────────────────────────────────────────────────────────────╯
```

O **Fiscália** é uma plataforma de monitoramento normativo ativo (**Push**) e agente conversacional (**Pull**) construída em **n8n**, **PostgreSQL 16 + `pgvector` (Supabase Ready)** e **Google Gemini** para acompanhar a transição da Reforma Tributária brasileira (`EC 132/2023` e `LC 214/2025` — `IBS`, `CBS`, `Imposto Seletivo` e `Split Payment` entre 2026 e 2033).

---

## 🏛️ Arquitetura do Sistema

Os diagramas editáveis em Draw.io estão disponíveis na raiz do projeto:
* **Arquitetura de Software:** [`fiscalia-architecture.drawio`](./fiscalia-architecture.drawio)
* **MER & Arquitetura Vetorial (`pgvector`):** [`fiscalia-mer-pgvector.drawio`](./fiscalia-mer-pgvector.drawio)
* **Especificação Técnica Completa:** [`docs/superpowers/specs/2026-11-06-fiscalia-design.md`](./docs/superpowers/specs/2026-11-06-fiscalia-design.md)

### Os 3 Workflows Modulares no n8n (`workflows/`)
1. **`01_push_dou_monitor.json` (Monitoramento Proativo Multi-Setorial — Push):**
   * Executa a cada 2h via Cron ou sob demanda via Webhook (`POST /webhook/simular-dou`).
   * Coleta atos normativos das Normas da Receita Federal / DOU (extraindo o HTML integral) ou carrega atos do dataset curado de Replay.
   * Deduplica por hash `SHA-256`, aplica pré-filtro regex tributário e classifica via `gemini-2.5-flash` (*Structured Output JSON*).
   * Gera embeddings de 768 dimensões (`text-embedding-004`), persiste em `public.ordinances` e dispara **1 único alerta executivo consolidado por assinante** no Telegram (Markdown) ou Slack (Block Kit).
2. **`02_pull_tax_agent.json` (Agente Tributário Contextualizado & Onboarding — Pull):**
   * Recebe mensagens do Telegram e Slack, faz a pré-injeção SQL do perfil e setores do usuário (`get_user_context_and_catalog()`) antes do Agente.
   * Responde comandos rápidos (`/setores`, `/resumo`, `/simular_dou`) ou aciona o **AI Agent (ReAct)** com memória persistente (`n8n_chat_histories`) e 4 Tools especializadas.
3. **`03_agent_tools_subworkflow.json` (Sub-Workflow de Ferramentas do Agente):**
   * **Tool A (`gerenciar_setor_usuario`):** Cadastra/remove setores entre os 12 macro-setores canônicos da `LC 214` e atualiza o `business_context` do usuário.
   * **Tool B (`consultar_situacao_e_cronograma_setorial`):** Consulta a matriz SQL (`tax_reform_matrix`) com alíquotas efetivas estimadas, reduções (60% / 30%), regras de crédito e cronograma 2026–2033.
   * **Tool C (`buscar_portarias_por_setor_rag`):** Busca híbrida no `pgvector` (`match_ordinances_by_sector()`) combinando filtro GIN por setor (`affected_sector_slugs && user_slugs OR escopo = 'GERAL'`) e similaridade de cosseno HNSW.
   * **Tool D (`verificar_dou_tempo_real`):** Checa ao vivo os 5 atos mais recentes do dia nas Normas da Receita Federal / DOU (timeout ≤ 8s).

---

## 🚀 Como Executar (Setup em 1 Comando)

### 1. Configurar Variáveis de Ambiente
```bash
cp .env.example .env
```
Edite o arquivo `.env` e preencha sua `GEMINI_API_KEY` (e opcionalmente `TELEGRAM_BOT_TOKEN` / `SLACK_BOT_TOKEN`).

### 2. Subir os Containers (`n8n` + `PostgreSQL 16 pgvector`)
```bash
docker compose up -d
```
O container `fiscalia-postgres` executa automaticamente na inicialização:
1. `001_init_schema.sql` — Extensões `vector` e `pgcrypto`, 7 tabelas e índices `GIN`/`HNSW`.
2. `002_rpc_functions.sql` — As 4 funções `plpgsql` de domínio e busca vetorial.
3. `001_sectors_and_matrix.sql` — Os 12 setores canônicos da `LC 214/2025` e a matriz `2026–2033`.
4. `002_demo_ordinances.sql` — 6 atos normativos curados da Reforma Tributária + assinantes de demonstração.

### 3. Importar os 3 Workflows no n8n
No Linux / macOS / Git Bash:
```bash
./scripts/import_workflows.sh
```
No Windows (PowerShell):
```powershell
.\scripts\import_workflows.ps1
```
Em seguida, acesse **`http://localhost:5678`**, configure a credencial do Postgres (`host: postgres`, `database: fiscalia`, `user: fiscalia`, `password: fiscalia_secret_2026`) e ative os workflows.

---

## 🧪 Roteiro de Demonstração & Testes Rápidos

### 1. Popular Embeddings de 768 Dimensões dos Seeds (Backfill)
```powershell
# PowerShell
.\scripts\trigger_demo_replay.ps1 -Action backfill_embeddings

# Ou via curl
curl -X POST http://localhost:5678/webhook/simular-dou \
  -H "Content-Type: application/json" \
  -d '{"action":"backfill_embeddings"}'
```

### 2. Disparar o Modo Replay do DOU/RFB (Fluxo 1 — Push)
```powershell
# PowerShell
.\scripts\trigger_demo_replay.ps1 -Action replay

# Ou especificando um ato normativo
.\scripts\trigger_demo_replay.ps1 -Action replay -ActNumber "IN RFB 2.255/2026"
```

### 3. Testar o Agente Conversacional (Fluxo 2 — Pull via Webhook)
```bash
# Exemplo 1: Comando /resumo para usuário de Saúde e Tecnologia
curl -X POST http://localhost:5678/webhook/fiscalia-telegram \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "from": {"id": 1001, "first_name": "Dra. Helena"},
      "chat": {"id": 1001},
      "text": "/resumo"
    }
  }'

# Exemplo 2: Pergunta aberta em linguagem natural acionando o AI Agent + Tools (Workflow 3)
curl -X POST http://localhost:5678/webhook/fiscalia-telegram \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "from": {"id": 1001, "first_name": "Dra. Helena"},
      "chat": {"id": 1001},
      "text": "Qual a redução de alíquota de IBS/CBS para clínicas médicas na LC 214 e o que saiu nas últimas portarias sobre cadastro obrigatório?"
    }
  }'
```

---

## ⚖️ Disclaimer Legal
O **Fiscália** é um assistente informativo de inteligência tributária baseado em IA. As análises, resumos e estimativas de alíquotas não substituem parecer jurídico ou contábil formal. Consulte sempre o texto integral publicado no Diário Oficial da União (DOU) e no portal de Normas da Receita Federal.
