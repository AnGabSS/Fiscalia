-- ==============================================================================
-- Fiscália — Migration 002: Funções SQL / RPC (plpgsql)
-- Contrato congelado para os Workflows 1, 2 e 3 do n8n
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. get_user_context_and_catalog
-- Realiza upsert do usuário (Telegram ou Slack) e retorna seu perfil,
-- lista de setores inscritos e o catálogo completo de 12 setores da LC 214
-- para pré-injeção direta no System Prompt do AI Agent (Fluxo 2).
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_user_context_and_catalog(
    p_channel_type TEXT,
    p_external_user_id TEXT,
    p_chat_id TEXT,
    p_display_name TEXT DEFAULT NULL
)
RETURNS TABLE (
    user_id UUID,
    channel_type TEXT,
    external_user_id TEXT,
    chat_id TEXT,
    display_name TEXT,
    business_context TEXT,
    subscribed_sector_slugs TEXT[],
    subscribed_sectors_detail JSONB,
    available_catalog JSONB
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
DECLARE
    v_user public.users%ROWTYPE;
BEGIN
    INSERT INTO public.users (channel_type, external_user_id, chat_id, display_name, is_active, updated_at)
    VALUES (
        LOWER(TRIM(p_channel_type)),
        TRIM(p_external_user_id),
        TRIM(p_chat_id),
        COALESCE(NULLIF(TRIM(p_display_name), ''), 'Usuário Fiscália'),
        TRUE,
        NOW()
    )
    ON CONFLICT ON CONSTRAINT uq_users_channel_external
    DO UPDATE SET
        chat_id = EXCLUDED.chat_id,
        display_name = COALESCE(NULLIF(EXCLUDED.display_name, 'Usuário Fiscália'), public.users.display_name),
        updated_at = NOW()
    RETURNING * INTO v_user;

    RETURN QUERY
    SELECT
        v_user.id AS user_id,
        v_user.channel_type,
        v_user.external_user_id,
        v_user.chat_id,
        v_user.display_name,
        COALESCE(v_user.business_context, 'Não informado') AS business_context,
        COALESCE(
            ARRAY(
                SELECT us.sector_slug
                FROM public.user_subscriptions us
                WHERE us.user_id = v_user.id
                ORDER BY us.sector_slug
            ),
            ARRAY[]::TEXT[]
        ) AS subscribed_sector_slugs,
        COALESCE(
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'slug', s.slug,
                        'name', s.name,
                        'description', s.description,
                        'regime_type', m.regime_type,
                        'estimated_effective_rate', m.estimated_effective_rate,
                        'reduction_percent', m.reduction_percent
                    ) ORDER BY s.slug
                )
                FROM public.user_subscriptions us
                JOIN public.sectors s ON s.slug = us.sector_slug
                LEFT JOIN public.tax_reform_matrix m ON m.sector_slug = s.slug
                WHERE us.user_id = v_user.id
            ),
            '[]'::jsonb
        ) AS subscribed_sectors_detail,
        COALESCE(
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'slug', s.slug,
                        'name', s.name,
                        'cnae_examples', s.cnae_examples
                    ) ORDER BY s.slug
                )
                FROM public.sectors s
            ),
            '[]'::jsonb
        ) AS available_catalog;
END;
$$;

