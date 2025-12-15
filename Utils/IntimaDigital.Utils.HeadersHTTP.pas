unit IntimaDigital.Utils.HeadersHTTP;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Net.URLClient,
  System.Generics.Collections;

type
  THeaderItem = record
    Name: string;
    Value: string;
    constructor Create(const AName, AValue: string);
    function IsEmpty: Boolean;
    function ToString: string;
  end;

  THeaderArray = TArray<THeaderItem>;

  THeaderArrayHelper = record helper for THeaderArray
  public
    function ToStringList: TStringList;
    function ToString(const ASeparator: string = ', '): string;
    function Find(const AName: string): THeaderItem;
    function Contains(const AName: string): Boolean;
    function Count: Integer;
    procedure Add(const AName, AValue: string);
    procedure Remove(const AName: string);
    procedure Clear;
    function Names: TArray<string>;
    function Values: TArray<string>;
  end;

  TURLClientHelper = class helper for TURLClient
  private
    function GetCustomHeaderCount: Integer;
    function GetCustomHeadersArray: TNetHeaders;
  public
    function GetCustomHeaders: THeaderArray;
    function GetCustomHeadersAsStringList: TStringList;
    function FormatCustomHeaders: string;
    procedure RemoveCustomHeader(const AName: string);
    function HasCustomHeader(const AName: string): Boolean;
    function GetCustomHeaderNames: TArray<string>;
    function GetCustomHeaderValues: TArray<string>;
    procedure AddCustomHeader(const AName, AValue: string);
    procedure ClearCustomHeaders;
    property CustomHeaderCount: Integer read GetCustomHeaderCount;
    property CustomHeadersArray: TNetHeaders read GetCustomHeadersArray;
  end;

implementation

uses
  System.StrUtils;

{ THeaderItem }

constructor THeaderItem.Create(const AName, AValue: string);
begin
  Name := AName;
  Value := AValue;
end;

function THeaderItem.IsEmpty: Boolean;
begin
  Result := (Name = '') and (Value = '');
end;

function THeaderItem.ToString: string;
begin
  Result := Name + ': ' + Value;
end;

{ THeaderArrayHelper }

function THeaderArrayHelper.ToStringList: TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  try
    Result.NameValueSeparator := '=';
    for I := 0 to High(Self) do
      if not Self[I].IsEmpty then
        Result.Add(Self[I].Name + '=' + Self[I].Value);
  except
    Result.Free;
    raise;
  end;
end;

function THeaderArrayHelper.ToString(const ASeparator: string = ', '): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Self) do
  begin
    if I > 0 then
      Result := Result + ASeparator;
    Result := Result + Self[I].ToString;
  end;
end;

function THeaderArrayHelper.Find(const AName: string): THeaderItem;
var
  I: Integer;
begin
  for I := 0 to High(Self) do
    if SameText(Self[I].Name, AName) then
      Exit(Self[I]);

  Result := Default(THeaderItem);
end;

function THeaderArrayHelper.Contains(const AName: string): Boolean;
begin
  Result := Find(AName).Name <> '';
end;

function THeaderArrayHelper.Count: Integer;
begin
  Result := Length(Self);
end;

procedure THeaderArrayHelper.Add(const AName, AValue: string);
var
  Len: Integer;
begin
  Len := Length(Self);
  SetLength(Self, Len + 1);
  Self[Len] := THeaderItem.Create(AName, AValue);
end;

procedure THeaderArrayHelper.Remove(const AName: string);
var
  I, J: Integer;
begin
  for I := High(Self) downto Low(Self) do
  begin
    if SameText(Self[I].Name, AName) then
    begin
      for J := I to High(Self) - 1 do
        Self[J] := Self[J + 1];
      SetLength(Self, Length(Self) - 1);
    end;
  end;
end;

procedure THeaderArrayHelper.Clear;
begin
  SetLength(Self, 0);
end;

function THeaderArrayHelper.Names: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    Result[I] := Self[I].Name;
end;

function THeaderArrayHelper.Values: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    Result[I] := Self[I].Value;
end;

{ TURLClientHelper }

function TURLClientHelper.GetCustomHeaderCount: Integer;
begin
  Result := Length(FCustomHeaders);
end;

function TURLClientHelper.GetCustomHeadersArray: TNetHeaders;
begin
  Result := FCustomHeaders;
end;

function TURLClientHelper.GetCustomHeaders: THeaderArray;
var
  I: Integer;
begin
  SetLength(Result, Length(FCustomHeaders));
  for I := 0 to High(FCustomHeaders) do
  begin
    Result[I].Name := FCustomHeaders[I].Name;
    Result[I].Value := FCustomHeaders[I].Value;
  end;
end;

function TURLClientHelper.GetCustomHeadersAsStringList: TStringList;
begin
  Result := GetCustomHeaders.ToStringList;
end;

function TURLClientHelper.FormatCustomHeaders: string;
var
  Headers: THeaderArray;
  I: Integer;
begin
  Result := '';
  Headers := GetCustomHeaders;
  for I := 0 to High(Headers) do
  begin
    Result := Result + Headers[I].Name + ': ' +
              IfThen(Headers[I].Value = '', '(vazio)', Headers[I].Value);
    if I < High(Headers) then
      Result := Result + sLineBreak;
  end;
end;

procedure TURLClientHelper.RemoveCustomHeader(const AName: string);
var
  I, J: Integer;
begin
  for I := High(FCustomHeaders) downto Low(FCustomHeaders) do
  begin
    if SameText(FCustomHeaders[I].Name, AName) then
    begin
      for J := I to High(FCustomHeaders) - 1 do
        FCustomHeaders[J] := FCustomHeaders[J + 1];
      SetLength(FCustomHeaders, Length(FCustomHeaders) - 1);
    end;
  end;
end;

function TURLClientHelper.HasCustomHeader(const AName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(FCustomHeaders) do
    if SameText(FCustomHeaders[I].Name, AName) then
      Exit(True);
end;

function TURLClientHelper.GetCustomHeaderNames: TArray<string>;
begin
  Result := GetCustomHeaders.Names;
end;

function TURLClientHelper.GetCustomHeaderValues: TArray<string>;
begin
  Result := GetCustomHeaders.Values;
end;

procedure TURLClientHelper.AddCustomHeader(const AName, AValue: string);
begin
  CustomHeaders[AName] := AValue;
end;

procedure TURLClientHelper.ClearCustomHeaders;
begin
  SetLength(FCustomHeaders, 0);
end;

end.
