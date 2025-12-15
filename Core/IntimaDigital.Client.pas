unit IntimaDigital.Client;

interface

uses
  System.SysUtils,
  System.NetConsts,
  System.Classes,
  System.JSON,
  System.StrUtils,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.Net.Mime,
  IntimaDigital.Types,
  IntimaDigital.Config,
  Rest.JSon,
  IntimaDigital.Utils.JSon,
  IntimaDigital.Models.Base,
  System.Rtti,
  System.TypInfo;

type
  TMethodType = (mtGet, mtPost, mtPut, mtDelete);

  TIntimaDigitalClient = class
  private
    FHttpClient: THTTPClient;
    FConfig: TIntimaDigitalConfig;
    FLastResponse: string;
    FLastStatusCode: Integer;

    FCorrelationId: string;
    FRequestStartTime: TDateTime;

    function HasValidationError(const AResponse: string): Boolean;
    procedure UpdateAuthorizationHeader;
    function ExtractValidationErrorMessage(const AResponse: string): string;

    function ExecuteRequest(const AMethod: TMethodType;
      const AEndpoint: string;
      const ABody: string = ''): TIDApiResponse<Boolean>;
    procedure HandleHttpError(var AResult: TIDApiResponse<Boolean>; const AResponse: string);
    function CreateRequestBodyStream(const ABody: string): TStream;

    procedure LogRequestStart(const AEndpoint: string; AMethod: TMethodType; const ABody: string = '');
    procedure LogRequestComplete(const AEndpoint: string; AMethod: TMethodType;
      AResponse: TIDApiResponse<Boolean>; const AResponseBody: string);
    function MethodToString(AMethod: TMethodType): string;
    procedure LogJsonRequestStart(const AEndpoint, AMethod: string; ABody: string = '');
    procedure LogJsonRequestComplete<T: class>(const AEndpoint, AMethod: string;
      AResponse: TIDApiResponse<T>; const AResponseBody: string);
    function SerializeObject<T: class>(AObject: T): string;

  public
    constructor Create(AConfig: TIntimaDigitalConfig);
    destructor Destroy; override;

    function Get(const AEndpoint: string; out AResponse: string): TIDApiResponse<Boolean>;
    function Post(const AEndpoint: string; const ABody: string; out AResponse: string): TIDApiResponse<Boolean>;
    function Put(const AEndpoint: string; const ABody: string; out AResponse: string): TIDApiResponse<Boolean>;
    function Dell(const AEndpoint: string; out AResponse: string): TIDApiResponse<Boolean>;

    function GetJson<T: class, constructor>(const AEndpoint: string): TIDApiResponse<T>;
    function PostJson<T: class, constructor>(const AEndpoint: string; ABody: T): TIDApiResponse<T>;
    function PutJson<T: class, constructor>(const AEndpoint: string; ABody: T): TIDApiResponse<T>;
    function DeleteJson<T: class, constructor>(const AEndpoint: string): TIDApiResponse<T>;

    property LastResponse: string read FLastResponse;
    property LastStatusCode: Integer read FLastStatusCode;
    property Config: TIntimaDigitalConfig read FConfig;
  end;

implementation

uses
  IntimaDigital.Auth.Service,
  IntimaDigital.APIDebugLog,
  System.Diagnostics,
  System.DateUtils;

{ TIntimaDigitalClient }

function TIntimaDigitalClient.MethodToString(AMethod: TMethodType): string;
begin
  case AMethod of
    mtGet: Result := 'GET';
    mtPost: Result := 'POST';
    mtPut: Result := 'PUT';
    mtDelete: Result := 'DELETE';
  else
    Result := 'UNKNOWN';
  end;
end;

procedure TIntimaDigitalClient.LogRequestStart(const AEndpoint: string;
  AMethod: TMethodType; const ABody: string = '');
begin
  FCorrelationId := TIntimaDigitalAPIDebugLogger.StartRequest(
    Self, AEndpoint, MethodToString(AMethod), ABody);
  FRequestStartTime := Now;
end;

procedure TIntimaDigitalClient.LogRequestComplete(const AEndpoint: string;
  AMethod: TMethodType; AResponse: TIDApiResponse<Boolean>; const AResponseBody: string);
