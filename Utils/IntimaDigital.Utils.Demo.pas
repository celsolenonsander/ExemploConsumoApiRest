unit IntimaDigital.Utils.Demo;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.DateUtils,
  System.IOUtils,
  {$IFNDEF CONSOLE}
  Vcl.Dialogs,
  Vcl.StdCtrls,
  {$ENDIF}
  IntimaDigital.Types,
  IntimaDigital.Config,
  IntimaDigital.Client,
  IntimaDigital.Auth.Service,
  IntimaDigital.History.Service,
  IntimaDigital.Notification.Service,
  IntimaDigital.Models.History,
  IntimaDigital.Models.Notification,
  IntimaDigital.Models.Contact,
  IntimaDigital.Models.Log,
  IntimaDigital.Models.Other,
  IntimaDigital.Utils,
  IntimaDigital.Logger;

type
  TIntimaDigitalDemo = class
  private
    FConfig: TIntimaDigitalConfig;
    FClient: TIntimaDigitalClient;
    FAuthService: TIntimaDigitalAuthService;
    FHistoryService: TIntimaDigitalHistoryService;
    FNotificationService: TIntimaDigitalNotificationService;

    {$IFNDEF CONSOLE}
    FLogMemo: TObject;
    procedure SetLogMemo(const Value: TObject);
    {$ENDIF}
    procedure Initialize;
  public
    {$IFDEF CONSOLE}
    constructor Create;
    {$ELSE}
    constructor Create(LogMemo: TObject = nil);
    {$ENDIF}

    destructor Destroy; override;

    procedure ConfigurarAPI(const ABaseURL, AUsername, APassword: string);
    function Autenticar: Boolean;
    function RefreshToken: Boolean;
    procedure Desconectar;

    procedure DemoHistoryReport;
    procedure DemoUploadNotification;
    procedure DemoNotificationContactsReport;

    procedure DemoTestModels;
    procedure DemoValidacaoDocumentos;
    procedure DemoBase64;
    procedure DemoStatusConexao;

    property Config: TIntimaDigitalConfig read FConfig;
    property AuthService: TIntimaDigitalAuthService read FAuthService;
    property HistoryService: TIntimaDigitalHistoryService read FHistoryService;
    property NotificationService: TIntimaDigitalNotificationService read FNotificationService;

    {$IFNDEF CONSOLE}
    property LogMemo: TObject read FLogMemo write SetLogMemo;
    {$ENDIF}
  end;

implementation

{ TIntimaDigitalDemo }

{$IFDEF CONSOLE}
constructor TIntimaDigitalDemo.Create;
begin
  TIntimaDigitalLogger.Instance.EnableTimestamp(True);
  TIntimaDigitalLogger.Instance.SetLogLevel(llInfo);

  Initialize;
end;
{$ELSE}
constructor TIntimaDigitalDemo.Create(LogMemo: TObject = nil);
begin
  FLogMemo := LogMemo;

  if Assigned(FLogMemo) and (FLogMemo is TMemo) then
    TIntimaDigitalLogger.Instance.SetMemo(TMemo(FLogMemo));

  TIntimaDigitalLogger.Instance.EnableTimestamp(True);
  TIntimaDigitalLogger.Instance.SetLogLevel(llInfo);

  Initialize;
end;

procedure TIntimaDigitalDemo.SetLogMemo(const Value: TObject);
begin
  FLogMemo := Value;
  if Assigned(FLogMemo) and (FLogMemo is TMemo) then
    TIntimaDigitalLogger.Instance.SetMemo(TMemo(FLogMemo));
end;
{$ENDIF}

procedure TIntimaDigitalDemo.Initialize;
begin
  FConfig := TIntimaDigitalConfig.Create;
  FConfig.LoadFromIni;

  FClient := TIntimaDigitalClient.Create(FConfig);

  FAuthService := TIntimaDigitalAuthService.Create(FClient, FConfig);
  FHistoryService := TIntimaDigitalHistoryService.Create(FClient);
  FNotificationService := TIntimaDigitalNotificationService.Create(FClient);

  LogInfo('TIntimaDigitalDemo inicializado');
  LogInfo('URL Base: %s', [FConfig.BaseURL]);
end;

