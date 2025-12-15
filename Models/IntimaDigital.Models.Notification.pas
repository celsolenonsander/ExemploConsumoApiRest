unit IntimaDigital.Models.Notification;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.Json,
  REST.Json.Types,
  System.Generics.Collections,
  IntimaDigital.Models.Base,
  IntimaDigital.Models.Contact,
  IntimaDigital.Utils.JSon;

type
  TNotificationType = (ntPrimary, ntSecondary, ntThirdParty, ntEnrichment);
  TNotificationOrigin = (noAPI, noManual, noPanel);
  TDataOrigin = (doDataEnrichment, doSender, doReuse, doManual);
  TApprovalStatus = (asWaitingContact, asPending, asWaitingSend, asProcessing,
    asSent, asEnrichmentFailed, asEnrichmentExpired, asCompleted, asCancelled,
    asExpired, asDuplicated, asWaitingRanking, asProcessingRanking, asCompletedNotSent);
  TNotificationPurpose = (npCancellation, npPreProtest);
  TDocumentType = (dtCPF, dtCNPJ);

  TNotification = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    [JSONSkipIfEmpty]
    FId: string;
    [JsonName('name')]
    [JSONSkipIfEmpty]
    FName: string;
    [JsonName('description')]
    [JSONSkipIfEmpty]
    FDescription: string;
    [JsonName('notified_name')]
    [JSONSkipIfEmpty]
    FNotifiedName: string;
    [JsonName('notified_document_number')]
    [JSONSkipIfEmpty]
    FNotifiedDocumentNumber: string;
    [JsonName('notified_document_type')]
    [JSONSkipIfEmpty]
    FNotifiedDocumentType: string;
    [JsonName('send_sms')]
    [JSONSkipIfEmpty]
    FSendSms: Boolean;
    [JsonName('send_whatsapp')]
    [JSONSkipIfEmpty]
    FSendWhatsapp: Boolean;
    [JsonName('file_url')]
    [JSONSkipIfEmpty]
    FFileUrl: string;
    [JsonName('is_active')]
    [JSONSkipIfEmpty]
    FIsActive: Boolean;
    [JsonName('created_at')]
    [JSONSkipIfEmpty]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    [JSONSkipIfEmpty]
    FUpdatedAt: TDateTime;
    [JsonName('protocol')]
    [JSONSkipIfEmpty]
    FProtocol: string;
    [JsonName('dt_protocol')]
    [JSONSkipIfEmpty]
    FDtProtocol: TDateTime;
    [JsonName('dt_limit')]
    [JSONSkipIfEmpty]
    FDtLimit: TDateTime;
    [JsonName('file_content')]
    [JSONSkipIfEmpty]
    FFileContent: string;
    [JsonName('partner_field')]
    [JSONSkipIfEmpty]
    FPartnerField: string;
    [JsonName('notification_origin')]
    [JSONSkipIfEmpty]
    FNotificationOrigin: string;
    [JsonName('data_origin')]
    [JSONSkipIfEmpty]
    FDataOrigin: string;
    [JsonName('approval_status')]
    [JSONSkipIfEmpty]
    FApprovalStatus: string;
    [JsonName('send_email')]
    [JSONSkipIfEmpty]
    FSendEmail: Boolean;
    [JsonName('destination_url')]
    [JSONSkipIfEmpty]
    FDestinationUrl: string;
    [JsonName('notification_type')]
    [JSONSkipIfEmpty]
    FNotificationType: string;
    [JsonName('vl_protest')]
    [JSONSkipIfEmpty]
    FVlProtest: string;
    [JsonName('vl_fee')]
    [JSONSkipIfEmpty]
    FVlFee: string;
    [JsonName('enrich_email')]
    [JSONSkipIfEmpty]
    FEnrichEmail: Boolean;
    [JsonName('enrich_whatsapp')]
    [JSONSkipIfEmpty]
    FEnrichWhatsapp: Boolean;
    [JsonName('enrich_sms')]
    [JSONSkipIfEmpty]
    FEnrichSms: Boolean;
    [JsonName('enrich_score')]
    [JSONSkipIfEmpty]
    FEnrichScore: Boolean;
    [JsonName('enrich_address')]
    [JSONSkipIfEmpty]
    FEnrichAddress: Boolean;
    [JsonName('dt_enrichment')]
    [JSONSkipIfEmpty]
    FDtEnrichment: TDateTime;
    [JsonName('dt_billing')]
    [JSONSkipIfEmpty]
    FDtBilling: TDateTime;
    [JsonName('notification_purpose')]
    [JSONSkipIfEmpty]
    FNotificationPurpose: string;
    [JsonName('title_number')]
    [JSONSkipIfEmpty]
    FTitleNumber: string;
    [JsonName('company_user')]
    [JSONSkipIfEmpty]
    FCompanyUser: string;
    [JsonName('company')]
    [JSONSkipIfEmpty]
    FCompany: string;
    [JsonName('contacts')]
    [JSONSkipIfEmpty]
    FContacts: TArray<string>;
    [JsonName('notification_code')]
    [JSONSkipIfEmpty]
    FNotificationCode: string;

    function GetNotificationTypeEnum: TNotificationType;
    procedure SetNotificationTypeEnum(Value: TNotificationType);
    function GetNotificationPurposeEnum: TNotificationPurpose;
    procedure SetNotificationPurposeEnum(Value: TNotificationPurpose);
    function GetDocumentTypeEnum: TDocumentType;
    procedure SetDocumentTypeEnum(Value: TDocumentType);

  public
    constructor Create; override;

    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property NotifiedName: string read FNotifiedName write FNotifiedName;
    property NotifiedDocumentNumber: string read FNotifiedDocumentNumber write FNotifiedDocumentNumber;
    property NotifiedDocumentType: string read FNotifiedDocumentType write FNotifiedDocumentType;
    property SendSms: Boolean read FSendSms write FSendSms;
    property SendWhatsapp: Boolean read FSendWhatsapp write FSendWhatsapp;
    property FileUrl: string read FFileUrl write FFileUrl;
    property IsActive: Boolean read FIsActive write FIsActive;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property Protocol: string read FProtocol write FProtocol;
    property DtProtocol: TDateTime read FDtProtocol write FDtProtocol;
    property DtLimit: TDateTime read FDtLimit write FDtLimit;
    property FileContent: string read FFileContent write FFileContent;
    property PartnerField: string read FPartnerField write FPartnerField;
    property NotificationOrigin: string read FNotificationOrigin write FNotificationOrigin;
    property DataOrigin: string read FDataOrigin write FDataOrigin;
    property ApprovalStatus: string read FApprovalStatus write FApprovalStatus;
    property SendEmail: Boolean read FSendEmail write FSendEmail;
    property DestinationUrl: string read FDestinationUrl write FDestinationUrl;
    property NotificationType: string read FNotificationType write FNotificationType;
    property VlProtest: string read FVlProtest write FVlProtest;
    property VlFee: string read FVlFee write FVlFee;
    property EnrichEmail: Boolean read FEnrichEmail write FEnrichEmail;
    property EnrichWhatsapp: Boolean read FEnrichWhatsapp write FEnrichWhatsapp;
    property EnrichSms: Boolean read FEnrichSms write FEnrichSms;
    property EnrichScore: Boolean read FEnrichScore write FEnrichScore;
    property EnrichAddress: Boolean read FEnrichAddress write FEnrichAddress;
    property DtEnrichment: TDateTime read FDtEnrichment write FDtEnrichment;
    property DtBilling: TDateTime read FDtBilling write FDtBilling;
    property NotificationPurpose: string read FNotificationPurpose write FNotificationPurpose;
    property TitleNumber: string read FTitleNumber write FTitleNumber;
    property CompanyUser: string read FCompanyUser write FCompanyUser;
    property Company: string read FCompany write FCompany;
    property Contacts: TArray<string> read FContacts write FContacts;
    property NotificationCode: string read FNotificationCode write FNotificationCode;

    property NotificationTypeEnum: TNotificationType read GetNotificationTypeEnum
      write SetNotificationTypeEnum;
    property NotificationPurposeEnum: TNotificationPurpose read GetNotificationPurposeEnum
      write SetNotificationPurposeEnum;
    property DocumentTypeEnum: TDocumentType read GetDocumentTypeEnum
      write SetDocumentTypeEnum;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TNotification;

    function AddContact(const AContactId: string): Integer;
    procedure ClearContacts;
  end;

  TApiNotification = class(TIntimaDigitalBaseModel)
  private
    [JsonName('protocol')]
    [JSONSkipIfEmpty]
    FProtocol: string;
    [JsonName('dt_protocol')]
    [JSONSkipIfEmpty]
    FDtProtocol: TDateTime;
    [JsonName('partner_field')]
    [JSONSkipIfEmpty]
    FPartnerField: string;
    [JsonName('notified_name')]
    [JSONSkipIfEmpty]
    FNotifiedName: string;
    [JsonName('notified_document_number')]
    [JSONSkipIfEmpty]
    FNotifiedDocumentNumber: string;
    [JsonName('notification_type')]
    [JSONSkipIfEmpty]
    FNotificationType: string;
    [JsonName('file_content')]
    [JSONSkipIfEmpty]
    FFileContent: string;
    [JsonName('time_stamp')]
    [JSONSkipIfEmpty]
    FTimeStamp: Boolean;
    [JsonName('send_email')]
    [JSONSkipIfEmpty]
    FSendEmail: Boolean;
    [JsonName('send_sms')]
    [JSONSkipIfEmpty]
    FSendSms: Boolean;
    [JsonName('send_whatsapp')]
    [JSONSkipIfEmpty]
    FSendWhatsapp: Boolean;
    [JsonName('allow_email_enrichment')]
    [JSONSkipIfEmpty]
    FAllowEmailEnrichment: Boolean;
    [JsonName('allow_sms_enrichment')]
    [JSONSkipIfEmpty]
    FAllowSmsEnrichment: Boolean;
    [JsonName('allow_whatsapp_enrichment')]
    [JSONSkipIfEmpty]
    FAllowWhatsappEnrichment: Boolean;
    [JsonName('allow_score_enrichment')]
    [JSONSkipIfEmpty]
    FAllowScoreEnrichment: Boolean;
    [JsonName('allow_address_enrichment')]
    [JSONSkipIfEmpty]
    FAllowAddressEnrichment: Boolean;
    [JsonName('ranking_enrichment')]
    [JSONSkipIfEmpty]
    FRankingEnrichment: Boolean;
    [JsonName('ranking_limit_email')]
    [JSONSkipIfEmpty]
    FRankingLimitEmail: Integer;
    [JsonName('ranking_limit_sms')]
    [JSONSkipIfEmpty]
    FRankingLimitSms: Integer;
    [JsonName('ranking_limit_whatsapp')]
    [JSONSkipIfEmpty]
    FRankingLimitWhatsapp: Integer;
    [JsonName('dt_limit')]
    [JSONSkipIfEmpty]
    FDtLimit: TDateTime;
    [JsonName('contacts')]
    [JSONSkipIfEmpty]
    FContacts: TArray<TContact>;
    [JsonName('notification_purpose')]
    [JSONSkipIfEmpty]
    FNotificationPurpose: string;
    [JsonName('destination_url')]
    [JSONSkipIfEmpty]
    FDestinationUrl: string;
    [JsonName('file_url')]
    [JSONSkipIfEmpty]
    FFileUrl: string;

  public
    constructor Create; override;
    destructor Destroy; override;

    property Protocol: string read FProtocol write FProtocol;
    property DtProtocol: TDateTime read FDtProtocol write FDtProtocol;
    property PartnerField: string read FPartnerField write FPartnerField;
    property NotifiedName: string read FNotifiedName write FNotifiedName;
    property NotifiedDocumentNumber: string read FNotifiedDocumentNumber write FNotifiedDocumentNumber;
    property NotificationType: string read FNotificationType write FNotificationType;
    property FileContent: string read FFileContent write FFileContent;
    property TimeStamp: Boolean read FTimeStamp write FTimeStamp;
    property SendEmail: Boolean read FSendEmail write FSendEmail;
    property SendSms: Boolean read FSendSms write FSendSms;
    property SendWhatsapp: Boolean read FSendWhatsapp write FSendWhatsapp;
    property AllowEmailEnrichment: Boolean read FAllowEmailEnrichment write FAllowEmailEnrichment;
    property AllowSmsEnrichment: Boolean read FAllowSmsEnrichment write FAllowSmsEnrichment;
    property AllowWhatsappEnrichment: Boolean read FAllowWhatsappEnrichment write FAllowWhatsappEnrichment;
    property AllowScoreEnrichment: Boolean read FAllowScoreEnrichment write FAllowScoreEnrichment;
    property AllowAddressEnrichment: Boolean read FAllowAddressEnrichment write FAllowAddressEnrichment;
    property RankingEnrichment: Boolean read FRankingEnrichment write FRankingEnrichment;
    property RankingLimitEmail: Integer read FRankingLimitEmail write FRankingLimitEmail;
    property RankingLimitSms: Integer read FRankingLimitSms write FRankingLimitSms;
    property RankingLimitWhatsapp: Integer read FRankingLimitWhatsapp write FRankingLimitWhatsapp;
    property DtLimit: TDateTime read FDtLimit write FDtLimit;
    property Contacts: TArray<TContact> read FContacts write FContacts;
    property NotificationPurpose: string read FNotificationPurpose write FNotificationPurpose;
    property DestinationUrl: string read FDestinationUrl write FDestinationUrl;
    property FileUrl: string read FFileUrl write FFileUrl;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TApiNotification;

    function AddContact(AContact: TContact): Integer;
    procedure ClearContacts;
    function GetContactsList: TObjectList<TContact>;
  end;

  TNotificationResponse = class(TIntimaDigitalBaseModel)
  private
    [JsonName('count')]
    [JSONSkipIfEmpty]
    FCount: Integer;
    [JsonName('next')]
    [JSONSkipIfEmpty]
    FNext: string;
    [JsonName('previous')]
    [JSONSkipIfEmpty]
    FPrevious: string;
    [JsonName('results')]
    [JSONSkipIfEmpty]
    FResults: TArray<TNotification>;
  public
    constructor Create; override;
    destructor Destroy; override;

    property Count: Integer read FCount write FCount;
    property Next: string read FNext write FNext;
    property Previous: string read FPrevious write FPrevious;
    property Results: TArray<TNotification> read FResults write FResults;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TNotificationResponse;

    function GetResultsList: TObjectList<TNotification>;
  end;

  TApiNotificationList =  class(TIntimaDigitalBaseList<TApiNotification>)
  public
    //function ToJson(JSONSkipIfEmpty :Boolean = False): string;
  end;

