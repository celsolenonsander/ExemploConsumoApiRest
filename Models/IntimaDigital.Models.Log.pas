unit IntimaDigital.Models.Log;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.Json,
  REST.Json.Types,
  System.Generics.Collections,
  IntimaDigital.Models.Base,
  IntimaDigital.Types;

type
  TLogType = (ltWHATSAPP, ltSMS, ltEMAIL);
  TLogStatus = (lsQUEUED, lsDUPLICATED, lsBOUNCE, lsSENT, lsFAILED, lsDELIVERED, 
                lsREAD, lsCLICK, lsCANCELED, lsINVALID, lsUNSUBSCRIBE);

  TLog = class(TIntimaDigitalBaseModel)
  private
    [JsonName('id')]
    FId: string;
    [JsonName('created_at')]
    FCreatedAt: TDateTime;
    [JsonName('updated_at')]
    FUpdatedAt: TDateTime;
    [JsonName('type')]
    FType: string;
    [JsonName('whatsapp')]
    FWhatsapp: string;
    [JsonName('sms')]
    FSms: string;
    [JsonName('email')]
    FEmail: string;
    [JsonName('destination')]
    FDestination: string;
    [JsonName('sender_id')]
    FSenderId: string;
    [JsonName('message_id')]
    FMessageId: string;
    [JsonName('message_event_ip_adress')]
    FMessageEventIpAdress: string;
    [JsonName('message')]
    FMessage: string;
    [JsonName('status')]
    FStatus: string;
    [JsonName('dt_queued')]
    FDtQueued: TDateTime;
    [JsonName('dt_sent')]
    FDtSent: TDateTime;
    [JsonName('dt_failed')]
    FDtFailed: TDateTime;
    [JsonName('dt_delivered')]
    FDtDelivered: TDateTime;
    [JsonName('dt_read')]
    FDtRead: TDateTime;
    [JsonName('dt_click')]
    FDtClick: TDateTime;
    [JsonName('dt_reply')]
    FDtReply: TDateTime;
    [JsonName('dt_link_access')]
    FDtLinkAccess: TDateTime;
    [JsonName('dt_download')]
    FDtDownload: TDateTime;
    [JsonName('dt_download_fail')]
    FDtDownloadFail: TDateTime;
    [JsonName('ip_adress')]
    FIpAdress: string;
    [JsonName('ip_agent')]
    FIpAgent: string;
    [JsonName('ip_localization')]
    FIpLocalization: string;
    [JsonName('test')]
    FTest: Boolean;
    [JsonName('template_id')]
    FTemplateId: string;
    [JsonName('main_log_id')]
    FMainLogId: string;
    [JsonName('notified_document_number')]
    FNotifiedDocumentNumber: string;
    [JsonName('term_accepted')]
    FTermAccepted: Boolean;
    [JsonName('file_url')]
    FFileUrl: string;
    [JsonName('protocol')]
    FProtocol: string;
    [JsonName('dt_protocol')]
    FDtProtocol: TDateTime;
    [JsonName('file_content')]
    FFileContent: string;
    [JsonName('partner_field')]
    FPartnerField: string;
    [JsonName('notification_type')]
    FNotificationType: string;
    [JsonName('dt_billing')]
    FDtBilling: TDateTime;
    [JsonName('notification')]
    FNotification: string;
    [JsonName('contact')]
    FContact: string;
    [JsonName('company')]
    FCompany: string;
    [JsonName('time_stamp')]
    FTimeStamp: TArray<string>;
    [JsonName('notification_url')]
    FNotificationUrl: string;
    
    function GetLogTypeEnum: TLogType;
    procedure SetLogTypeEnum(Value: TLogType);
    function GetLogStatusEnum: TLogStatus;
    procedure SetLogStatusEnum(Value: TLogStatus);
    function GetNotification: string;
    function GetContact: string;
    function GetCompany: string;
    function GetWhatsapp: string;
    function GetSms: string;
    function GetEmail: string;
  public
    constructor Create; override;
    
    property Id: string read FId write FId;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
    property LogType: string read FType write FType;
    property Whatsapp: string read GetWhatsapp write FWhatsapp;
    property Sms: string read GetSms write FSms;
    property Email: string read GetEmail write FEmail;
    property Destination: string read FDestination write FDestination;
    property SenderId: string read FSenderId write FSenderId;
    property MessageId: string read FMessageId write FMessageId;
    property MessageEventIpAdress: string read FMessageEventIpAdress write FMessageEventIpAdress;
    property Message: string read FMessage write FMessage;
    property Status: string read FStatus write FStatus;
    property DtQueued: TDateTime read FDtQueued write FDtQueued;
    property DtSent: TDateTime read FDtSent write FDtSent;
    property DtFailed: TDateTime read FDtFailed write FDtFailed;
    property DtDelivered: TDateTime read FDtDelivered write FDtDelivered;
    property DtRead: TDateTime read FDtRead write FDtRead;
    property DtClick: TDateTime read FDtClick write FDtClick;
    property DtReply: TDateTime read FDtReply write FDtReply;
    property DtLinkAccess: TDateTime read FDtLinkAccess write FDtLinkAccess;
    property DtDownload: TDateTime read FDtDownload write FDtDownload;
    property DtDownloadFail: TDateTime read FDtDownloadFail write FDtDownloadFail;
    property IpAdress: string read FIpAdress write FIpAdress;
    property IpAgent: string read FIpAgent write FIpAgent;
    property IpLocalization: string read FIpLocalization write FIpLocalization;
    property Test: Boolean read FTest write FTest;
    property TemplateId: string read FTemplateId write FTemplateId;
    property MainLogId: string read FMainLogId write FMainLogId;
    property NotifiedDocumentNumber: string read FNotifiedDocumentNumber write FNotifiedDocumentNumber;
    property TermAccepted: Boolean read FTermAccepted write FTermAccepted;
    property FileUrl: string read FFileUrl write FFileUrl;
    property Protocol: string read FProtocol write FProtocol;
    property DtProtocol: TDateTime read FDtProtocol write FDtProtocol;
    property FileContent: string read FFileContent write FFileContent;
    property PartnerField: string read FPartnerField write FPartnerField;
    property NotificationType: string read FNotificationType write FNotificationType;
    property DtBilling: TDateTime read FDtBilling write FDtBilling;
    property Notification: string read GetNotification write FNotification;
    property Contact: string read GetContact write FContact;
    property Company: string read GetCompany write FCompany;
    property TimeStamp: TArray<string> read FTimeStamp write FTimeStamp;
    property NotificationUrl: string read FNotificationUrl write FNotificationUrl;
    
    property LogTypeEnum: TLogType read GetLogTypeEnum write SetLogTypeEnum;
    property LogStatusEnum: TLogStatus read GetLogStatusEnum write SetLogStatusEnum;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TLog;

    class function LogTypeToString(Value: TLogType): string;
    class function StringToLogType(const Value: string): TLogType;
    class function LogStatusToString(Value: TLogStatus): string;
    class function StringToLogStatus(const Value: string): TLogStatus;

    function GetTimeStampList: TList<string>;
    procedure AddTimeStamp(const ATimeStampId: string);
    procedure ClearTimeStamps;
  end;

  TLogResponse = class(TIntimaDigitalBaseModel)
  private
    [JsonName('count')]
    FCount: Integer;
    [JsonName('next')]
    FNext: string;
    [JsonName('previous')]
    FPrevious: string;
    [JsonName('results')]
    FResults: TArray<TLog>;
    
    function GetNext: string;
    function GetPrevious: string;
  public
    constructor Create; override;
    destructor Destroy; override;
    
    property Count: Integer read FCount write FCount;
    property Next: string read GetNext write FNext;
    property Previous: string read GetPrevious write FPrevious;
    property Results: TArray<TLog> read FResults write FResults;
    
    //function ToJson: string; override;
    //class function FromJson(const AJson: string): TLogResponse;
    
    function GetResultsList: TObjectList<TLog>;
  end;

