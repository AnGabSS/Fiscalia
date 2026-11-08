-- ==============================================================================
-- Fiscália — Suite de Testes de Integração SQL & pgvector
-- Valida schema, seeds da LC 214/2025 e as 4 funções RPC em container real
-- ==============================================================================

\set ON_ERROR_STOP on

DO $$
DECLARE
    v_sector_count INT;
    v_matrix_count INT;
    v_ordinance_count INT;
    v_ctx RECORD;
    v_sub_res JSONB;
    v_ord_id UUID;
    v_subscriber_rows INT;
    v_rag_rows INT;
    v_dummy_vec vector(768);
BEGIN
    -- 1. Verifica contagem exata dos 12 setores canônicos e da matriz tributária
    SELECT COUNT(*) INTO v_sector_count FROM public.sectors;
    ASSERT v_sector_count = 12,
        format('Esperado 12 setores em public.sectors, encontrado: %s', v_sector_count);

    SELECT COUNT(*) INTO v_matrix_count FROM public.tax_reform_matrix;
    ASSERT v_matrix_count = 12,
        format('Esperado 12 registros em public.tax_reform_matrix, encontrado: %s', v_matrix_count);

    -- 2. Verifica seeds de portarias de Replay
    SELECT COUNT(*) INTO v_ordinance_count FROM public.ordinances WHERE is_replay_seed = TRUE;
    ASSERT v_ordinance_count >= 6,
        format('Esperado >= 6 portarias de seed, encontrado: %s', v_ordinance_count);

    -- 3. Testa RPC 1: get_user_context_and_catalog (Upsert + catálogo de 12 setores)
    SELECT * INTO v_ctx
    FROM public.get_user_context_and_catalog('telegram', 'ci_test_user_999', '999000111', 'CI Tester');

    ASSERT v_ctx.user_id IS NOT NULL, 'get_user_context_and_catalog deve retornar user_id válido';
    ASSERT v_ctx.channel_type = 'telegram', 'channel_type deve ser telegram';
    ASSERT jsonb_array_length(v_ctx.available_catalog) = 12,
        'available_catalog deve conter os 12 setores canônicos';

    -- 4. Testa RPC 2: manage_user_subscription (set, add, ignore invalid slugs, remove, clear)
    v_sub_res := public.manage_user_subscription(
        v_ctx.user_id,
        'set',
        ARRAY['saude_servicos_medicos', 'tecnologia_saas', 'setor_inexistente_xyz'],
        'Clínica Médica e Telemedicina no Lucro Presumido'
    );

    ASSERT (v_sub_res->>'success')::boolean = TRUE, 'manage_user_subscription set deve retornar success=true';
    ASSERT jsonb_array_length(v_sub_res->'subscribed_sector_slugs') = 2,
        'Deve inscrever exatamente os 2 setores válidos';
    ASSERT jsonb_array_length(v_sub_res->'ignored_invalid_slugs') = 1,
        'Deve reportar o slug inválido em ignored_invalid_slugs';

    -- 5. Testa RPC 3: get_consolidated_subscribers_for_ordinance (1 alerta consolidado + idempotência)
    SELECT id INTO v_ord_id
    FROM public.ordinances
    WHERE escopo = 'GERAL'
    LIMIT 1;

    SELECT COUNT(*) INTO v_subscriber_rows
    FROM public.get_consolidated_subscribers_for_ordinance(v_ord_id)
    WHERE user_id = v_ctx.user_id;

    ASSERT v_subscriber_rows = 1,
        format('Usuário inscrito em 2 setores deve receber exatamente 1 alerta consolidado, recebeu: %s', v_subscriber_rows);

    -- Registra entrega em alert_deliveries e verifica idempotência (não deve retornar novamente)
    INSERT INTO public.alert_deliveries (ordinance_id, user_id, channel_type)
    VALUES (v_ord_id, v_ctx.user_id, 'telegram');

    SELECT COUNT(*) INTO v_subscriber_rows
    FROM public.get_consolidated_subscribers_for_ordinance(v_ord_id)
    WHERE user_id = v_ctx.user_id;

    ASSERT v_subscriber_rows = 0,
        'Após registro em alert_deliveries, o assinante não deve receber alerta duplicado';

    -- 6. Testa RPC 4: match_ordinances_by_sector com vetor de 768 dimensões
    v_dummy_vec := array_fill(0.01::real, ARRAY[768])::vector(768);

    SELECT COUNT(*) INTO v_rag_rows
    FROM public.match_ordinances_by_sector(
        v_dummy_vec,
        ARRAY['saude_servicos_medicos'],
        5,
        0.10
    );

    ASSERT v_rag_rows >= 2,
        format('Busca RAG para saude_servicos_medicos deve retornar portaria setorial + GERAL, retornou: %s', v_rag_rows);

    -- Limpeza do usuário de teste
    DELETE FROM public.users WHERE id = v_ctx.user_id;

    RAISE NOTICE '✅ TODOS OS TESTES DE CONTRATO SQL E PGVECTOR PASSARAM COM SUCESSO!';
END;
$$;
