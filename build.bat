@echo off
setlocal enabledelayedexpansion

echo ===========================================
echo   BUILD INTIMA DIGITAL CMD DEMO
echo   Projeto: IntimaDigitalAPI
echo ===========================================

rem Configurações
set PROJECT_ROOT=%~dp0
set DELPHI_PATH=C:\Program Files (x86)\Embarcadero\Studio\20.0\bin
set DCC=%DELPHI_PATH%\dcc32.exe
set OUTPUT_PATH=%PROJECT_ROOT%bin
set CONFIG_PATH=%PROJECT_ROOT%config

rem Verificar se o Delphi está instalado
if not exist "%DCC%" (
    echo.
    echo ERRO: Compilador Delphi não encontrado em:
    echo %DCC%
    echo.
    echo Verifique se o Delphi está instalado corretamente.
    pause
    exit /b 1
)

echo.
echo Projeto: IntimaDigital.CmdDemo.dpr
echo Compilador: %DCC%
echo Saída: %OUTPUT_PATH%
echo.

rem Criar diretório de saída
if not exist "%OUTPUT_PATH%" (
    echo Criando diretório de saída...
    mkdir "%OUTPUT_PATH%"
)

rem Diretórios de include
set INCLUDE_FLAGS=-I"%PROJECT_ROOT%Core" -I"%PROJECT_ROOT%Models" -I"%PROJECT_ROOT%Services" -I"%PROJECT_ROOT%Utils"

echo Compilando...
"%DCC%" -B -CC -NSSystem;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;Winapi;System.Json;REST.Json %INCLUDE_FLAGS% -E"%OUTPUT_PATH%" "%PROJECT_ROOT%IntimaDigital.CmdDemo.dpr"

if errorlevel 1 (
    echo.
    echo ERRO na compilacao!
    echo.
    pause
    exit /b 1
)

echo.
echo Compilacao concluida com sucesso!
echo.

rem Copiar arquivos de configuração
echo Copiando arquivos de configuração...
if not exist "%OUTPUT_PATH%\config" mkdir "%OUTPUT_PATH%\config"

if exist "%CONFIG_PATH%\IntimaDigital.ini" (
    copy "%CONFIG_PATH%\IntimaDigital.ini" "%OUTPUT_PATH%\config\" >nul
    echo ✓ IntimaDigital.ini copiado
) else (
    echo ⚠ IntimaDigital.ini não encontrado em %CONFIG_PATH%
    echo Criando template de configuração...
    echo [API] > "%OUTPUT_PATH%\config\IntimaDigital.ini"
    echo BaseURL=https://api.hom.intimadigital.com.br/ >> "%OUTPUT_PATH%\config\IntimaDigital.ini"
    echo Username=SEU_USUARIO_AQUI >> "%OUTPUT_PATH%\config\IntimaDigital.ini"
    echo Password=SUA_SENHA_AQUI >> "%OUTPUT_PATH%\config\IntimaDigital.ini"
    echo Environment=0 >> "%OUTPUT_PATH%\config\IntimaDigital.ini"
    echo ✓ Template criado em %OUTPUT_PATH%\config\IntimaDigital.ini
)

rem Copiar template se existir
if exist "%CONFIG_PATH%\IntimaDigital.ini.template" (
    copy "%CONFIG_PATH%\IntimaDigital.ini.template" "%OUTPUT_PATH%\config\" >nul
    echo ✓ Template copiado
)

echo.
echo ===========================================
echo   BUILD CONCLUIDO!
echo ===========================================
echo.
echo Executavel: %OUTPUT_PATH%\IntimaDigital.CmdDemo.exe
echo.
echo Para executar:
echo 1. Edite o arquivo: %OUTPUT_PATH%\config\IntimaDigital.ini
echo 2. Configure seu usuario e senha
echo 3. Execute: %OUTPUT_PATH%\IntimaDigital.CmdDemo.exe
echo.
pause