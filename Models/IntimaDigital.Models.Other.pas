unit IntimaDigital.Models.Other;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.Json,
  REST.Json.Types,
  System.Generics.Collections,
  IntimaDigital.Models.Base;

type
  TMailTemplate = class;
  TSmsTemplate = class;
  TWhatsappTemplate = class;
  TWhatsappSender = class;
  TTimeStamp = class;

  TMailTemplate = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('name')]
    FName: string;
    [JsonName('alias')]
    FAlias: string;
    [JsonName('html')]
    FHtml: string;
    [JsonName('is_active')]
    FIsActive: Boolean;
    [JsonName('created_at')]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    FUpdatedAt: TDateTime;
    [JsonName('default')]
    FDefault: Boolean;
    [JsonName('default_secondary')]
    FDefaultSecondary: Boolean;
    [JsonName('default_third_party')]
    FDefaultThirdParty: Boolean;
    [JsonName('template_purpose')]
    FTemplatePurpose: string;
    [JsonName('company_authorized')]
    FCompanyAuthorized: string;
  public
    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Alias: string read FAlias write FAlias;
    property Html: string read FHtml write FHtml;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property Default: Boolean read FDefault write FDefault;
    property DefaultSecondary: Boolean read FDefaultSecondary write FDefaultSecondary;
    property DefaultThirdParty: Boolean read FDefaultThirdParty write FDefaultThirdParty;
    property TemplatePurpose: string read FTemplatePurpose write FTemplatePurpose;
    property CompanyAuthorized: string read FCompanyAuthorized write FCompanyAuthorized;
    
    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TMailTemplate;
  end;

  TSmsTemplate = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('name')]
    FName: string;
    [JsonName('message')]
    FMessage: string;
    [JsonName('is_active')]
    FIsActive: Boolean;
    [JsonName('created_at')]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    FUpdatedAt: TDateTime;
    [JsonName('default')]
    FDefault: Boolean;
    [JsonName('default_secondary')]
    FDefaultSecondary: Boolean;
    [JsonName('default_third_party')]
    FDefaultThirdParty: Boolean;
    [JsonName('template_purpose')]
    FTemplatePurpose: string;
    [JsonName('company_authorized')]
    FCompanyAuthorized: string;
  public
    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Message: string read FMessage write FMessage;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property Default: Boolean read FDefault write FDefault;
    property DefaultSecondary: Boolean read FDefaultSecondary write FDefaultSecondary;
    property DefaultThirdParty: Boolean read FDefaultThirdParty write FDefaultThirdParty;
    property TemplatePurpose: string read FTemplatePurpose write FTemplatePurpose;
    property CompanyAuthorized: string read FCompanyAuthorized write FCompanyAuthorized;
    
    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TSmsTemplate;
  end;

  TWhatsappTemplate = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('name')]
    FName: string;
    [JsonName('message')]
    FMessage: string;
    [JsonName('is_active')]
    FIsActive: Boolean;
    [JsonName('created_at')]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    FUpdatedAt: TDateTime;
    [JsonName('default')]
    FDefault: Boolean;
    [JsonName('default_secondary')]
    FDefaultSecondary: Boolean;
    [JsonName('default_third_party')]
    FDefaultThirdParty: Boolean;
    [JsonName('template_purpose')]
    FTemplatePurpose: string;
    [JsonName('template_external_id')]
    FTemplateExternalId: string;
    [JsonName('company_authorized')]
    FCompanyAuthorized: string;
  public
    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Message: string read FMessage write FMessage;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property Default: Boolean read FDefault write FDefault;
    property DefaultSecondary: Boolean read FDefaultSecondary write FDefaultSecondary;
    property DefaultThirdParty: Boolean read FDefaultThirdParty write FDefaultThirdParty;
    property TemplatePurpose: string read FTemplatePurpose write FTemplatePurpose;
    property TemplateExternalId: string read FTemplateExternalId write FTemplateExternalId;
    property CompanyAuthorized: string read FCompanyAuthorized write FCompanyAuthorized;
    
    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TWhatsappTemplate;
  end;

  TWhatsappSenderEnvironment = (wseRECUPERI, wsePROTESTADO, wseNOTIFICA, 
                                wse4CURITIBA, wse1CARDOSO, wseSANTOANDRE, 
                                wseCANARANA, wseSOLFACIL, wseCAPACITAPRO);

  TWhatsappSender = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('current_send_capacity')]
    FCurrentSendCapacity: string;
    [JsonName('phone')]
    FPhone: string;
    [JsonName('environment')]
    FEnvironment: string;
    [JsonName('is_active')]
    FIsActive: Boolean;
    [JsonName('send_capacity')]
    FSendCapacity: Integer;
    [JsonName('created_at')]
    FCreatedAt: TDateTime;
    [JsonName('default')]
    FDefault: Boolean;
    [JsonName('service_external_id')]
    FServiceExternalId: string;
    [JsonName('service_external_token')]
    FServiceExternalToken: string;
    [JsonName('company_environment')]
    FCompanyEnvironment: Integer;
    
    function GetEnvironmentEnum: TWhatsappSenderEnvironment;
    procedure SetEnvironmentEnum(Value: TWhatsappSenderEnvironment);
  public
    property Id: string read FId write FId;
    property CurrentSendCapacity: string read FCurrentSendCapacity write FCurrentSendCapacity;
    property Phone: string read FPhone write FPhone;
    property Environment: string read FEnvironment write FEnvironment;
    property IsActive: Boolean read FIsActive write FIsActive;
    property SendCapacity: Integer read FSendCapacity write FSendCapacity;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property Default: Boolean read FDefault write FDefault;
    property ServiceExternalId: string read FServiceExternalId write FServiceExternalId;
    property ServiceExternalToken: string read FServiceExternalToken write FServiceExternalToken;
    property CompanyEnvironment: Integer read FCompanyEnvironment write FCompanyEnvironment;
    
    property EnvironmentEnum: TWhatsappSenderEnvironment read GetEnvironmentEnum
      write SetEnvironmentEnum;
    
    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TWhatsappSender;
    
    class function EnvironmentToString(Value: TWhatsappSenderEnvironment): string;
    class function StringToEnvironment(const Value: string): TWhatsappSenderEnvironment;
  end;

  TTimeStampType = (tstDOWNLOAD, tstREAD, tstACCESS);
  TTimeStampOrigin = (tsoBRY, tsoSER, tsoSAF);

  TTimeStamp = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('created_at')]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    FUpdatedAt: TDateTime;
    [JsonName('origin')]
    FOrigin: string;
    [JsonName('token')]
    FToken: string;
    [JsonName('document_nonce')]
    FDocumentNonce: string;
    [JsonName('time_stamp_nonce')]
    FTimeStampNonce: string;
    [JsonName('hash')]
    FHash: string;
    [JsonName('content')]
    FContent: string;
    [JsonName('hour')]
    FHour: TDateTime;
    [JsonName('signature')]
    FSignature: string;
    [JsonName('type')]
    FType: string;
    [JsonName('log')]
    FLog: string;
    [JsonName('dt_billing')]
    FDtBilling: TDateTime;
    [JsonName('zip_path')]
    FZipPath: string;
    [JsonName('notification')]
    FNotification: string;
    
    function GetTimeStampTypeEnum: TTimeStampType;
    procedure SetTimeStampTypeEnum(Value: TTimeStampType);
    function GetTimeStampOriginEnum: TTimeStampOrigin;
    procedure SetTimeStampOriginEnum(Value: TTimeStampOrigin);
    function GetLog: string;
    function GetNotification: string;
  public
    property Id: string read FId write FId;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property Origin: string read FOrigin write FOrigin;
    property Token: string read FToken write FToken;
    property DocumentNonce: string read FDocumentNonce write FDocumentNonce;
    property TimeStampNonce: string read FTimeStampNonce write FTimeStampNonce;
    property Hash: string read FHash write FHash;
    property Content: string read FContent write FContent;
    property Hour: TDateTime read FHour write FHour;
    property Signature: string read FSignature write FSignature;
    property TimeStampType: string read FType write FType;
    property Log: string read GetLog write FLog;
    property DtBilling: TDateTime read FDtBilling write FDtBilling;
    property ZipPath: string read FZipPath write FZipPath;
    property Notification: string read GetNotification write FNotification;
    
    property TimeStampTypeEnum: TTimeStampType read GetTimeStampTypeEnum write SetTimeStampTypeEnum;
    property TimeStampOriginEnum: TTimeStampOrigin read GetTimeStampOriginEnum write SetTimeStampOriginEnum;
    
    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TTimeStamp;
    
    class function TimeStampTypeToString(Value: TTimeStampType): string;
    class function StringToTimeStampType(const Value: string): TTimeStampType;
    class function TimeStampOriginToString(Value: TTimeStampOrigin): string;
    class function StringToTimeStampOrigin(const Value: string): TTimeStampOrigin;
  end;

