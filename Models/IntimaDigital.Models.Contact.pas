unit IntimaDigital.Models.Contact;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.Json,
  REST.Json.Types,
  System.Generics.Collections,
  IntimaDigital.Models.Base,
  IntimaDigital.Utils.JSon;

type
  TContactType = (ctSMS, ctWhatsapp, ctEmail, ctAddress, ctScore, ctPhone,
                  ctContactPhone, ctContactCellphone, ctContactEmail);
  TProcessingStatus = (psQ, psA, psW, psP, psF, psR, psX, psY, psN, psD);
  TDataOrigin = (doDataEnrichment, doSender, doReuse, doManual);

  TContactBasic = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    [JSONSkipIfEmpty]
    FId: string;
    [JsonName('name')]
    [JSONSkipIfEmpty]
    FName: string;
    [JsonName('value')]
    [JSONSkipIfEmpty]
    FValue: string;
    [JsonName('type')]
    [JSONSkipIfEmpty]
    FType: string;
    [JsonName('data_origin')]
    [JSONSkipIfEmpty]
    FDataOrigin: string;
    [JsonName('valid_whatsapp')]
    [JSONSkipIfEmpty]
    FValidWhatsapp: Boolean;
    [JsonName('is_active')]
    [JSONSkipIfEmpty]
    FIsActive: Boolean;
    [JsonName('ranking')]
    [JSONSkipIfEmpty]
    FRanking: Integer;
    [JsonName('deleted_by_entity')]
    [JSONSkipIfEmpty]
    FDeletedByEntity: Boolean;

    function GetContactTypeEnum: TContactType;
    procedure SetContactTypeEnum(Value: TContactType);
    function GetDataOriginEnum: TDataOrigin;
    procedure SetDataOriginEnum(Value: TDataOrigin);
  public
    constructor Create; override;

    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Value: string read FValue write FValue;
    property ContactType: string read FType write FType;
    property DataOrigin: string read FDataOrigin write FDataOrigin;
    property ValidWhatsapp: Boolean read FValidWhatsapp write FValidWhatsapp;
    property IsActive: Boolean read FIsActive write FIsActive;
    property Ranking: Integer read FRanking write FRanking;
    property DeletedByEntity: Boolean read FDeletedByEntity write FDeletedByEntity;


    property ContactTypeEnum: TContactType read GetContactTypeEnum write SetContactTypeEnum;
    property DataOriginEnum: TDataOrigin read GetDataOriginEnum write SetDataOriginEnum;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TContactBasic;

    class function ContactTypeToString(Value: TContactType): string;
    class function StringToContactType(const Value: string): TContactType;
    class function DataOriginToString(Value: TDataOrigin): string;
    class function StringToDataOrigin(const Value: string): TDataOrigin;
  end;

  TContact = class(TContactBasic)
  private
    [JsonName('sent')]
    [JSONSkipIfEmpty]
    FSent: Boolean;
    [JsonName('failed')]
    [JSONSkipIfEmpty]
    FFailed: Boolean;
    [JsonName('bounce')]
    [JSONSkipIfEmpty]
    FBounce: Boolean;
    [JsonName('created_at')]
    [JSONSkipIfEmpty]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    [JSONSkipIfEmpty]
    FUpdatedAt: TDateTime;
    [JsonName('campaign_id')]
    [JSONSkipIfEmpty]
    FCampaignId: string;
    [JsonName('processing_status')]
    [JSONSkipIfEmpty]
    FProcessingStatus: string;
    [JsonName('processed_ranking')]
    [JSONSkipIfEmpty]
    FProcessedRanking: Boolean;
    [JsonName('entity')]
    [JSONSkipIfEmpty]
    FEntity: Integer;

    function GetProcessingStatusEnum: TProcessingStatus;
    procedure SetProcessingStatusEnum(Value: TProcessingStatus);
  public
    constructor Create; override;

    property Sent: Boolean read FSent write FSent;
    property Failed: Boolean read FFailed write FFailed;
    property Bounce: Boolean read FBounce write FBounce;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property CampaignId: string read FCampaignId write FCampaignId;
    property ProcessingStatus: string read FProcessingStatus write FProcessingStatus;
    property ProcessedRanking: Boolean read FProcessedRanking write FProcessedRanking;
    property Entity: Integer read FEntity write FEntity;

    property ProcessingStatusEnum: TProcessingStatus read GetProcessingStatusEnum
      write SetProcessingStatusEnum;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TContact;

    class function ProcessingStatusToString(Value: TProcessingStatus): string;
    class function StringToProcessingStatus(const Value: string): TProcessingStatus;
  end;

  TEntity = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    [JSONSkipIfEmpty]
    FId: Integer;
    [JsonName('contacts')]
    [JSONSkipIfEmpty]
    FContacts: TArray<TContactBasic>;
    [JsonName('created_at')]
    [JSONSkipIfEmpty]
    FCreatedAt: TDateTime;
    [JsonName('name')]
    [JSONSkipIfEmpty]
    FName: string;
    [JsonName('document_number')]
    [JSONSkipIfEmpty]
    FDocumentNumber: string;
    [JsonName('is_active')]
    [JSONSkipIfEmpty]
    FIsActive: Boolean;
    [JsonName('company')]
    [JSONSkipIfEmpty]
    FCompany: string;
  public
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer read FId write FId;
    property Contacts: TArray<TContactBasic> read FContacts write FContacts;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property Name: string read FName write FName;
    property DocumentNumber: string read FDocumentNumber write FDocumentNumber;
    property IsActive: Boolean read FIsActive write FIsActive;
    property Company: string read FCompany write FCompany;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TEntity;

    function GetContactsList: TObjectList<TContactBasic>;
    function AddContact(AContact: TContactBasic): Integer;
    procedure ClearContacts;
  end;

  TUnsubscribe = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    [JSONSkipIfEmpty]
    FId: string;
    [JsonName('type')]
    [JSONSkipIfEmpty]
    FType: string;
    [JsonName('value')]
    [JSONSkipIfEmpty]
    FValue: string;
    [JsonName('manual')]
    [JSONSkipIfEmpty]
    FManual: Boolean;
    [JsonName('created_at')]
    [JSONSkipIfEmpty]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    [JSONSkipIfEmpty]
    FUpdatedAt: TDateTime;
    [JsonName('whatsapp_sender')]
    [JSONSkipIfEmpty]
    FWhatsappSender: string;
    [JsonName('email_sender')]
    [JSONSkipIfEmpty]
    FEmailSender: string;
    [JsonName('company')]
    [JSONSkipIfEmpty]
    FCompany: string;

    function GetContactTypeEnum: TContactType;
    procedure SetContactTypeEnum(Value: TContactType);
  public
    constructor Create; override;

    property Id: string read FId write FId;
    property UnsubscribeType: string read FType write FType;
    property Value: string read FValue write FValue;
    property Manual: Boolean read FManual write FManual;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property WhatsappSender: string read FWhatsappSender write FWhatsappSender;
    property EmailSender: string read FEmailSender write FEmailSender;
    property Company: string read FCompany write FCompany;

    property ContactTypeEnum: TContactType read GetContactTypeEnum write SetContactTypeEnum;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TUnsubscribe;
  end;

