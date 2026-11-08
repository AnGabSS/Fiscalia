-- ==============================================================================
-- Fiscália — Migration 001: Schema Principal, Extensões e Índices Vetoriais
-- Compatível com PostgreSQL 16 + pgvector local e Supabase Cloud
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;

-- Schema dedicado para tabelas internas do n8n (isolado das tabelas de domínio)
CREATE SCHEMA IF NOT EXISTS n8n_internal;

-- ------------------------------------------------------------------------------
-- 1. sectors: Catálogo canônico de 12 macro-setores da LC 214/2025
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sectors (
    slug TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    cnae_examples TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 2. users: Perfil multi-canal (Slack e Telegram) e contexto do negócio
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_type TEXT NOT NULL CHECK (channel_type IN ('telegram', 'slack')),
    external_user_id TEXT NOT NULL,
    chat_id TEXT NOT NULL,
    display_name TEXT,
    business_context TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_users_channel_external UNIQUE (channel_type, external_user_id)
);

CREATE INDEX IF NOT EXISTS idx_users_active_channel ON public.users (is_active, channel_type);

-- ------------------------------------------------------------------------------
-- 3. user_subscriptions: Relação N:N entre usuários e setores monitorados
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    sector_slug TEXT NOT NULL REFERENCES public.sectors(slug) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, sector_slug)
);

CREATE INDEX IF NOT EXISTS idx_user_subscriptions_sector ON public.user_subscriptions (sector_slug);

-- ------------------------------------------------------------------------------
-- 4. tax_reform_matrix: Matriz estática da Reforma Tributária (LC 214 2026-2033)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tax_reform_matrix (
    sector_slug TEXT PRIMARY KEY REFERENCES public.sectors(slug) ON DELETE CASCADE,
    regime_type TEXT NOT NULL,
    estimated_effective_rate TEXT NOT NULL,
    reduction_percent NUMERIC(5,2) NOT NULL DEFAULT 0.00,
    legal_basis TEXT NOT NULL,
    credit_rules TEXT NOT NULL,
    transition_schedule JSONB NOT NULL DEFAULT '{}'::jsonb,
    key_obligations TEXT[] NOT NULL DEFAULT '{}',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 5. ordinances: Atos normativos (DOU / RFB), classificação setorial e embeddings
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ordinances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_hash TEXT NOT NULL UNIQUE,
    act_number TEXT NOT NULL,
    title TEXT NOT NULL,
    official_url TEXT NOT NULL,
    published_at DATE NOT NULL DEFAULT CURRENT_DATE,
    raw_excerpt TEXT NOT NULL,
    escopo TEXT NOT NULL CHECK (escopo IN ('GERAL', 'ESPECIFICO_SETORIAL')),
    grau_urgencia TEXT NOT NULL CHECK (grau_urgencia IN ('ALTA', 'MEDIA', 'BAIXA')),
    tributos TEXT[] NOT NULL DEFAULT '{}',
    affected_sector_slugs TEXT[] NOT NULL DEFAULT '{}',
    setores_afetados_detalhe JSONB NOT NULL DEFAULT '[]'::jsonb,
    resumo_geral TEXT NOT NULL,
    previsao_vigencia TEXT,
    embedding vector(768),
    is_replay_seed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ordinances_affected_sectors_gin
    ON public.ordinances USING GIN (affected_sector_slugs);

CREATE INDEX IF NOT EXISTS idx_ordinances_escopo_published
    ON public.ordinances (escopo, published_at DESC);

CREATE INDEX IF NOT EXISTS idx_ordinances_embedding_hnsw
    ON public.ordinances USING hnsw (embedding vector_cosine_ops);

-- ------------------------------------------------------------------------------
-- 6. alert_deliveries: Registro de idempotência para evitar alertas duplicados
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.alert_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ordinance_id UUID NOT NULL REFERENCES public.ordinances(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    channel_type TEXT NOT NULL CHECK (channel_type IN ('telegram', 'slack')),
    delivered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_alert_ordinance_user UNIQUE (ordinance_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_alert_deliveries_ordinance ON public.alert_deliveries (ordinance_id);

-- ------------------------------------------------------------------------------
-- 7. n8n_chat_histories: Memória conversacional do AI Agent no Postgres
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.n8n_chat_histories (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_n8n_chat_histories_session
    ON public.n8n_chat_histories (session_id, id DESC);
