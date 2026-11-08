# ==============================================================================
# Fiscalia - Ponte Local para Telegram (@brfiscaliabot -> n8n Webhook Local)
# Permite conversar com o bot no Telegram sem precisar de ngrok / tunel HTTPS!
# Uso:
#   .\scripts\telegram_bridge.ps1
# ==============================================================================
param(
    [string]$WebhookUrl = "http://localhost:5678/webhook/fiscalia-telegram"
)

$ErrorActionPreference = "Stop"

# Carrega TELEGRAM_BOT_TOKEN do arquivo .env se existir
$BotToken = $env:TELEGRAM_BOT_TOKEN
if (-not $BotToken -and (Test-Path ".\.env")) {
    $line = Get-Content ".\.env" | Where-Object { $_ -match "^TELEGRAM_BOT_TOKEN=(.+)$" } | Select-Object -First 1
    if ($line -match "^TELEGRAM_BOT_TOKEN=(.+)$") {
        $BotToken = $Matches[1].Trim()
    }
}

if (-not $BotToken -or $BotToken -eq "your_telegram_bot_token_here") {
    throw "TELEGRAM_BOT_TOKEN nao encontrado no .env"
}

$me = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getMe" -Method Get
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Fiscalia Telegram Bridge Ativo!" -ForegroundColor Green
Write-Host " Bot conectado: @$($me.result.username) ($($me.result.first_name))" -ForegroundColor Cyan
Write-Host " Encaminhando mensagens para: $WebhookUrl" -ForegroundColor Cyan
Write-Host " Envie '/setores', '/resumo' ou uma pergunta no Telegram!" -ForegroundColor Yellow
Write-Host " (Pressione Ctrl+C para encerrar)" -ForegroundColor Gray
Write-Host "============================================================" -ForegroundColor Cyan

# Garante que nao ha webhook antigo bloqueando o getUpdates
Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/deleteWebhook" -Method Post | Out-Null

$offset = 0
while ($true) {
    try {
        $updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getUpdates?offset=$offset&timeout=25" -Method Get -TimeoutSec 35
        foreach ($upd in $updates.result) {
            $offset = [int64]$upd.update_id + 1
            if ($upd.message -and $upd.message.text) {
                $user = $upd.message.from.first_name
                $text = $upd.message.text
                $chatId = $upd.message.chat.id
                Write-Host "[Telegram -> n8n] ($user | chat_id=$chatId): $text" -ForegroundColor Yellow

                $payload = $upd | ConvertTo-Json -Depth 10 -Compress
                try {
                    $resp = Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType "application/json; charset=utf-8" -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) -TimeoutSec 60
                    Write-Host "[n8n -> Telegram] Resposta processada com sucesso!" -ForegroundColor Green
                } catch {
                    Write-Host "[Erro no Webhook n8n] $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}