destructor TIntimaDigitalDemo.Destroy;
begin
  LogDebug('Destruindo TIntimaDigitalDemo...');

  FNotificationService.Free;
  FHistoryService.Free;
  FAuthService.Free;
  FClient.Free;
  FConfig.Free;

  inherited;
end;

function TIntimaDigitalDemo.Autenticar: Boolean;
var
  Response: TIDApiResponse<Boolean>;
begin
  if FConfig.Username.IsEmpty or FConfig.Password.IsEmpty then
  begin
    LogError('Credenciais não configuradas. Use a opção 1 para configurar.');
    Exit(False);
  end;

  LogInfo('Autenticando com usuário: %s', [FConfig.Username]);

  Response := FAuthService.Authenticate(FConfig.Username, FConfig.Password);
  Result := Response.Success;

  if Result then
  begin
    LogInfo('Autenticação realizada com sucesso!');
    LogDebug('Token: %s', [Copy(FConfig.Token, 1, 20) + '...']);
    LogDebug('Refresh Token: %s', [Copy(FConfig.RefreshToken, 1, 20) + '...']);
    LogDebug('Expira em: %s', [DateTimeToStr(FConfig.TokenExpiration)]);
  end
  else
  begin
    LogError('Falha na autenticação: %s', [Response.ErrorMessage]);
  end;
end;

procedure TIntimaDigitalDemo.ConfigurarAPI(const ABaseURL, AUsername, APassword: string);
begin
  LogInfo('Configurando API...');
  LogDebug('URL: %s', [ABaseURL]);
  LogDebug('Usuário: %s', [AUsername]);

  FConfig.BaseURL := ABaseURL;
  FConfig.Username := AUsername;
  FConfig.Password := APassword;
  FConfig.SaveToIni;

  LogSuccess('Configuração salva com sucesso!');
end;

procedure TIntimaDigitalDemo.DemoBase64;
var
  TextoOriginal, TextoCodificado, TextoDecodificado: string;
  TestFilePath: string;
  File1, File2 :TBytes;
begin
  try
    LogInfo('Iniciando teste Base64...');

    TextoOriginal := 'Intima Digital API - Teste Base64';
    TextoCodificado := TIntimaDigitalUtils.EncodeBase64(TextoOriginal);
    TextoDecodificado := TIntimaDigitalUtils.DecodeBase64(TextoCodificado);

    LogInfo('Teste Base64 - Texto:');
    LogInfo('Original: %s', [TextoOriginal]);
    LogDebug('Codificado: %s', [TextoCodificado]);
    LogInfo('Decodificado: %s', [TextoDecodificado]);

    if TextoOriginal = TextoDecodificado then
      LogSuccess('Codificação/Decodificação bem-sucedida!')
    else
      LogError('Falha na codificação/decodificação');

    LogInfo('');

    TestFilePath := ExtractFilePath(ParamStr(0)) + 'test_base64.txt';
    LogInfo('Criando arquivo de teste: %s', [TestFilePath]);

    with TStringList.Create do
    try
      Text := 'Conteúdo de teste para Base64' + sLineBreak +
              'Linha 2' + sLineBreak +
              'Linha 3 - ' + DateTimeToStr(Now);
      SaveToFile(TestFilePath);
      LogDebug('Arquivo criado com %d bytes', [Length(Text)]);
    finally
      Free;
    end;

    TextoCodificado := TIntimaDigitalUtils.FileToBase64(TestFilePath);
    LogInfo('Arquivo para Base64 (primeiros 100 chars): %s...',
      [Copy(TextoCodificado, 1, 100)]);

    TextoDecodificado := ExtractFilePath(ParamStr(0)) + 'test_base64_decoded.txt';
    TIntimaDigitalUtils.Base64ToFile(TextoCodificado, TextoDecodificado);
    LogInfo('Arquivo decodificado criado: %s', [TextoDecodificado]);

    if FileExists(TestFilePath) and FileExists(TextoDecodificado) then
    begin
      File1 := TFile.ReadAllBytes(TestFilePath);
      File2 := TFile.ReadAllBytes(TextoDecodificado);
      if CompareMem(@File1[0], @File2[0], Length(File1)) then
        LogSuccess('Arquivos idênticos! Base64 funcionando corretamente.')
      else
        LogError('Arquivos diferentes!');
    end;

    if FileExists(TestFilePath) then
      DeleteFile(TestFilePath);
    if FileExists(TextoDecodificado) then
      DeleteFile(TextoDecodificado);

    LogSuccess('Teste Base64 concluído com sucesso!');

  except
    on E: Exception do
      LogError('Erro no teste Base64: %s', [E.Message]);
  end;