implementation

uses
  System.DateUtils,
  System.StrUtils;

{ TLog }

procedure TLog.AddTimeStamp(const ATimeStampId: string);
begin
  SetLength(FTimeStamp, Length(FTimeStamp) + 1);
  FTimeStamp[High(FTimeStamp)] := ATimeStampId;
end;

procedure TLog.ClearTimeStamps;
begin
  SetLength(FTimeStamp, 0);
end;

constructor TLog.Create;
begin
  inherited;
  FCreatedAt := 0;
  FUpdatedAt := 0;
  FDtQueued := 0;
  FDtSent := 0;
  FDtFailed := 0;
  FDtDelivered := 0;
  FDtRead := 0;
  FDtClick := 0;
  FDtReply := 0;
  FDtLinkAccess := 0;
  FDtDownload := 0;
  FDtDownloadFail := 0;
  FDtProtocol := 0;
  FDtBilling := 0;
  FTest := False;
  FTermAccepted := False;
  FTimeStamp := [];
end;

//class function TLog.FromJson(const AJson: string): TLog;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TLog>(AJson);
//end;

function TLog.GetCompany: string;
begin
  Result := FCompany;
end;

function TLog.GetContact: string;
begin
  Result := FContact;
end;

function TLog.GetEmail: string;
begin
  Result := FEmail;
