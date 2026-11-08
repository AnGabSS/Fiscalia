import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();

const CANONICAL_SLUGS = [
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
];

const REQUIRED_FILES = [
  '.gitignore',
  '.env.example',
  'docker-compose.yml',
  'README.md',
  'fiscalia-architecture.drawio',
  'fiscalia-mer-pgvector.drawio',
  'docs/superpowers/specs/2026-11-06-fiscalia-design.md',
  'supabase/migrations/001_init_schema.sql',
  'supabase/migrations/002_rpc_functions.sql',
  'supabase/seed/001_sectors_and_matrix.sql',
  'supabase/seed/002_demo_ordinances.sql',
  'workflows/01_push_dou_monitor.json',
  'workflows/02_pull_tax_agent.json',
  'workflows/03_agent_tools_subworkflow.json',
  'scripts/import_workflows.sh',
  'scripts/import_workflows.ps1',
  'scripts/trigger_demo_replay.sh',
  'scripts/trigger_demo_replay.ps1',
  'scripts/telegram_bridge.ps1'
];

test('1. Estrutura do repositório e proteção de segredos (.gitignore)', () => {
  for (const relPath of REQUIRED_FILES) {
    const fullPath = path.join(ROOT, relPath);
    assert.ok(fs.existsSync(fullPath), `Arquivo obrigatório ausente: ${relPath}`);
    const stat = fs.statSync(fullPath);
    assert.ok(stat.size > 0, `Arquivo obrigatório está vazio: ${relPath}`);
  }

  const gitignore = fs.readFileSync(path.join(ROOT, '.gitignore'), 'utf8');
  assert.match(gitignore, /^\.env$/m, '.gitignore deve ignorar o arquivo .env');
});

test('2. Schema SQL (001_init_schema.sql) contém as 7 tabelas e índices pgvector/GIN', () => {
  const schemaSql = fs.readFileSync(
    path.join(ROOT, 'supabase/migrations/001_init_schema.sql'),
    'utf8'
  );

  assert.match(schemaSql, /CREATE EXTENSION IF NOT EXISTS vector/i);
  assert.match(schemaSql, /CREATE EXTENSION IF NOT EXISTS pgcrypto/i);

  const expectedTables = [
    'sectors',
    'users',
    'user_subscriptions',
    'tax_reform_matrix',
    'ordinances',
    'alert_deliveries',
    'n8n_chat_histories'
  ];

  for (const table of expectedTables) {
    const regex = new RegExp(`CREATE TABLE IF NOT EXISTS public\\.${table}\\b`, 'i');
    assert.match(schemaSql, regex, `Tabela public.${table} deve estar definida em 001_init_schema.sql`);
  }

  assert.match(schemaSql, /embedding\s+vector\(768\)/i, 'Coluna embedding deve ser vector(768)');
  assert.match(schemaSql, /USING\s+hnsw\s*\(\s*embedding\s+vector_cosine_ops\s*\)/i, 'Índice HNSW deve existir');
  assert.match(schemaSql, /USING\s+GIN\s*\(\s*affected_sector_slugs\s*\)/i, 'Índice GIN deve existir');
});

test('3. Funções RPC (002_rpc_functions.sql) respeitam o contrato congelado', () => {
  const rpcSql = fs.readFileSync(
    path.join(ROOT, 'supabase/migrations/002_rpc_functions.sql'),
    'utf8'
  );

  const expectedFunctions = [
    'get_user_context_and_catalog',
    'manage_user_subscription',
    'get_consolidated_subscribers_for_ordinance',
    'match_ordinances_by_sector'
  ];

  for (const fn of expectedFunctions) {
    const regex = new RegExp(`CREATE OR REPLACE FUNCTION public\\.${fn}\\b`, 'i');
    assert.match(rpcSql, regex, `Função RPC public.${fn} ausente em 002_rpc_functions.sql`);
  }

  assert.match(
    rpcSql,
    /#variable_conflict use_column/,
    'Funções RETURNS TABLE devem declarar #variable_conflict use_column'
  );
});