end;

procedure TIntimaDigitalDemo.DemoHistoryReport;
var
  Filter: THistoryFilter;
  Response: TIDApiResponse<THistoryResponse>;
  HistoryResponse: THistoryResponse;
  History: THistory;
  HistoryList: TObjectList<THistory>;
begin
  if not FConfig.IsAuthenticated then
  begin
    LogError('Não autenticado. Execute a autenticação primeiro.');
    Exit;
  end;

  Filter := THistoryFilter.Create;
  Filter.Page := 1;

  try
    LogInfo('Buscando histórico...');
    Response := FHistoryService.GetHistoryReport(Filter);

    if Response.Success and Assigned(Response.Data) then
    begin
      HistoryResponse := Response.Data;
      HistoryList := HistoryResponse.GetResultsList;
      try
        LogSuccess('Total de históricos: %d', [HistoryResponse.Count]);
        LogInfo('');

        if HistoryList.Count > 0 then
        begin
          LogInfo('Últimos históricos encontrados:');
          TIntimaDigitalLogger.Instance.Separator;

          for History in HistoryList do
          begin
            if HistoryList.IndexOf(History) >= 5 then
              Break;

            LogInfo('ID: %s', [Copy(History.Id, 1, 8)]);
            LogInfo('Nome: %s', [History.access_name]);
            LogInfo('Documento: %s', [History.access_document]);
            LogInfo('Data Acesso: %s', [DateTimeToStr(History.dt_link_access)]);
            LogInfo('IP: %s', [History.ip_adress]);
            TIntimaDigitalLogger.Instance.Separator;
          end;

          if HistoryList.Count > 5 then
            LogInfo('... e mais %d registros', [HistoryList.Count - 5]);
        end
        else
        begin
          LogWarning('Nenhum histórico encontrado para os filtros informados.');
        end;
      finally
        HistoryList.Free;
      end;
    end
    else
    begin
      LogError('Erro ao buscar histórico: %s', [Response.ErrorMessage]);
    end;
  finally
    if Assigned(Response.Data) then
      Response.Data.Free;
  end;
end;

procedure TIntimaDigitalDemo.DemoNotificationContactsReport;
var
  Filter: TNotificationFilter;
  Response: TIDApiResponse<TNotificationResponse>;
  NotificationResponse: TNotificationResponse;
  NotificationList: TObjectList<TNotification>;
  Notification: TNotification;
begin
  if not FConfig.IsAuthenticated then
  begin
    LogError('Não autenticado. Execute a autenticação primeiro.');
    Exit;
  end;

  Filter := TNotificationFilter.Create;

  try
    LogInfo('Buscando notificações...');
    Response := FNotificationService.GetNotificationContactsReport(Filter);

    if Response.Success and Assigned(Response.Data) then
    begin
      NotificationResponse := Response.Data;
      NotificationList := NotificationResponse.GetResultsList;
      try
        LogSuccess('Total de notificações: %d', [NotificationResponse.Count]);
        LogInfo('');

        if NotificationList.Count > 0 then
        begin
          LogInfo('Últimas notificações encontradas:');
          TIntimaDigitalLogger.Instance.Separator;

          for Notification in NotificationList do
          begin
            if NotificationList.IndexOf(Notification) >= 5 then
              Break;

            LogInfo('ID: %s', [Copy(Notification.Id, 1, 8)]);
            LogInfo('Nome: %s', [Notification.NotifiedName]);
            LogInfo('Documento: %s', [Notification.NotifiedDocumentNumber]);
            LogInfo('Protocolo: %s', [Notification.Protocol]);
            LogInfo('Tipo: %s', [Notification.NotificationType]);
            LogInfo('Criada em: %s', [DateTimeToStr(Notification.CreatedAt)]);
            TIntimaDigitalLogger.Instance.Separator;
          end;

          if NotificationList.Count > 5 then
            LogInfo('... e mais %d registros', [NotificationList.Count - 5]);
        end
        else
        begin
          LogWarning('Nenhuma notificação encontrada para os filtros informados.');
        end;
      finally
        NotificationList.Free;
      end;
    end
    else
    begin
      LogError('Erro ao buscar notificações: %s', [Response.ErrorMessage]);
    end;
  finally
    if Assigned(Response.Data) then
      Response.Data.Free;
  end;