implementation

uses
  System.DateUtils;

{ TNotification }

constructor TNotification.Create;
begin
  inherited;
  FContacts := [];
  FCreatedAt := 0;
  FUpdatedAt := 0;
  FDtProtocol := 0;
  FDtLimit := 0;
  FDtEnrichment := 0;
  FDtBilling := 0;
  FIsActive := True;
end;

function TNotification.AddContact(const AContactId: string): Integer;
begin
  SetLength(FContacts, Length(FContacts) + 1);
  FContacts[High(FContacts)] := AContactId;
  Result := High(FContacts);
end;

procedure TNotification.ClearContacts;
begin
  SetLength(FContacts, 0);
end;

//class function TNotification.FromJson(const AJson: string): TNotification;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TNotification>(AJson);
//end;

function TNotification.GetDocumentTypeEnum: TDocumentType;
begin
  if FNotifiedDocumentType = 'CNPJ' then
    Result := dtCNPJ
  else
    Result := dtCPF;
end;

function TNotification.GetNotificationPurposeEnum: TNotificationPurpose;
begin
  if FNotificationPurpose = 'pre-protest' then
    Result := npPreProtest
  else
    Result := npCancellation;
end;

function TNotification.GetNotificationTypeEnum: TNotificationType;
begin
  if FNotificationType = 'secondary' then
    Result := ntSecondary
  else if FNotificationType = 'third_party' then
    Result := ntThirdParty
  else if FNotificationType = 'enrichment' then
    Result := ntEnrichment
  else
    Result := ntPrimary;