implementation

uses
  System.DateUtils,
  System.StrUtils;

{ TMailTemplate }
//
//class function TMailTemplate.FromJson(const AJson: string): TMailTemplate;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TMailTemplate>(AJson);
//end;

//function TMailTemplate.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TSmsTemplate }

//class function TSmsTemplate.FromJson(const AJson: string): TSmsTemplate;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TSmsTemplate>(AJson);
//end;

//function TSmsTemplate.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TWhatsappTemplate }

//class function TWhatsappTemplate.FromJson(const AJson: string): TWhatsappTemplate;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TWhatsappTemplate>(AJson);
//end;

//function TWhatsappTemplate.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TWhatsappSender }

class function TWhatsappSender.EnvironmentToString(Value: TWhatsappSenderEnvironment): string;
begin
  case Value of
    wseRECUPERI: Result := 'RECUPERI';
    wsePROTESTADO: Result := 'PROTESTADO';
    wseNOTIFICA: Result := 'NOTIFICA';
    wse4CURITIBA: Result := '4CURITIBA';
    wse1CARDOSO: Result := '1CARDOSO';
    wseSANTOANDRE: Result := 'SANTOANDRE';
    wseCANARANA: Result := 'CANARANA';
    wseSOLFACIL: Result := 'SOLFACIL';
    wseCAPACITAPRO: Result := 'CAPACITAPRO';
  else
    Result := '';
  end;