-- ------------------------------------------------------------------------------
-- 2. manage_user_subscription
-- Gerencia os setores inscritos do usuário e seu business_context (Tool A e /setores).
-- p_action: 'add' | 'set' | 'remove' | 'clear' | 'update_context'
-- Ignora slugs que não pertençam ao catálogo canônico de 12 setores.
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.manage_user_subscription(
    p_user_id UUID,
    p_action TEXT,
    p_sector_slugs TEXT[] DEFAULT '{}',
    p_business_context TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_action TEXT := LOWER(TRIM(COALESCE(p_action, 'add')));
    v_valid_slugs TEXT[];
    v_invalid_slugs TEXT[];
    v_current_slugs TEXT[];
    v_current_names TEXT[];
    v_updated_context TEXT;
BEGIN
    SELECT ARRAY(
        SELECT s.slug
        FROM public.sectors s
        WHERE s.slug = ANY(COALESCE(p_sector_slugs, '{}'))
        ORDER BY s.slug
    ) INTO v_valid_slugs;

    SELECT ARRAY(
        SELECT DISTINCT x
        FROM unnest(COALESCE(p_sector_slugs, '{}')) AS x
        WHERE x IS NOT NULL
          AND TRIM(x) <> ''
          AND NOT EXISTS (SELECT 1 FROM public.sectors s WHERE s.slug = x)
    ) INTO v_invalid_slugs;

    IF p_business_context IS NOT NULL AND TRIM(p_business_context) <> '' THEN
        UPDATE public.users
        SET business_context = TRIM(p_business_context),
            updated_at = NOW()
        WHERE id = p_user_id;
    END IF;

    IF v_action = 'clear' THEN
        DELETE FROM public.user_subscriptions
        WHERE user_id = p_user_id;

    ELSIF v_action = 'set' THEN
        DELETE FROM public.user_subscriptions
        WHERE user_id = p_user_id;

        IF array_length(v_valid_slugs, 1) > 0 THEN
            INSERT INTO public.user_subscriptions (user_id, sector_slug)
            SELECT p_user_id, unnest(v_valid_slugs)
            ON CONFLICT (user_id, sector_slug) DO NOTHING;
        END IF;

    ELSIF v_action = 'remove' THEN
        IF array_length(v_valid_slugs, 1) > 0 THEN
            DELETE FROM public.user_subscriptions
            WHERE user_id = p_user_id
              AND sector_slug = ANY(v_valid_slugs);
        END IF;

    ELSIF v_action IN ('add', 'update_context') THEN
        IF array_length(v_valid_slugs, 1) > 0 THEN
            INSERT INTO public.user_subscriptions (user_id, sector_slug)
            SELECT p_user_id, unnest(v_valid_slugs)
            ON CONFLICT (user_id, sector_slug) DO NOTHING;
        END IF;
    ELSE
        RETURN jsonb_build_object(
            'success', FALSE,
            'error', format('Ação inválida: %s. Use add, set, remove, clear ou update_context.', v_action)
        );
    END IF;

    SELECT
        ARRAY(
            SELECT us.sector_slug
            FROM public.user_subscriptions us
            WHERE us.user_id = p_user_id
            ORDER BY us.sector_slug
        ),
        ARRAY(
            SELECT s.name
            FROM public.user_subscriptions us
            JOIN public.sectors s ON s.slug = us.sector_slug
            WHERE us.user_id = p_user_id
            ORDER BY s.slug
        )
    INTO v_current_slugs, v_current_names;

    SELECT u.business_context
    INTO v_updated_context
    FROM public.users u
    WHERE u.id = p_user_id;

    RETURN jsonb_build_object(
        'success', TRUE,
        'action_applied', v_action,
        'subscribed_sector_slugs', COALESCE(v_current_slugs, '{}'),
        'subscribed_sector_names', COALESCE(v_current_names, '{}'),
        'ignored_invalid_slugs', COALESCE(v_invalid_slugs, '{}'),
        'business_context', COALESCE(v_updated_context, 'Não informado')
    );
END;
$$;

-- ------------------------------------------------------------------------------
-- 3. get_consolidated_subscribers_for_ordinance
-- Retorna exatamente 1 linha consolidada por usuário afetado por uma portaria:
--   - Se a portaria for ESPECIFICO_SETORIAL: retorna usuários inscritos em pelo
--     menos 1 dos setores em affected_sector_slugs, agrupando todos os setores
--     coincidentes daquele usuário em uma única mensagem (zero spam).
--   - Se a portaria for GERAL e grau_urgencia IN ('ALTA', 'MEDIA'): retorna
--     todos os usuários ativos com pelo menos 1 assinatura ativa.
--   - Exclui usuários que já receberam alerta para esta ordinance_id (alert_deliveries).
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_consolidated_subscribers_for_ordinance(
    p_ordinance_id UUID
)
RETURNS TABLE (
    user_id UUID,
    channel_type TEXT,
    external_user_id TEXT,
    chat_id TEXT,
    display_name TEXT,
    business_context TEXT,
    matched_sector_slugs TEXT[],
    matched_sector_names TEXT[],
    matched_impacts JSONB
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
DECLARE
    v_ord public.ordinances%ROWTYPE;
BEGIN
    SELECT * INTO v_ord
    FROM public.ordinances o
    WHERE o.id = p_ordinance_id;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    RETURN QUERY
    WITH user_matches AS (
        SELECT
            u.id AS u_id,
            u.channel_type AS u_channel,
            u.external_user_id AS u_ext_id,
            u.chat_id AS u_chat_id,
            COALESCE(u.display_name, 'Assinante') AS u_name,
            COALESCE(u.business_context, '') AS u_context,
            ARRAY_AGG(us.sector_slug ORDER BY us.sector_slug) AS m_slugs,
            ARRAY_AGG(s.name ORDER BY us.sector_slug) AS m_names
        FROM public.users u
        JOIN public.user_subscriptions us ON us.user_id = u.id
        JOIN public.sectors s ON s.slug = us.sector_slug
        WHERE u.is_active = TRUE
          AND NOT EXISTS (
              SELECT 1
              FROM public.alert_deliveries ad
              WHERE ad.ordinance_id = v_ord.id
                AND ad.user_id = u.id
          )
          AND (
              (us.sector_slug = ANY(v_ord.affected_sector_slugs))
              OR (v_ord.escopo = 'GERAL' AND v_ord.grau_urgencia IN ('ALTA', 'MEDIA'))
          )
        GROUP BY u.id, u.channel_type, u.external_user_id, u.chat_id, u.display_name, u.business_context
    )
    SELECT
        um.u_id AS user_id,
        um.u_channel AS channel_type,
        um.u_ext_id AS external_user_id,
        um.u_chat_id AS chat_id,
        um.u_name AS display_name,
        um.u_context AS business_context,
        um.m_slugs AS matched_sector_slugs,
        um.m_names AS matched_sector_names,
        COALESCE(
            (
                SELECT jsonb_agg(elem)
                FROM jsonb_array_elements(v_ord.setores_afetados_detalhe) AS elem
                WHERE (elem->>'setor_slug') = ANY(um.m_slugs)
                   OR v_ord.escopo = 'GERAL'
            ),
            v_ord.setores_afetados_detalhe
        ) AS matched_impacts
    FROM user_matches um
    ORDER BY um.u_channel, um.u_id;
END;
$$;

-- ------------------------------------------------------------------------------
-- 4. match_ordinances_by_sector
-- Busca semântica via pgvector (distância de cosseno) filtrada pelos setores
-- do usuário OU atos de escopo 'GERAL'. Possui fallback automático caso os
-- embeddings de seed ainda não tenham sido preenchidos (is_replay_seed).
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.match_ordinances_by_sector(
    p_query_embedding vector(768),
    p_sector_slugs TEXT[] DEFAULT '{}',
    p_match_count INT DEFAULT 5,
    p_similarity_threshold FLOAT DEFAULT 0.35
)
RETURNS TABLE (
    ordinance_id UUID,
    act_number TEXT,
    title TEXT,
    official_url TEXT,
    published_at DATE,
    escopo TEXT,
    grau_urgencia TEXT,
    tributos TEXT[],
    affected_sector_slugs TEXT[],
    setores_afetados_detalhe JSONB,
    resumo_geral TEXT,
    previsao_vigencia TEXT,
    similarity FLOAT
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
    SELECT
        o.id AS ordinance_id,
        o.act_number,
        o.title,
        o.official_url,
        o.published_at,
        o.escopo,
        o.grau_urgencia,
        o.tributos,
        o.affected_sector_slugs,
        o.setores_afetados_detalhe,
        o.resumo_geral,
        o.previsao_vigencia,
        CASE
            WHEN o.embedding IS NOT NULL AND p_query_embedding IS NOT NULL
                THEN (1 - (o.embedding <=> p_query_embedding))::FLOAT
            ELSE 0.50::FLOAT
        END AS similarity
    FROM public.ordinances o
    WHERE (
        o.escopo = 'GERAL'
        OR COALESCE(array_length(p_sector_slugs, 1), 0) = 0
        OR o.affected_sector_slugs && p_sector_slugs
    )
    AND (
        o.embedding IS NULL
        OR p_query_embedding IS NULL
        OR (1 - (o.embedding <=> p_query_embedding)) >= p_similarity_threshold
    )
    ORDER BY
        CASE
            WHEN o.embedding IS NOT NULL AND p_query_embedding IS NOT NULL
                THEN (o.embedding <=> p_query_embedding)
            ELSE 0.50
        END ASC,
        o.published_at DESC
    LIMIT COALESCE(p_match_count, 5);
END;
$$;