var
  Duration: Int64;
begin
  if not FCorrelationId.IsEmpty then
  begin
    Duration := MilliSecondsBetween(Now, FRequestStartTime);
    TIntimaDigitalAPIDebugLogger.CompleteRequest(
      FCorrelationId, AEndpoint, MethodToString(AMethod),
      Self, AResponse, AResponseBody, Duration);
    FCorrelationId := '';
  end;
end;

procedure TIntimaDigitalClient.LogJsonRequestStart(const AEndpoint, AMethod: string;
  ABody: string = '');
begin
  FCorrelationId := TIntimaDigitalAPIDebugLogger.StartRequest(
    Self, AEndpoint, AMethod, ABody);
  FRequestStartTime := Now;
end;

procedure TIntimaDigitalClient.LogJsonRequestComplete<T>(const AEndpoint, AMethod: string;
  AResponse: TIDApiResponse<T>; const AResponseBody: string);
var
  Duration: Int64;
begin
  if not FCorrelationId.IsEmpty then
  begin
    Duration := MilliSecondsBetween(Now, FRequestStartTime);
    TIntimaDigitalAPIDebugLogger.CompleteJsonRequest<T>(
      FCorrelationId, AEndpoint, AMethod,
      Self, AResponse, AResponseBody, Duration);
    FCorrelationId := '';
  end;
end;

constructor TIntimaDigitalClient.Create(AConfig: TIntimaDigitalConfig);
begin
  inherited Create;
  FConfig := AConfig;
  FHttpClient := THTTPClient.Create;
  FHttpClient.ConnectionTimeout := FConfig.Timeout;
  FHttpClient.ResponseTimeout := FConfig.Timeout;
  FHttpClient.UserAgent := 'IntimaDigital-Delphi-Client/1.0';
  FHttpClient.Accept := 'application/json';
  FHttpClient.ContentType := 'application/json';
  FLastResponse := '';
  FLastStatusCode := 0;

  FCorrelationId := '';
  FRequestStartTime := 0;

  TIntimaDigitalAPIDebugLogger.ConfigureDebug(
    admIDEOnly,
    10,
    True,
    True,
    True
  );
end;

destructor TIntimaDigitalClient.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

function TIntimaDigitalClient.CreateRequestBodyStream(const ABody: string): TStream;
begin
  Result := nil;
  if not ABody.IsEmpty then
  begin
    Result := TStringStream.Create(ABody, TEncoding.UTF8);
    Result.Position := 0;
  end;
end;

function TIntimaDigitalClient.ExecuteRequest(const AMethod: TMethodType;
  const AEndpoint: string;
  const ABody: string = ''): TIDApiResponse<Boolean>;
var
  Response: IHTTPResponse;
  URL: string;
  RequestStream: TStream;
  AuthResponse: TIDApiResponse<Boolean>;
  RetryCount: Integer;
  lAuthService: TIntimaDigitalAuthService;
