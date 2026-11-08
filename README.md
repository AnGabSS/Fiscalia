# 🏛️ Fiscália

> **Monitoramento da Reforma Tributária sem ruído e direto no chat.**  
> *n8n · PostgreSQL + pgvector (Supabase) · Google Gemini · Telegram & Slack*

---

## 💡 O Problema

A transição da Reforma Tributária (`LC 214/2025` — `IBS`, `CBS`, `Imposto Seletivo` e `Split Payment` até 2033) gera dezenas de portarias e instruções normativas toda semana no Diário Oficial da União (DOU) e na Receita Federal.

Na prática, quem tem empresa sofre com duas coisas:
1. **Muito ruído:** Centenas de atos administrativos que não mudam nada na sua operação.
2. **Respostas genéricas:** Quando você pergunta para uma IA comum *"como fica meu imposto?"*, ela chuta alíquotas e não cruza a regra do seu setor com as portarias que saíram ontem.

---

## 🚀 A Ideia do Fiscália

A proposta aqui é simples: você diz para o bot **qual é o seu setor de atuação** (ex: *SaaS/Tecnologia, Saúde, Agro, Varejo, Construção Civil*) e o **Fiscália** trabalha de dois jeitos:

1. **No automático (Push):** A cada 2h ele lê as normas da Receita/DOU, usa o **Google Gemini** para descobrir quais setores foram afetados e manda **um único resumo direto no seu Telegram ou Slack** — só se o seu setor for impactado. Sem spam.
2. **No bate-papo (Pull):** Você manda uma pergunta no chat (ou usa `/setores` e `/resumo`) e um **Agente de IA** responde combinando a tabela oficial da transição (`2026–2033`) com busca semântica (`pgvector`) nas portarias reais.

---

## 🧠 Como a Arquitetura se Conecta

Tudo roda orquestrado em **3 workflows no n8n** conversando com **Postgres + `pgvector`**:

* **`01_push_dou_monitor`** — Lê o DOU/Receita (ou roda em *Modo Replay* para testes), classifica o impacto por setor com o Gemini, gera os embeddings (`768d`) e dispara os alertas.
* **`02_pull_tax_agent`** — Recebe sua mensagem do Telegram/Slack, carrega seu perfil tributário no banco e aciona o Agente de IA.
* **`03_agent_tools_subworkflow`** — As 4 ferramentas do Agente:
  * **Setores:** Cadastra ou troca os setores que você monitora.
  * **Matriz Tributária:** Consulta alíquotas, reduções (60%, 30%) e o cronograma `2026–2033`.
  * **Busca RAG (`pgvector`):** Busca híbrida nas portarias filtrando pelo seu setor.
  * **DOU Live:** Checa na hora o que saiu hoje na Receita Federal.

> 📐 Quer ver o desenho completo? Os diagramas editáveis estão na raiz do projeto:  
> • [Arquitetura do Sistema (`fiscalia-architecture.drawio`)](./fiscalia-architecture.drawio)  
> • [MER & Dados Vetoriais (`fiscalia-mer-pgvector.drawio`)](./fiscalia-mer-pgvector.drawio)

---

## 🛠️ Mão na Massa (Rodando em 3 Passos)

### 1. Configure o `.env`
```powershell
Copy-Item .env.example .env
```
Coloque sua `GEMINI_API_KEY`, seu `TELEGRAM_BOT_TOKEN` (e sua `DATABASE_URL` se quiser usar o Supabase Cloud em vez do banco local).

### 2. Suba a stack e importe os fluxos
```powershell
docker compose up -d
.\scripts\import_workflows.ps1
```
*(No Linux/macOS, use `./scripts/import_workflows.sh`).*

### 3. Converse com o bot no Telegram
Para testar localmente sem precisar configurar `ngrok`, rode a ponte local:
```powershell
.\scripts\telegram_bridge.ps1
```
Depois é só abrir seu bot no Telegram e mandar:
* `/setores` — lista os 12 setores da `LC 214/2025`
* `/setores set saude_servicos_medicos tecnologia_saas` — assina seus setores
* `/resumo` — traz o raio-x completo do seu segmento
* `/simular_dou` — simula uma portaria nova caindo no DOU em tempo real

---

## 🧪 Rodando os Testes

```bash
node --test tests/validate_workflows_and_contracts.mjs
```
Todo `push` também passa automaticamente pelo pipeline do **GitHub Actions** ([`.github/workflows/ci.yml`](./.github/workflows/ci.yml)), que valida os contratos JS/JSON, sobe um `pgvector:pg16` real para testar as funções SQL e faz o smoke test de importação no `n8n`.

---

*⚖️ **Nota:** O Fiscália é um projeto de engenharia de IA e inteligência normativa. Ele facilita a leitura da Reforma Tributária, mas não substitui o seu contador ou advogado tributarista.*