end;

procedure TIntimaDigitalDemo.DemoStatusConexao;
begin
  TIntimaDigitalLogger.Instance.Section('Status da Conexão');

  LogInfo('URL Base: %s', [FConfig.BaseURL]);
  LogInfo('Usuário: %s', [FConfig.Username]);

  if FConfig.Environment = envProduction then
    LogInfo('Ambiente: Produção')
  else
    LogInfo('Ambiente: Homologação');

  LogInfo('Autenticado: %s', [BoolToStr(FConfig.IsAuthenticated, True)]);
  LogInfo('Token Expirado: %s', [BoolToStr(FConfig.IsTokenExpired, True)]);
  LogInfo('Timeout: %dms', [FConfig.Timeout]);
  LogInfo('Tentativas: %d', [FConfig.RetryCount]);

  if FConfig.IsAuthenticated then
    LogSuccess('Conexão ativa e autenticada')
  else
    LogError('Não autenticado');
end;

procedure TIntimaDigitalDemo.DemoTestModels;
var
  Contact: TContact;
  ContactJson: string;
  Notification: TApiNotification;
  NotificationJson: string;
  Log: TLog;
  LogJson: string;
begin
  try
    TIntimaDigitalLogger.Instance.Section('Teste de Modelos');

    LogInfo('Teste 1: Modelo de Contato');
    Contact := TContact.Create;
    try
      Contact.Name := 'Cliente Teste';
      Contact.Value := 'cliente.teste@empresa.com';
      Contact.ContactTypeEnum := ctEmail;
      Contact.Sent := False;
      Contact.IsActive := True;
      Contact.CreatedAt := Now;

      ContactJson := Contact.ToJson;
      LogDebug('JSON do Contato:');
      LogDebug(ContactJson);
    finally
      Contact.Free;
    end;

    LogInfo('');
    LogInfo('Teste 2: Modelo de Notificação');
    Notification := TApiNotification.Create;
    try
      Notification.Protocol := 'TEST' + FormatDateTime('YYYYMMDDHHNNSS', Now);
      Notification.DtProtocol := Now;
      Notification.NotifiedName := 'Notificado de Teste';
      Notification.NotifiedDocumentNumber := '12345678900';
      Notification.NotificationType := 'primary';
      Notification.DtLimit := IncDay(Now, 15);
      Notification.SendEmail := True;
      Notification.SendSms := True;
      Notification.SendWhatsapp := False;
      Notification.TimeStamp := False;

      NotificationJson := Notification.ToJson;
      LogDebug('JSON da Notificação:');
      LogDebug(NotificationJson);
    finally
      Notification.Free;
    end;

    LogInfo('');
    LogInfo('Teste 3: Modelo de Log');
    Log := TLog.Create;
    try
      Log.Id := TIntimaDigitalUtils.CreateGUIDStr;
      Log.Destination := 'destinatario@email.com';
      Log.LogTypeEnum := ltEMAIL;
      Log.LogStatusEnum := lsSENT;
      Log.DtQueued := Now;
      Log.DtSent := Now;
      Log.NotifiedDocumentNumber := '98765432100';
      Log.Protocol := 'PROT2024001';
      Log.CreatedAt := Now;

      LogJson := Log.ToJson;
      LogDebug('JSON do Log:');
      LogDebug(LogJson);
    finally
      Log.Free;
    end;

    LogSuccess('Testes de modelo concluídos com sucesso!');

  except
    on E: Exception do
      LogError('Erro no teste: %s', [E.Message]);
  end;
end;

procedure TIntimaDigitalDemo.DemoUploadNotification;
var
  Notification: TApiNotification;
  NotificationList: TApiNotificationList;
  Contact: TContact;
  Response: TIDApiResponse<TApiNotificationList>;
  {$IFDEF CONSOLE}
  Resposta: string;
  {$ENDIF}
