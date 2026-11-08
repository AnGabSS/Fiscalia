-- ==============================================================================
-- Fiscália — Seed 002: Atos Normativos Curados (Replay/Demo) e Usuários de Teste
-- Base Legal: Regulamentação infralegal da LC 214/2025 (RFB e Comitê Gestor do IBS)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Atos Normativos Curados da Reforma Tributária (public.ordinances)
-- ------------------------------------------------------------------------------
INSERT INTO public.ordinances (
    external_hash,
    act_number,
    title,
    official_url,
    published_at,
    raw_excerpt,
    escopo,
    grau_urgencia,
    tributos,
    affected_sector_slugs,
    setores_afetados_detalhe,
    resumo_geral,
    previsao_vigencia,
    is_replay_seed
)
VALUES
    -- Ato 1: Escopo GERAL | Urgência ALTA | Alíquota-teste 2026 (0,9% CBS + 0,1% IBS)
    (
        'seed_rfb_cgibs_ato_conjunto_001_2025',
        'Ato Conjunto RFB/CGIBS nº 01/2025',
        'Dispõe sobre a apuração assistida da alíquota-teste de 0,9% da CBS e de 0,1% do IBS no ano-calendário de 2026, as hipóteses de dispensa de recolhimento por cumprimento de obrigações acessórias e a sistemática de compensação com PIS/Pasep e COFINS.',
        'https://www.in.gov.br/en/web/dou/-/ato-conjunto-rfb-cgibs-n-1-2025-aliquota-teste-2026',
        '2025-11-10',
        'O SECRETÁRIO ESPECIAL DA RECEITA FEDERAL DO BRASIL E O PRESIDENTE DO COMITÊ GESTOR DO IMPOSTO SOBRE BENS E SERVIÇOS, no uso das atribuições que lhes conferem o art. 125 do ADCT e os arts. 342 a 348 da Lei Complementar nº 214, de 16 de janeiro de 2025, resolvem: Art. 1º No período de 1º de janeiro a 31 de dezembro de 2026, os sujeitos passivos submetidos ao regime regular do IBS e da CBS deverão destacar nos documentos fiscais eletrônicos a alíquota-teste de 0,9% (nove décimos por cento) a título de Contribuição sobre Bens e Serviços (CBS) e de 0,1% (um décimo por cento) a título de Imposto sobre Bens e Serviços (IBS). § 1º O contribuinte que cumprir tempestivamente as obrigações acessórias de emissão de documentos fiscais eletrônicos com os novos grupos de tributação (UB/IBS/CBS) e de validação na plataforma de apuração assistida ficará dispensado do recolhimento efetivo em moeda dos valores destacados no § 1º do art. 346 da LC 214/2025. § 2º Na hipótese de recolhimento efetivo da CBS e do IBS em 2026, o montante pago será integralmente deduzido do valor devido a título de Contribuição para o PIS/Pasep e de COFINS no mesmo período de apuração, ou compensado com quaisquer outros tributos administrados pela Receita Federal via PER/DCOMP Web.',
        'GERAL',
        'ALTA',
        ARRAY['CBS', 'IBS', 'PIS', 'COFINS'],
        ARRAY[
            'tecnologia_saas',
            'saude_servicos_medicos',
            'educacao',
            'agronegocio',
            'varejo_comercio',
            'industria_manufatura',
            'construcao_imobiliario',
            'transporte_logistica',
            'servicos_financeiros',
            'alimentacao_hotelaria',
            'profissoes_regulamentadas',
            'energia_combustiveis_telecom'
        ],
        '[
            {
                "setor_slug": "tecnologia_saas",
                "setor_nome": "Tecnologia, SaaS e Serviços Digitais",
                "resumo_impacto_setor": "Obrigatoriedade de destaque de 0,9% de CBS e 0,1% de IBS nas NFS-e emitidas a partir de 01/01/2026, com dispensa do pagamento em dinheiro caso o leiaute nacional seja emitido sem rejeições.",
                "acao_recomendada": "Parametrizar o ERP de faturamento recorrente para preencher as tags XML de CBS (0,9%) e IBS (0,1%) na NFS-e Nacional até dezembro/2025 para garantir a dispensa de recolhimento."
            },
            {
                "setor_slug": "varejo_comercio",
                "setor_nome": "Varejo, E-commerce e Comércio Atacadista",
                "resumo_impacto_setor": "Exige atualização de todos os emissores de NF-e (modelo 55) e NFC-e (modelo 65) com os novos códigos cClassTrib para usufruir da dispensa financeira do 1% de teste em 2026.",
                "acao_recomendada": "Homologar a Nota Técnica 2025.002 nos PDVs e plataformas de e-commerce e validar a compensação automática no DCTFWeb/PIS-COFINS caso ocorra recolhimento."
            },
            {
                "setor_slug": "industria_manufatura",
                "setor_nome": "Indústria de Transformação e Zona Franca",
                "resumo_impacto_setor": "Transição operacional assistida em todas as saídas industriais sem impacto de caixa em 2026 se cumprido o cronograma de escrituração digital.",
                "acao_recomendada": "Auditar o cadastro de NCMs e vincular cada item às tabelas de alíquota padrão, reduzida ou zero da LC 214/2025 para evitar rejeição de NF-e em janeiro de 2026."
            },
            {
                "setor_slug": "profissoes_regulamentadas",
                "setor_nome": "Advocacia, Contabilidade, Engenharia e Consultoria",
                "resumo_impacto_setor": "Sociedades no Lucro Presumido ou Real deverão destacar a alíquota-teste nas notas de honorários, ficando isentas do recolhimento se emitirem a NFS-e no padrão nacional.",
                "acao_recomendada": "Verificar se o município da sede já está integrado ao Ambiente de Dados Nacional (ADN) da NFS-e e atualizar o sistema de emissão de notas de honorários."
            }
        ]'::jsonb,
        'Regulamenta a operacionalização do ano-teste da Reforma Tributária em 2026 (0,9% de CBS e 0,1% de IBS). Confirma que as empresas que emitirem corretamente os documentos fiscais eletrônicos no novo leiaute com destaque informativo ficam dispensadas do pagamento financeiro do tributo-teste, ou poderão abatê-lo integralmente do PIS/COFINS devido no mês.',
        '01/01/2026 (efeitos operacionais e de homologação imediatos)',
        TRUE
    ),

    -- Ato 2: Escopo ESPECIFICO_SETORIAL | Urgência ALTA | tecnologia_saas, profissoes_regulamentadas
    (
        'seed_rfb_cgibs_in_002_2025_nfse_saas_profissoes',
        'Instrução Normativa Conjunta RFB/CGIBS nº 14/2025',
        'Institui o leiaute XML obrigatório da NFS-e de Padrão Nacional (versão 2.1 - Reforma Tributária) e regulamenta o destaque de IBS e CBS no licenciamento de software, SaaS, computação em nuvem e serviços intelectuais de profissões regulamentadas.',
        'https://www.in.gov.br/en/web/dou/-/instrucao-normativa-conjunta-rfb-cgibs-n-14-2025-nfse-nacional',
        '2025-11-18',
        'Art. 1º Fica aprovada a versão 2.1 do Leiaute da Nota Fiscal de Serviços Eletrônica de Padrão Nacional (NFS-e Nacional), de adoção obrigatória por todos os prestadores de serviços contribuintes da CBS e do IBS. Art. 2º Nas operações de licenciamento ou cessão de direito de uso de programas de computador, Software as a Service (SaaS), Infrastructure as a Service (IaaS), Platform as a Service (PaaS), armazenamento de dados em nuvem e suporte técnico remoto, o grupo XML <IBSCBS> deverá indicar obrigatoriamente o código de município de domicílio principal do adquirente (destinatário) para fins de partilha no destino, nos termos do art. 11 da LC 214/2025. Art. 3º Para as sociedades prestadoras de serviços de profissões intelectuais regulamentadas referidas no art. 128 da LC 214/2025 (advocacia, contabilidade, auditoria, engenharia, arquitetura, economia e consultoria técnica), a aplicação do redutor de alíquota de 30% (trinta por cento) no campo <pRedAliq> condiciona-se ao preenchimento do grupo <infConselhoProf>, contendo a sigla do conselho de fiscalização (OAB, CRC, CREA, CAU, CORECON ou CRA) e o número de registro ativo da sociedade.',
        'ESPECIFICO_SETORIAL',
        'ALTA',
        ARRAY['IBS', 'CBS', 'ISS', 'PIS', 'COFINS'],
        ARRAY['tecnologia_saas', 'profissoes_regulamentadas'],
        '[
            {
                "setor_slug": "tecnologia_saas",
                "setor_nome": "Tecnologia, SaaS e Serviços Digitais",
                "resumo_impacto_setor": "Torna obrigatória a emissão da NFS-e Nacional v2.1 para SaaS, licenciamento de software e nuvem, exigindo a identificação exata do município do cliente (tributação no destino) e os códigos NBS de tecnologia.",
                "acao_recomendada": "Enriquecer o cadastro de clientes B2B e B2C com validação obrigatória de código IBGE do município de destino e atualizar a integração via API com o Ambiente de Dados Nacional (ADN) da NFS-e."
            },
            {
                "setor_slug": "profissoes_regulamentadas",
                "setor_nome": "Advocacia, Contabilidade, Engenharia e Consultoria",
                "resumo_impacto_setor": "Condiciona a trava automática de redução de 30% na alíquota de IBS/CBS ao preenchimento da tag XML <infConselhoProf> com o registro ativo na OAB, CRC, CREA ou CAU em cada nota fiscal emitida.",
                "acao_recomendada": "Cadastrar o número de inscrição da sociedade no respectivo Conselho de Classe dentro do sistema de faturamento para habilitar o redutor de 30% (código de benefício fiscal da LC 214/2025)."
            }
        ]'::jsonb,
        'Estabelece o novo leiaute XML v2.1 da NFS-e Nacional para a Reforma Tributária. Para empresas de Tecnologia/SaaS, exige o código IBGE do domicílio do cliente para cálculo do IBS no destino. Para escritórios de Advocacia, Contabilidade e Engenharia, exige a tag XML com o registro no conselho profissional (OAB/CRC/CREA/CAU) para liberar a redução de 30% na alíquota.',
        '01/01/2026 (ambiente de produção nacional)',
        TRUE
    ),

    -- Ato 3: Escopo ESPECIFICO_SETORIAL | Urgência ALTA | saude_servicos_medicos, educacao
    (
        'seed_rfb_cgibs_portaria_028_2025_saude_educacao_60',
        'Portaria Conjunta RFB/CGIBS nº 28/2025',
        'Estabelece os requisitos cadastrais e o procedimento de habilitação eletrônica no Cadastro Nacional de Regimes Diferenciados (CNRD) para fruição da redução de 60% nas alíquotas do IBS e da CBS pelos setores de Saúde Humana e Educação Regular.',
        'https://www.in.gov.br/en/web/dou/-/portaria-conjunta-rfb-cgibs-n-28-2025-habilitacao-saude-educacao',
        '2025-11-24',
        'Art. 1º A aplicação da redução de 60% (sessenta por cento) das alíquotas do IBS e da CBS prevista nos arts. 129 a 135 da Lei Complementar nº 214, de 2025, para os serviços de educação e de saúde humana fica condicionada à habilitação prévia do contribuinte no Cadastro Nacional de Regimes Diferenciados (CNRD), módulo integrante do Portal Nacional da Reforma Tributária (e-CAC/CGIBS). Art. 2º Para as instituições de ensino infantil, fundamental, médio, técnico e superior listadas no Anexo II da LC 214/2025, o deferimento automático dependerá do cruzamento eletrônico do CNPJ com o Cadastro e-MEC ou com o Censo Escolar do INEP, bem como da segregação das receitas vinculadas ao Programa Universidade para Todos (Prouni), sujeitas à redução de 100% da CBS. Art. 3º Para hospitais, clínicas médicas, odontológicas, laboratórios de análises clínicas e diagnóstico por imagem listados no Anexo III da LC 214/2025, exige-se vinculação ativa no Cadastro Nacional de Estabelecimentos de Saúde (CNES) do Ministério da Saúde e segregação de procedimentos puramente estéticos não reparadores.',
        'ESPECIFICO_SETORIAL',
        'ALTA',
        ARRAY['IBS', 'CBS', 'ISS'],
        ARRAY['saude_servicos_medicos', 'educacao'],
        '[
            {
                "setor_slug": "saude_servicos_medicos",
                "setor_nome": "Saúde, Hospitais, Clínicas e Planos",
                "resumo_impacto_setor": "Sem a habilitação eletrônica no CNRD vinculada ao registro ativo no CNES, o sistema nacional rejeitará as notas fiscais emitidas com o redutor de 60% de IBS/CBS, exigindo a alíquota cheia (26,5%-28%).",
                "acao_recomendada": "Regularizar imediatamente o cadastro de todas as unidades e filiais no CNES/Ministério da Saúde, protocolar a habilitação no CNRD via e-CAC e separar no ERP os códigos NBS de procedimentos médicos vs. estéticos."
            },
            {
                "setor_slug": "educacao",
                "setor_nome": "Educação e Ensino Regular",
                "resumo_impacto_setor": "Vincula a fruição da redução de 60% no ensino regular e da alíquota zero de CBS no Prouni à validação cruzada do CNPJ com o sistema e-MEC / Censo Escolar do INEP dentro do CNRD.",
                "acao_recomendada": "Realizar o credenciamento no módulo CNRD informando os atos autorizativos do MEC/Secretaria de Educação e parametrizar códigos de serviço distintos para ensino regular (red. 60%) e cursos livres (alíquota padrão)."
            }
        ]'::jsonb,
        'Cria o Cadastro Nacional de Regimes Diferenciados (CNRD) e torna obrigatória a habilitação prévia de hospitais, clínicas, laboratórios (via cruzamento com o CNES) e escolas/universidades (via cruzamento com o MEC/INEP) para utilização do redutor de 60% nas alíquotas de IBS e CBS.',
        'Habilitação aberta a partir de 01/12/2025; trava de emissão ativa em 01/02/2026',
        TRUE
    ),

    -- Ato 4: Escopo ESPECIFICO_SETORIAL | Urgência ALTA | servicos_financeiros, varejo_comercio
    (
        'seed_rfb_cgibs_in_033_2025_split_payment_pix_cartoes',
        'Instrução Normativa RFB/CGIBS/BACEN nº 33/2025',
        'Regulamenta a operacionalização do recolhimento na liquidação financeira (Split Payment automático e simplificado) em transações via PIX empresarial, cartões de crédito, débito e marketplaces para o comércio varejista e instituições financeiras e de pagamento.',
        'https://www.in.gov.br/en/web/dou/-/instrucao-normativa-rfb-cgibs-bacen-n-33-2025-split-payment',
        '2025-12-01',
        'Art. 1º As instituições financeiras, as instituições de pagamento, as credenciadoras, as subcredenciadoras e os iniciadores de transação de pagamento (ITP) integrantes do Sistema de Pagamentos Brasileiro (SPB) e do arranjo PIX deverão segregar e recolher automaticamente, no ato da liquidação financeira da operação com bens ou serviços, os valores de IBS e CBS destacados na NF-e, NFC-e ou NFS-e vinculada, em cumprimento aos arts. 27 a 35 da Lei Complementar nº 214, de 2025. Art. 2º Para o comércio varejista e e-commerce, a chave de acesso de 44 dígitos do documento fiscal eletrônico deverá constar no payload do QR Code dinâmico do PIX ou na mensagem ISO 8583/20022 das transações de cartão (TEF/POS integrado). Art. 3º Na modalidade de Split Payment Inteligente, o motor do Comitê Gestor e da RFB consultará em tempo real o saldo de créditos apropriados pelo estabelecimento varejista na apuração assistida, retendo na liquidação financeira apenas o saldo líquido devedor de IBS e CBS da operação.',
        'ESPECIFICO_SETORIAL',
        'ALTA',
        ARRAY['IBS', 'CBS', 'ICMS'],
        ARRAY['servicos_financeiros', 'varejo_comercio'],
        '[
            {
                "setor_slug": "servicos_financeiros",
                "setor_nome": "Bancos, Fintechs, Seguros e Meios de Pagamento",
                "resumo_impacto_setor": "Impõe aos bancos, fintechs, adquirentes e subadquirentes a obrigação técnica de ler a chave do documento fiscal no payload do PIX/cartão, consultar a API de Split Inteligente da RFB/CGIBS e segregar o tributo no momento do repasse (liquidação D+0/D+1/D+30).",
                "acao_recomendada": "Adequar os motores de liquidação do arranjo PIX e grades de liquidação de cartões ao padrão técnico de mensageria do Split Payment e homologar a API de consulta de créditos em tempo real."
            },
            {
                "setor_slug": "varejo_comercio",
                "setor_nome": "Varejo, E-commerce e Comércio Atacadista",
                "resumo_impacto_setor": "Altera diretamente o fluxo de caixa do varejo físico e digital: o valor do IBS/CBS passa a ser retido automaticamente no ato do pagamento via PIX ou cartão, mas o Split Inteligente abatendo créditos de entrada evita retenção em excesso se as notas de compra estiverem escrituradas.",
                "acao_recomendada": "Integrar obrigatoriamente o TEF/PDV e o checkout do e-commerce para injetar a chave de 44 dígitos da NF-e/NFC-e na transação de pagamento e automatizar o manifesto/registro imediato das notas fiscais de entrada (compras) para alimentar o saldo de créditos do Split Inteligente."
            }
        ]'::jsonb,
        'Regulamenta a arquitetura técnica e operacional do Split Payment em pagamentos via PIX, cartões de débito/crédito e marketplaces. Determina a vinculação da chave da NF-e/NFC-e na transação financeira e detalha como o Split Inteligente abaterá em tempo real os créditos de entrada do varejista antes de reter o imposto.',
        'Homologação técnica em 2026; operação financeira obrigatória a partir de 01/01/2027',
        TRUE
    ),

    -- Ato 5: Escopo ESPECIFICO_SETORIAL | Urgência MEDIA | construcao_imobiliario
    (
        'seed_rfb_cgibs_ato_041_2025_cib_redutor_ajuste_imobiliario',
        'Ato Normativo Conjunto RFB/CGIBS nº 41/2025',
        'Dispõe sobre a inscrição de imóveis no Cadastro Imobiliário Brasileiro (CIB/SINTER) e os procedimentos de escrituração do Redutor de Ajuste, do Redutor Social e da opção pelo regime de transição de incorporações imobiliárias.',
        'https://www.in.gov.br/en/web/dou/-/ato-normativo-conjunto-rfb-cgibs-n-41-2025-cib-regime-imobiliario',
        '2025-12-05',
        'Art. 1º Ficam estabelecidos os procedimentos para vinculação do identificador único do Cadastro Imobiliário Brasileiro (CIB), integrante do Sistema Nacional de Gestão de Informações Territoriais (SINTER), a todas as operações de incorporação imobiliária, parcelamento do solo, construção civil, alienação e locação de bens imóveis de que tratam os arts. 251 a 287 da Lei Complementar nº 214, de 2025. Art. 2º Para fins de constituição do Redutor de Ajuste aplicável aos terrenos em estoque em 31 de dezembro de 2026 e às novas aquisições, a incorporadora ou loteadora deverá registrar no livro eletrônico do regime imobiliário o valor de aquisição do terreno atualizado pelo IPCA, acrescido do ITBI, laudêmio e contrapartidas urbanísticas e ambientais efetivamente suportadas. Art. 3º Na alienação de unidades imobiliárias residenciais novas, após a dedução do Redutor de Ajuste, aplicar-se-á o Redutor Social de R$ 100.000,00 (cem mil reais) por unidade autônoma (ou R$ 30.000,00 por lote residencial) diretamente sobre a base de cálculo do IBS e da CBS, incidindo sobre o saldo remanescente a alíquota reduzida em 50% (cinquenta por cento). Art. 4º Nas operações de locação residencial, aplica-se o Redutor Social mensal de R$ 600,00 (seiscentos reais) por imóvel locado e a redução de 70% (setenta por cento) nas alíquotas do IBS e da CBS.',
        'ESPECIFICO_SETORIAL',
        'MEDIA',
        ARRAY['IBS', 'CBS', 'ISS', 'RET'],
        ARRAY['construcao_imobiliario'],
        '[
            {
                "setor_slug": "construcao_imobiliario",
                "setor_nome": "Construção Civil, Incorporação e Locação Imobiliária",
                "resumo_impacto_setor": "Define o passo a passo para cadastrar terrenos e empreendimentos no CIB/SINTER e habilitar o Redutor de Ajuste (que impede a tributação sobre o valor do terreno) e o Redutor Social (dedução de R$ 100 mil por apartamento novo e R$ 600/mês no aluguel residencial), além do prazo de opção pelo regime de transição para obras com Patrimônio de Afetação (RET).",
                "acao_recomendada": "Levantar toda a documentação de aquisição, ITBI e outorgas onerosas do landbank (terrenos em estoque) para averbação do Redutor de Ajuste até dez/2026 e mapear o código CIB de cada matrícula imobiliária para emissão das notas e contratos."
            }
        ]'::jsonb,
        'Regulamenta o Cadastro Imobiliário Brasileiro (CIB) e a escrituração digital do Redutor de Ajuste (dedução do custo atualizado do terreno e ITBI) e do Redutor Social (abatimento de R$ 100 mil por imóvel residencial novo, R$ 30 mil por lote e R$ 600/mês no aluguel), além das regras de transição para incorporações no RET.',
        'Cadastramento CIB e estoque de terrenos ao longo de 2026; efeitos tributários plenos em 01/01/2027',
        TRUE
    ),

    -- Ato 6: Escopo ESPECIFICO_SETORIAL | Urgência MEDIA | agronegocio, transporte_logistica
    (
        'seed_rfb_cgibs_portaria_052_2025_agro_credito_presumido_frete',
        'Portaria Conjunta RFB/CGIBS nº 52/2025',
        'Fixa a metodologia e os percentuais de crédito presumido de IBS e CBS na aquisição de bens de produtor rural não contribuinte e de transportador autônomo de cargas (TAC), e disciplina o creditamento imediato sobre fretes e combustíveis monofásicos.',
        'https://www.in.gov.br/en/web/dou/-/portaria-conjunta-rfb-cgibs-n-52-2025-credito-presumido-agro-frete',
        '2025-12-09',
        'Art. 1º Os adquirentes de produtos agropecuários, aquícolas e florestais que sejam contribuintes regulares do IBS e da CBS (cooperativas, agroindústrias, cerealistas e atacadistas) poderão apropriar crédito presumido nas aquisições realizadas de produtor rural pessoa física ou jurídica não contribuinte (receita bruta anual inferior a R$ 3.600.000,00), nos termos dos arts. 164 a 171 da Lei Complementar nº 214, de 2025, condicionado à emissão de Nota Fiscal Eletrônica de Entrada vinculada à NFP-e do produtor. Art. 2º Nas prestações de serviço de transporte rodoviário de cargas, as transportadoras e os embarcadores contribuintes do regime regular apropriarão de forma integral e imediata os créditos de IBS e CBS destacados no Conhecimento de Transporte Eletrônico (CT-e), bem como o montante do IBS e da CBS cobrados pelo regime monofásico nas aquisições de óleo diesel, biodiesel e etanol hidratado utilizados na frota própria ou arrendada, mediante captura do grupo <ICMSMonofasico/IBSCBSMono> da NF-e emitida pelo posto revendedor ou TRR. Art. 3º Na subcontratação de Transportador Autônomo de Cargas (TAC) pessoa física inscrito no RNTRC da ANTT, o contratante contribuinte fará jus ao crédito presumido calculado sobre o valor do frete pago.',
        'ESPECIFICO_SETORIAL',
        'MEDIA',
        ARRAY['IBS', 'CBS', 'ICMS'],
        ARRAY['agronegocio', 'transporte_logistica'],
        '[
            {
                "setor_slug": "agronegocio",
                "setor_nome": "Agronegócio, Produtor Rural e Insumos Agro",
                "resumo_impacto_setor": "Estabelece as regras para agroindústrias, cooperativas e tradings recuperarem o crédito presumido de IBS/CBS ao comprarem grãos, gado, leite ou madeira de pequenos e médios produtores rurais não contribuintes (faturamento até R$ 3,6 milhões), além de confirmar o crédito integral do frete de escoamento de safra.",
                "acao_recomendada": "Classificar a base de fornecedores rurais entre contribuintes opcionais e não contribuintes (até R$ 3,6 milhões/ano) e configurar o ERP para emissão automática de NF-e de entrada com apropriação do crédito presumido."
            },
            {
                "setor_slug": "transporte_logistica",
                "setor_nome": "Transporte de Cargas, Passageiros e Logística",
                "resumo_impacto_setor": "Garante o aproveitamento imediato de 100% do crédito do IBS/CBS monofásico embutido no óleo diesel e biodiesel das frotas, além de regulamentar o crédito presumido na contratação de caminhoneiros autônomos (TAC).",
                "acao_recomendada": "Exigir que todos os abastecimentos de frota em postos e TRRs sejam acobertados por NF-e (modelo 55) contendo o CNPJ da transportadora e as tags de tributação monofásica, e validar o RNTRC ativo dos caminhoneiros autônomos subcontratados."
            }
        ]'::jsonb,
        'Regulamenta a apropriação de crédito presumido de IBS e CBS na compra de produção de produtor rural não contribuinte (até R$ 3,6 milhões/ano) e na contratação de caminhoneiros autônomos (TAC), além de detalhar a tomada imediata de crédito sobre fretes (CT-e) e sobre o IBS/CBS monofásico do óleo diesel.',
        '01/01/2027 (para CBS) e escalonado de 2029 a 2033 (para IBS)',
        TRUE
    )
