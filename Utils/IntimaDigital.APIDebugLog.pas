unit IntimaDigital.APIDebugLog;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.JSON,
  System.DateUtils,
  IntimaDigital.Client,
  IntimaDigital.Types,
  IntimaDigital.Logger,
  System.TypInfo,
  Winapi.Windows;

type
  TAPIDebugMode = (admIDEOnly, admAlways, admNever);

  TAPIRequestLog = record
    Timestamp: TDateTime;
    CorrelationId: string;
    Endpoint: string;
    Method: string;
    StatusCode: Integer;
    RequestDuration: Int64;
    RequestHeaders: string;
    RequestBody: string;
    ResponseBody: string;
    ResponseSize: Integer;
    ErrorMessage: string;
    RetryCount: Integer;
    TokenStatus: string;
    URL: string;
    function ToFormattedString: string;
    function ToJSON: string;
    function GetLogFileName: string;
    function PadRight(const AText: string; AWidth: Integer; AFillChar: Char = ' '): string;
  end;

  TIntimaDigitalAPIDebugLogger = class
  private
    class var FIsActive: Boolean;
    class var FDebugMode: TAPIDebugMode;
    class var FCS: TCriticalSection;
    class var FMaxLogSizeMB: Integer;
    class var FEnableRequestBody: Boolean;
    class var FEnableResponseBody: Boolean;
    class var FEnablePerformanceLog: Boolean;
    class var FLogDirectory: string;

    class procedure Initialize;
    class function IsRunningInIDE: Boolean;
    class function ShouldLog: Boolean;
    class procedure WriteToDebugFile(const AFileName, AContent: string);
    class procedure RotateLogIfNeeded(const AFileName: string);
    class function GenerateCorrelationId: string;
    class function SanitizeForLog(const AText: string; AMaxLength: Integer = 5000): string;
    class function FormatJSON(const AJSON: string): string;
    class function GetMethodName(AMethodType: string): string;

    class function FormatTokenInfo(AClient: TIntimaDigitalClient): string;
    //class function FormatHeaders(AHeaders: TArray<string>): string; static;

  public
    class procedure ConfigureDebug(
      AMode: TAPIDebugMode = admIDEOnly;
      AMaxLogSizeMB: Integer = 10;
      AEnableRequestBody: Boolean = True;
      AEnableResponseBody: Boolean = True;
      AEnablePerformance: Boolean = True;
      const ALogDirectory: string = ''
    );

    class function StartRequest(
      AClient: TIntimaDigitalClient;
      const AEndpoint, AMethod: string;
      ARequestBody: string = ''
    ): string;

    class procedure CompleteRequest(
      const ACorrelationId, AEndpoint, AMethod: string;
      AClient: TIntimaDigitalClient;
      AResponse: TIDApiResponse<Boolean>;
      const AResponseBody: string;
      ARequestDuration: Int64);

  class procedure CompleteJsonRequest<T>(
    const ACorrelationId, AEndpoint, AMethod: string;
    AClient: TIntimaDigitalClient;
    AResponse: TIDApiResponse<T>;
    const AResponseBody: string;
    ARequestDuration: Int64);

    class procedure LogTokenRefresh(AClient: TIntimaDigitalClient; ASuccess: Boolean);
    class procedure LogRetryAttempt(AClient: TIntimaDigitalClient; const AEndpoint: string; AAttempt: Integer);
    class procedure LogConfigChange(AClient: TIntimaDigitalClient; const AChange: string);

    class procedure Debug(const AMessage: string); overload;
    class procedure Debug(const AFormat: string; AArgs: array of const); overload;
    class procedure Info(const AMessage: string); overload;
    class procedure Info(const AFormat: string; AArgs: array of const); overload;
    class procedure Warning(const AMessage: string); overload;
    class procedure Warning(const AFormat: string; AArgs: array of const); overload;
    class procedure Error(const AMessage: string); overload;
    class procedure Error(const AFormat: string; AArgs: array of const); overload;

    class property IsActive: Boolean read FIsActive;
    class property DebugMode: TAPIDebugMode read FDebugMode write FDebugMode;
  end;

