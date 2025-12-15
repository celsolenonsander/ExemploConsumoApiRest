unit IntimaDigital.Notification.Service;

interface

uses
  System.SysUtils,
  System.DateUtils,
  IntimaDigital.Types,
  IntimaDigital.Client,
  IntimaDigital.Models.Notification,
  IntimaDigital.Models.Contact;

type
  TNotificationFilter = record
    Id: string;
    NotifiedDocumentNumber: string;
    Protocol: string;
    Limit: Integer;
    Offset: Integer;
    EnrichSms: Boolean;
    EnrichWhatsapp: Boolean;
    EnrichEmail: Boolean;
    EnrichAddress: Boolean;
    EnrichScore: Boolean;
    DtEnrichment: TDateTime;
    CreatedFrom: TDateTime;
    CreatedTo: TDateTime;
    
    function ToQueryString: string;
    class function Create: TNotificationFilter; static;
  end;

  TNotificationDetailFilter = record
    CompanyId: string;
    Id: string;
    Pdf: Boolean;
    
    function ToQueryString: string;
    class function Create: TNotificationDetailFilter; static;
  end;

  TIntimaDigitalNotificationService = class
  private
    FClient: TIntimaDigitalClient;
    
    function BuildQueryString(const BaseURL: string; const Filter: TNotificationFilter): string; overload;
    function BuildQueryString(const BaseURL: string; const Filter: TNotificationDetailFilter): string; overload;
  public
    constructor Create(AClient: TIntimaDigitalClient);
    
    function UploadNotification(ANotification: TApiNotificationList): TIDApiResponse<TApiNotificationList>; overload;
    function UploadNotification(AStrJSon: String): TIDApiResponse<Boolean>; overload;

    function GetNotificationContactsReport(const Filter: TNotificationFilter): TIDApiResponse<TNotificationResponse>;
    function GetNotificationDetail(const Filter: TNotificationDetailFilter): TIDApiResponse<TNotificationResponse>;

    function CreatePrimaryNotification(const AProtocol: string;
      const ADtProtocol: TDateTime; const ANotifiedName, ANotifiedDocument: string;
      const AFileContent: string; ADtLimit: TDateTime): TApiNotification;
    
    function CreateThirdPartyNotification(const AProtocol: string; 
      const ADtProtocol: TDateTime; const ANotifiedName, ANotifiedDocument: string;
      const ADestinationURL: string; ADtLimit: TDateTime): TApiNotification;
    
    property Client: TIntimaDigitalClient read FClient;
  end;

implementation

{ TNotificationFilter }

class function TNotificationFilter.Create: TNotificationFilter;
begin
  Result.Id := '';
  Result.NotifiedDocumentNumber := '';
  Result.Protocol := '';
  Result.Limit := 0;
  Result.Offset := 0;
  Result.EnrichSms := False;
  Result.EnrichWhatsapp := False;
  Result.EnrichEmail := False;
  Result.EnrichAddress := False;
  Result.EnrichScore := False;
  Result.DtEnrichment := 0;
  Result.CreatedFrom := 0;
  Result.CreatedTo := 0;
end;

function TNotificationFilter.ToQueryString: string;
var
  Params: TArray<string>;
begin
  Params := [];
  
  if not Id.IsEmpty then
    Params := Params + ['id=' + Id];
    
  if not NotifiedDocumentNumber.IsEmpty then
    Params := Params + ['notified_document_number=' + NotifiedDocumentNumber];
    
  if not Protocol.IsEmpty then
    Params := Params + ['protocol=' + Protocol];
    
  if Limit > 0 then
    Params := Params + ['limit=' + Limit.ToString];
    
  if Offset > 0 then
    Params := Params + ['offset=' + Offset.ToString];
    
  if EnrichSms then
    Params := Params + ['enrich_sms=true'];
    
  if EnrichWhatsapp then
    Params := Params + ['enrich_whatsapp=true'];
    
  if EnrichEmail then
    Params := Params + ['enrich_email=true'];
    
  if EnrichAddress then
    Params := Params + ['enrich_address=true'];
    
  if EnrichScore then
    Params := Params + ['enrich_score=true'];
    
  if DtEnrichment > 0 then
    Params := Params + ['dt_enrichment=' + DateToISO8601(DtEnrichment)];
    
  if CreatedFrom > 0 then
    Params := Params + ['created_from=' + DateToISO8601(CreatedFrom)];
    
  if CreatedTo > 0 then
    Params := Params + ['created_to=' + DateToISO8601(CreatedTo)];
    
  if Length(Params) > 0 then
    Result := '?' + string.Join('&', Params)
  else
    Result := '';
