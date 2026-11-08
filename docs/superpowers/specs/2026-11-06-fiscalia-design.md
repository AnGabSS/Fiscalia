# Fiscália — Especificação Técnica & System Design

**Data:** 2026-11-06  ·  **Status:** Aprovado  ·  **Escopo:** Projeto Completo (Portfólio & Estudo de Caso Técnico Ponta a Ponta)

---

## 1. Intenção & Propósito (Why)

O período de transição da Reforma Tributária brasileira (`EC 132/2023` e `LC 214/2025` — introduzindo `IBS`, `CBS`, `Imposto Seletivo` e `Split Payment` entre 2026 e 2033) gera um volume contínuo de atos normativos (`Instruções Normativas`, `Portarias`, `Atos Conjuntos RFB/CGIBS`) no *Diário Oficial da União (DOU)* e nas *Normas da Receita Federal*. Empresas e profissionais tributários enfrentam dois problemas críticos:

1. **Excesso de ruído no monitoramento:** Os feeds oficiais publicam centenas de atos administrativos irrelevantes por dia, enquanto normas com impacto setorial direto (ex: redução de 60% para Saúde e Educação, regimes específicos para Construção Civil, Agronegócio e Serviços Financeiros, ou novos layouts XML de NFS-e para Tecnologia/SaaS) passam despercebidas.
2. **Falta de consulta contextualizada por setor:** Chatbots genéricos alucinam alíquotas ou não combinam a matriz estática da transição (`LC 214` 2026–2033) com as portarias recém-publicadas filtradas especificamente para o setor econômico do usuário.

O **Fiscália** integra dois fluxos complementares construídos em **n8n**, **PostgreSQL 16 + `pgvector` (compatível com Supabase)**, **Google Gemini** e **Slack + Telegram**:

* **Fluxo 1 — Monitoramento Proativo Multi-Setorial (Push):** Coleta atos normativos (ao vivo da Receita Federal/DOU com extração do texto HTML integral + **Modo Replay/Simulador** sob demanda), classifica os impactos por setor via Gemini (*Structured Output*), indexa embeddings vetoriais (`vector(768)`) e dispara **um único alerta executivo consolidado por assinante** no Slack ou Telegram apenas quando seus setores inscritos (ou normas de escopo `GERAL` de urgência Alta/Média) são afetados.
* **Fluxo 2 — Agente Tributário Contextualizado & Onboarding (Pull):** Assistente conversacional no Slack e Telegram com pré-carregamento do perfil setorial do usuário no prompt, memória de conversa persistente no Postgres, comandos rápidos (`/setores`, `/resumo`, `/simular_dou`) e 4 ferramentas especializadas no **Workflow 3** (`gerenciar_setor_usuario`, `consultar_situacao_e_cronograma_setorial`, `buscar_portarias_por_setor_rag` e `verificar_dou_tempo_real`).

---

## 2. Catálogo Canônico de 12 Macro-Setores Econômicos (`LC 214/2025`)

1. `tecnologia_saas` — Tecnologia, SaaS e Serviços Digitais
2. `saude_servicos_medicos` — Saúde, Hospitais, Clínicas e Planos (Redução de 60%)
3. `educacao` — Educação e Ensino Regular (Redução de 60%)
4. `agronegocio` — Agronegócio, Produtor Rural e Insumos Agro (Redução de 60% / Crédito Presumido)
5. `varejo_comercio` — Varejo, E-commerce e Comércio Atacadista (Regime Padrão + Split Payment)
6. `industria_manufatura` — Indústria de Transformação e Zona Franca (Extinção gradual do IPI + Crédito Amplo)
7. `construcao_imobiliario` — Construção Civil, Incorporação e Locação Imobiliária (CIB + Redutor de Ajuste/Social)
8. `transporte_logistica` — Transporte de Cargas, Passageiros e Logística (Crédito imediato sobre frete e insumos)
9. `servicos_financeiros` — Bancos, Fintechs, Seguros e Meios de Pagamento (Regime Específico + Split Payment)
10. `alimentacao_hotelaria` — Bares, Restaurantes, Hotelaria e Eventos (Regime Específico com alíquota reduzida)
11. `profissoes_regulamentadas` — Advocacia, Contabilidade, Engenharia e Consultoria (Redução de 30%)
12. `energia_combustiveis_telecom` — Energia, Combustíveis (Monofásico), Mineração e Telecom

---

## 3. Diagramas de Arquitetura e Dados (Draw.io)

* [fiscalia-architecture.drawio](../../../fiscalia-architecture.drawio) — Visão geral da arquitetura em 3 camadas (Fontes/Canais, Orquestrador n8n com 3 Workflows e IA/Banco de Dados).
* [fiscalia-mer-pgvector.drawio](../../../fiscalia-mer-pgvector.drawio) — Modelo Entidade-Relacionamento (MER) das 7 tabelas + Arquitetura de Dados e Busca Híbrida (`GIN` + `HNSW`) no `pgvector`.