procedure APIDebug(const AMessage: string); overload;
procedure APIDebug(const AFormat: string; AArgs: array of const); overload;
procedure APIInfo(const AMessage: string); overload;
procedure APIInfo(const AFormat: string; AArgs: array of const); overload;
procedure APIError(const AMessage: string); overload;
procedure APIError(const AFormat: string; AArgs: array of const); overload;

implementation

uses
  System.IOUtils, System.NetEncoding, System.Generics.Collections, System.StrUtils;

{ TAPIRequestLog }

function TAPIRequestLog.PadRight(const AText: string; AWidth: Integer;
  AFillChar: Char): string;
begin
  if Length(AText) >= AWidth then
    Result := AText
  else
    Result := AText + StringOfChar(AFillChar, AWidth - Length(AText));
end;

function TAPIRequestLog.ToFormattedString: string;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.Add(PadRight('=', 80, '='));
    Lines.Add(Format('API REQUEST LOG - %s', [FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz', Timestamp)]));
    Lines.Add(PadRight('=', 80, '='));
    Lines.Add('');

    Lines.Add('CORRELATION ID: ' + CorrelationId);
    Lines.Add('ENDPOINT:       ' + Endpoint);
    Lines.Add('METHOD:         ' + Method);
    Lines.Add('URL:            ' + URL);
    Lines.Add('STATUS CODE:    ' + IfThen(StatusCode > 0, StatusCode.ToString, 'N/A'));
    Lines.Add('DURATION:       ' + RequestDuration.ToString + ' ms');
    Lines.Add('RETRY COUNT:    ' + RetryCount.ToString);
    Lines.Add('TOKEN STATUS:   ' + TokenStatus);
    Lines.Add('');

    if not RequestHeaders.IsEmpty then
    begin
      Lines.Add('REQUEST HEADERS:');
      Lines.Add(RequestHeaders);
      Lines.Add('');
    end;

    if not RequestBody.IsEmpty then
    begin
      Lines.Add('REQUEST BODY:');
      Lines.Add(RequestBody);
      Lines.Add('');
    end;

    if not ResponseBody.IsEmpty then
    begin
      Lines.Add('RESPONSE BODY:');
      Lines.Add('Size: ' + ResponseSize.ToString + ' bytes');
      Lines.Add(ResponseBody);
      Lines.Add('');
    end;

    if not ErrorMessage.IsEmpty then
    begin
      Lines.Add('ERROR:');
      Lines.Add(ErrorMessage);
      Lines.Add('');
    end;

    Lines.Add(PadRight('=', 80, '='));
    Lines.Add('');

    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

function TAPIRequestLog.ToJSON: string;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('timestamp', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', Timestamp));
    JSON.AddPair('correlationId', CorrelationId);
    JSON.AddPair('endpoint', Endpoint);
    JSON.AddPair('method', Method);
    JSON.AddPair('url', URL);
    if StatusCode > 0 then
      JSON.AddPair('statusCode', TJSONNumber.Create(StatusCode));
    JSON.AddPair('durationMs', TJSONNumber.Create(RequestDuration));
    JSON.AddPair('retryCount', TJSONNumber.Create(RetryCount));
    JSON.AddPair('tokenStatus', TokenStatus);
    JSON.AddPair('responseSize', TJSONNumber.Create(ResponseSize));

    if not RequestHeaders.IsEmpty then
      JSON.AddPair('requestHeaders', RequestHeaders);

    if not RequestBody.IsEmpty then
      JSON.AddPair('requestBody', RequestBody);

    if not ResponseBody.IsEmpty then
      JSON.AddPair('responseBody', ResponseBody);

    if not ErrorMessage.IsEmpty then
      JSON.AddPair('error', ErrorMessage);

    Result := JSON.ToString;
  finally
    JSON.Free;
  end;
end;

function TAPIRequestLog.GetLogFileName: string;
begin
  Result := FormatDateTime('yyyy-mm-dd', Timestamp) + '_api_debug.log';
end;

{ TIntimaDigitalAPIDebugLogger }

class procedure TIntimaDigitalAPIDebugLogger.Initialize;
begin
  if FCS = nil then
  begin
    FCS := TCriticalSection.Create;
    FDebugMode := admIDEOnly;
    FMaxLogSizeMB := 10;
    FEnableRequestBody := True;
    FEnableResponseBody := True;
    FEnablePerformanceLog := True;
    FLogDirectory := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'logs\';

    FIsActive := ShouldLog;

    if FIsActive then
    begin
      ForceDirectories(FLogDirectory);
      Debug('IntimaDigitalAPIDebugLogger inicializado');
      Debug('Modo: %s', [GetEnumName(TypeInfo(TAPIDebugMode), Ord(FDebugMode))]);
      Debug('Diretório de log: %s', [FLogDirectory]);
    end;
  end;
end;

class function TIntimaDigitalAPIDebugLogger.IsRunningInIDE: Boolean;
begin
  Result := IsDebuggerPresent or
            FindCmdLineSwitch('DEBUG', ['-', '/'], True) or
            FindCmdLineSwitch('LOG', ['-', '/'], True);
end;

class function TIntimaDigitalAPIDebugLogger.ShouldLog: Boolean;
begin
  case FDebugMode of
    admIDEOnly: Result := IsRunningInIDE;
    admAlways:  Result := True;
    admNever:   Result := False;
  else
    Result := False;
  end;
end;

class procedure TIntimaDigitalAPIDebugLogger.WriteToDebugFile(const AFileName, AContent: string);
var
  FullPath: string;
  StreamWriter: TStreamWriter;
begin
  if not FIsActive then Exit;

  FCS.Enter;
  try
    FullPath := FLogDirectory + AFileName;
    RotateLogIfNeeded(FullPath);

    StreamWriter := TStreamWriter.Create(FullPath, True, TEncoding.UTF8);
    try
      StreamWriter.WriteLine(AContent);
    finally
      StreamWriter.Free;
    end;
  finally
    FCS.Leave;
  end;
end;

class procedure TIntimaDigitalAPIDebugLogger.RotateLogIfNeeded(const AFileName: string);
var
  FileSize: Int64;
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  if not FileExists(AFileName) then
    Exit;

  FindResult := FindFirst(AFileName, faAnyFile, SearchRec);
  if FindResult = 0 then
  begin
    try
      FileSize := SearchRec.Size;
      if FileSize > (FMaxLogSizeMB * 1024 * 1024) then
      begin
        RenameFile(AFileName,
          ChangeFileExt(AFileName, '_' +
            FormatDateTime('yyyymmdd_hhnnss', Now) + '.log'));
      end;
    finally
      System.SysUtils.FindClose(SearchRec);
    end;
  end;
end;

class function TIntimaDigitalAPIDebugLogger.GenerateCorrelationId: string;
begin
  Result := TGUID.NewGuid.ToString;
  Delete(Result, 1, 1);
  Delete(Result, Length(Result), 1);
end;

class function TIntimaDigitalAPIDebugLogger.SanitizeForLog(const AText: string; AMaxLength: Integer): string;
begin
  Result := AText;
  if Result.Length > AMaxLength then
    Result := Copy(Result, 1, AMaxLength) + '... [TRUNCATED ' +
      (Result.Length - AMaxLength).ToString + ' chars]';
end;

class function TIntimaDigitalAPIDebugLogger.FormatJSON(const AJSON: string): string;
var
  JSONValue: TJSONValue;
begin
  if AJSON.Trim.IsEmpty then
    Exit('');

  try
    JSONValue := TJSONObject.ParseJSONValue(AJSON);
    if Assigned(JSONValue) then
    begin
      Result := JSONValue.ToString;
      JSONValue.Free;
    end
    else
      Result := AJSON;
  except
    Result := AJSON;
  end;
end;

class function TIntimaDigitalAPIDebugLogger.GetMethodName(AMethodType: string): string;
begin
  if SameText(AMethodType, 'mtGet') then Result := 'GET'
  else if SameText(AMethodType, 'mtPost') then Result := 'POST'
  else if SameText(AMethodType, 'mtPut') then Result := 'PUT'
  else if SameText(AMethodType, 'mtDelete') then Result := 'DELETE'
  else Result := AMethodType;
end;

//class function TIntimaDigitalAPIDebugLogger.FormatHeaders(AHeaders: TArray<string>): string;
//var
//  SB: TStringBuilder;
//  i: Integer;
//begin
//  SB := TStringBuilder.Create;
//  try
//    for i := 0 to High(AHeaders) do
//    begin
//      SB.AppendLine(AHeaders[i]);
//    end;
//    Result := SB.ToString.Trim;
//  finally
//    SB.Free;
//  end;
//end;

class function TIntimaDigitalAPIDebugLogger.FormatTokenInfo(AClient: TIntimaDigitalClient): string;
begin
  if not Assigned(AClient) or not Assigned(AClient.Config) then
    Exit('No config');

  Result := 'Token: ' +
    IfThen(AClient.Config.Token.IsEmpty, 'Empty',
      'Exists (' + IntToStr(Length(AClient.Config.Token)) + ' chars)') +
    ' | Expired: ' + BoolToStr(AClient.Config.IsTokenExpired, True) +
    ' | Has Refresh: ' + BoolToStr(not AClient.Config.RefreshToken.IsEmpty, True);
end;

class procedure TIntimaDigitalAPIDebugLogger.ConfigureDebug(
  AMode: TAPIDebugMode; AMaxLogSizeMB: Integer;
  AEnableRequestBody, AEnableResponseBody, AEnablePerformance: Boolean;
  const ALogDirectory: string);
begin
  Initialize;

  FDebugMode := AMode;
  FMaxLogSizeMB := AMaxLogSizeMB;
  FEnableRequestBody := AEnableRequestBody;
  FEnableResponseBody := AEnableResponseBody;
  FEnablePerformanceLog := AEnablePerformance;

  if not ALogDirectory.IsEmpty then
    FLogDirectory := IncludeTrailingPathDelimiter(ALogDirectory);

  FIsActive := ShouldLog;

  if FIsActive then
  begin
    Debug('Configuração de debug atualizada');
    Debug('Modo: %s', [GetEnumName(TypeInfo(TAPIDebugMode), Ord(FDebugMode))]);
    Debug('Log directory: %s', [FLogDirectory]);
  end;
end;

class function TIntimaDigitalAPIDebugLogger.StartRequest(
  AClient: TIntimaDigitalClient;
  const AEndpoint, AMethod: string;
  ARequestBody: string): string;
var
  LogEntry: TAPIRequestLog;
  LogContent: string;
begin
  Initialize;
  if not FIsActive then Exit('');

  Result := GenerateCorrelationId;

  LogEntry.Timestamp := Now;
  LogEntry.CorrelationId := Result;
  LogEntry.Endpoint := AEndpoint;
  LogEntry.Method := GetMethodName(AMethod);
  LogEntry.URL := AClient.Config.GetFullURL(AEndpoint);
  LogEntry.TokenStatus := FormatTokenInfo(AClient);
  LogEntry.RetryCount := 0;

  if FEnableRequestBody and not ARequestBody.IsEmpty then
    LogEntry.RequestBody := FormatJSON(SanitizeForLog(ARequestBody))
  else
    LogEntry.RequestBody := '[REQUEST BODY DISABLED IN CONFIG]';

  LogEntry.RequestHeaders := '[HEADERS LOGGED AT RESPONSE TIME]';

  LogContent := Format('[%s] START REQUEST %s %s (Correlation: %s)',
    [FormatDateTime('hh:nn:ss.zzz', LogEntry.Timestamp),
     LogEntry.Method, LogEntry.Endpoint, Result]);

  WriteToDebugFile(LogEntry.GetLogFileName, LogContent);

  if FDebugMode = admIDEOnly then
    IntimaDigital.Logger.LogDebug(LogContent);
end;

class procedure TIntimaDigitalAPIDebugLogger.CompleteRequest(
  const ACorrelationId, AEndpoint, AMethod: string;
  AClient: TIntimaDigitalClient;
  AResponse: TIDApiResponse<Boolean>;
  const AResponseBody: string;
  ARequestDuration: Int64);
var
  LogEntry: TAPIRequestLog;
  SuccessStr: string;
  LogContent: string;
begin
  if not FIsActive or ACorrelationId.IsEmpty then Exit;

  LogEntry.Timestamp := Now;
  LogEntry.CorrelationId := ACorrelationId;
  LogEntry.Endpoint := AEndpoint;
  LogEntry.Method := AMethod;
  LogEntry.StatusCode := AResponse.StatusCode;
  LogEntry.RequestDuration := ARequestDuration;
  LogEntry.ErrorMessage := AResponse.ErrorMessage;
  LogEntry.ResponseSize := Length(AResponseBody);

  if Assigned(AClient) and Assigned(AClient.Config) then
    LogEntry.URL := AClient.Config.GetFullURL(AEndpoint)
  else
    LogEntry.URL := '[Client not available]';

  LogEntry.TokenStatus := FormatTokenInfo(AClient);
  LogEntry.RetryCount := 0;
  LogEntry.RequestHeaders := '';

  if FEnableResponseBody then
    LogEntry.ResponseBody := FormatJSON(SanitizeForLog(AResponseBody))
  else
    LogEntry.ResponseBody := '[RESPONSE BODY DISABLED IN CONFIG]';

  if FEnableRequestBody then
    LogEntry.RequestBody := '[REQUEST BODY LOGGED AT START TIME]'
  else
    LogEntry.RequestBody := '[REQUEST BODY DISABLED IN CONFIG]';

  SuccessStr := IfThen(AResponse.Success, 'SUCCESS', 'FAILURE');

  Debug('[%s] %s %s - Status: %d, Duration: %dms, Size: %d bytes',
    [ACorrelationId, AMethod, AEndpoint, AResponse.StatusCode, ARequestDuration, LogEntry.ResponseSize]);

  if not AResponse.Success and not AResponse.ErrorMessage.IsEmpty then
    Debug('[%s] ERROR: %s', [ACorrelationId, AResponse.ErrorMessage]);

  if FEnablePerformanceLog then
  begin
    WriteToDebugFile('api_performance.csv',
      Format('"%s","%s","%s","%s","%d","%d","%d","%s","%s"',
        [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', LogEntry.Timestamp),
         ACorrelationId,
         AMethod,
         AEndpoint,
         LogEntry.StatusCode,
         LogEntry.RequestDuration,
         LogEntry.ResponseSize,
         SuccessStr,
         StringReplace(AResponse.ErrorMessage, '"', '""', [rfReplaceAll])]));
  end;

  if not AResponse.Success then
  begin
    LogContent := Format('[ERROR %s] %s %s - Status: %d, Error: %s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', LogEntry.Timestamp),
       AMethod,
       AEndpoint,
       LogEntry.StatusCode,
       AResponse.ErrorMessage]);

    WriteToDebugFile('api_errors.log', LogContent);

    if not AResponseBody.IsEmpty and (Length(AResponseBody) < 5000) then
    begin
      WriteToDebugFile('api_errors_detail.log',
        Format('[%s] Response Body: %s',
          [ACorrelationId, SanitizeForLog(AResponseBody, 2000)]));
    end;
  end;

  if FEnableResponseBody and (LogEntry.ResponseSize < 10000) then
  begin
    WriteToDebugFile('api_detailed_' + FormatDateTime('yyyy-mm-dd', Now) + '.log',
      LogEntry.ToFormattedString);
  end;
end;

class procedure TIntimaDigitalAPIDebugLogger.CompleteJsonRequest<T>(
  const ACorrelationId, AEndpoint, AMethod: string;
  AClient: TIntimaDigitalClient;
  AResponse: TIDApiResponse<T>;
  const AResponseBody: string;
  ARequestDuration: Int64);
var
  BooleanResponse: TIDApiResponse<Boolean>;
begin
  if not FIsActive or ACorrelationId.IsEmpty then Exit;

  BooleanResponse.Success := AResponse.Success;
  BooleanResponse.ErrorMessage := AResponse.ErrorMessage;
  BooleanResponse.StatusCode := AResponse.StatusCode;

  CompleteRequest(ACorrelationId, AEndpoint, AMethod, AClient,
    BooleanResponse, AResponseBody, ARequestDuration);
end;

class procedure TIntimaDigitalAPIDebugLogger.LogTokenRefresh(
  AClient: TIntimaDigitalClient; ASuccess: Boolean);
begin
  if not FIsActive then Exit;

  Debug('Token Refresh: %s', [BoolToStr(ASuccess, True)]);

  if ASuccess then
    Info('Token atualizado com sucesso')
  else
    Warning('Falha ao atualizar token');
end;

class procedure TIntimaDigitalAPIDebugLogger.LogRetryAttempt(
  AClient: TIntimaDigitalClient; const AEndpoint: string; AAttempt: Integer);
begin
  if not FIsActive then Exit;

  Warning('Tentativa %d para endpoint: %s', [AAttempt, AEndpoint]);
end;

class procedure TIntimaDigitalAPIDebugLogger.LogConfigChange(
  AClient: TIntimaDigitalClient; const AChange: string);
begin
  if not FIsActive then Exit;

  Info('Configuração alterada: %s', [AChange]);
end;

class procedure TIntimaDigitalAPIDebugLogger.Debug(const AMessage: string);
begin
  if not FIsActive then Exit;

  WriteToDebugFile('api_debug.log',
    Format('[DEBUG %s] %s',
      [FormatDateTime('hh:nn:ss.zzz', Now), AMessage]));

  if IsRunningInIDE then
    IntimaDigital.Logger.LogDebug(AMessage);
end;

class procedure TIntimaDigitalAPIDebugLogger.Debug(const AFormat: string; AArgs: array of const);
begin
  Debug(Format(AFormat, AArgs));
end;

class procedure TIntimaDigitalAPIDebugLogger.Info(const AMessage: string);
begin
  if not FIsActive then Exit;

  WriteToDebugFile('api_debug.log',
    Format('[INFO  %s] %s',
      [FormatDateTime('hh:nn:ss.zzz', Now), AMessage]));

  IntimaDigital.Logger.LogInfo(AMessage);
end;

class procedure TIntimaDigitalAPIDebugLogger.Info(const AFormat: string; AArgs: array of const);
begin
  Info(Format(AFormat, AArgs));
end;

class procedure TIntimaDigitalAPIDebugLogger.Warning(const AMessage: string);
begin
  if not FIsActive then Exit;

  WriteToDebugFile('api_debug.log',
    Format('[WARN  %s] %s',
      [FormatDateTime('hh:nn:ss.zzz', Now), AMessage]));

  IntimaDigital.Logger.LogWarning(AMessage);
end;

class procedure TIntimaDigitalAPIDebugLogger.Warning(const AFormat: string; AArgs: array of const);
begin
  Warning(Format(AFormat, AArgs));
end;

class procedure TIntimaDigitalAPIDebugLogger.Error(const AMessage: string);
begin
  if not FIsActive then Exit;

  WriteToDebugFile('api_debug.log',
    Format('[ERROR %s] %s',
      [FormatDateTime('hh:nn:ss.zzz', Now), AMessage]));

  WriteToDebugFile('api_errors.log',
    Format('%s - %s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), AMessage]));

  IntimaDigital.Logger.LogError(AMessage);
end;

class procedure TIntimaDigitalAPIDebugLogger.Error(const AFormat: string; AArgs: array of const);
begin
  Error(Format(AFormat, AArgs));
end;

procedure APIDebug(const AMessage: string);
begin
  TIntimaDigitalAPIDebugLogger.Debug(AMessage);
end;

procedure APIDebug(const AFormat: string; AArgs: array of const);
begin
  TIntimaDigitalAPIDebugLogger.Debug(AFormat, AArgs);
end;

procedure APIInfo(const AMessage: string);
begin
  TIntimaDigitalAPIDebugLogger.Info(AMessage);
end;

procedure APIInfo(const AFormat: string; AArgs: array of const);
begin
  TIntimaDigitalAPIDebugLogger.Info(AFormat, AArgs);
end;

procedure APIError(const AMessage: string);
begin
  TIntimaDigitalAPIDebugLogger.Error(AMessage);
end;

procedure APIError(const AFormat: string; AArgs: array of const);
begin
  TIntimaDigitalAPIDebugLogger.Error(AFormat, AArgs);
end;

initialization
  TIntimaDigitalAPIDebugLogger.FCS := nil;

finalization
  if Assigned(TIntimaDigitalAPIDebugLogger.FCS) then
    FreeAndNil(TIntimaDigitalAPIDebugLogger.FCS);

end.
