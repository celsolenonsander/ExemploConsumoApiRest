@echo off
setlocal

echo ===========================================
echo   INTIMA DIGITAL CMD DEMO
echo ===========================================

set BIN_PATH=%~dp0bin
set EXE_FILE=%BIN_PATH%\IntimaDigital.CmdDemo.exe

if not exist "%EXE_FILE%" (
    echo.
    echo ERRO: Executavel nao encontrado!
    echo.
    echo Execute primeiro: build.bat
    echo.
    pause
    exit /b 1
)

echo.
echo Executando: IntimaDigital.CmdDemo.exe
echo.
cd /d "%BIN_PATH%"
"%EXE_FILE%"

if errorlevel 1 (
    echo.
    echo O programa foi encerrado com erro.
    pause
)