implementation

uses
  System.DateUtils,
  System.StrUtils;

{ TContactBasic }

constructor TContactBasic.Create;
begin
  inherited;
  FIsActive := True;
  FValidWhatsapp := False;
  FDeletedByEntity := False;
  FRanking := 0;
end;

class function TContactBasic.ContactTypeToString(Value: TContactType): string;
begin
  case Value of
    ctSMS: Result := 'sms';
    ctWhatsapp: Result := 'whatsapp';
    ctEmail: Result := 'email';
    ctAddress: Result := 'address';
    ctScore: Result := 'score';
    ctPhone: Result := 'phone';
    ctContactPhone: Result := 'contact_phone';
    ctContactCellphone: Result := 'contact_cellphone';
    ctContactEmail: Result := 'contact_email';
  else
    Result := '';
  end;
end;

class function TContactBasic.DataOriginToString(Value: TDataOrigin): string;
begin
  case Value of
    doDataEnrichment: Result := 'data_enrichment';
    doSender: Result := 'sender';
    doReuse: Result := 'reuse';
    doManual: Result := 'manual';
  else
    Result := '';
  end;
end;

//class function TContactBasic.FromJson(const AJson: string): TContactBasic;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TContactBasic>(AJson);
//end;

function TContactBasic.GetContactTypeEnum: TContactType;
begin
  Result := StringToContactType(FType);
end;

function TContactBasic.GetDataOriginEnum: TDataOrigin;
begin
  Result := StringToDataOrigin(FDataOrigin);
end;

