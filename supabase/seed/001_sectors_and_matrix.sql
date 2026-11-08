-- ==============================================================================
-- Fiscália — Seed 001: Catálogo de 12 Macro-Setores e Matriz da Reforma Tributária
-- Base Legal: Emenda Constitucional nº 132/2023 e Lei Complementar nº 214/2025
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Catálogo Canônico de 12 Macro-Setores (public.sectors)
-- ------------------------------------------------------------------------------
INSERT INTO public.sectors (slug, name, description, cnae_examples)
VALUES
    (
        'tecnologia_saas',
        'Tecnologia, SaaS e Serviços Digitais',
        'Desenvolvimento e licenciamento de software, SaaS, computação em nuvem (IaaS/PaaS), cibersegurança, inteligência artificial, processamento de dados e plataformas digitais.',
        ARRAY['6201-5/01', '6202-3/00', '6203-1/00', '6204-0/00', '6311-9/00', '6319-4/00']
    ),
    (
        'saude_servicos_medicos',
        'Saúde, Hospitais, Clínicas e Planos',
        'Atividades de atendimento hospitalar, clínicas médicas e odontológicas, laboratórios de análises clínicas e imagem, home care, dispositivos médicos e planos de assistência à saúde.',
        ARRAY['8610-1/01', '8630-5/01', '8630-5/03', '8640-2/02', '6550-2/00', '3250-7/01']
    ),
    (
        'educacao',
        'Educação e Ensino Regular',
        'Educação infantil, ensino fundamental, médio, técnico profissionalizante e ensino superior reconhecidos pelo MEC, incluindo atividades educacionais abrangidas pelo Prouni.',
        ARRAY['8511-2/00', '8512-1/00', '8513-9/00', '8520-1/00', '8531-7/00', '8532-5/00']
    ),
    (
        'agronegocio',
        'Agronegócio, Produtor Rural e Insumos Agro',
        'Produção agrícola, pecuária, aquicultura, silvicultura, cooperativas agropecuárias e comercialização de insumos agropecuários (fertilizantes, defensivos, sementes e rações).',
        ARRAY['0111-3/01', '0115-6/00', '0151-2/01', '0161-0/01', '2013-4/02', '4623-1/08']
    ),
    (
        'varejo_comercio',
        'Varejo, E-commerce e Comércio Atacadista',
        'Comércio varejista físico, marketplaces, e-commerce, supermercados, farmácias de varejo, lojas de departamento e distribuição atacadista de bens de consumo.',
        ARRAY['4711-3/01', '4711-3/02', '4751-2/01', '4771-7/01', '4781-4/00', '4691-5/00']
    ),
    (
        'industria_manufatura',
        'Indústria de Transformação e Zona Franca',
        'Indústria de transformação de bens de capital e consumo, metalurgia, química, automotiva, têxtil, alimentos industrializados e operações incentivadas na Zona Franca de Manaus (ZFM).',
        ARRAY['1011-2/01', '2029-1/00', '2441-5/01', '2710-4/01', '2829-1/99', '2910-7/01']
    ),
    (
        'construcao_imobiliario',
        'Construção Civil, Incorporação e Locação Imobiliária',
        'Incorporação de empreendimentos imobiliários, construção de edifícios e obras de infraestrutura, loteamento, compra e venda de imóveis, locação e administração imobiliária.',
        ARRAY['4110-7/00', '4120-4/00', '4211-1/01', '6810-2/01', '6810-2/02', '6822-6/00']
    ),
    (
        'transporte_logistica',
        'Transporte de Cargas, Passageiros e Logística',
        'Transporte rodoviário, ferroviário, aquaviário e aéreo de cargas, operadores logísticos, armazéns gerais, transporte coletivo urbano/metropolitano e aviação regional.',
        ARRAY['4930-2/01', '4930-2/02', '4921-3/01', '5011-4/01', '5111-1/00', '5211-7/01']
    ),
    (
        'servicos_financeiros',
        'Bancos, Fintechs, Seguros e Meios de Pagamento',
        'Instituições bancárias, cooperativas de crédito, fintechs (SCD/SEP), instituições de pagamento, adquirentes de cartões, seguradoras, resseguradoras, previdência complementar e bolsas.',
        ARRAY['6421-2/00', '6422-1/00', '6431-0/00', '6511-1/01', '6520-1/00', '6619-3/02']
    ),
    (
        'alimentacao_hotelaria',
        'Bares, Restaurantes, Hotelaria e Eventos',
        'Restaurantes, bares, lanchonetes, fornecimento de refeições preparadas, meios de hospedagem (hotéis, resorts e pousadas), parques temáticos, agências de turismo e produção de eventos.',
        ARRAY['5510-8/01', '5611-2/01', '5611-2/04', '5620-1/01', '7911-2/00', '8230-0/01']
    ),
    (
        'profissoes_regulamentadas',
        'Advocacia, Contabilidade, Engenharia e Consultoria',
        'Prestação de serviços intelectuais de natureza científica, literária ou artística submetidos à fiscalização de conselho profissional (OAB, CRC, CREA, CAU, CORECON, CRA, etc.).',
        ARRAY['6911-7/01', '6920-6/01', '7111-1/00', '7112-0/00', '7020-4/00', '7490-1/99']
    ),
    (
        'energia_combustiveis_telecom',
        'Energia, Combustíveis (Monofásico), Mineração e Telecom',
        'Geração, transmissão e distribuição de energia elétrica, refino e distribuição de combustíveis e biocombustíveis, extração mineral para exportação/indústria e telecomunicações.',
        ARRAY['3511-5/01', '3514-0/00', '1921-7/00', '4681-8/01', '0710-3/01', '6110-8/01']
    )
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    cnae_examples = EXCLUDED.cnae_examples;