ON CONFLICT (external_hash) DO UPDATE SET
    act_number = EXCLUDED.act_number,
    title = EXCLUDED.title,
    official_url = EXCLUDED.official_url,
    published_at = EXCLUDED.published_at,
    raw_excerpt = EXCLUDED.raw_excerpt,
    escopo = EXCLUDED.escopo,
    grau_urgencia = EXCLUDED.grau_urgencia,
    tributos = EXCLUDED.tributos,
    affected_sector_slugs = EXCLUDED.affected_sector_slugs,
    setores_afetados_detalhe = EXCLUDED.setores_afetados_detalhe,
    resumo_geral = EXCLUDED.resumo_geral,
    previsao_vigencia = EXCLUDED.previsao_vigencia,
    is_replay_seed = EXCLUDED.is_replay_seed;

-- ------------------------------------------------------------------------------
-- 2. Usuários de Demonstração e Assinaturas Setoriais (public.users / user_subscriptions)
-- ------------------------------------------------------------------------------
WITH upserted_users AS (
    INSERT INTO public.users (
        id,
        channel_type,
        external_user_id,
        chat_id,
        display_name,
        business_context,
        is_active
    )
    VALUES
        (
            '11111111-1111-4111-8111-111111111111'::uuid,
            'telegram',
            'demo_tg_001',
            'demo_tg_001',
            'Marina Costa (CFO — CloudB2B & Consultoria)',
            'Empresa de SaaS B2B no Lucro Presumido com faturamento anual de R$ 18 milhões e braço de consultoria em engenharia de software.',
            TRUE
        ),
        (
            '22222222-2222-4222-8222-222222222222'::uuid,
            'slack',
            'U01DEMO002',
            'C01DEMO002',
            'Roberto Almeida (Diretor Fiscal — Grupo Varejo & AgroLog)',
            'Rede de varejo omnichannel e atacado alimentar com frota própria de distribuição rodoviária e compra direta de produtores rurais.',
            TRUE
        )
    ON CONFLICT (channel_type, external_user_id) DO UPDATE SET
        chat_id = EXCLUDED.chat_id,
        display_name = EXCLUDED.display_name,
        business_context = EXCLUDED.business_context,
        is_active = EXCLUDED.is_active,
        updated_at = NOW()
    RETURNING id, channel_type, external_user_id
)
INSERT INTO public.user_subscriptions (user_id, sector_slug)
SELECT u.id, s.sector_slug
FROM upserted_users u
JOIN (
    VALUES
        ('telegram', 'demo_tg_001', 'tecnologia_saas'),
        ('telegram', 'demo_tg_001', 'profissoes_regulamentadas'),
        ('slack',    'U01DEMO002',  'varejo_comercio'),
        ('slack',    'U01DEMO002',  'agronegocio'),
        ('slack',    'U01DEMO002',  'transporte_logistica')
) AS s(channel_type, external_user_id, sector_slug)
    ON u.channel_type = s.channel_type
   AND u.external_user_id = s.external_user_id
ON CONFLICT (user_id, sector_slug) DO NOTHING;