begin
  LogRequestStart(AEndpoint, AMethod, ABody);

  Result.Success := False;
  Result.ErrorMessage := '';
  Result.StatusCode := 0;
  FLastResponse := '';
  FLastStatusCode := 0;

  try
    URL := FConfig.GetFullURL(AEndpoint);

    if not (AEndpoint.Contains('jwt/obtain') or
            AEndpoint.Contains('jwt/refresh')) then
    begin
      if FConfig.IsTokenExpired then
      begin
        if not FConfig.RefreshToken.IsEmpty then
        begin
          lAuthService := TIntimaDigitalAuthService.Create(Self, FConfig);
          try
            AuthResponse := lAuthService.RefreshToken;

            if not AuthResponse.Success then
            begin
              Result.ErrorMessage := 'Token expirado e não foi possível renovar. Faça login novamente.';
              TIntimaDigitalAPIDebugLogger.LogTokenRefresh(Self, False);
              Exit;
            end
            else
            begin
              TIntimaDigitalAPIDebugLogger.LogTokenRefresh(Self, True);
            end;
          finally
            lAuthService.Free;
          end;
        end
        else
        begin
          Result.ErrorMessage := 'Token expirado. Faça login novamente.';
          TIntimaDigitalAPIDebugLogger.Debug('Token expirado sem refresh token disponível');
          Exit;
        end;
      end;
    end;

    UpdateAuthorizationHeader;

    RequestStream := nil;
    if (AMethod in [mtPost, mtPut]) and not ABody.IsEmpty then
    begin
      TIntimaDigitalAPIDebugLogger.Debug(Format('[%S] Body: %s', [MethodToString(AMethod), TJSONUtil.Format(ABody)]));

      RequestStream := CreateRequestBodyStream(ABody);
    end;

    try
      RetryCount := 0;
      while RetryCount <= FConfig.RetryCount do
      begin
        try
          case AMethod of
            mtGet:
              Response := FHttpClient.Get(URL);
            mtPost:
              Response := FHttpClient.Post(URL, RequestStream);
            mtPut:
              Response := FHttpClient.Put(URL, RequestStream);
            mtDelete:
              Response := FHttpClient.Delete(URL);
          end;
          Break;
        except
          on E: ENetHTTPClientException do
          begin
            if RetryCount < FConfig.RetryCount then
            begin
              Inc(RetryCount);
              TIntimaDigitalAPIDebugLogger.LogRetryAttempt(Self, AEndpoint, RetryCount);
              Sleep(FConfig.RetryDelay);
              Continue;
            end
            else
              raise;
          end;
        end;
      end;

      Result.StatusCode := Response.StatusCode;
      FLastStatusCode := Result.StatusCode;
      FLastResponse := Response.ContentAsString(TEncoding.UTF8);
      TIntimaDigitalAPIDebugLogger.Debug('Response: ' + TJSONUtil.Format(FLastResponse));

      if (Result.StatusCode >= 200) and (Result.StatusCode < 300) then
      begin
        if HasValidationError(FLastResponse) then
        begin
          Result.Success := False;
          Result.ErrorMessage := 'Erro de validação: ' + ExtractValidationErrorMessage(FLastResponse);
        end
        else
        begin
          Result.Success := True;
        end;
      end
      else
      begin
        Result.Success := False;
        HandleHttpError(Result, FLastResponse);

        if Result.StatusCode = 401 then
        begin
          FConfig.ClearAuth;
          TIntimaDigitalAPIDebugLogger.Debug('Status 401 - Token limpo do config');
        end;
      end;

    finally
      if Assigned(RequestStream) then
        RequestStream.Free;
    end;

  except
    on E: ENetHTTPClientException do
    begin
      Result.ErrorMessage := Format('Erro de conexão: %s', [E.Message]);
      Result.StatusCode := 0;
      FLastStatusCode := 0;
    end;
    on E: ENetHTTPException do
    begin
      Result.ErrorMessage := Format('Erro HTTP: %s', [E.Message]);
      Result.StatusCode := 0;
      FLastStatusCode := 0;
    end;
    on E: Exception do
    begin
      Result.ErrorMessage := Format('Erro: %s', [E.Message]);
      Result.StatusCode := 0;
      FLastStatusCode := 0;
    end;
  end;

  LogRequestComplete(AEndpoint, AMethod, Result, FLastResponse);
end;

procedure TIntimaDigitalClient.HandleHttpError(var AResult: TIDApiResponse<Boolean>; const AResponse: string);
begin
  if HasValidationError(AResponse) then
  begin
    AResult.ErrorMessage := 'Erro de validação: ' + ExtractValidationErrorMessage(AResponse);
    Exit;
  end;

  case AResult.StatusCode of
    401:
      AResult.ErrorMessage := 'Não autorizado. Token pode estar expirado ou inválido.';
    400:
      AResult.ErrorMessage := 'Requisição inválida: ' + Copy(AResponse, 1, 200);
    403:
      AResult.ErrorMessage := 'Acesso proibido. Permissões insuficientes.';
    404:
      AResult.ErrorMessage := 'Recurso não encontrado.';
    409:
      AResult.ErrorMessage := 'Conflito. O recurso já existe ou está em uso.';
    422:
      AResult.ErrorMessage := 'Entidade não processável: ' + ExtractValidationErrorMessage(AResponse);
    429:
      AResult.ErrorMessage := 'Muitas requisições. Tente novamente mais tarde.';
    500:
      AResult.ErrorMessage := 'Erro interno do servidor.';
    502, 503, 504:
      AResult.ErrorMessage := 'Serviço temporariamente indisponível. Tente novamente.';
  else
    if AResult.StatusCode >= 400 then
    begin
      if not AResponse.IsEmpty then
        AResult.ErrorMessage := Format('HTTP %d: %s', [AResult.StatusCode, Copy(AResponse, 1, 200)])
      else
        AResult.ErrorMessage := Format('HTTP %d: Erro desconhecido', [AResult.StatusCode]);
    end;
  end;
