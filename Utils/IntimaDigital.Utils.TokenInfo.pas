unit IntimaDigital.Utils.TokenInfo;

interface

uses
  System.SysUtils, System.Classes, System.NetEncoding, System.JSON, System.DateUtils,
  System.StrUtils;

type
  TJWTTokenInfo = record
    TokenType: string;
    UserID: Integer;
    IssuedAt: TDateTime;
    ExpiresAt: TDateTime;
    TokenID: string;
    IsExpired: Boolean;
    ValidForHours: Double;
    ValidForDays: Double;
    SecondsRemaining: Int64;
    function ToString: string;
  end;

  EJWTException = class(Exception);

  TJWTHelper = class
  private
    class function Base64URLDecode(const Input: string): string; static;
    class function AddPadding(const Input: string): string; static;
  public
    class function DecodeToken(const Token: string): TJWTTokenInfo; static;
    class function IsTokenExpired(const Token: string): Boolean; static;
    class function GetExpirationDate(const Token: string): TDateTime; static;
    class function GetTimeRemaining(const Token: string): Int64; static;
    class function GetIssuedDate(const Token: string): TDateTime; static;
    class function GetUserID(const Token: string): Integer; static;
    class function GetTokenType(const Token: string): string; static;
    class function TokenWillExpireIn(const Token: string; Hours: Double): Boolean; static;

    class function UnixToDateTime(UnixTime: Int64; LocalTime: Boolean = True): TDateTime; static;
    class function DateTimeToUnix(ADateTime: TDateTime; LocalTime: Boolean = True): Int64; static;

    class function IsValidTokenFormat(const Token: string): Boolean; static;
  end;

implementation

const
  UnixDateDelta = 25569;

{ TJWTTokenInfo }

function TJWTTokenInfo.ToString: string;
var
  Dias, Horas, Minutos, Segundos: Integer;
  TempoRestanteStr: string;
begin
  if SecondsRemaining > 0 then
  begin
    Dias := SecondsRemaining div 86400;
    Horas := (SecondsRemaining mod 86400) div 3600;
    Minutos := (SecondsRemaining mod 3600) div 60;
    Segundos := SecondsRemaining mod 60;

    if Dias > 0 then
      TempoRestanteStr := Format('%d dias, %d horas, %d minutos, %d segundos',
        [Dias, Horas, Minutos, Segundos])
    else if Horas > 0 then
      TempoRestanteStr := Format('%d horas, %d minutos, %d segundos',
        [Horas, Minutos, Segundos])
    else if Minutos > 0 then
      TempoRestanteStr := Format('%d minutos, %d segundos', [Minutos, Segundos])
    else
      TempoRestanteStr := Format('%d segundos', [Segundos]);
  end
  else
    TempoRestanteStr := 'EXPIRADO';

  Result :=
    '=== INFORMAÇÕES DO TOKEN JWT ===' + sLineBreak +
    'Tipo de Token: ' + TokenType + sLineBreak +
    'ID do Usuário: ' + IntToStr(UserID) + sLineBreak +
    'ID do Token (JTI): ' + TokenID + sLineBreak +
    '---' + sLineBreak +
    'Emitido em: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', IssuedAt) + sLineBreak +
    'Expira em: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', ExpiresAt) + sLineBreak +
    '---' + sLineBreak +
    'Status: ' + IfThen(IsExpired, 'EXPIRADO', 'VÁLIDO') + sLineBreak +
    'Tempo restante: ' + TempoRestanteStr + sLineBreak +
    'Validade total: ' + FormatFloat('0.00', ValidForHours) + ' horas' +
    IfThen(ValidForDays >= 1,
      Format(' (%.2f dias)', [ValidForDays]), '');
end;

{ TJWTHelper }

class function TJWTHelper.Base64URLDecode(const Input: string): string;
var
  Base64Str: string;
begin
  Base64Str := StringReplace(Input, '-', '+', [rfReplaceAll]);
  Base64Str := StringReplace(Base64Str, '_', '/', [rfReplaceAll]);

  Base64Str := AddPadding(Base64Str);

  Result := TNetEncoding.Base64.Decode(Base64Str);
end;

class function TJWTHelper.AddPadding(const Input: string): string;
var
  PadLength: Integer;
begin
  Result := Input;
  PadLength := Length(Result) mod 4;
  if PadLength > 0 then
    Result := Result + StringOfChar('=', 4 - PadLength);
end;

class function TJWTHelper.DecodeToken(const Token: string): TJWTTokenInfo;
var
  Parts: TArray<string>;
  PayloadBase64, PayloadJSON: string;
  JSONObj: TJSONObject;
  ExpUnix, IatUnix: Int64;
  CurrentUnix: Int64;