end;

procedure TNotification.SetDocumentTypeEnum(Value: TDocumentType);
begin
  case Value of
    dtCPF: FNotifiedDocumentType := 'CPF';
    dtCNPJ: FNotifiedDocumentType := 'CNPJ';
  end;
end;

procedure TNotification.SetNotificationPurposeEnum(Value: TNotificationPurpose);
begin
  case Value of
    npCancellation: FNotificationPurpose := 'cancellation';
    npPreProtest: FNotificationPurpose := 'pre-protest';
  end;
end;

procedure TNotification.SetNotificationTypeEnum(Value: TNotificationType);
begin
  case Value of
    ntPrimary: FNotificationType := 'primary';
    ntSecondary: FNotificationType := 'secondary';
    ntThirdParty: FNotificationType := 'third_party';
    ntEnrichment: FNotificationType := 'enrichment';
  end;
end;

//function TNotification.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TApiNotification }

function TApiNotification.AddContact(AContact: TContact): Integer;
begin
  SetLength(FContacts, Length(FContacts) + 1);
  FContacts[High(FContacts)] := AContact;
  Result := High(FContacts);
end;

procedure TApiNotification.ClearContacts;
var
  I: Integer;
begin
  for I := 0 to High(FContacts) do
    FContacts[I].Free;
  SetLength(FContacts, 0);
