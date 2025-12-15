program IntimaDigital.CmdDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Net.HttpClient,
  System.DateUtils,
  System.Types,
  WinAPI.Windows,
  System.IOUtils,
  IntimaDigital.Types in 'Core\IntimaDigital.Types.pas',
  IntimaDigital.Config in 'Core\IntimaDigital.Config.pas',
  IntimaDigital.Client in 'Core\IntimaDigital.Client.pas',
  IntimaDigital.Utils in 'Utils\IntimaDigital.Utils.pas',
  IntimaDigital.Logger in 'Utils\IntimaDigital.Logger.pas',
  IntimaDigital.Models.Base in 'Models\IntimaDigital.Models.Base.pas',
  IntimaDigital.Models.History in 'Models\IntimaDigital.Models.History.pas',
  IntimaDigital.Models.Log in 'Models\IntimaDigital.Models.Log.pas',
  IntimaDigital.Models.Notification in 'Models\IntimaDigital.Models.Notification.pas',
  IntimaDigital.Models.Contact in 'Models\IntimaDigital.Models.Contact.pas',
  IntimaDigital.Models.Other in 'Models\IntimaDigital.Models.Other.pas',
  IntimaDigital.Auth.Service in 'Services\IntimaDigital.Auth.Service.pas',
  IntimaDigital.History.Service in 'Services\IntimaDigital.History.Service.pas',
  IntimaDigital.Notification.Service in 'Services\IntimaDigital.Notification.Service.pas',
  IntimaDigital.Utils.Demo in 'Utils\IntimaDigital.Utils.Demo.pas',
  IntimaDigital.Utils.TokenInfo in 'Utils\IntimaDigital.Utils.TokenInfo.pas',
  IntimaDigital.APIDebugLog in 'Utils\IntimaDigital.APIDebugLog.pas',
  IntimaDigital.Utils.HeadersHTTP in 'Utils\IntimaDigital.Utils.HeadersHTTP.pas',
  IntimaDigital.Utils.JSon in 'Utils\IntimaDigital.Utils.JSon.pas';

const
  FOREGROUND_BLUE       = $0001;
  FOREGROUND_GREEN      = $0002;
  FOREGROUND_RED        = $0004;
  FOREGROUND_INTENSITY  = $0008;

  FOREGROUND_CYAN       = FOREGROUND_BLUE or FOREGROUND_GREEN;
  FOREGROUND_MAGENTA    = FOREGROUND_BLUE or FOREGROUND_RED;
  FOREGROUND_YELLOW     = FOREGROUND_RED or FOREGROUND_GREEN;
  FOREGROUND_WHITE      = FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE;

var
  Demo: TIntimaDigitalDemo;
  Opcao: Integer;
  BaseURL, Username: string;

procedure SetConsoleColor(Color: Word);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), Color);
end;

procedure ResetConsoleColor;
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE);
end;