begin
  if not IsValidTokenFormat(Token) then
    raise EJWTException.Create('Formato de token JWT inválido');

  Parts := Token.Split(['.']);
  if Length(Parts) <> 3 then
    raise EJWTException.Create('Token JWT não contém 3 partes');

  try
    PayloadBase64 := Parts[1];

    PayloadJSON := Base64URLDecode(PayloadBase64);

    JSONObj := TJSONObject.ParseJSONValue(PayloadJSON) as TJSONObject;
    if not Assigned(JSONObj) then
      raise EJWTException.Create('Não foi possível interpretar o payload JSON');

    try
      if Assigned(JSONObj.GetValue('token_type')) then
        Result.TokenType := JSONObj.GetValue('token_type').Value
      else
        Result.TokenType := '';

      if Assigned(JSONObj.GetValue('user_id')) then
        Result.UserID := (JSONObj.GetValue('user_id') as TJSONNumber).AsInt
      else
        Result.UserID := 0;

      if Assigned(JSONObj.GetValue('jti')) then
        Result.TokenID := JSONObj.GetValue('jti').Value
      else
        Result.TokenID := '';

      IatUnix := (JSONObj.GetValue('iat') as TJSONNumber).AsInt64;
      ExpUnix := (JSONObj.GetValue('exp') as TJSONNumber).AsInt64;

      Result.IssuedAt := UnixToDateTime(IatUnix);
      Result.ExpiresAt := UnixToDateTime(ExpUnix);

      Result.ValidForHours := (ExpUnix - IatUnix) / 3600;
      Result.ValidForDays := Result.ValidForHours / 24;

      CurrentUnix := DateTimeToUnix(Now);
      Result.IsExpired := CurrentUnix >= ExpUnix;
      Result.SecondsRemaining := ExpUnix - CurrentUnix;
      if Result.SecondsRemaining < 0 then
        Result.SecondsRemaining := 0;

    finally
      JSONObj.Free;
    end;

  except
    on E: EJSONException do
      raise EJWTException.Create('Erro ao processar JSON do token: ' + E.Message);
    on E: Exception do
      raise EJWTException.Create('Erro ao decodificar token: ' + E.Message);
  end;
end;

class function TJWTHelper.IsTokenExpired(const Token: string): Boolean;
var
  Info: TJWTTokenInfo;
begin
  Info := DecodeToken(Token);
  Result := Info.IsExpired;
end;

class function TJWTHelper.GetExpirationDate(const Token: string): TDateTime;
var
  Info: TJWTTokenInfo;
begin
  Info := DecodeToken(Token);
  Result := Info.ExpiresAt;
end;

class function TJWTHelper.GetTimeRemaining(const Token: string): Int64;
var
  Info: TJWTTokenInfo;
begin
  Info := DecodeToken(Token);
  Result := Info.SecondsRemaining;
end;

class function TJWTHelper.GetIssuedDate(const Token: string): TDateTime;
var
  Info: TJWTTokenInfo;
begin
  Info := DecodeToken(Token);
  Result := Info.IssuedAt;
end;

class function TJWTHelper.GetUserID(const Token: string): Integer;
var
  Info: TJWTTokenInfo;
begin
  Info := DecodeToken(Token);
  Result := Info.UserID;
end;

class function TJWTHelper.GetTokenType(const Token: string): string;
var
  Info: TJWTTokenInfo;
begin
  Info := DecodeToken(Token);
  Result := Info.TokenType;
end;

class function TJWTHelper.TokenWillExpireIn(const Token: string; Hours: Double): Boolean;
var
  Info: TJWTTokenInfo;
  SecondsThreshold: Int64;
begin
  Info := DecodeToken(Token);
  SecondsThreshold := Trunc(Hours * 3600);
  Result := Info.SecondsRemaining <= SecondsThreshold;
end;

class function TJWTHelper.UnixToDateTime(UnixTime: Int64; LocalTime: Boolean = True): TDateTime;
begin
  Result := UnixDateDelta + (UnixTime / 86400);
  if LocalTime then
    Result := TTimeZone.Local.ToLocalTime(Result);
end;

class function TJWTHelper.DateTimeToUnix(ADateTime: TDateTime; LocalTime: Boolean = True): Int64;
begin
  if LocalTime then
    ADateTime := TTimeZone.Local.ToUniversalTime(ADateTime);
  Result := Round((ADateTime - UnixDateDelta) * 86400);
end;

class function TJWTHelper.IsValidTokenFormat(const Token: string): Boolean;
var
  DotCount, I: Integer;
begin
  Result := False;

  if Token.Trim = '' then
    Exit;

  DotCount := 0;
  for I := 1 to Length(Token) do
    if Token[I] = '.' then
      Inc(DotCount);

  Result := (DotCount = 2);
end;

end.
