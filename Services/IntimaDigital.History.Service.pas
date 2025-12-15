unit IntimaDigital.History.Service;

interface

uses
  System.SysUtils,
  System.DateUtils,
  IntimaDigital.Types,
  IntimaDigital.Client,
  IntimaDigital.Models.History;

type
  THistoryFilter = record
    Id: string;
    AccessDocument: string;
    LogId: string;
    DtAccessFrom: TDateTime;
    DtAccessTo: TDateTime;
    DtDownloadFrom: TDateTime;
    DtDownloadTo: TDateTime;
    Page: Integer;
    
    function ToQueryString: string;
    class function Create: THistoryFilter; static;
  end;

  TIntimaDigitalHistoryService = class
  private
    FClient: TIntimaDigitalClient;
    
    function BuildQueryString(const BaseURL: string; const Filter: THistoryFilter): string;
  public
    constructor Create(AClient: TIntimaDigitalClient);
    
    function GetHistoryReport(const Filter: THistoryFilter): TIDApiResponse<THistoryResponse>;
    
    property Client: TIntimaDigitalClient read FClient;
  end;

implementation

{ THistoryFilter }

class function THistoryFilter.Create: THistoryFilter;
begin
  Result.Id := '';
  Result.AccessDocument := '';
  Result.LogId := '';
  Result.DtAccessFrom := 0;
  Result.DtAccessTo := 0;
  Result.DtDownloadFrom := 0;
  Result.DtDownloadTo := 0;
  Result.Page := 1;
end;

function THistoryFilter.ToQueryString: string;
var
  Params: TArray<string>;
begin
  Params := [];
  
  if not Id.IsEmpty then
    Params := Params + ['id=' + Id];
    
  if not AccessDocument.IsEmpty then
    Params := Params + ['access_document=' + AccessDocument];
    
  if not LogId.IsEmpty then
    Params := Params + ['log_id=' + LogId];
    
  if DtAccessFrom > 0 then
    Params := Params + ['dt_access_from=' + DateToISO8601(DtAccessFrom)];
    
  if DtAccessTo > 0 then
    Params := Params + ['dt_access_to=' + DateToISO8601(DtAccessTo)];
    
  if DtDownloadFrom > 0 then
    Params := Params + ['dt_download_from=' + DateToISO8601(DtDownloadFrom)];
    
  if DtDownloadTo > 0 then
    Params := Params + ['dt_download_to=' + DateToISO8601(DtDownloadTo)];
    
  if Page > 1 then
    Params := Params + ['page=' + Page.ToString];
    
  if Length(Params) > 0 then
    Result := '?' + string.Join('&', Params)
  else
    Result := '';
end;

{ TIntimaDigitalHistoryService }

function TIntimaDigitalHistoryService.BuildQueryString(const BaseURL: string; 
  const Filter: THistoryFilter): string;
begin
  Result := BaseURL + Filter.ToQueryString;
end;

constructor TIntimaDigitalHistoryService.Create(AClient: TIntimaDigitalClient);
begin
  inherited Create;
  FClient := AClient;
end;

function TIntimaDigitalHistoryService.GetHistoryReport(const Filter: THistoryFilter): TIDApiResponse<THistoryResponse>;
var
  Endpoint: string;
begin
  Endpoint := 'log/api/history/report/';
  Endpoint := BuildQueryString(Endpoint, Filter);
  
  Result := FClient.GetJson<THistoryResponse>(Endpoint);
end;

end.