# build-msbuild.ps1
# Compila usando MSBuild (recomendado para Delphi moderno)

param(
    [string]$Configuration = "Release",
    [string]$Platform = "Win32"
)

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "   INTIMA DIGITAL - BUILD COM MSBUILD" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host

# Configurações
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectFile = Join-Path $ProjectRoot "IntimaDigital.CmdDemo.dproj"
$OutputPath = Join-Path $ProjectRoot "bin"
$MSBuildPath = "C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\MSBuild.exe"

# Verificar se o MSBuild existe
if (-not (Test-Path $MSBuildPath)) {
    Write-Host "ERRO: MSBuild não encontrado em:" -ForegroundColor Red
    Write-Host $MSBuildPath -ForegroundColor Red
    Write-Host "Verifique a instalação do Delphi." -ForegroundColor Red
    exit 1
}

# Verificar se o projeto existe
if (-not (Test-Path $ProjectFile)) {
    Write-Host "ERRO: Projeto não encontrado:" -ForegroundColor Red
    Write-Host $ProjectFile -ForegroundColor Red
    exit 1
}

Write-Host "Projeto: $ProjectFile" -ForegroundColor Yellow
Write-Host "Configuração: $Configuration" -ForegroundColor Yellow
Write-Host "Plataforma: $Platform" -ForegroundColor Yellow
Write-Host "Saída: $OutputPath" -ForegroundColor Yellow
Write-Host

# Comando MSBuild
$MSBuildArgs = @(
    "$ProjectFile",
    "/t:Build",
    "/p:Config=$Configuration",
    "/p:Platform=$Platform",
    "/p:DCC_ExeOutput=$OutputPath",
    "/verbosity:minimal"
)

Write-Host "Compilando..." -ForegroundColor Green
& $MSBuildPath $MSBuildArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Compilação concluída com sucesso!" -ForegroundColor Green
    
    # Copiar configurações
    $ConfigSource = Join-Path $ProjectRoot "config"
    $ConfigDest = Join-Path $OutputPath "config"
    
    if (Test-Path $ConfigSource) {
        if (-not (Test-Path $ConfigDest)) {
            New-Item -ItemType Directory -Path $ConfigDest | Out-Null
        }
        
        Copy-Item "$ConfigSource\*" $ConfigDest -Recurse -Force
        Write-Host "✓ Arquivos de configuração copiados" -ForegroundColor Green
    }
    
    $ExePath = Join-Path $OutputPath "IntimaDigital.CmdDemo.exe"
    Write-Host "`nExecutável: $ExePath" -ForegroundColor Cyan
    
    # Verificar se o executável foi criado
    if (Test-Path $ExePath) {
        $FileInfo = Get-Item $ExePath
        Write-Host "Tamanho: $([math]::Round($FileInfo.Length/1KB, 2)) KB" -ForegroundColor Cyan
        Write-Host "Data: $($FileInfo.LastWriteTime)" -ForegroundColor Cyan
    }
    
    Write-Host "`nPara executar:" -ForegroundColor Yellow
    Write-Host "cd ""$OutputPath""" -ForegroundColor White
    Write-Host ".\IntimaDigital.CmdDemo.exe" -ForegroundColor White
    
} else {
    Write-Host "`n✗ ERRO na compilação!" -ForegroundColor Red
    exit 1
}