end;

function TIntimaDigitalClient.Get(const AEndpoint: string; out AResponse: string): TIDApiResponse<Boolean>;
begin
  Result := ExecuteRequest(mtGet, AEndpoint);
  AResponse := FLastResponse;
end;

function TIntimaDigitalClient.Post(const AEndpoint: string; const ABody: string; out AResponse: string): TIDApiResponse<Boolean>;
begin
  Result := ExecuteRequest(mtPost, AEndpoint, ABody);
  AResponse := FLastResponse;
end;

function TIntimaDigitalClient.Put(const AEndpoint: string; const ABody: string; out AResponse: string): TIDApiResponse<Boolean>;
begin
  Result := ExecuteRequest(mtPut, AEndpoint, ABody);
  AResponse := FLastResponse;
end;

function TIntimaDigitalClient.Dell(const AEndpoint: string; out AResponse: string): TIDApiResponse<Boolean>;
begin
  Result := ExecuteRequest(mtDelete, AEndpoint);
  AResponse := FLastResponse;
end;

function TIntimaDigitalClient.HasValidationError(const AResponse: string): Boolean;
begin
  Result := False;

  if AResponse.IsEmpty then
    Exit;

  Result := (AResponse.Contains('"Error"') and AResponse.Contains('"Msg"')) or
            (AResponse.Contains('"error"') and AResponse.Contains('"message"')) or
            AResponse.Contains('non_field_errors') or
            AResponse.Contains('validation_error') or
            AResponse.Contains('ValidationError') or
            AResponse.Contains('ErrorDetail') or
            AResponse.Contains('invalid') or
            AResponse.Contains('required') or
            (AResponse.Contains('"success"') and AResponse.Contains(':false')) or
            (AResponse.Contains('"Success"') and AResponse.Contains('[]'));
end;

function TIntimaDigitalClient.ExtractValidationErrorMessage(const AResponse: string): string;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  JsonValue: TJSONValue;
  ErrorArray: TJSONArray;
  ErrorFields: TStringList;
  i: Integer;
  MsgStr: string;
