unit IntimaDigital.Models.History;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.Json,
  System.Generics.Collections,
  IntimaDigital.Models.Base;

type
  THistory = class(TIntimaDigitalBaseModel)
  private
    Fid: string;
    Fcreated_at: TDateTime;
    Fupdated_at: TDateTime;
    Fdt_link_access: TDateTime;
    Fdt_download: TDateTime;
    Fdt_download_fail: TDateTime;
    Fip_adress: string;
    Fip_agent: string;
    Fip_localization: string;
    Fterm_accepted: Boolean;
    Faccess_name: string;
    Faccess_document: string;
    Flog: string;
    Fcompany: string;
    Fnotification: string;

    function Getdt_download: TDateTime;
    function Getdt_download_fail: TDateTime;
    function Getnotification: string;
  public
    constructor Create; override;

    property id: string read Fid write Fid;
    property created_at: TDateTime read Fcreated_at write Fcreated_at;
    property updated_at: TDateTime read Fupdated_at write Fupdated_at;
    property dt_link_access: TDateTime read Fdt_link_access write Fdt_link_access;
    property dt_download: TDateTime read Getdt_download write Fdt_download;
    property dt_download_fail: TDateTime read Getdt_download_fail write Fdt_download_fail;
    property ip_adress: string read Fip_adress write Fip_adress;
    property ip_agent: string read Fip_agent write Fip_agent;
    property ip_localization: string read Fip_localization write Fip_localization;
    property term_accepted: Boolean read Fterm_accepted write Fterm_accepted;
    property access_name: string read Faccess_name write Faccess_name;
    property access_document: string read Faccess_document write Faccess_document;
    property log: string read Flog write Flog;
    property company: string read Fcompany write Fcompany;
    property notification: string read Getnotification write Fnotification;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): THistory;
  end;

  THistoryResponse = class(TIntimaDigitalBaseModel)
  private
    Fcount: Integer;
    Fnext: string;
    Fprevious: string;
    Fresults: TArray<THistory>;

    function Getnext: string;
    function Getprevious: string;
  public
    constructor Create; override;
    destructor Destroy; override;

    property count: Integer read Fcount write Fcount;
    property next: string read Getnext write Fnext;
    property previous: string read Getprevious write Fprevious;
    property results: TArray<THistory> read Fresults write Fresults;

    //function ToJson: string; override;
    //class function FromJson(const AJson: string): THistoryResponse;

    function GetResultsList: TObjectList<THistory>;
  end;

implementation

uses
  System.DateUtils, System.JSON.Types;

{ THistory }

constructor THistory.Create;
begin
  inherited;
  Fcreated_at := 0;
  Fupdated_at := 0;
  Fdt_link_access := 0;
  Fdt_download := 0;
  Fdt_download_fail := 0;
end;

//class function THistory.FromJson(const AJson: string): THistory;
//begin
//  Result := TJson.JsonToObject<THistory>(AJson);
//end;

function THistory.Getdt_download: TDateTime;
begin
  Result := Fdt_download;
end;

function THistory.Getdt_download_fail: TDateTime;
begin
  Result := Fdt_download_fail;
end;

function THistory.Getnotification: string;
begin
  Result := Fnotification;
end;

//function THistory.ToJson: string;
//begin
//  Result := TJson.ObjectToJsonString(Self);
//end;

{ THistoryResponse }

constructor THistoryResponse.Create;
begin
  inherited;
  Fresults := [];
end;

destructor THistoryResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(Fresults) - 1 do
    Fresults[I].Free;
  SetLength(Fresults, 0);
  inherited;
end;

//class function THistoryResponse.FromJson(const AJson: string): THistoryResponse;
//begin
//  Result := TJson.JsonToObject<THistoryResponse>(AJson);
//end;

function THistoryResponse.Getnext: string;
begin
  Result := Fnext;
end;

function THistoryResponse.Getprevious: string;
begin
  Result := Fprevious;
end;

function THistoryResponse.GetResultsList: TObjectList<THistory>;
var
  History: THistory;
begin
  Result := TObjectList<THistory>.Create(True);
  for History in Fresults do
    Result.Add(History);
end;

//function THistoryResponse.ToJson: string;
//begin
//  Result := TJson.ObjectToJsonString(Self);
//end;

end.