test('4. Seeds tributários (LC 214/2025) contêm todos os 12 setores canônicos e portarias de Replay', () => {
  const seedSectors = fs.readFileSync(
    path.join(ROOT, 'supabase/seed/001_sectors_and_matrix.sql'),
    'utf8'
  );
  const seedOrdinances = fs.readFileSync(
    path.join(ROOT, 'supabase/seed/002_demo_ordinances.sql'),
    'utf8'
  );

  for (const slug of CANONICAL_SLUGS) {
    assert.ok(
      seedSectors.includes(`'${slug}'`),
      `Slug canônico '${slug}' deve estar presente em 001_sectors_and_matrix.sql`
    );
  }

  assert.match(seedOrdinances, /is_replay_seed/i);
  assert.match(seedOrdinances, /Ato Conjunto RFB\/CGIBS/i);
});

test('5. Workflows do n8n possuem grafo válido, JS compilável e credencial padronizada', () => {
  const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
  const workflowFiles = [
    'workflows/01_push_dou_monitor.json',
    'workflows/02_pull_tax_agent.json',
    'workflows/03_agent_tools_subworkflow.json'
  ];

  for (const wfRel of workflowFiles) {
    const raw = fs.readFileSync(path.join(ROOT, wfRel), 'utf8');
    const wf = JSON.parse(raw);

    assert.ok(wf.name, `${wfRel} deve possuir propriedade "name"`);
    assert.ok(Array.isArray(wf.nodes) && wf.nodes.length > 0, `${wfRel} deve possuir nós`);
    assert.ok(wf.connections && typeof wf.connections === 'object', `${wfRel} deve possuir connections`);

    const nodeIds = new Set();
    const nodeNames = new Set();

    for (const node of wf.nodes) {
      assert.ok(node.id, `Nó sem id em ${wfRel}`);
      assert.ok(node.name, `Nó sem name em ${wfRel}`);
      assert.ok(!nodeIds.has(node.id), `ID de nó duplicado "${node.id}" em ${wfRel}`);
      assert.ok(!nodeNames.has(node.name), `Nome de nó duplicado "${node.name}" em ${wfRel}`);
      nodeIds.add(node.id);
      nodeNames.add(node.name);

      if (node.type === 'n8n-nodes-base.code' && node.parameters?.jsCode) {
        assert.doesNotThrow(
          () => new AsyncFunction('$input', '$json', '$env', '$', '$items', node.parameters.jsCode),
          `Erro de sintaxe JS no nó "${node.name}" de ${wfRel}`
        );
      }

      if (node.type === 'n8n-nodes-base.postgres') {
        assert.equal(
          node.credentials?.postgres?.id,
          'fiscalia-postgres-cred',
          `Nó Postgres "${node.name}" em ${wfRel} deve usar a credencial "fiscalia-postgres-cred"`
        );
      }
    }

    for (const [sourceName, outputs] of Object.entries(wf.connections)) {
      assert.ok(
        nodeNames.has(sourceName),
        `Conexão de origem inexistente "${sourceName}" em ${wfRel}`
      );
      for (const branches of Object.values(outputs)) {
        for (const branch of branches) {
          for (const edge of branch) {
            assert.ok(
              nodeNames.has(edge.node),
              `Conexão de destino inexistente "${edge.node}" (vindo de "${sourceName}") em ${wfRel}`
            );
          }
        }
      }
    }
  }
});

test('6. Diagramas Draw.io possuem XML mxGraphModel bem-formado e sem comentários XML', () => {
  for (const diag of ['fiscalia-architecture.drawio', 'fiscalia-mer-pgvector.drawio']) {
    const xml = fs.readFileSync(path.join(ROOT, diag), 'utf8');
    assert.match(xml, /^<mxGraphModel\b/);
    assert.match(xml, /<\/mxGraphModel>\s*$/);
    assert.doesNotMatch(xml, /<!--/, `${diag} não deve conter comentários XML`);
    assert.match(xml, /<mxCell id="0"\/>/);
    assert.match(xml, /<mxCell id="1" parent="0"\/>/);
  }
});