begin
  if not FConfig.IsAuthenticated then
  begin
    LogError('Não autenticado. Execute a autenticação primeiro.');
    Exit;
  end;

  NotificationList := TApiNotificationList.Create;
  Notification := TApiNotification.Create;
  try
    LogInfo('Criando notificação de teste...');

    Notification.Protocol := 'DEMO' + FormatDateTime('YYYYMMDDHHNNSS', Now);
    Notification.DtProtocol := Now;
    Notification.PartnerField := '0123-abc';
    Notification.NotifiedName := 'John Doe';
    Notification.NotifiedDocumentNumber := '12345678900';
    Notification.NotificationType := 'primary';

    Notification.FileContent := 'JVBERi0xLjQNJeLjz9MNCjQgMCBvYmoNPDwvTGluZWFJVBERi0xLjQNJeLjz9MNCjQgMCBvYmoNPDwvTGluZWFyaXplZyaXplZ';

    Notification.TimeStamp := False;
    Notification.SendEmail := False;
    Notification.SendSms := False;
    Notification.SendWhatsapp := False;

    Notification.AllowEmailEnrichment := False;
    Notification.AllowSmsEnrichment := False;
    Notification.AllowWhatsappEnrichment := False;
    Notification.AllowScoreEnrichment := False;
    Notification.AllowAddressEnrichment := False;

    Notification.RankingEnrichment := False;
    Notification.RankingLimitEmail := 10;
    Notification.RankingLimitSms := 10;
    Notification.RankingLimitWhatsapp := 10;

    Notification.DtLimit := IncDay(Now, 10);


    Notification.NotificationPurpose := '';
    Notification.DestinationUrl := '';
    Notification.FileUrl := '';

    Contact := TContact.Create;
    try
      Contact.Name := 'Jane Doe';
      Contact.ContactTypeEnum := ctEmail;
      Contact.Value := 'jane@example.com';
      Contact.Sent := False;
      Contact.IsActive := True;
      Contact.DataOrigin := 'manual';
      Notification.AddContact(Contact);
      LogDebug('Contato de email adicionado: jane@example.com');
    except
      Contact.Free;
      raise;
    end;

    Contact := TContact.Create;
    try
      Contact.Name := 'Jane Doe';
      Contact.ContactTypeEnum := ctSMS;
      Contact.Value := '41999999999';
      Contact.Sent := False;
      Contact.IsActive := True;
      Contact.DataOrigin := 'manual';
      Notification.AddContact(Contact);
      LogDebug('Contato de SMS adicionado: 41999999999');
    except
      Contact.Free;
      raise;
    end;

    Contact := TContact.Create;
    try
      Contact.Name := 'Jane Doe';
      Contact.ContactTypeEnum := ctWhatsapp;
      Contact.Value := '41999999999';
      Contact.Sent := False;
      Contact.IsActive := True;
      Contact.DataOrigin := 'manual';
      Notification.AddContact(Contact);
      LogDebug('Contato de WhatsApp adicionado: 41999999999');
    except
      Contact.Free;
      raise;
    end;

    NotificationList.Add(Notification);

    LogInfo('JSON a ser enviado:');
    LogDebug(NotificationList.ToJson);
    LogInfo('');

    {$IFDEF CONSOLE}
    WriteLn('');
    Write('Deseja enviar esta notificação? (S/N): ');
    Readln(Resposta);

    if UpperCase(Resposta) <> 'S' then
    begin
      LogWarning('Envio cancelado pelo usuário.');
      Exit;
    end;
    {$ELSE}
    if MessageDlg('Deseja enviar esta notificação?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    begin
      LogWarning('Envio cancelado pelo usuário.');
      Exit;
    end;
    {$ENDIF}

    LogInfo('Enviando notificação...');
    try
      Response := FNotificationService.UploadNotification(NotificationList);

      if Response.Success then
      begin
        LogSuccess('Notificação enviada com sucesso!');
        LogSuccess('Protocolo: ' + Notification.Protocol);

        if Assigned(Response.Data) and (Response.Data.Count > 0) then
        begin
          LogInfo('');
          LogInfo('========== DETALHES DA RESPOSTA ==========');
          for Notification in Response.Data do
          begin
            LogInfo('Protocolo: %s', [Notification.Protocol]);
            LogInfo('Tipo: %s', [Notification.NotificationType]);
            if Notification.PartnerField <> '' then
              LogInfo('Campo Parceiro: %s', [Notification.PartnerField]);
            LogInfo('-----------------------------------------');
          end;
        end;

//        if not (Response.DataStr.IsEmpty)  then
//        begin
//          LogInfo('');
//          LogInfo('========== DETALHES DA RESPOSTA ==========');
//          LogInfo('Protocolo: %s', [Notification.Protocol]);
//          LogInfo('Tipo: %s', [Notification.NotificationType]);
//          LogInfo('Response: %s', [Response.DataStr]);
//          LogInfo('-----------------------------------------');
//        end;
      end
      else
      begin
        LogError('Erro ao enviar notificação!');
        LogError('Mensagem: %s', [Response.ErrorMessage]);
        LogError('Status Code: %d', [Response.StatusCode]);
      end;
    except
      on E: Exception do
      begin
        LogError('Exceção ao enviar notificação: %s', [E.Message]);
      end;
    end;

  finally
    NotificationList.Free;

//    if (Assigned(Response.Data)) then
//      Response.Data.Free;
  end;
end;

procedure TIntimaDigitalDemo.DemoValidacaoDocumentos;
var
  CPFValido, CPFInvalido: string;
  CNPJValido, CNPJInvalido: string;
begin
  try
    TIntimaDigitalLogger.Instance.Section('Validação de Documentos');

    LogInfo('Teste de Validação CPF:');

    CPFValido := '42052464808';
    CPFInvalido := '11111111111';

    if TIntimaDigitalUtils.IsValidCPF(CPFValido) then
      LogSuccess('CPF %s: VÁLIDO', [CPFValido])
    else
      LogError('CPF %s: INVÁLIDO', [CPFValido]);

    LogInfo('Formatação: %s', [TIntimaDigitalUtils.FormatCPF(CPFValido)]);
    LogInfo('Limpeza: %s', [TIntimaDigitalUtils.CleanDocument('123.456.789-09')]);
    LogInfo('');

    if TIntimaDigitalUtils.IsValidCPF(CPFInvalido) then
      LogSuccess('CPF %s: VÁLIDO', [CPFInvalido])
    else
      LogError('CPF %s: INVÁLIDO', [CPFInvalido]);
    LogInfo('');

    LogInfo('Teste de Validação CNPJ:');

    CNPJValido := '11222333000181';
    CNPJInvalido := '00000000000000';

    if TIntimaDigitalUtils.IsValidCNPJ(CNPJValido) then
      LogSuccess('CNPJ %s: VÁLIDO', [CNPJValido])
    else
      LogError('CNPJ %s: INVÁLIDO', [CNPJValido]);

    LogInfo('Formatação: %s', [TIntimaDigitalUtils.FormatCNPJ(CNPJValido)]);
    LogInfo('Limpeza: %s', [TIntimaDigitalUtils.CleanDocument('11.222.333/0001-81')]);
    LogInfo('');

    if TIntimaDigitalUtils.IsValidCNPJ(CNPJInvalido) then
      LogSuccess('CNPJ %s: VÁLIDO', [CNPJInvalido])
    else
      LogError('CNPJ %s: INVÁLIDO', [CNPJInvalido]);
    LogInfo('');

    LogInfo('Teste de Limpeza de Documento:');
    LogInfo('Documento sujo: "ABC123.456.789-09XYZ"');
    LogInfo('Documento limpo: "%s"',
      [TIntimaDigitalUtils.CleanDocument('ABC123.456.789-09XYZ')]);

    LogSuccess('Testes de validação concluídos!');

  except
    on E: Exception do
      LogError('Erro no teste: %s', [E.Message]);
  end;
end;

procedure TIntimaDigitalDemo.Desconectar;
begin
  FAuthService.Logout;
  LogSuccess('Desconectado com sucesso');
end;

function TIntimaDigitalDemo.RefreshToken: Boolean;
var
  Response: TIDApiResponse<Boolean>;
begin
  LogInfo('Renovando token...');

  Response := FAuthService.RefreshToken;
  Result := Response.Success;

  if Result then
  begin
    LogSuccess('Token renovado com sucesso!');
    LogDebug('Novo token expira em: %s', [DateTimeToStr(FConfig.TokenExpiration)]);
  end
  else
  begin
    LogError('Falha ao renovar token: %s', [Response.ErrorMessage]);
  end;
end;

end.