end;

constructor TApiNotification.Create;
begin
  inherited;
  FContacts := [];
  FDtProtocol := 0;
  FDtLimit := 0;
  FTimeStamp := False;
  FSendEmail := False;
  FSendSms := False;
  FSendWhatsapp := False;
  FAllowEmailEnrichment := False;
  FAllowSmsEnrichment := False;
  FAllowWhatsappEnrichment := False;
  FAllowScoreEnrichment := False;
  FAllowAddressEnrichment := False;
  FRankingEnrichment := False;
  FRankingLimitEmail := 0;
  FRankingLimitSms := 0;
  FRankingLimitWhatsapp := 0;
end;

destructor TApiNotification.Destroy;
begin
  ClearContacts;
  inherited;
end;

//class function TApiNotification.FromJson(const AJson: string): TApiNotification;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TApiNotification>(AJson);
//end;

function TApiNotification.GetContactsList: TObjectList<TContact>;
var
  Contact: TContact;
begin
  Result := TObjectList<TContact>.Create;
  for Contact in FContacts do
    Result.Add(Contact);
end;

//function TApiNotification.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TNotificationResponse }

constructor TNotificationResponse.Create;
begin
  inherited;
  FResults := [];
end;

destructor TNotificationResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(FResults) - 1 do
    FResults[I].Free;
  SetLength(FResults, 0);
  inherited;
end;

//class function TNotificationResponse.FromJson(const AJson: string): TNotificationResponse;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TNotificationResponse>(AJson);
//end;

function TNotificationResponse.GetResultsList: TObjectList<TNotification>;
var
  Notification: TNotification;
begin
  Result := TObjectList<TNotification>.Create;
  for Notification in FResults do
    Result.Add(Notification);
end;

//function TNotificationResponse.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TApiNotificationList }

//function TApiNotificationList.ToJson(JSONSkipIfEmpty :Boolean = False): string;
//var
//  LJsonArray: TJSONArray;
//  LNotification: TApiNotification;
//begin
//  LJsonArray := TJSONArray.Create;
//  try
//    for LNotification in Self do
//    begin
//      LJsonArray.AddElement(TJSONObject.ParseJSONValue(LNotification.ToJson(True)) as TJSONObject);
//    end;
//    Result := LJsonArray.ToJSON;
//  finally
//    LJsonArray.Free;
//  end;
//end;

end.
