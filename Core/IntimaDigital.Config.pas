unit IntimaDigital.Config;

interface

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils,
  IntimaDigital.Types;

type
  TIntimaDigitalConfig = class
  private
    FBaseURL: string;
    FUsername: string;
    FPassword: string;
    FToken: string;
    FRefreshToken: string;
    FTokenExpiration: TDateTime;
    FEnvironment: TIDEnvironment;
    FTimeout: Integer;
    FRetryCount: Integer;
    FRetryDelay: Integer;
    FFileName: string;
    
    function GetIsAuthenticated: Boolean;
    function GetIsTokenExpired: Boolean;
    procedure SetFileName(const Value: string);
  public
    constructor Create;
    
    procedure LoadFromIni(const AFileName: string = '');
    procedure SaveToIni(const AFileName: string = '');
    procedure ClearAuth;
    
    property BaseURL: string read FBaseURL write FBaseURL;
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
    property Token: string read FToken write FToken;
    property RefreshToken: string read FRefreshToken write FRefreshToken;
    property TokenExpiration: TDateTime read FTokenExpiration write FTokenExpiration;
    property Environment: TIDEnvironment read FEnvironment write FEnvironment;
    property Timeout: Integer read FTimeout write FTimeout;
    property RetryCount: Integer read FRetryCount write FRetryCount;
    property RetryDelay: Integer read FRetryDelay write FRetryDelay;
    property FileName: string read FFileName write SetFileName;

    property IsAuthenticated: Boolean read GetIsAuthenticated;
    property IsTokenExpired: Boolean read GetIsTokenExpired;

    function GetFullURL(const AEndpoint: string): string;
  end;

implementation

const
  DEFAULT_TIMEOUT = 30000;
  DEFAULT_RETRY_COUNT = 3;
  DEFAULT_RETRY_DELAY = 1000;
  
  PRODUCTION_URL = 'https://api.intimadigital.com.br/';
  HOMOLOGATION_URL = 'https://api.hom.intimadigital.com.br/';

{ TIntimaDigitalConfig }

constructor TIntimaDigitalConfig.Create;
begin
  inherited;
  FEnvironment := envHomologation;
  FTimeout := DEFAULT_TIMEOUT;
  FRetryCount := DEFAULT_RETRY_COUNT;
  FRetryDelay := DEFAULT_RETRY_DELAY;
  FTokenExpiration := 0;
end;

procedure TIntimaDigitalConfig.ClearAuth;
begin
  FToken := '';
  FRefreshToken := '';
  FTokenExpiration := 0;
end;

function TIntimaDigitalConfig.GetFullURL(const AEndpoint: string): string;
begin
  if FBaseURL.IsEmpty then
  begin
    case FEnvironment of
      envProduction: Result := PRODUCTION_URL;
      envHomologation: Result := HOMOLOGATION_URL;
    else
      Result := HOMOLOGATION_URL;
    end;
  end
  else
  begin
    Result := FBaseURL;
  end;
  
  if not Result.EndsWith('/') then
    Result := Result + '/';
    
  if AEndpoint.StartsWith('/') then
    Result := Result + AEndpoint.Substring(1)
  else
    Result := Result + AEndpoint;
end;

function TIntimaDigitalConfig.GetIsAuthenticated: Boolean;
begin
  Result := not FToken.IsEmpty and not GetIsTokenExpired;
end;

function TIntimaDigitalConfig.GetIsTokenExpired: Boolean;
begin
  Result := (FTokenExpiration > 0) and (Now > FTokenExpiration);
end;

procedure TIntimaDigitalConfig.LoadFromIni(const AFileName: string);
var
  IniFile: TIniFile;
begin
  if AFileName.IsEmpty then
    FileName := TPath.Combine(TPath.GetDocumentsPath, 'IntimaDigital.ini')
  else
    FileName := AFileName;
    
  if not TFile.Exists(FileName) then
    Exit;
    
  IniFile := TIniFile.Create(FileName);
  try
    FBaseURL := IniFile.ReadString('API', 'BaseURL', '');
    FUsername := IniFile.ReadString('API', 'Username', '');
    FPassword := IniFile.ReadString('API', 'Password', '');
    FEnvironment := TIDEnvironment(IniFile.ReadInteger('API', 'Environment', 0));
    FTimeout := IniFile.ReadInteger('API', 'Timeout', DEFAULT_TIMEOUT);
    FRetryCount := IniFile.ReadInteger('API', 'RetryCount', DEFAULT_RETRY_COUNT);
    FRetryDelay := IniFile.ReadInteger('API', 'RetryDelay', DEFAULT_RETRY_DELAY);
  finally
    IniFile.Free;
  end;
end;

procedure TIntimaDigitalConfig.SaveToIni(const AFileName: string);
var
  IniFile: TIniFile;
  FileName: string;
begin
  if AFileName.IsEmpty then
    FileName := TPath.Combine(TPath.GetDocumentsPath, 'IntimaDigital.ini')
  else
    FileName := AFileName;
    
  IniFile := TIniFile.Create(FileName);
  try
    IniFile.WriteString('API', 'BaseURL', FBaseURL);
    IniFile.WriteString('API', 'Username', FUsername);
    IniFile.WriteInteger('API', 'Environment', Ord(FEnvironment));
    IniFile.WriteInteger('API', 'Timeout', FTimeout);
    IniFile.WriteInteger('API', 'RetryCount', FRetryCount);
    IniFile.WriteInteger('API', 'RetryDelay', FRetryDelay);
  finally
    IniFile.Free;
  end;
end;

procedure TIntimaDigitalConfig.SetFileName(const Value: string);
begin
  FFileName := Value;
end;

end.