class function TContactBasic.StringToContactType(const Value: string): TContactType;
begin
  if Value = 'sms' then
    Result := ctSMS
  else if Value = 'whatsapp' then
    Result := ctWhatsapp
  else if Value = 'email' then
    Result := ctEmail
  else if Value = 'address' then
    Result := ctAddress
  else if Value = 'score' then
    Result := ctScore
  else if Value = 'phone' then
    Result := ctPhone
  else if Value = 'contact_phone' then
    Result := ctContactPhone
  else if Value = 'contact_cellphone' then
    Result := ctContactCellphone
  else if Value = 'contact_email' then
    Result := ctContactEmail
  else
    Result := ctEmail;
end;

class function TContactBasic.StringToDataOrigin(const Value: string): TDataOrigin;
begin
  if Value = 'data_enrichment' then
    Result := doDataEnrichment
  else if Value = 'sender' then
    Result := doSender
  else if Value = 'reuse' then
    Result := doReuse
  else if Value = 'manual' then
    Result := doManual
  else
    Result := doManual;
end;

procedure TContactBasic.SetContactTypeEnum(Value: TContactType);
begin
  FType := ContactTypeToString(Value);
end;

procedure TContactBasic.SetDataOriginEnum(Value: TDataOrigin);
begin
  FDataOrigin := DataOriginToString(Value);
end;

//function TContactBasic.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TContact }

constructor TContact.Create;
begin
  inherited;
  FSent := False;
  FFailed := False;
  FBounce := False;
  FProcessedRanking := False;
  FEntity := 0;
  FCreatedAt := 0;
  FUpdatedAt := 0;
end;

//class function TContact.FromJson(const AJson: string): TContact;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TContact>(AJson);
//end;

function TContact.GetProcessingStatusEnum: TProcessingStatus;
begin
  Result := StringToProcessingStatus(FProcessingStatus);
end;

class function TContact.ProcessingStatusToString(Value: TProcessingStatus): string;
begin
  case Value of
    psQ: Result := 'Q';
    psA: Result := 'A';
    psW: Result := 'W';
    psP: Result := 'P';
    psF: Result := 'F';
    psR: Result := 'R';
    psX: Result := 'X';
    psY: Result := 'Y';
    psN: Result := 'N';
    psD: Result := 'D';
  else
    Result := '';
  end;
end;

procedure TContact.SetProcessingStatusEnum(Value: TProcessingStatus);
begin
  FProcessingStatus := ProcessingStatusToString(Value);
end;

class function TContact.StringToProcessingStatus(const Value: string): TProcessingStatus;
begin
  if Value = 'Q' then
    Result := psQ
  else if Value = 'A' then
    Result := psA
  else if Value = 'W' then
    Result := psW
  else if Value = 'P' then
    Result := psP
  else if Value = 'F' then
    Result := psF
  else if Value = 'R' then
    Result := psR
  else if Value = 'X' then
    Result := psX
  else if Value = 'Y' then
    Result := psY
  else if Value = 'N' then
    Result := psN
  else if Value = 'D' then
    Result := psD
  else
    Result := psQ;
end;

//function TContact.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TEntity }

function TEntity.AddContact(AContact: TContactBasic): Integer;
begin
  SetLength(FContacts, Length(FContacts) + 1);
  FContacts[High(FContacts)] := AContact;
  Result := High(FContacts);
end;

procedure TEntity.ClearContacts;
var
  I: Integer;
begin
  for I := 0 to High(FContacts) do
    FContacts[I].Free;
  SetLength(FContacts, 0);
end;

constructor TEntity.Create;
begin
  inherited;
  FContacts := [];
  FCreatedAt := 0;
  FIsActive := True;
end;

destructor TEntity.Destroy;
begin
  ClearContacts;
  inherited;
end;

//class function TEntity.FromJson(const AJson: string): TEntity;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TEntity>(AJson);
//end;

function TEntity.GetContactsList: TObjectList<TContactBasic>;
var
  Contact: TContactBasic;
begin
  Result := TObjectList<TContactBasic>.Create;
  for Contact in FContacts do
    Result.Add(Contact);
end;

//function TEntity.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TUnsubscribe }

constructor TUnsubscribe.Create;
begin
  inherited;
  FCreatedAt := 0;
  FUpdatedAt := 0;
  FManual := False;
end;

//class function TUnsubscribe.FromJson(const AJson: string): TUnsubscribe;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TUnsubscribe>(AJson);
//end;

function TUnsubscribe.GetContactTypeEnum: TContactType;
begin
  Result := TContactBasic.StringToContactType(FType);
end;

procedure TUnsubscribe.SetContactTypeEnum(Value: TContactType);
begin
  FType := TContactBasic.ContactTypeToString(Value);
end;

//function TUnsubscribe.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

end.
