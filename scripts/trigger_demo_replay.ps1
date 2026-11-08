# ==============================================================================
# Fiscalia - Disparo Rapido do Modo Replay / Backfill de Embeddings (PowerShell)
# Uso:
#   .\scripts\trigger_demo_replay.ps1                        # Replay padrao
#   .\scripts\trigger_demo_replay.ps1 -Action backfill_embeddings
#   .\scripts\trigger_demo_replay.ps1 -ActNumber "IN RFB 2.255/2026"
# ==============================================================================
param(
    [ValidateSet("replay", "backfill_embeddings", "live")]
    [string]$Action = "replay",
    [string]$ActNumber = "",
    [string]$BaseUrl = "http://localhost:5678"
)

$ErrorActionPreference = "Stop"

$bodyObj = @{ action = $Action }
if ($ActNumber -ne "") {
    $bodyObj.act_number = $ActNumber
}
$jsonBody = $bodyObj | ConvertTo-Json -Compress

Write-Host "Disparando POST $BaseUrl/webhook/simular-dou com payload: $jsonBody" -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "$BaseUrl/webhook/simular-dou" -Method Post -ContentType "application/json" -Body $jsonBody
$response | ConvertTo-Json -Depth 6