begin
  Result := '';

  if AResponse.IsEmpty then
    Exit;

  TIntimaDigitalAPIDebugLogger.Error(AResponse);
  try
    JsonObject := TJSONObject.ParseJSONValue(AResponse) as TJSONObject;
    if JsonObject = nil then
    begin
      if AResponse.Length < 500 then
        Result := AResponse
      else
        Result := Copy(AResponse, 1, 500) + '...';
      Exit;
    end;

    try
      if JsonObject.TryGetValue('Msg', JsonValue) then
      begin
        if JsonValue is TJSONArray then
        begin
          JsonArray := JsonValue as TJSONArray;
          if JsonArray.Count > 0 then
          begin
            MsgStr := JsonArray.Items[0].Value;
            MsgStr := StringReplace(MsgStr, '''', '"', [rfReplaceAll]);

            i := Pos('string=', MsgStr);
            if i > 0 then
            begin
              Delete(MsgStr, 1, i + 6);
              i := Pos(', code=', MsgStr);
              if i > 0 then
                Delete(MsgStr, i, Length(MsgStr));

              MsgStr := StringReplace(MsgStr, '{', '', [rfReplaceAll]);
              MsgStr := StringReplace(MsgStr, '}', '', [rfReplaceAll]);
              MsgStr := StringReplace(MsgStr, '[', '', [rfReplaceAll]);
              MsgStr := StringReplace(MsgStr, ']', '', [rfReplaceAll]);
              MsgStr := StringReplace(MsgStr, 'ErrorDetail', '', [rfReplaceAll]);
              MsgStr := StringReplace(MsgStr, 'non_field_errors:', '', [rfReplaceAll]);
              MsgStr := StringReplace(MsgStr, ':', '', [rfReplaceAll]);

              Result := Trim(MsgStr);
            end;
          end;
        end;
      end;

      if Result.IsEmpty and JsonObject.TryGetValue('Error', JsonValue) then
      begin
        if JsonValue is TJSONArray then
        begin
          ErrorArray := JsonValue as TJSONArray;
          if ErrorArray.Count > 0 then
          begin
            ErrorFields := TStringList.Create;
            try
              for i := 0 to ErrorArray.Count - 1 do
              begin
                ErrorFields.Add(ErrorArray.Items[i].Value);
              end;

              if ErrorFields.Count > 10 then
              begin
                Result := Format('%d campos com erro: %s...',
                  [ErrorFields.Count, String.Join(', ', ErrorFields.ToStringArray, 0, 10)]);
              end
              else
              begin
                Result := Format('Campos com erro: %s',
                  [String.Join(', ', ErrorFields.ToStringArray)]);
              end;
            finally
              ErrorFields.Free;
            end;
          end;
        end;
      end;

      if Result.IsEmpty then
      begin
        if JsonObject.TryGetValue('message', JsonValue) then
          Result := JsonValue.Value
        else if JsonObject.TryGetValue('error', JsonValue) then
          Result := JsonValue.Value
        else if JsonObject.TryGetValue('detail', JsonValue) then
          Result := JsonValue.Value;
      end;

      if Result.Length > 1000 then
        Result := Copy(Result, 1, 1000) + '...';

    finally
      JsonObject.Free;
    end;
  except
    on E: Exception do
    begin
      Result := 'Erro ao processar mensagem de validação: ' + E.Message;
    end;
  end;
end;

procedure TIntimaDigitalClient.UpdateAuthorizationHeader;
begin
  if not FConfig.Token.IsEmpty then
    FHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + FConfig.Token
  else
    FHttpClient.CustomHeaders['Authorization'] := '';
end;

function TIntimaDigitalClient.GetJson<T>(const AEndpoint: string): TIDApiResponse<T>;
var
  ApiResponse: TIDApiResponse<Boolean>;
begin
  LogJsonRequestStart(AEndpoint, 'GET');

  Result.Success := False;
  Result.Data := nil;
  Result.ErrorMessage := '';
  Result.StatusCode := 0;

  ApiResponse := ExecuteRequest(mtGet, AEndpoint);
  Result.StatusCode := ApiResponse.StatusCode;

  if ApiResponse.Success then
  begin
    if not FLastResponse.IsEmpty then
    begin
      if HasValidationError(FLastResponse) then
      begin
        Result.ErrorMessage := 'Erro de validação: ' + ExtractValidationErrorMessage(FLastResponse);
        Exit;
      end;

      try
        Result.Data := TJson.JsonToObject<T>(FLastResponse);
        Result.Success := True;
      except
        on E: Exception do
        begin
          Result.ErrorMessage := 'Erro ao converter JSON: ' + E.Message;
          if FLastResponse.Length > 1000 then
            Result.ErrorMessage := Result.ErrorMessage + ' (primeiros 1000 chars: ' + Copy(FLastResponse, 1, 1000) + '...)'
          else
            Result.ErrorMessage := Result.ErrorMessage + ' (JSON: ' + FLastResponse + ')';
        end;
      end;
    end
    else
    begin
      Result.Success := True;
    end;
  end
  else
  begin
    Result.ErrorMessage := ApiResponse.ErrorMessage;
  end;

  LogJsonRequestComplete<T>(AEndpoint, 'GET', Result, FLastResponse);
end;

function TIntimaDigitalClient.PostJson<T>(const AEndpoint: string; ABody: T): TIDApiResponse<T>;
var
  BodyJson: string;
  ApiResponse: TIDApiResponse<Boolean>;
begin
  Result.Success := False;
  Result.Data := nil;
  Result.ErrorMessage := '';
  Result.StatusCode := 0;

  try
    BodyJson := '';
    if Assigned(ABody) then
      BodyJson := SerializeObject(ABody);

    LogJsonRequestStart(AEndpoint, 'POST', BodyJson);

    ApiResponse := ExecuteRequest(mtPost, AEndpoint, BodyJson);
    Result.StatusCode := ApiResponse.StatusCode;

    if ApiResponse.Success then
    begin
      if not FLastResponse.IsEmpty then
      begin
        try
          Result.Data := TJson.JsonToObject<T>(FLastResponse);
          Result.Success := True;
        except
          on E: Exception do
          begin
            Result.ErrorMessage := 'Erro ao converter JSON: ' + E.Message;
          end;
        end;
      end
      else
      begin
        Result.Success := True;
      end;
    end
    else
    begin
      Result.ErrorMessage := ApiResponse.ErrorMessage;
    end;
  except
    on E: Exception do
    begin
      Result.ErrorMessage := 'Erro no PostJson: ' + E.Message;
    end;
  end;

  LogJsonRequestComplete<T>(AEndpoint, 'POST', Result, FLastResponse);
end;

function TIntimaDigitalClient.PutJson<T>(const AEndpoint: string; ABody: T): TIDApiResponse<T>;
var
  BodyJson: string;
  ApiResponse: TIDApiResponse<Boolean>;
begin
  Result.Success := False;
  Result.Data := nil;
  Result.ErrorMessage := '';
  Result.StatusCode := 0;

  try
    BodyJson := '';
    if Assigned(ABody) then
      BodyJson := SerializeObject(ABody);

    LogJsonRequestStart(AEndpoint, 'PUT', BodyJson);

    ApiResponse := ExecuteRequest(mtPut, AEndpoint, BodyJson);
    Result.StatusCode := ApiResponse.StatusCode;

    if ApiResponse.Success then
    begin
      if not FLastResponse.IsEmpty then
      begin
        try
          Result.Data := TJson.JsonToObject<T>(FLastResponse);
          Result.Success := True;
        except
          on E: Exception do
        begin
          Result.ErrorMessage := 'Erro ao converter JSON: ' + E.Message;
        end;
      end;
    end
    else
    begin
      Result.Success := True;
    end;
  end
  else
  begin
    Result.ErrorMessage := ApiResponse.ErrorMessage;
  end;
  except
    on E: Exception do
    begin
      Result.ErrorMessage := 'Erro no PutJson: ' + E.Message;
    end;
  end;

  LogJsonRequestComplete<T>(AEndpoint, 'PUT', Result, FLastResponse);
end;

function TIntimaDigitalClient.SerializeObject<T>(AObject: T): string;
begin
 Result := '';
  if not Assigned(AObject) then
    Exit;

  if AObject is TIntimaDigitalBaseModel then
  begin
    Result := TIntimaDigitalBaseModel(AObject).ToJson;
    Exit;
  end;

  Result := TryCallToJsonViaRTTI(AObject);
  if not Result.IsEmpty then
    Exit;

  Result := TJson.ObjectToJsonString(AObject, [joDateIsUTC, joDateFormatISO8601]);
end;

function TIntimaDigitalClient.DeleteJson<T>(const AEndpoint: string): TIDApiResponse<T>;
var
  ApiResponse: TIDApiResponse<Boolean>;
begin
  LogJsonRequestStart(AEndpoint, 'DELETE');

  Result.Success := False;
  Result.Data := nil;
  Result.ErrorMessage := '';
  Result.StatusCode := 0;

  ApiResponse := ExecuteRequest(mtDelete, AEndpoint);
  Result.StatusCode := ApiResponse.StatusCode;

  if ApiResponse.Success then
  begin
    if not FLastResponse.IsEmpty then
    begin
      try
        Result.Data := TJson.JsonToObject<T>(FLastResponse);
        Result.Success := True;
      except
        on E: Exception do
        begin
          Result.ErrorMessage := 'Erro ao converter JSON: ' + E.Message;
        end;
      end;
    end
    else
    begin
      Result.Success := True;
    end;
  end
  else
  begin
    Result.ErrorMessage := ApiResponse.ErrorMessage;
  end;

  LogJsonRequestComplete<T>(AEndpoint, 'DELETE', Result, FLastResponse);
end;

end.
