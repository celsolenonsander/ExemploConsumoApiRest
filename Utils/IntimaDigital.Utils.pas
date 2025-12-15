unit IntimaDigital.Utils;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.NetEncoding,
  System.DateUtils,
  Winapi.Windows,
  System.IOUtils,
  IntimaDigital.Types;

type
  TIntimaDigitalUtils = class
  public
    class function EncodeBase64(const AValue: string): string;
    class function DecodeBase64(const AValue: string): string;
    class function FileToBase64(const AFileName: string): string;
    class procedure Base64ToFile(const ABase64, AFileName: string);

    class function FormatCPF(const ACPF: string): string;
    class function FormatCNPJ(const ACNPJ: string): string;
    class function CleanDocument(const ADocument: string): string;
    class function IsValidCPF(const ACPF: string): Boolean;
    class function IsValidCNPJ(const ACNPJ: string): Boolean;

    class function DateToISO8601(ADate: TDateTime): string;
    class function ISO8601ToDate(const ADateStr: string): TDateTime;

    class function CreateGUIDStr: string;
    class function GenerateProtocol: string;

    class function BuildQueryParams(const AParams: array of TArray<string>): string;
  end;

implementation

{ TIntimaDigitalUtils }

class procedure TIntimaDigitalUtils.Base64ToFile(const ABase64, AFileName: string);
var
  Bytes: TBytes;
  Stream: TFileStream;
begin
  Bytes := TNetEncoding.Base64.DecodeStringToBytes(ABase64);
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    if Length(Bytes) > 0 then
      Stream.Write(Bytes[0], Length(Bytes));
  finally
    Stream.Free;
  end;
end;

class function TIntimaDigitalUtils.BuildQueryParams(const AParams: array of TArray<string>): string;
var
  I: Integer;
  Params: TArray<string>;
begin
  Params := [];
  for I := 0 to High(AParams) do
  begin
    if (Length(AParams[I]) = 2) and not AParams[I][1].IsEmpty then
      Params := Params + [AParams[I][0] + '=' + AParams[I][1]];
  end;

  if Length(Params) > 0 then
    Result := '?' + string.Join('&', Params)
  else
    Result := '';
end;

class function TIntimaDigitalUtils.CleanDocument(const ADocument: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(ADocument) do
  begin
    if CharInSet(ADocument[I], ['0'..'9']) then
      Result := Result + ADocument[I];
  end;
end;

class function TIntimaDigitalUtils.CreateGUIDStr: string;
var
  Guid: TGUID;
begin
  if System.SysUtils.CreateGUID(Guid) = S_OK then
    Result := Guid.ToString
  else
    Result := '';
end;

class function TIntimaDigitalUtils.DateToISO8601(ADate: TDateTime): string;
begin
  if ADate = 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd', ADate);
end;

class function TIntimaDigitalUtils.DecodeBase64(const AValue: string): string;
begin
  Result := TNetEncoding.Base64.Decode(AValue);
end;

class function TIntimaDigitalUtils.EncodeBase64(const AValue: string): string;
begin
  Result := TNetEncoding.Base64.Encode(AValue);
end;

class function TIntimaDigitalUtils.FileToBase64(const AFileName: string): string;
var
  Stream: TFileStream;
  Bytes: TBytes;
begin
  if not TFile.Exists(AFileName) then
    Exit('');

  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Bytes, Stream.Size);
    if Stream.Size > 0 then
      Stream.Read(Bytes[0], Stream.Size);
    Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
  finally
    Stream.Free;
  end;
end;

class function TIntimaDigitalUtils.FormatCNPJ(const ACNPJ: string): string;
var
  CleanCNPJ: string;
begin
  CleanCNPJ := CleanDocument(ACNPJ);
  if Length(CleanCNPJ) = 14 then
    Result := Format('%s.%s.%s/%s-%s',
      [Copy(CleanCNPJ, 1, 2), Copy(CleanCNPJ, 3, 3), Copy(CleanCNPJ, 6, 3),
       Copy(CleanCNPJ, 9, 4), Copy(CleanCNPJ, 13, 2)])
  else
    Result := CleanCNPJ;