-- ------------------------------------------------------------------------------
-- 2. Matriz da Reforma Tributária por Setor (public.tax_reform_matrix)
-- ------------------------------------------------------------------------------
INSERT INTO public.tax_reform_matrix (
    sector_slug,
    regime_type,
    estimated_effective_rate,
    reduction_percent,
    legal_basis,
    credit_rules,
    transition_schedule,
    key_obligations
)
VALUES
    -- 1. tecnologia_saas
    (
        'tecnologia_saas',
        'Regime Padrão (Alíquota Cheia com Não Cumulatividade Plena)',
        '26,5% a 28,0% (Alíquota de referência IBS + CBS)',
        0.00,
        'EC 132/2023, art. 156-A e art. 195, V; LC 214/2025, arts. 4º a 12 (incidência ampla sobre bens imateriais, direitos, licenciamento de software e SaaS) e arts. 47 a 56 (crédito amplo).',
        'Não cumulatividade plena (crédito financeiro amplo): permite apropriação integral de créditos de IBS/CBS sobre servidores em nuvem (IaaS/PaaS), licenças de software de terceiros, energia elétrica, equipamentos de TI, aluguel comercial e serviços B2B contratados. Clientes pessoas jurídicas no regime regular tomam crédito integral do IBS/CBS destacado na NFS-e Nacional, neutralizando parte do aumento nominal em operações B2B. Folha de pagamento continua sem gerar crédito.',
        '{
            "2026": "Ano-teste: destaque de 0,9% de CBS e 0,1% de IBS na NFS-e Nacional (compensável com PIS/COFINS ou dispensado mediante cumprimento de obrigações acessórias).",
            "2027": "Entrada em vigor plena da CBS (~8,8%) e extinção definitiva do PIS e da COFINS (fim da dicotomia cumulativo 3,65% vs. não cumulativo 9,25%). IBS permanece em 0,1%.",
            "2028": "Manutenção da CBS plena e preparação dos sistemas municipais/estaduais para transição do ISS/ICMS.",
            "2029": "Início da redução gradual do ISS/ICMS (90% da alíquota original) e elevação do IBS para 10% da alíquota definitiva.",
            "2030": "ISS/ICMS reduzidos a 80% e IBS elevado a 20% da alíquota definitiva.",
            "2031": "ISS/ICMS reduzidos a 70% e IBS elevado a 30% da alíquota definitiva.",
            "2032": "ISS/ICMS reduzidos a 60% e IBS elevado a 40% da alíquota definitiva.",
            "2033": "Vigência integral do IVA Dual (IBS + CBS) com extinção total do ISS e do ICMS e fim da guerra fiscal municipal de ISS (2% a 5%)."
        }'::jsonb,
        ARRAY[
            'Emissão obrigatória da NFS-e de Padrão Nacional com leiaute XML atualizado contendo grupos de IBS e CBS.',
            'Determinação do local da operação pelo domicílio principal do adquirente/destinatário (princípio do destino), exigindo cadastro rigoroso de CEP/município do tomador.',
            'Adaptação a retenções automáticas via Split Payment nas liquidações financeiras e cobranças recorrentes de assinaturas SaaS.',
            'Revisão de contratos B2B de longo prazo para cláusulas de gross-up tributário a partir de 2027 (extinção do regime cumulativo de PIS/COFINS de 3,65%).'
        ]
    ),

    -- 2. saude_servicos_medicos
    (
        'saude_servicos_medicos',
        'Regime Diferenciado (Redução de 60% na Alíquota) e Regime Específico para Planos de Saúde',
        '10,6% a 11,2% para serviços médicos/hospitalares (red. 60%); dispositivos/medicamentos listados com redução de 60% ou alíquota zero',
        60.00,
        'EC 132/2023, art. 9º, § 1º, II e III; LC 214/2025, arts. 130 a 135 e Anexos III, IV, XII e XIII (serviços de saúde humana, dispositivos médicos e medicamentos); arts. 234 a 242 (regime específico de planos de assistência à saúde).',
        'Para hospitais, clínicas e laboratórios: manutenção do direito ao crédito integral sobre insumos, medicamentos, reagentes, equipamentos médicos, energia e serviços terceirizados, mesmo aplicando a redução de 60% na saída. Medicamentos essenciais de programas governamentais, oncológicos e doenças raras contam com alíquota zero (redução de 100%). Para operadoras de planos de saúde: base de cálculo específica correspondente aos prêmios/mensalidades recebidos deduzidos das indenizações, sinistros e despesas médicas pagas na rede credenciada, com alíquota reduzida em 60% e vedação de crédito para contratantes pessoas físicas.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS) e cadastramento prévio de serviços médicos e NCMs de medicamentos/dispositivos nos Anexos da LC 214/2025.",
            "2027": "Vigência da CBS com redução de 60% (~3,52%) para serviços de saúde e extinção de PIS/COFINS; entrada em vigor do regime específico de planos de saúde para CBS.",
            "2028": "Operação plena da CBS reduzida e consolidação da malha de glosas e deduções de sinistros de planos de saúde.",
            "2029": "Transição do ISS hospitalar/clínico e ICMS de medicamentos (10% IBS com redutor de 60% / 90% ISS e ICMS).",
            "2030": "Escalonamento para 20% do IBS (com redutor de 60%) e 80% do ISS/ICMS.",
            "2031": "Escalonamento para 30% do IBS e 70% do ISS/ICMS.",
            "2032": "Escalonamento para 40% do IBS e 60% do ISS/ICMS.",
            "2033": "Extinção definitiva do ISS (inclusive sociedades uniprofissionais médicas) e do ICMS sobre medicamentos, vigorando integralmente o IVA Dual reduzido."
        }'::jsonb,
        ARRAY[
            'Classificação rigorosa dos procedimentos médicos/laboratoriais (NBS) e de medicamentos/dispositivos médicos (NCM/Anvisa) conforme Anexos da LC 214/2025.',
            'Habilitação eletrônica perante RFB e CGIBS comprovando regularidade sanitária e enquadramento nos serviços de saúde humana.',
            'Segregação contábil e fiscal entre procedimentos médicos essenciais (redução de 60%) e procedimentos puramente estéticos não reparadores (alíquota padrão).',
            'Para planos de saúde: declaração mensal padronizada de prêmios arrecadados versus sinistros médicos efetivamente liquidados.'
        ]
    ),

    -- 3. educacao
    (
        'educacao',
        'Regime Diferenciado (Redução de 60% na Alíquota) e Redução de 100% para Prouni',
        '10,6% a 11,2% (Ensino Regular com redução de 60%); 0,0% sobre receitas vinculadas ao Prouni (CBS)',
        60.00,
        'EC 132/2023, art. 9º, § 1º, I; LC 214/2025, art. 129 e Anexo II (serviços de educação de ensino infantil, fundamental, médio, técnico e superior); art. 149 (alíquota zero de CBS para Prouni).',
        'Direito a crédito financeiro de IBS e CBS sobre aquisição de bens e serviços operacionais (material didático, plataformas LMS/tecnologia educacional, mobiliário, energia elétrica, limpeza, segurança e locação de imóveis). Como a folha de pagamento docente representa o maior custo do setor e não gera crédito de IVA, a redução de 60% na alíquota de saída atua como mecanismo de equilíbrio. Cursos livres não regulamentados pelo MEC permanecem no regime padrão.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS) com validação do código NBS educacional e credenciamento MEC/Secretarias de Educação.",
            "2027": "Substituição do PIS/COFINS pela CBS reduzida em 60% (~3,52%); manutenção da desoneração integral (alíquota zero de CBS) para receitas de bolsas do Prouni.",
            "2028": "Consolidação da apuração assistida da CBS nas mensalidades escolares e universitárias.",
            "2029": "Início da transição do ISS municipal sobre mensalidades (90% ISS / 10% IBS reduzido em 60%).",
            "2030": "Escalonamento para 80% ISS / 20% IBS reduzido.",
            "2031": "Escalonamento para 70% ISS / 30% IBS reduzido.",
            "2032": "Escalonamento para 60% ISS / 40% IBS reduzido.",
            "2033": "Extinção total do ISS e vigência plena do IBS + CBS com redução de 60% para ensino regular."
        }'::jsonb,
        ARRAY[
            'Vinculação obrigatória do ato autorizativo/credenciamento oficial (MEC, Conselhos Estaduais ou Municipais de Educação) no cadastro fiscal.',
            'Segregação no faturamento (NFS-e Nacional) entre ensino regular listado no Anexo II (redução de 60%) e atividades acessórias ou cursos livres (alíquota cheia).',
            'Controle individualizado das bolsas integrais e parciais do Prouni para comprovação da redução de 100% da CBS.',
            'Adequação dos sistemas de cobrança de mensalidades escolares ao Split Payment simplificado para consumidores pessoas físicas (B2C).'
        ]
    ),

    -- 4. agronegocio
    (
        'agronegocio',
        'Regime Diferenciado (Redução de 60%), Cesta Básica Zero e Produtor Rural Não Contribuinte',
        '10,6% a 11,2% para produtos/insumos agro (red. 60%); 0,0% para Cesta Básica Nacional; Diferimento em insumos',
        60.00,
        'EC 132/2023, art. 9º, § 1º, IX e § 4º; LC 214/2025, arts. 127, 138 e Anexos I, VII e IX (Cesta Básica Nacional, produtos agropecuários e insumos); arts. 164 a 171 (Produtor Rural não contribuinte e crédito presumido).',
        'Diferimento de 100% do IBS e da CBS nas operações internas e interestaduais com insumos agropecuários e aquícolas (fertilizantes, defensivos, sementes, mudas, rações, vacinas) quando destinados a produtores rurais contribuintes ou cooperativas. Produtor rural pessoa física ou jurídica com receita anual inferior a R$ 3,6 milhões pode optar por ser não contribuinte de IBS/CBS, gerando crédito presumido ao adquirente contribuinte (cooperativa, cerealista, frigorífico ou agroindústria). Exportações agropecuárias mantêm imunidade plena com ressarcimento ágil de saldos credores em até 30/60 dias.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS) para produtores PJ e agroindústrias; definição dos percentuais anuais de crédito presumido do produtor não contribuinte.",
            "2027": "Vigência da CBS (com alíquota zero na Cesta Básica, redução de 60% nos demais produtos agro e diferimento em insumos); extinção de PIS/COFINS e dos créditos presumidos antigos da Lei 10.925/2004.",
            "2028": "Estabilização do ressarcimento de créditos de CBS para agroindústrias exportadoras.",
            "2029": "Início da transição do ICMS e benefícios fiscais estaduais (Convênio ICMS 100/97) à razão de 10% ao ano para o IBS.",
            "2030": "80% ICMS / 20% IBS com aplicação do Fundo de Compensação de Benefícios Fiscais para agroindústrias habilitadas.",
            "2031": "70% ICMS / 30% IBS.",
            "2032": "60% ICMS / 40% IBS.",
            "2033": "Extinção definitiva do ICMS e do Funrural sobre comercialização, na parte coberta pelo IVA, consolidando o regime agro da LC 214/2025."
        }'::jsonb,
        ARRAY[
            'Opção anual formal de enquadramento ou desenquadramento como contribuinte regular de IBS/CBS para produtores rurais com faturamento até R$ 3,6 milhões.',
            'Emissão de NF-e (ou Nota Fiscal Eletrônica do Produtor Rural - NFP-e) com destaque específico de diferimento de insumos ou geração de crédito presumido na venda à agroindústria.',
            'Habilitação de cooperativas agropecuárias para aproveitamento de alíquota zero nas operações entre associado e cooperativa.',
            'Rastreabilidade de NCMs enquadrados no Anexo I (Cesta Básica Nacional com alíquota zero) versus Anexo VII (redução de 60%).'
        ]
    ),

    -- 5. varejo_comercio
    (
        'varejo_comercio',
        'Regime Padrão (Não Cumulatividade Plena, Fim da ICMS-ST e Split Payment no PDV/E-commerce)',
        '26,5% a 28,0% no regime geral; 0,0% em itens da Cesta Básica; 10,6% a 11,2% em higiene/alimentos reduzidos',
        0.00,
        'EC 132/2023, art. 156-A, § 1º, VII e VIII; LC 214/2025, arts. 27 a 35 (Split Payment e responsabilidade de plataformas digitais/marketplaces) e arts. 47 a 56 (crédito amplo de despesas comerciais e logísticas).',
        'Crédito financeiro amplo sobre todas as mercadorias adquiridas para revenda, fretes sobre compras e vendas, embalagens, taxas de intermediação/comissões de marketplaces, tarifas de adquirentes sujeitas ao IVA, energia elétrica das lojas e centros de distribuição, aluguéis comerciais e marketing/publicidade. Extinção progressiva da Substituição Tributária do ICMS (ICMS-ST), eliminando o capital de giro represado no estoque, mas contrabalançada pela retenção instantânea do tributo no momento da liquidação financeira via Split Payment.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS) nas NF-e e NFC-e, com atualização dos sistemas de frente de caixa (PDV) e gateways de e-commerce.",
            "2027": "Vigência plena da CBS (~8,8%) em substituição ao PIS/COFINS; início da operação do Split Payment para transações B2B e meios eletrônicos.",
            "2028": "Expansão do Split Payment simplificado para o varejo B2C e operacionalização do Cashback obrigatório na CBS para famílias de baixa renda (CadÚnico).",
            "2029": "Início da redução gradual do ICMS e da ICMS-ST (90% ICMS / 10% IBS) e levantamento de estoques para estorno/aproveitamento de créditos de transição.",
            "2030": "80% ICMS / 20% IBS; tributação no destino plena na parcela do IBS para e-commerce interestadual (substituindo gradualmente o DIFAL).",
            "2031": "70% ICMS / 30% IBS.",
            "2032": "60% ICMS / 40% IBS.",
            "2033": "Extinção total do ICMS, da ICMS-ST e do DIFAL; vigência integral do IBS + CBS no destino com Split Payment e Cashback automatizados."
        }'::jsonb,
        ARRAY[
            'Adequação das emissões de NF-e (modelo 55) e NFC-e (modelo 65) às novas tabelas de CST e códigos de classificação tributária (cClassTrib) do IBS/CBS.',
            'Integração de ERPs e meios de pagamento (PIX, cartões de crédito/débito) para conciliação automática dos valores retidos via Split Payment com os créditos de entrada.',
            'Cumprimento das regras de responsabilidade solidária ou substitutiva em vendas realizadas por meio de plataformas digitais e marketplaces (art. 22 da LC 214/2025).',
            'Inventário e controle de estoques na virada de transição (2027 para PIS/COFINS e 2029-2033 para ICMS/ICMS-ST) para recuperação de créditos acumulados.'
        ]
    ),

    -- 6. industria_manufatura
    (
        'industria_manufatura',
        'Regime Padrão com Crédito Financeiro Imediato de Ativo Imobilizado, Imposto Seletivo (IS) e Regime ZFM',
        '26,5% a 28,0% (Regime Padrão); Redução de IPI a zero em 2027 (exceto concorrentes da ZFM); IS sobre itens nocivos',
        0.00,
        'EC 132/2023, art. 92-B e art. 126 do ADCT; LC 214/2025, arts. 47 a 56 (crédito integral e imediato sobre bens de capital/ativo imobilizado), arts. 384 a 408 (Fundo de Compensação de Benefícios Fiscais) e arts. 439 a 469 (Zona Franca de Manaus e Áreas de Livre Comércio).',
        'Fim da restrição do "crédito físico" (que limitava o crédito apenas ao que integrava fisicamente o produto final): a indústria passa a tomar crédito financeiro integral e imediato sobre aquisições de máquinas, equipamentos, ativo imobilizado (fim do parcelamento em 48 vezes do CIAP), peças de reposição, EPIs, energia elétrica integral, fretes e serviços administrativos. Na Zona Franca de Manaus (ZFM), manutenção do diferencial competitivo até 2073 por meio de créditos presumidos de IBS/CBS, alíquota zero na entrada de insumos industrializados e manutenção seletiva do IPI para bens com Processo Produtivo Básico (PPB) na ZFM.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS); prazo para habilitação de benefícios onerosos de ICMS no Fundo de Compensação de Benefícios Fiscais junto à RFB.",
            "2027": "Vigência da CBS (~8,8%) e extinção do PIS/COFINS; redução a zero das alíquotas do IPI (exceto produtos industrializados na ZFM); entrada em vigor do Imposto Seletivo (IS).",
            "2028": "Operação plena do ressarcimento de créditos sobre investimentos em bens de capital (CAPEX) em até 60 dias.",
            "2029": "Início da redução de 10% ao ano do ICMS e de seus incentivos fiscais estaduais, com início dos repasses mensais do Fundo de Compensação de Benefícios Fiscais (2029 a 2032).",
            "2030": "80% ICMS / 20% IBS; compensação financeira de benefícios onerosos pelo Fundo.",
            "2031": "70% ICMS / 30% IBS.",
            "2032": "60% ICMS / 40% IBS; último ano do Fundo de Compensação de Benefícios Fiscais do ICMS.",
            "2033": "Extinção definitiva do ICMS e vigência integral do IBS + CBS no destino, encerrando a guerra fiscal industrial entre estados."
        }'::jsonb,
        ARRAY[
            'Protocolo tempestivo (entre jan/2026 e dez/2028) de habilitação no Fundo de Compensação de Benefícios Fiscais de ICMS concedidos por prazo certo e sob condição onerosa até 31/05/2023.',
            'Adequação da engenharia fiscal para produtos sujeitos ao Imposto Seletivo (veículos poluentes, bebidas açucaradas, alcoólicas, tabaco e bens minerais).',
            'Para indústrias na ZFM: comprovação de Processo Produtivo Básico (PPB) e controle de créditos presumidos de IBS/CBS nas vendas para o restante do território nacional.',
            'Apuração e homologação dos saldos credores acumulados de ICMS (inclusive exportação) para compensação em até 240 parcelas mensais corrigidas pelo IPCA a partir de 2033.'
        ]
    ),

    -- 7. construcao_imobiliario
    (
        'construcao_imobiliario',
        'Regime Específico de Bens Imóveis (Redução de 50% em Incorporação/Construção, 70% em Locação, Redutor de Ajuste e Social)',
        '13,25% a 14,0% nominal em alienação/construção (red. 50%) com Redutor de Ajuste sobre terreno; 7,95% a 8,4% em locação (red. 70%)',
        50.00,
        'EC 132/2023, art. 156-A, § 6º, X; LC 214/2025, arts. 251 a 287 (Regime Específico de Bens Imóveis: incorporação, loteamento, construção civil, alienação, locação, Cadastro Imobiliário Brasileiro - CIB, Redutor de Ajuste e Redutor Social).',
        'As alíquotas de IBS e CBS são reduzidas em 50% para operações de incorporação imobiliária, parcelamento do solo, alienação de imóvel construído e serviços de construção civil, e reduzidas em 70% para locação, cessão onerosa e arrendamento de bens imóveis. Além da redução de alíquota, aplica-se o "Redutor de Ajuste" (dedução direta da base de cálculo correspondente ao custo de aquisição atualizado do terreno, ITBI e laudêmio), tributando apenas o valor agregado da obra/incorporação. Aplica-se também o "Redutor Social" (dedução fixa da base de cálculo de R$ 100.000 por imóvel residencial novo alienado, R$ 30.000 por lote residencial e R$ 600 por mês no aluguel residencial). Mantém direito a crédito de IBS/CBS sobre materiais de construção (cimento, aço, acabamento) e serviços subcontratados.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS); implantação obrigatória do Cadastro Imobiliário Brasileiro (CIB) no SINTER para todos os imóveis urbanos e rurais.",
            "2027": "Vigência da CBS no regime imobiliário e opção pelo regime especial de transição (4% de CBS sobre receita recebida para incorporações com patrimônio de afetação registrado até 31/12/2028).",
            "2028": "Constituição e atualização do Redutor de Ajuste para terrenos em estoque existentes em 31/12/2026.",
            "2029": "Início da transição do ISS da construção civil e do ICMS sobre materiais (90% ISS/ICMS / 10% IBS imobiliário).",
            "2030": "80% ISS/ICMS / 20% IBS imobiliário.",
            "2031": "70% ISS/ICMS / 30% IBS imobiliário.",
            "2032": "60% ISS/ICMS / 40% IBS imobiliário.",
            "2033": "Extinção do ISS sobre construção civil e consolidação plena do Regime Específico de Bens Imóveis (IBS + CBS)."
        }'::jsonb,
        ARRAY[
            'Vinculação obrigatória do código único do Cadastro Imobiliário Brasileiro (CIB) em todas as escrituras, contratos de compra e venda, locações e notas fiscais de obra.',
            'Escrituração e controle individualizado por empreendimento/SPE do saldo do Redutor de Ajuste (custo do terreno atualizado pelo IPCA + contrapartidas urbanísticas + ITBI).',
            'Análise de viabilidade e opção formal pelo regime de transição do Patrimônio de Afetação (RET) para empreendimentos lançados até o término do período de transição.',
            'Monitoramento dos limites de enquadramento de pessoa física como contribuinte de IBS/CBS (ex.: locação com receita > R$ 240 mil/ano em mais de 3 imóveis ou venda de mais de 3 imóveis/ano).'
        ]
    ),

    -- 8. transporte_logistica
    (
        'transporte_logistica',
        'Regime Padrão no Transporte de Cargas (com Crédito Pleno de Combustível/Frota) e Regimes Diferenciados em Passageiros',
        '26,5% a 28,0% no transporte de cargas (100% creditável pelo embarcador B2B); 0,0% no transporte público coletivo urbano; red. 60% em aviação regional e coletivo intermunicipal',
        0.00,
        'EC 132/2023, art. 9º, § 1º, V e XII; LC 214/2025, arts. 11 (local da operação no destino da entrega da carga), arts. 47 a 56 (crédito de combustível monofásico e frota), art. 137 (redução de 60% no transporte coletivo rodoviário/ferroviário/aquaviário) e art. 157 (isenção/alíquota zero no transporte público coletivo urbano/metropolitano).',
        'No transporte de cargas: alíquota padrão, porém com dois vetores altamente favoráveis: (1) apropriação integral e imediata de créditos de IBS/CBS sobre aquisição de caminhões/implementos rodoviários (CAPEX), pneus, peças de manutenção, seguros patrimoniais, pedágios e sobre o IBS/CBS cobrado pelo regime monofásico no óleo diesel e biodiesel; (2) o embarcador/contratante B2B toma 100% de crédito do frete contratado. Na contratação de Transportador Autônomo de Cargas (TAC) pessoa física não contribuinte, a transportadora ou embarcador faz jus a crédito presumido de IBS/CBS.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS) nos conhecimentos de transporte eletrônicos (CT-e e CT-e OS) e manifesto de documentos fiscais (MDF-e).",
            "2027": "Vigência plena da CBS (~8,8%) sobre fretes com direito imediato ao crédito monofásico da CBS incidente sobre o óleo diesel e compras de frota.",
            "2028": "Operacionalização plena do crédito presumido na subcontratação de caminhoneiros autônomos (TAC).",
            "2029": "Início da transição do ICMS de transporte interestadual/intermunicipal e do ISS intramunicipal (90% ICMS/ISS / 10% IBS no município de destino da entrega).",
            "2030": "80% ICMS/ISS / 20% IBS.",
            "2031": "70% ICMS/ISS / 30% IBS.",
            "2032": "60% ICMS/ISS / 40% IBS.",
            "2033": "Extinção do ICMS e do ISS sobre transportes, eliminando a distinção fiscal entre transporte intramunicipal (ISS) e intermunicipal/interestadual (ICMS)."
        }'::jsonb,
        ARRAY[
            'Atualização do emissor de CT-e (modelo 57) e CT-e OS (modelo 67) para apuração do IBS no local de destino final da entrega da carga.',
            'Captura automatizada das NF-e de abastecimento de frota para apropriação do crédito do IBS/CBS monofásico retido na refinaria sobre o óleo diesel.',
            'Emissão de documento fiscal de entrada/pagamento para formalizar o crédito presumido nas contratações de Transportadores Autônomos de Cargas (TAC).',
            'Segregação contábil para operadoras de transporte coletivo urbano/metropolitano (alíquota zero) versus fretamento privado e turismo.'
        ]
    ),

    -- 9. servicos_financeiros
    (
        'servicos_financeiros',
        'Regime Específico de Serviços Financeiros (Base por Margem/Spread, Alíquota Uniforme Nacional e Split Payment)',
        'Alíquota específica fixada para manter a carga tributária histórica do setor (incidente sobre spread bancário e tarifas)',
        0.00,
        'EC 132/2023, art. 156-A, § 6º, II; LC 214/2025, arts. 181 a 233 (Regime Específico de Serviços Financeiros: operações de crédito, câmbio, títulos, valores mobiliários, arrendamento mercantil, seguros, previdência e arranjos de pagamento) e arts. 27 a 35 (obrigações das instituições de pagamento no Split Payment).',
        'Em operações de intermediação financeira (empréstimos, financiamentos, descontos de títulos e leasing), a base de cálculo é composta pelas receitas financeiras brutas deduzidas das despesas financeiras de captação (tributação pelo spread/margem) e das perdas efetivas no recebimento de créditos (inadimplência comprovada). Em tarifas bancárias, gestão de fundos e corretagem, incide sobre a receita bruta. Tomadores pessoas jurídicas contribuintes do regime regular podem apropriar crédito de IBS/CBS sobre tarifas e serviços financeiros contratados (inclusive parte dos encargos financeiros conforme regulamentação do Comitê Gestor e RFB), o que inexistia no regime cumulativo de PIS/COFINS (4,65%) e ISS.',
        '{
            "2026": "Ano-teste e desenvolvimento obrigatório pelos bancos, adquirentes e fintechs da infraestrutura tecnológica do Split Payment integrado ao PIX e cartões.",
            "2027": "Substituição do PIS/COFINS (4,65% sobre spread/receitas) pela CBS do Regime Específico Financeiro; redução a zero do IOF-Seguros; início da operação do Split Payment pela rede bancária.",
            "2028": "Consolidação das deduções de perdas de crédito (inadimplência) na apuração da CBS financeira.",
            "2029": "Início da transição do ISS bancário/financeiro para o IBS (redução de 10% ao ano do ISS e ajuste correspondente na alíquota modal do regime financeiro).",
            "2030": "80% ISS / 20% IBS financeiro.",
            "2031": "70% ISS / 30% IBS financeiro.",
            "2032": "60% ISS / 40% IBS financeiro.",
            "2033": "Extinção completa do ISS sobre serviços bancários e meios de pagamento, vigorando alíquota nacional única de IBS + CBS para todo o Sistema Financeiro Nacional."
        }'::jsonb,
        ARRAY[
            'Implementação tecnológica mandatória dos motores de liquidação de Split Payment (inteligente e simplificado) por bancos, iniciadores de transação de pagamento (ITP), subadquirentes e credenciadoras.',
            'Apuração mensal segregada entre receitas de spread (captação vs. aplicação com dedução de perdas efetivas de crédito) e receitas de tarifas/comissões.',
            'Emissão de demonstrativos fiscais eletrônicos padronizados para permitir a tomada de crédito de IBS/CBS pelos clientes corporativos (B2B) tomadores de crédito e serviços.',
            'Para seguradoras: cálculo da base de IBS/CBS pelos prêmios recebidos deduzidos das indenizações/sinistros pagos e comissões de corretagem já tributadas.'
        ]
    ),

    -- 10. alimentacao_hotelaria
    (
        'alimentacao_hotelaria',
        'Regime Específico de Bares, Restaurantes, Hotelaria e Parques (Redução de 40% na Alíquota com Regras Próprias)',
        '15,9% a 16,8% (Redução de 40% sobre a alíquota padrão de IBS e CBS)',
        40.00,
        'EC 132/2023, art. 156-A, § 6º, IV; LC 214/2025, arts. 243 a 250 (Regime Específico de Bares e Restaurantes) e arts. 288 a 296 (Regime Específico de Hotelaria, Parques de Diversão, Parques Temáticos e Turismo).',
        'Redução de 40% nas alíquotas de IBS e CBS sobre o fornecimento de alimentação e bebidas preparadas em bares, restaurantes e lanchonetes, bem como em diárias de hotelaria e parques temáticos. Exclusão expressa das gorjetas da base de cálculo (desde que repassadas integralmente aos empregados e limitadas a 20% da conta) e exclusão dos valores retidos por plataformas de delivery quando tributados separadamente. Em bares e restaurantes (foco B2C), aplica-se vedação de transferência de crédito de IBS/CBS aos adquirentes das refeições, mantendo-se, contudo, o aproveitamento de créditos pelas empresas do setor sobre insumos alimentícios, energia e aluguel conforme regras do regime específico.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS) com adequação dos emissores de NFC-e/SAT e sistemas PMS hoteleiros.",
            "2027": "Vigência da CBS com redução de 40% (~5,28%); encerramento definitivo de benefícios emergenciais remanescentes (ex.: PERSE) e extinção do PIS/COFINS.",
            "2028": "Ajuste fino na conciliação de vendas via aplicativos de delivery e OTAs (Online Travel Agencies) sob o mecanismo de Split Payment.",
            "2029": "Início da transição do ICMS de alimentação (regimes especiais estaduais de 3,2% a 4%) e do ISS de hotelaria/eventos (90% ICMS/ISS / 10% IBS reduzido em 40%).",
            "2030": "80% ICMS/ISS / 20% IBS reduzido em 40%.",
            "2031": "70% ICMS/ISS / 30% IBS reduzido em 40%.",
            "2032": "60% ICMS/ISS / 40% IBS reduzido em 40%.",
            "2033": "Extinção dos regimes especiais estaduais de ICMS para bares/restaurantes e do ISS hoteleiro, vigorando integralmente o Regime Específico da LC 214/2025."
        }'::jsonb,
        ARRAY[
            'Segregação rigorosa no PDV entre alimentos/bebidas preparados no estabelecimento (regime específico com redução de 40%) e revenda pura de bebidas alcoólicas, refrigerantes ou tabacaria industrializados (sujeitos à alíquota cheia e Imposto Seletivo).',
            'Destaque separado das gorjetas espontâneas ou sugeridas (até 20%) no documento fiscal eletrônico para exclusão da base de cálculo de IBS/CBS.',
            'Conciliação fiscal das vendas intermediadas por plataformas digitais de entrega de alimentos (delivery) e agências de viagens online (OTAs).',
            'Para empresas optantes pelo Simples Nacional: avaliação anual entre permanecer no recolhimento unificado (DAS) ou recolher IBS/CBS "por fora" no regime específico.'
        ]
    ),

    -- 11. profissoes_regulamentadas
    (
        'profissoes_regulamentadas',
        'Regime Diferenciado de Profissões Intelectuais Regulamentadas (Redução de 30% na Alíquota)',
        '18,55% a 19,6% (Redução de 30% sobre a alíquota padrão de IBS e CBS)',
        30.00,
        'EC 132/2023, art. 9º, § 1º, XVIII; LC 214/2025, art. 128 (redução de 30% das alíquotas do IBS e da CBS para prestação de serviços de profissões intelectuais de natureza científica, literária ou artística submetidas à fiscalização de conselho profissional).',
        'Redução de 30% nas alíquotas de IBS e CBS para sociedades de advogados, escritórios de contabilidade, auditoria, engenharia, arquitetura, agronomia, economia, administração, jornalismo, publicidade e demais profissões listadas no art. 128 da LC 214/2025, desde que cumpridos os requisitos societários (sócios habilitados no respectivo conselho profissional e atuação dentro do objeto da profissão). Permite crédito integral para o escritório sobre aluguel, softwares jurídicos/contábeis/CAD, energia e insumos, e garante ao cliente pessoa jurídica (B2B) o crédito integral do IBS/CBS efetivamente destacado na NFS-e sobre os honorários pagos.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS); cadastramento do registro ativo no Conselho Profissional (OAB, CRC, CREA, CAU, etc.) junto ao cadastro nacional de contribuintes.",
            "2027": "Substituição do PIS/COFINS (geralmente 3,65% no Lucro Presumido) pela CBS com redução de 30% (~6,16%), com geração de crédito de CBS para os clientes PJ do escritório.",
            "2028": "Consolidação da apuração assistida da CBS sobre honorários contratuais e de êxito.",
            "2029": "Início da redução gradual do ISS — inclusive do regime de ISS Fixo por profissional das Sociedades Uniprofissionais (SUP) — à razão de 10% ao ano, com entrada de 10% do IBS (reduzido em 30%).",
            "2030": "80% ISS (ou ISS Fixo SUP) / 20% IBS reduzido em 30%.",
            "2031": "70% ISS / 30% IBS reduzido em 30%.",
            "2032": "60% ISS / 40% IBS reduzido em 30%.",
            "2033": "Extinção definitiva do ISS e das Sociedades Uniprofissionais (SUP) de ISS fixo, vigorando integralmente o IBS + CBS com redução de 30%."
        }'::jsonb,
        ARRAY[
            'Manutenção de quadro societário composto exclusivamente por pessoas naturais habilitadas nos respectivos conselhos profissionais (vedado sócio pessoa jurídica ou investidor leigo para fruição dos 30%).',
            'Vinculação do número de inscrição da sociedade e dos profissionais responsáveis no Conselho de Classe (OAB, CRC, CREA, CAU) nas emissões da NFS-e Nacional.',
            'Renegociação de contratos de honorários com clientes corporativos (B2B), demonstrando que o IBS/CBS destacado gera crédito financeiro abatível pelo cliente (neutralidade no preço líquido).',
            'Revisão de cláusulas de honorários de êxito/sucumbência de longo prazo cujo fato gerador (pagamento/liquidação) ocorrerá após 2027/2029.'
        ]
    ),

    -- 12. energia_combustiveis_telecom
    (
        'energia_combustiveis_telecom',
        'Regime Monofásico em Combustíveis (Alíquota ad rem), Regime Padrão em Energia/Telecom (com Cashback) e IS na Extração Mineral',
        'Combustíveis: Alíquota específica (R$/litro ou kg) uniforme nacional; Energia e Telecom: 26,5% a 28,0% (com crédito amplo B2B e Cashback B2C); Mineração: IS de até 0,25%',
        0.00,
        'EC 132/2023, art. 156-A, § 5º, VIII e § 6º, I e art. 153, VIII; LC 214/2025, arts. 172 a 180 (Regime Monofásico de Combustíveis), arts. 113 a 125 (Devolução Personalizada / Cashback em Energia Elétrica, Gás Canalizado e Telecomunicações) e arts. 409 a 438 (Imposto Seletivo sobre extração de minério de ferro, petróleo e gás natural).',
        'Combustíveis (gasolina, etanol, diesel, biodiesel, GLP, QAV): tributação concentrada em fase única (monofásica) na refinaria, usina, formulador ou importador, com alíquota ad rem (valor fixo por unidade de medida) uniforme em todo o país e reajustada anualmente; assegura direito a crédito integral de IBS/CBS quando o combustível for adquirido como insumo por contribuintes regulares (transportadoras, indústrias, agronegócio). Energia Elétrica e Telecomunicações: passagem das antigas alíquotas punitivas de ICMS (25% a 32% antes da LC 194/2022) para a alíquota padrão do IVA, permitindo crédito integral de 100% da fatura de energia e telecom para todos os clientes comerciais, industriais e de serviços (fim da restrição a laudos técnicos de consumo no processo produtivo). Na mineração e petróleo, incidência do Imposto Seletivo (teto de 0,25%) na extração.',
        '{
            "2026": "Ano-teste (0,9% CBS + 0,1% IBS) nas Notas Fiscais de Energia Elétrica (NF3e - modelo 66) e de Comunicação/Telecom (NFCom - modelo 62).",
            "2027": "Entrada em vigor plena do Regime Monofásico da CBS sobre todos os combustíveis (unificando a sistemática ad rem já iniciada no ICMS pela LC 192/2022); início do Imposto Seletivo (até 0,25%) sobre extração mineral; Cashback de 100% da CBS nas contas de luz e gás de famílias do CadÚnico.",
            "2028": "Operação plena da apropriação automatizada de créditos de CBS sobre faturas de energia (NF3e), telecom (NFCom) e combustíveis para clientes corporativos.",
            "2029": "Início da transição do ICMS de energia, telecom e combustíveis para o IBS (10% IBS / 90% ICMS) e ativação do Cashback mínimo de 20% do IBS para baixa renda.",
            "2030": "80% ICMS / 20% IBS.",
            "2031": "70% ICMS / 30% IBS.",
            "2032": "60% ICMS / 40% IBS.",
            "2033": "Extinção definitiva do ICMS sobre energia, combustíveis e telecomunicações, consolidando o regime nacional unificado."
        }'::jsonb,
        ARRAY[
            'Emissão obrigatória da NF3e (Nota Fiscal da Energia Elétrica Eletrônica - modelo 66) e da NFCom (Nota Fiscal Fatura de Serviços de Comunicação Eletrônica - modelo 62) com destaque do IBS/CBS e desconto direto do Cashback para inscritos no CadÚnico.',
            'Para distribuidoras, postos revendedores e TRRs de combustíveis: destaque informativo nos documentos fiscais do valor do IBS e da CBS já recolhidos anteriormente por tributação monofásica, viabilizando o crédito ao adquirente PJ.',
            'Cumprimento do diferencial competitivo constitucional para biocombustíveis (etanol hidratado, etanol anidro, biodiesel e biometano) em relação aos combustíveis fósseis.',
            'Para mineradoras e operadoras de óleo e gás: apuração mensal do Imposto Seletivo (IS) sobre o valor de referência na extração (limitado a 0,25%), vedado seu aproveitamento como crédito de IBS/CBS nas etapas seguintes.'
        ]
    )
ON CONFLICT (sector_slug) DO UPDATE SET
    regime_type = EXCLUDED.regime_type,
    estimated_effective_rate = EXCLUDED.estimated_effective_rate,
    reduction_percent = EXCLUDED.reduction_percent,
    legal_basis = EXCLUDED.legal_basis,
    credit_rules = EXCLUDED.credit_rules,
    transition_schedule = EXCLUDED.transition_schedule,
    key_obligations = EXCLUDED.key_obligations,
    updated_at = NOW();
