#!/usr/bin/env bash
# ==============================================================================
# Fiscália — Disparo Rápido do Modo Replay / Backfill de Embeddings (Webhook)
# Uso:
#   ./scripts/trigger_demo_replay.sh                # Dispara Replay de ato seed
#   ./scripts/trigger_demo_replay.sh backfill       # Gera embeddings 768d dos seeds
#   ./scripts/trigger_demo_replay.sh IN-RFB-2255    # Dispara ato específico
# ==============================================================================
set -euo pipefail

N8N_BASE_URL="${N8N_BASE_URL:-http://localhost:5678}"
ARG="${1:-replay}"

if [ "${ARG}" = "backfill" ]; then
  PAYLOAD='{"action":"backfill_embeddings"}'
  echo "🔄 Acionando backfill de embeddings (text-embedding-004 768d) para os seeds..."
elif [ "${ARG}" = "replay" ]; then
  PAYLOAD='{"action":"replay"}'
  echo "🚀 Disparando Modo Replay do DOU/RFB (Workflow 1)..."
else
  PAYLOAD="{\"action\":\"replay\",\"act_number\":\"${ARG}\"}"
  echo "🚀 Disparando Modo Replay para o ato específico: ${ARG}..."
fi

curl -sS -X POST "${N8N_BASE_URL}/webhook/simular-dou" \
  -H "Content-Type: application/json" \
  -d "${PAYLOAD}"

echo ""
echo "✅ Requisição concluída!"