procedure PrintHeader;
begin
  SetConsoleColor(FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  Writeln('╔══════════════════════════════════════════════════════════╗');
  Writeln('║                INTIMA DIGITAL API                        ║');
  Writeln('║                 DEMO CONSOLE v1.0.0                      ║');
  Writeln('║        ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + '                    ║');
  Writeln('╚══════════════════════════════════════════════════════════╝');
  ResetConsoleColor;
  Writeln;
end;

procedure PrintMenu;
begin
  SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
  Writeln('┌──────────────────────────────────────────────────────────┐');
  Writeln('│                      MENU PRINCIPAL                      │');
  Writeln('├──────────────────────────────────────────────────────────┤');
  ResetConsoleColor;

  SetConsoleColor(FOREGROUND_WHITE);
  Writeln('│ 1.  Configurar API                                     │');
  Writeln('│ 2.  Autenticar                                         │');
  Writeln('│ 3.  Renovar Token                                      │');
  Writeln('│ 4.  Buscar Histórico de Acessos                        │');
  Writeln('│ 5.  Enviar Notificação/Intimação                       │');
  Writeln('│ 6.  Buscar Relatório de Notificações                   │');
  Writeln('│ 7.  Testar Modelos JSON                                │');
  Writeln('│ 8.  Limpar Configuração                                │');
  Writeln('│ 9.  Status da Conexão                                  │');
  Writeln('│ 10. Testar Validação CPF/CNPJ                          │');
  Writeln('│ 11. Testar Base64                                      │');
  Writeln('│ 12. Testar Conexão com API                             │');
  Writeln('│ 13. Exibir Logs Salvos                                 │');
  Writeln('│ 0.  Sair                                               │');

  SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
  Writeln('└──────────────────────────────────────────────────────────┘');
  ResetConsoleColor;
  Writeln;
end;

procedure PrintSection(const Title: string);
var
  TracoCount: Integer;
begin
  Writeln;
  SetConsoleColor(FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  TracoCount := 60 - Length(Title);
  Writeln('┌─ ' + UpperCase(Title) + ' ' + StringOfChar('─', TracoCount) + '┐');
  ResetConsoleColor;
end;

procedure PrintEndSection;
begin
  SetConsoleColor(FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  Writeln('└' + StringOfChar('─', 62) + '┘');
  ResetConsoleColor;
  Writeln;
end;

function LerSenhaOculta(const Prompt: string): string;
var
  Ch: Char;
  Senha: string;
begin
  Write(Prompt);
  Senha := '';

  Flush(Input);

  repeat
    Read(Ch);

    if Ch = #13 then
      Break;

    if Ch = #8 then
    begin
      if Length(Senha) > 0 then
      begin
        Delete(Senha, Length(Senha), 1);
        Write(#8 + ' ' + #8);
      end;
    end
    else
    begin
      Senha := Senha + Ch;
      Write('*');
    end;
  until False;

  Writeln;
  Result := Senha;
end;

procedure ConfigurarAPI;
var
  SenhaOculta: string;
begin
  PrintSection('CONFIGURAÇÃO DA API');

  SetConsoleColor(FOREGROUND_GREEN);
  Writeln('ℹ  Informe os dados de acesso à API:');
  ResetConsoleColor;
  Writeln;

  Write('  URL Base [', Demo.Config.BaseURL, ']: ');
  Readln(BaseURL);

  if BaseURL.IsEmpty then
    BaseURL := Demo.Config.BaseURL;

  repeat
    Write('  Usuário: ');
    Readln(Username);

    if Username.IsEmpty then
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Usuário é obrigatório!');
      ResetConsoleColor;
    end;
  until not Username.IsEmpty;

  repeat
    SenhaOculta := LerSenhaOculta('  Senha: ');

    if SenhaOculta.IsEmpty then
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Senha é obrigatória!');
      ResetConsoleColor;
    end;
  until not SenhaOculta.IsEmpty;

  try
    Demo.ConfigurarAPI(BaseURL, Username, SenhaOculta);
    SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    Writeln('  ✓ Configuração salva com sucesso!');
    ResetConsoleColor;

    Writeln;
    SetConsoleColor(FOREGROUND_CYAN);
    Writeln('  Configuração atual:');
    Writeln('  • URL Base: ', BaseURL);
    Writeln('  • Usuário: ', Username);
    Writeln('  • Senha: ', StringOfChar('*', SenhaOculta.Length));
    ResetConsoleColor;

  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro ao salvar configuração: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure Autenticar;
var
  TempoRestante: Integer;
begin
  PrintSection('AUTENTICAÇÃO');

  if Demo.Config.Username.IsEmpty or Demo.Config.Password.IsEmpty then
  begin
    SetConsoleColor(FOREGROUND_YELLOW);
    Writeln('⚠  Configure a API primeiro (opção 1)');
    ResetConsoleColor;
    PrintEndSection;
    Exit;
  end;

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Autenticando com usuário: ', Demo.Config.Username);
  ResetConsoleColor;
  Writeln;

  try
    if Demo.Autenticar then
    begin
      SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
      Writeln('  ✓ Autenticado com sucesso!');
      ResetConsoleColor;

      Writeln;
      SetConsoleColor(FOREGROUND_CYAN);
      Writeln('  Informações da sessão:');
      Writeln('  • Token: ', Copy(Demo.Config.Token, 1, 20), '...');
      Writeln('  • Expira em: ', FormatDateTime('dd/mm/yyyy hh:nn:ss', Demo.Config.TokenExpiration));
      Writeln('  • Token Info: ', TJWTHelper.DecodeToken(Demo.Config.Token).ToString);
      TempoRestante := SecondsBetween(Now, Demo.Config.TokenExpiration) div 60;
      Writeln('  • Tempo restante: ', TempoRestante, ' minutos');
      ResetConsoleColor;
    end
    else
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Falha na autenticação');
      ResetConsoleColor;
    end;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro durante autenticação: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure RenovarToken;
begin
  PrintSection('RENOVAÇÃO DE TOKEN');

  if not Demo.Config.IsAuthenticated then
  begin
    SetConsoleColor(FOREGROUND_YELLOW);
    Writeln('⚠  Faça autenticação primeiro (opção 2)');
    ResetConsoleColor;
    PrintEndSection;
    Exit;
  end;

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Token atual expira em: ', FormatDateTime('dd/mm/yyyy hh:nn:ss', Demo.Config.TokenExpiration));
  Writeln('ℹ  Tentando renovar token...');
  ResetConsoleColor;
  Writeln;

  try
    if Demo.RefreshToken then
    begin
      SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
      Writeln('  ✓ Token renovado com sucesso!');
      ResetConsoleColor;

      Writeln;
      SetConsoleColor(FOREGROUND_CYAN);
      Writeln('  Novo token expira em: ', FormatDateTime('dd/mm/yyyy hh:nn:ss', Demo.Config.TokenExpiration));
      ResetConsoleColor;
    end
    else
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Falha ao renovar token');
      ResetConsoleColor;
    end;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro ao renovar token: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure BuscarHistorico;
begin
  PrintSection('HISTÓRICO DE ACESSOS');

  if not Demo.Config.IsAuthenticated then
  begin
    SetConsoleColor(FOREGROUND_YELLOW);
    Writeln('⚠  Faça autenticação primeiro (opção 2)');
    ResetConsoleColor;
    PrintEndSection;
    Exit;
  end;

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Buscando histórico de acessos...');
  ResetConsoleColor;

  try
    Demo.DemoHistoryReport;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro ao buscar histórico: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure EnviarNotificacao;
begin
  PrintSection('ENVIO DE NOTIFICAÇÃO');

  if not Demo.Config.IsAuthenticated then
  begin
    SetConsoleColor(FOREGROUND_YELLOW);
    Writeln('⚠  Faça autenticação primeiro (opção 2)');
    ResetConsoleColor;
    PrintEndSection;
    Exit;
  end;

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Criando notificação de demonstração...');
  ResetConsoleColor;
  Writeln;

  try
    Demo.DemoUploadNotification;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro ao enviar notificação: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure BuscarNotificacoes;
begin
  PrintSection('RELATÓRIO DE NOTIFICAÇÕES');

  if not Demo.Config.IsAuthenticated then
  begin
    SetConsoleColor(FOREGROUND_YELLOW);
    Writeln('⚠  Faça autenticação primeiro (opção 2)');
    ResetConsoleColor;
    PrintEndSection;
    Exit;
  end;

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Buscando relatório de notificações...');
  ResetConsoleColor;

  try
    Demo.DemoNotificationContactsReport;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro ao buscar notificações: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure TestarModelosJSON;
begin
  PrintSection('TESTE DE MODELOS JSON');

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Testando serialização dos modelos...');
  ResetConsoleColor;

  try
    Demo.DemoTestModels;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro nos testes: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure LimparConfiguracao;
var
  Resposta: string;
begin
  PrintSection('LIMPAR CONFIGURAÇÃO');

  SetConsoleColor(FOREGROUND_YELLOW);
  Writeln('⚠  ATENÇÃO: Esta ação irá remover todas as configurações!');
  Writeln;
  Write('  Tem certeza que deseja continuar? (S/N): ');
  ResetConsoleColor;

  Readln(Resposta);

  if UpperCase(Resposta) = 'S' then
  begin
    try
      Demo.Config.ClearAuth;
      Demo.Config.SaveToIni;

      SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
      Writeln('  ✓ Configuração limpa com sucesso!');
      ResetConsoleColor;
    except
      on E: Exception do
      begin
        SetConsoleColor(FOREGROUND_RED);
        Writeln('  ✗ Erro ao limpar configuração: ', E.Message);
        ResetConsoleColor;
      end;
    end;
  end
  else
  begin
    SetConsoleColor(FOREGROUND_CYAN);
    Writeln('  Operação cancelada.');
    ResetConsoleColor;
  end;

  PrintEndSection;
end;

procedure StatusConexao;
begin
  PrintSection('STATUS DA CONEXÃO');

  try
    Demo.DemoStatusConexao;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro ao verificar status: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure TestarValidacaoCPFCNPJ;
begin
  PrintSection('VALIDAÇÃO CPF/CNPJ');

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Testando validação e formatação de documentos...');
  ResetConsoleColor;

  try
    Demo.DemoValidacaoDocumentos;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro nos testes: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure TestarBase64;
begin
  PrintSection('TESTE BASE64');

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Testando codificação e decodificação Base64...');
  ResetConsoleColor;

  try
    Demo.DemoBase64;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro nos testes: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure TestarConexaoAPI;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
begin
  PrintSection('TESTE DE CONEXÃO COM API');

  SetConsoleColor(FOREGROUND_CYAN);
  Writeln('ℹ  Testando conexão com a API...');
  ResetConsoleColor;
  Writeln;

  if Demo.Config.BaseURL.IsEmpty then
  begin
    SetConsoleColor(FOREGROUND_YELLOW);
    Writeln('  ⚠  URL Base não configurada.');
    ResetConsoleColor;
    PrintEndSection;
    Exit;
  end;

  try
    HttpClient := THTTPClient.Create;
    try
      SetConsoleColor(FOREGROUND_CYAN);
      Writeln('  Conectando em: ', Demo.Config.BaseURL);
      ResetConsoleColor;

      Response := HttpClient.Get(Demo.Config.BaseURL + '/health');

      if Response.StatusCode = 200 then
      begin
        SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
        Writeln('  ✓ Conexão estabelecida com sucesso!');
        Writeln('  Status: ', Response.StatusCode, ' - ', Response.StatusText);
        ResetConsoleColor;
      end
      else
      begin
        SetConsoleColor(FOREGROUND_YELLOW);
        Writeln('  ⚠  API respondeu com status: ', Response.StatusCode);
        Writeln('  Mensagem: ', Response.StatusText);
        ResetConsoleColor;
      end;
    finally
      HttpClient.Free;
    end;
  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln('  ✗ Erro na conexão: ', E.Message);
      ResetConsoleColor;
    end;
  end;

  PrintEndSection;
end;

procedure ExibirLogsSalvos;
//var
//  LogPath: String;
//  Arquivos: TStringList;
//  I: Integer;
//  FilePath: String;
//  Escolha: Integer;
//  LogContent: TStringList;
//  J: Integer;
//  SearchOption: TSearchOption;
//  Files: TStringDynArray;
//  F: TFileStream;
//  FileInfo: TSearchRec;
begin
//  PrintSection('LOGS SALVOS');
//
//  LogPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'logs\';
//
//  if not DirectoryExists(LogPath) then
//  begin
//    SetConsoleColor(FOREGROUND_YELLOW);
//    Writeln('  ⚠  Diretório de logs não encontrado: ', LogPath);
//    ResetConsoleColor;
//    PrintEndSection;
//    Exit;
//  end;
//
//  try
//    Arquivos := TStringList.Create;
//    LogContent := TStringList.Create;
//    try
//      // Usar FindFirst/FindNext para listar arquivos (compatível com versões antigas)
//      if FindFirst(LogPath + '*.log', faAnyFile, FileInfo) = 0 then
//      begin
//        repeat
//          if (FileInfo.Name <> '.') and (FileInfo.Name <> '..') then
//          begin
//            Arquivos.Add(FileInfo.Name);
//          end;
//        until FindNext(FileInfo) <> 0;
//        FindClose(FileInfo);
//      end;
//
//      if Arquivos.Count = 0 then
//      begin
//        SetConsoleColor(FOREGROUND_YELLOW);
//        Writeln('  ⚠  Nenhum arquivo de log encontrado.');
//        ResetConsoleColor;
//      end
//      else
//      begin
//        SetConsoleColor(FOREGROUND_CYAN);
//        Writeln('  Arquivos de log encontrados (', Arquivos.Count, '):');
//        ResetConsoleColor;
//        Writeln;
//
//        for I := 0 to Arquivos.Count - 1 do
//        begin
//          FilePath := LogPath + Arquivos[I];
//
//          Writeln('  ', I + 1, '. ', Arquivos[I]);
//          try
//            // Obter informações do arquivo usando FileAge e FileSize
//            if FileAge(FilePath, FileInfo.Time) then
//            begin
//              F := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
//              try
//                Writeln('     Tamanho: ', (F.Size div 1024), ' KB');
//              finally
//                F.Free;
//              end;
//              Writeln('     Modificado: ', DateTimeToStr(FileDateToDateTime(FileInfo.Time)));
//            end;
//          except
//            on E: Exception do
//            begin
//              Writeln('     Erro ao obter informações do arquivo');
//            end;
//          end;
//          Writeln;
//        end;
//
//        Writeln;
//        Write('  Deseja visualizar algum arquivo? (número ou 0 para cancelar): ');
//        Readln(Escolha);
//
//        if (Escolha > 0) and (Escolha <= Arquivos.Count) then
//        begin
//          Writeln;
//          SetConsoleColor(FOREGROUND_CYAN);
//          Writeln('  Conteúdo do arquivo: ', Arquivos[Escolha - 1]);
//          ResetConsoleColor;
//          Writeln(StringOfChar('─', 80));
//
//          try
//            LogContent.LoadFromFile(LogPath + Arquivos[Escolha - 1]);
//            for J := 0 to LogContent.Count - 1 do
//            begin
//              // Colorir baseado no nível de log
//              if Pos('[ERROR]', LogContent[J]) > 0 then
//                SetConsoleColor(FOREGROUND_RED)
//              else if Pos('[WARN]', LogContent[J]) > 0 then
//                SetConsoleColor(FOREGROUND_YELLOW)
//              else if Pos('[INFO]', LogContent[J]) > 0 then
//                SetConsoleColor(FOREGROUND_GREEN)
//              else if Pos('[DEBUG]', LogContent[J]) > 0 then
//                SetConsoleColor(FOREGROUND_BLUE)
//              else
//                ResetConsoleColor;
//
//              Writeln('  ', LogContent[J]);
//            end;
//          except
//            on E: Exception do
//            begin
//              SetConsoleColor(FOREGROUND_RED);
//              Writeln('  Erro ao carregar arquivo: ', E.Message);
//              ResetConsoleColor;
//            end;
//          end;
//
//          ResetConsoleColor;
//          Writeln(StringOfChar('─', 80));
//        end;
//      end;
//
//    finally
//      LogContent.Free;
//      Arquivos.Free;
//    end;
//  except
//    on E: Exception do
//    begin
//      SetConsoleColor(FOREGROUND_RED);
//      Writeln('  ✗ Erro ao listar logs: ', E.Message);
//      ResetConsoleColor;
//    end;
//  end;
//
//  PrintEndSection;
end;

procedure Despedida;
begin
  Writeln;
  SetConsoleColor(FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  Writeln('╔══════════════════════════════════════════════════════════╗');
  Writeln('║                OBRIGADO POR UTILIZAR                     ║');
  Writeln('║                INTIMA DIGITAL API                        ║');
  Writeln('║                                                          ║');
  Writeln('║                Até logo!                                 ║');
  Writeln('╚══════════════════════════════════════════════════════════╝');
  ResetConsoleColor;
  Sleep(3000);
  Writeln;
end;

begin
  try
    SetConsoleOutputCP(CP_UTF8);

    TIntimaDigitalLogger.Instance.SetLogLevel(llInfo);
    TIntimaDigitalLogger.Instance.EnableTimestamp(True);
    TIntimaDigitalLogger.Instance.EnableFileLogging(True);

    Demo := TIntimaDigitalDemo.Create;
    try
      PrintHeader;

      LogInfo('Intima Digital Console Demo iniciado');
      LogInfo('Diretório atual: %s', [GetCurrentDir]);
      LogInfo('Arquivo de configuração: %s', [Demo.Config.FileName]);

      repeat
        PrintMenu;

        SetConsoleColor(FOREGROUND_GREEN or FOREGROUND_INTENSITY);
        Write('» Escolha uma opção: ');
        ResetConsoleColor;

        try
          Readln(Opcao);
        except
          Opcao := -1;
        end;

        LogDebug('Opção selecionada: %d', [Opcao]);

        case Opcao of
          1:  ConfigurarAPI;
          2:  Autenticar;
          3:  RenovarToken;
          4:  BuscarHistorico;
          5:  EnviarNotificacao;
          6:  BuscarNotificacoes;
          7:  TestarModelosJSON;
          8:  LimparConfiguracao;
          9:  StatusConexao;
          10: TestarValidacaoCPFCNPJ;
          11: TestarBase64;
          12: TestarConexaoAPI;
          13: ExibirLogsSalvos;
          0:  begin
                LogInfo('Encerrando aplicação...');
                Despedida;
              end;
        else
          SetConsoleColor(FOREGROUND_RED);
          Writeln('  ✗ Opção inválida! Tente novamente.');
          ResetConsoleColor;
        end;

        if Opcao <> 0 then
        begin
          Writeln;
          SetConsoleColor(FOREGROUND_CYAN);
          Write('  Pressione Enter para continuar...');
          ResetConsoleColor;
          Readln;
          Writeln;
        end;

      until Opcao = 0;

    finally
      LogInfo('Liberando recursos...');
      Demo.Free;
      LogInfo('Aplicação encerrada com sucesso');
    end;

  except
    on E: Exception do
    begin
      SetConsoleColor(FOREGROUND_RED);
      Writeln;
      Writeln('╔══════════════════════════════════════════════════════════╗');
      Writeln('║                    ERRO FATAL                            ║');
      Writeln('╠══════════════════════════════════════════════════════════╣');
      Writeln('║ ' + Format('%-58s', [E.Message]) + ' ║');
      Writeln('║ Classe: ' + Format('%-49s', [E.ClassName]) + ' ║');
      Writeln('╚══════════════════════════════════════════════════════════╝');
      ResetConsoleColor;

      Writeln;
      Write('Pressione Enter para sair...');
      Readln;
    end;
  end;
end.