end;

function TLog.GetLogStatusEnum: TLogStatus;
begin
  Result := StringToLogStatus(FStatus);
end;

function TLog.GetLogTypeEnum: TLogType;
begin
  Result := StringToLogType(FType);
end;

function TLog.GetNotification: string;
begin
  Result := FNotification;
end;

function TLog.GetSms: string;
begin
  Result := FSms;
end;

function TLog.GetTimeStampList: TList<string>;
var
  TimeStamp: string;
begin
  Result := TList<string>.Create;
  for TimeStamp in FTimeStamp do
    Result.Add(TimeStamp);
end;

function TLog.GetWhatsapp: string;
begin
  Result := FWhatsapp;
end;

class function TLog.LogStatusToString(Value: TLogStatus): string;
begin
  case Value of
    lsQUEUED: Result := 'QUEUED';
    lsDUPLICATED: Result := 'DUPLICATED';
    lsBOUNCE: Result := 'BOUNCE';
    lsSENT: Result := 'SENT';
    lsFAILED: Result := 'FAILED';
    lsDELIVERED: Result := 'DELIVERED';
    lsREAD: Result := 'READ';
    lsCLICK: Result := 'CLICK';
    lsCANCELED: Result := 'CANCELED';
    lsINVALID: Result := 'INVALID';
    lsUNSUBSCRIBE: Result := 'UNSUBSCRIBE';
  else
    Result := '';
  end;
end;

class function TLog.LogTypeToString(Value: TLogType): string;
begin
  case Value of
    ltWHATSAPP: Result := 'WHATSAPP';
    ltSMS: Result := 'SMS';
    ltEMAIL: Result := 'EMAIL';
  else
    Result := '';
  end;
end;

procedure TLog.SetLogStatusEnum(Value: TLogStatus);
begin
  FStatus := LogStatusToString(Value);
end;

procedure TLog.SetLogTypeEnum(Value: TLogType);
begin
  FType := LogTypeToString(Value);
end;

class function TLog.StringToLogStatus(const Value: string): TLogStatus;
begin
  if Value = 'QUEUED' then
    Result := lsQUEUED
  else if Value = 'DUPLICATED' then
    Result := lsDUPLICATED
  else if Value = 'BOUNCE' then
    Result := lsBOUNCE
  else if Value = 'SENT' then
    Result := lsSENT
  else if Value = 'FAILED' then
    Result := lsFAILED
  else if Value = 'DELIVERED' then
    Result := lsDELIVERED
  else if Value = 'READ' then
    Result := lsREAD
  else if Value = 'CLICK' then
    Result := lsCLICK
  else if Value = 'CANCELED' then
    Result := lsCANCELED
  else if Value = 'INVALID' then
    Result := lsINVALID
  else if Value = 'UNSUBSCRIBE' then
    Result := lsUNSUBSCRIBE
  else
    Result := lsQUEUED;
end;

class function TLog.StringToLogType(const Value: string): TLogType;
begin
  if Value = 'WHATSAPP' then
    Result := ltWHATSAPP
  else if Value = 'SMS' then
    Result := ltSMS
  else if Value = 'EMAIL' then
    Result := ltEMAIL
  else
    Result := ltEMAIL;
end;

//function TLog.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

{ TLogResponse }

constructor TLogResponse.Create;
begin
  inherited;
  FResults := [];
end;

destructor TLogResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(FResults) - 1 do
    FResults[I].Free;
  SetLength(FResults, 0);
  inherited;
end;

//class function TLogResponse.FromJson(const AJson: string): TLogResponse;
//begin
//  Result := TIntimaDigitalBaseModel.FromJson<TLogResponse>(AJson);
//end;

function TLogResponse.GetNext: string;
begin
  Result := FNext;
end;

function TLogResponse.GetPrevious: string;
begin
  Result := FPrevious;
end;

function TLogResponse.GetResultsList: TObjectList<TLog>;
var
  Log: TLog;
begin
  Result := TObjectList<TLog>.Create;
  for Log in FResults do
    Result.Add(Log);
end;

//function TLogResponse.ToJson: string;
//begin
//  Result := inherited ToJson;
//end;

end.