end;

class function TIntimaDigitalUtils.FormatCPF(const ACPF: string): string;
var
  CleanCPF: string;
begin
  CleanCPF := CleanDocument(ACPF);
  if Length(CleanCPF) = 11 then
    Result := Format('%s.%s.%s-%s',
      [Copy(CleanCPF, 1, 3), Copy(CleanCPF, 4, 3), Copy(CleanCPF, 7, 3),
       Copy(CleanCPF, 10, 2)])
  else
    Result := CleanCPF;
end;

class function TIntimaDigitalUtils.GenerateProtocol: string;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  DecodeDateTime(Now, Year, Month, Day, Hour, Min, Sec, MSec);
  Result := Format('%.4d%.2d%.2d%.2d%.2d%.2d', [Year, Month, Day, Hour, Min, Sec]);
end;

class function TIntimaDigitalUtils.ISO8601ToDate(const ADateStr: string): TDateTime;
begin
  Result := 0;
  if ADateStr.IsEmpty then
    Exit;

  try
    if ADateStr.Contains('T') then
      Result := System.DateUtils.ISO8601ToDate(ADateStr)
    else
      Result := StrToDateDef(ADateStr, 0);
  except
    Result := 0;
  end;
end;

class function TIntimaDigitalUtils.IsValidCNPJ(const ACNPJ: string): Boolean;
var
  I, J, Dig1, Dig2: Integer;
  Soma: Integer;
  CNPJ: string;
begin
  Result := False;
  CNPJ := CleanDocument(ACNPJ);

  if Length(CNPJ) <> 14 then
    Exit;

  for I := 1 to 13 do
  begin
    if CNPJ[I] <> CNPJ[1] then
      Break;
    if I = 13 then
      Exit;
  end;

  Soma := 0;
  J := 5;
  for I := 1 to 12 do
  begin
    Soma := Soma + StrToIntDef(CNPJ[I], 0) * J;
    Inc(J);
    if J > 9 then
      J := 2;
  end;

  Dig1 := 11 - (Soma mod 11);
  if Dig1 >= 10 then
    Dig1 := 0;

  Soma := 0;
  J := 6;
  for I := 1 to 13 do
  begin
    Soma := Soma + StrToIntDef(CNPJ[I], 0) * J;
    Inc(J);
    if J > 9 then
      J := 2;
  end;

  Dig2 := 11 - (Soma mod 11);
  if Dig2 >= 10 then
    Dig2 := 0;

  Result := (StrToIntDef(CNPJ[13], -1) = Dig1) and
            (StrToIntDef(CNPJ[14], -1) = Dig2);
end;

class function TIntimaDigitalUtils.IsValidCPF(const ACPF: string): Boolean;
var
  CleanedCPF: string;

  function AllDigitsAreEqual(const Value: string): Boolean;
  var
    I: Integer;
  begin
    for I := 1 to Length(Value) - 1 do
      if Value[I] <> Value[1] then
        Exit(False);
    Result := True;
  end;

  function CalculateVerifierDigit(const Value: string; Digit: Integer): Integer;
  var
    I, Weight, Sum: Integer;
  begin
    Sum := 0;
    for I := 1 to 8 + Digit do
    begin
      Weight := (10 + Digit) - I;
      Sum := Sum + StrToIntDef(Value[I], 0) * Weight;
    end;

    Result := 11 - (Sum mod 11);
    if Result >= 10 then
      Result := 0;
  end;

begin
  Result := False;
  CleanedCPF := CleanDocument(ACPF);

  if Length(CleanedCPF) <> 11 then
    Exit;

  if AllDigitsAreEqual(CleanedCPF) then
    Exit;

  Result := (StrToIntDef(CleanedCPF[10], -1) = CalculateVerifierDigit(CleanedCPF, 1)) and
            (StrToIntDef(CleanedCPF[11], -1) = CalculateVerifierDigit(CleanedCPF, 2));
end;

end.
