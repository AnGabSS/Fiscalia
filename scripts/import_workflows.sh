#!/usr/bin/env bash
# ==============================================================================
# Fiscália — Importação Automatizada dos 3 Workflows no Container n8n
# ==============================================================================
set -euo pipefail

CONTAINER_NAME="${N8N_CONTAINER:-fiscalia-n8n}"

echo "============================================================"
echo " Fiscália — Importando Workflows no container: ${CONTAINER_NAME}"
echo "============================================================"

for wf in /workflows/03_agent_tools_subworkflow.json \
          /workflows/01_push_dou_monitor.json \
          /workflows/02_pull_tax_agent.json; do
  echo "-> Importando ${wf}..."
  docker exec -u node "${CONTAINER_NAME}" n8n import:workflow --input="${wf}"
done

echo ""
echo "✅ Todos os 3 workflows foram importados com sucesso!"
echo "👉 Acesse http://localhost:5678 para visualizar e ativar os fluxos no n8n."