end;

{ TNotificationDetailFilter }

class function TNotificationDetailFilter.Create: TNotificationDetailFilter;
begin
  Result.CompanyId := '';
  Result.Id := '';
  Result.Pdf := False;
end;

function TNotificationDetailFilter.ToQueryString: string;
var
  Params: TArray<string>;
begin
  Params := [];
  
  if not CompanyId.IsEmpty then
    Params := Params + ['company_id=' + CompanyId];
    
  if not Id.IsEmpty then
    Params := Params + ['id=' + Id];
    
  if Pdf then
    Params := Params + ['pdf=true'];
    
  if (Length(Params) > 0) then
    Result := '?' + string.Join('&', Params)
  else
    Result := '';
end;

{ TIntimaDigitalNotificationService }

function TIntimaDigitalNotificationService.BuildQueryString(const BaseURL: string; 
  const Filter: TNotificationFilter): string;
begin
  Result := BaseURL + Filter.ToQueryString;
end;

function TIntimaDigitalNotificationService.BuildQueryString(const BaseURL: string; 
  const Filter: TNotificationDetailFilter): string;
begin
  Result := BaseURL + Filter.ToQueryString;
end;

constructor TIntimaDigitalNotificationService.Create(AClient: TIntimaDigitalClient);
begin
  inherited Create;
  FClient := AClient;
end;

function TIntimaDigitalNotificationService.CreatePrimaryNotification(const AProtocol: string; 
  const ADtProtocol: TDateTime; const ANotifiedName, ANotifiedDocument: string;
  const AFileContent: string; ADtLimit: TDateTime): TApiNotification;
begin
  Result := TApiNotification.Create;
  try
    Result.Protocol := AProtocol;
    Result.DtProtocol := ADtProtocol;
    Result.NotifiedName := ANotifiedName;
    Result.NotifiedDocumentNumber := ANotifiedDocument;
    Result.FileContent := AFileContent;
    Result.NotificationType := 'primary';
    Result.DtLimit := ADtLimit;
    Result.SendEmail := False;
    Result.SendSms := False;
    Result.SendWhatsapp := False;
    Result.TimeStamp := False;
  except
    Result.Free;
    raise;
  end;
end;

function TIntimaDigitalNotificationService.CreateThirdPartyNotification(const AProtocol: string; 
  const ADtProtocol: TDateTime; const ANotifiedName, ANotifiedDocument: string;
  const ADestinationURL: string; ADtLimit: TDateTime): TApiNotification;
begin
  Result := TApiNotification.Create;
  try
    Result.Protocol := AProtocol;
    Result.DtProtocol := ADtProtocol;
    Result.NotifiedName := ANotifiedName;
    Result.NotifiedDocumentNumber := ANotifiedDocument;
    Result.DestinationUrl := ADestinationURL;
    Result.NotificationType := 'third_party';
    Result.DtLimit := ADtLimit;
    Result.SendEmail := False;
    Result.SendSms := False;
    Result.SendWhatsapp := False;
  except
    Result.Free;
    raise;
  end;
end;

function TIntimaDigitalNotificationService.GetNotificationContactsReport(
  const Filter: TNotificationFilter): TIDApiResponse<TNotificationResponse>;
var
  Endpoint: string;
begin
  Endpoint := 'notification/api/notification/contacts/report/';
  Endpoint := BuildQueryString(Endpoint, Filter);
  
  Result := FClient.GetJson<TNotificationResponse>(Endpoint);
end;

function TIntimaDigitalNotificationService.GetNotificationDetail(
  const Filter: TNotificationDetailFilter): TIDApiResponse<TNotificationResponse>;
var
  Endpoint: string;
begin
  Endpoint := 'notification/api/notification/detail/';
  Endpoint := BuildQueryString(Endpoint, Filter);
  
  Result := FClient.GetJson<TNotificationResponse>(Endpoint);
end;

function TIntimaDigitalNotificationService.UploadNotification(
  AStrJSon: String): TIDApiResponse<Boolean>;
var
  lResponse: String;
begin
  Result := FClient.Post('notification/api/notification-upload-json/', AStrJSon, lResponse);
  Result.DataStr := lResponse;
end;

function TIntimaDigitalNotificationService.UploadNotification(
  ANotification: TApiNotificationList): TIDApiResponse<TApiNotificationList>;

begin
  Result := FClient.PostJson<TApiNotificationList>('notification/api/notification-upload-json/', ANotification);
end;

end.