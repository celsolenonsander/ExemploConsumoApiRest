unit IntimaDigital.Auth.Service;

interface

uses
  System.SysUtils,
  System.JSON,
  REST.Json,
  IntimaDigital.Types,
  IntimaDigital.Config,
  IntimaDigital.Client,
  IntimaDigital.Utils.TokenInfo;

type
  TAuthResponse = class
  private
    FAccess: string;
    FRefresh: string;
    FUsername: string;
    FName: string;
    FIsSuperuser: Boolean;
    FEmail: string;
    FCompany: string;
  public
    property Access: string read FAccess write FAccess;
    property Refresh: string read FRefresh write FRefresh;
    property Username: string read FUsername write FUsername;
    property Name: string read FName write FName;
    property IsSuperuser: Boolean read FIsSuperuser write FIsSuperuser;
    property Email: string read FEmail write FEmail;
    property Company: string read FCompany write FCompany;

    function Token: String;

    function ToJson: string;
    class function FromJson(const AJson: string): TAuthResponse;
  end;

  TIntimaDigitalAuthService = class
  private
    FClient: TIntimaDigitalClient;
    FConfig: TIntimaDigitalConfig;
  public
    constructor Create(AClient: TIntimaDigitalClient; AConfig: TIntimaDigitalConfig);
    
    function Authenticate(const AUsername, APassword: string): TIDApiResponse<Boolean>;
    function RefreshToken: TIDApiResponse<Boolean>;
    function Logout: TIDApiResponse<Boolean>;
    
    property Client: TIntimaDigitalClient read FClient;
    property Config: TIntimaDigitalConfig read FConfig;
  end;

implementation

uses
  System.DateUtils;

{ TAuthResponse }

class function TAuthResponse.FromJson(const AJson: string): TAuthResponse;
begin
  Result := TJson.JsonToObject<TAuthResponse>(AJson);
end;

function TAuthResponse.ToJson: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

function TAuthResponse.Token: String;
begin
  Result := FAccess;
end;

{ TIntimaDigitalAuthService }

constructor TIntimaDigitalAuthService.Create(AClient: TIntimaDigitalClient; 
  AConfig: TIntimaDigitalConfig);
begin
  inherited Create;
  FClient := AClient;
  FConfig := AConfig;
end;

function TIntimaDigitalAuthService.Authenticate(const AUsername, APassword: string): TIDApiResponse<Boolean>;
var
  AuthJson: TJSONObject;
  ResponseStr: string;
  AuthResponse: TAuthResponse;
  ApiResponse: TIDApiResponse<Boolean>;
begin
  Result.Success := False;
  Result.ErrorMessage := '';
  
  FConfig.ClearAuth;

  AuthJson := TJSONObject.Create;
  try
    AuthJson.AddPair('username', AUsername);
    AuthJson.AddPair('password', APassword);
    
    ApiResponse := FClient.Post('jwt/obtain/', AuthJson.ToJSON, ResponseStr);
    Result.StatusCode := ApiResponse.StatusCode;
    
    if ApiResponse.Success then
    begin
      try
        AuthResponse := TAuthResponse.FromJson(ResponseStr);
        try
          FConfig.Token := AuthResponse.Token;
          FConfig.RefreshToken := AuthResponse.Refresh;
          FConfig.TokenExpiration := TJWTHelper.DecodeToken(AuthResponse.Token).ExpiresAt;

          FConfig.Username := AUsername;
          FConfig.Password := APassword;
          
          Result.Success := True;
        finally
          AuthResponse.Free;
        end;
      except
        on E: Exception do
          Result.ErrorMessage := 'Erro ao processar resposta de autenticação: ' + E.Message;
      end;
    end
    else
    begin
      Result.ErrorMessage := ApiResponse.ErrorMessage;
    end;
    
  finally
    AuthJson.Free;
  end;
end;

function TIntimaDigitalAuthService.Logout: TIDApiResponse<Boolean>;
begin
  Result.Success := False;
  
  try
    FConfig.ClearAuth;
    Result.Success := True;
  except
    on E: Exception do
      Result.ErrorMessage := 'Erro ao fazer logout: ' + E.Message;
  end;
end;

function TIntimaDigitalAuthService.RefreshToken: TIDApiResponse<Boolean>;
var
  RefreshJson: TJSONObject;
  ResponseStr: string;
  AuthResponse: TAuthResponse;
  ApiResponse: TIDApiResponse<Boolean>;
begin
  Result.Success := False;
  Result.ErrorMessage := '';
  
  if FConfig.RefreshToken.IsEmpty then
  begin
    Result.ErrorMessage := 'Refresh token não disponível';
    Exit;
  end;
  
  RefreshJson := TJSONObject.Create;
  try
    RefreshJson.AddPair('refresh', FConfig.RefreshToken);
    
    ApiResponse := FClient.Post('jwt/refresh/', RefreshJson.ToJSON, ResponseStr);
    Result.StatusCode := ApiResponse.StatusCode;
    
    if ApiResponse.Success then
    begin
      try
        AuthResponse := TAuthResponse.FromJson(ResponseStr);
        try
          FConfig.Token := AuthResponse.Token;
          if not AuthResponse.Refresh.IsEmpty then
            FConfig.RefreshToken := AuthResponse.Refresh;
          
          FConfig.TokenExpiration := TJWTHelper.DecodeToken(AuthResponse.Token).ExpiresAt;
          
          Result.Success := True;
        finally
          AuthResponse.Free;
        end;
      except
        on E: Exception do
          Result.ErrorMessage := 'Erro ao processar refresh token: ' + E.Message;
      end;
    end
    else
    begin
      Result.ErrorMessage := ApiResponse.ErrorMessage;
    end;
    
  finally
    RefreshJson.Free;
  end;
end;

end.