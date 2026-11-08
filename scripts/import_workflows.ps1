# ==============================================================================
# Fiscalia - Importacao Automatizada dos 3 Workflows no Container n8n (PowerShell)
# ==============================================================================
param(
    [string]$ContainerName = "fiscalia-n8n"
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Fiscalia - Importando Workflows no container: $ContainerName" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$running = docker inspect -f "{{.State.Running}}" $ContainerName 2>$null
if ($running -ne "true") {
    throw "O container '$ContainerName' nao esta em execucao. Rode 'docker compose up -d' primeiro."
}

$workflows = @(
    "/workflows/03_agent_tools_subworkflow.json",
    "/workflows/01_push_dou_monitor.json",
    "/workflows/02_pull_tax_agent.json"
)

foreach ($wf in $workflows) {
    Write-Host "-> Importando $wf..." -ForegroundColor Yellow
    docker exec -u node $ContainerName n8n import:workflow --input="$wf"
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao importar $wf no container $ContainerName."
    }
}

Write-Host ""
Write-Host "Todos os 3 workflows foram importados com sucesso!" -ForegroundColor Green
Write-Host "Acesse http://localhost:5678 para visualizar e ativar os fluxos no n8n." -ForegroundColor Cyan