end;

//class function TWhatsappSender.FromJson(const AJson: string): TWhatsappSender;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TWhatsappSender>(AJson);
//end;

function TWhatsappSender.GetEnvironmentEnum: TWhatsappSenderEnvironment;
begin
  Result := StringToEnvironment(FEnvironment);
end;

class function TWhatsappSender.StringToEnvironment(const Value: string): TWhatsappSenderEnvironment;
begin
  if Value = 'RECUPERI' then
    Result := wseRECUPERI
  else if Value = 'PROTESTADO' then
    Result := wsePROTESTADO
  else if Value = 'NOTIFICA' then
    Result := wseNOTIFICA
  else if Value = '4CURITIBA' then
    Result := wse4CURITIBA
  else if Value = '1CARDOSO' then
    Result := wse1CARDOSO
  else if Value = 'SANTOANDRE' then
    Result := wseSANTOANDRE
  else if Value = 'CANARANA' then
    Result := wseCANARANA
  else if Value = 'SOLFACIL' then
    Result := wseSOLFACIL
  else if Value = 'CAPACITAPRO' then
    Result := wseCAPACITAPRO
  else
    Result := wseNOTIFICA;
end;

procedure TWhatsappSender.SetEnvironmentEnum(Value: TWhatsappSenderEnvironment);
begin
  FEnvironment := EnvironmentToString(Value);
end;

//function TWhatsappSender.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TTimeStamp }

//class function TTimeStamp.FromJson(const AJson: string): TTimeStamp;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TTimeStamp>(AJson);
//end;

function TTimeStamp.GetLog: string;
begin
  Result := FLog;
end;

function TTimeStamp.GetNotification: string;
begin
  Result := FNotification;
end;

function TTimeStamp.GetTimeStampOriginEnum: TTimeStampOrigin;
begin
  Result := StringToTimeStampOrigin(FOrigin);
end;

function TTimeStamp.GetTimeStampTypeEnum: TTimeStampType;
begin
  Result := StringToTimeStampType(FType);
end;

procedure TTimeStamp.SetTimeStampOriginEnum(Value: TTimeStampOrigin);
begin
  FOrigin := TimeStampOriginToString(Value);
end;

procedure TTimeStamp.SetTimeStampTypeEnum(Value: TTimeStampType);
begin
  FType := TimeStampTypeToString(Value);
end;

class function TTimeStamp.StringToTimeStampOrigin(const Value: string): TTimeStampOrigin;
begin
  if Value = 'BRY' then
    Result := tsoBRY
  else if Value = 'SER' then
    Result := tsoSER
  else if Value = 'SAF' then
    Result := tsoSAF
  else
    Result := tsoBRY;
end;

class function TTimeStamp.StringToTimeStampType(const Value: string): TTimeStampType;
begin
  if Value = 'DOWNLOAD' then
    Result := tstDOWNLOAD
  else if Value = 'READ' then
    Result := tstREAD
  else if Value = 'ACCESS' then
    Result := tstACCESS
  else
    Result := tstDOWNLOAD;
end;

class function TTimeStamp.TimeStampOriginToString(Value: TTimeStampOrigin): string;
begin
  case Value of
    tsoBRY: Result := 'BRY';
    tsoSER: Result := 'SER';
    tsoSAF: Result := 'SAF';
  else
    Result := '';
  end;
end;

class function TTimeStamp.TimeStampTypeToString(Value: TTimeStampType): string;
begin
  case Value of
    tstDOWNLOAD: Result := 'DOWNLOAD';
    tstREAD: Result := 'READ';
    tstACCESS: Result := 'ACCESS';
  else
    Result := '';
  end;
end;

//function TTimeStamp.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

end.