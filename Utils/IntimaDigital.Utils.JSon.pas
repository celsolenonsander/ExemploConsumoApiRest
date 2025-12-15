unit IntimaDigital.Utils.JSon;

interface

uses
  System.Classes,
  REST.JsonReflect,
  System.RTTI,
  System.SysUtils,
  System.JSON,
  System.JSON.Writers,
  System.JSON.Types;

type
  TSimpleSkipEmptyInterceptor = class(TJSONInterceptor)
  public
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  JSONSkipIfEmptyAttribute = class(TCustomAttribute)
  end;

  TSkipIfEmptyConverter = class(TJSONInterceptor)
  private
    class var FInterceptor: TSimpleSkipEmptyInterceptor;
    class constructor Create;
    class destructor Destroy;
  public
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TJSONUtil = class
  public
    class function Format(const AJSONString: string; AIndent: Integer = 2): string; static;
    class function IsValidJSON(const AJSONString: string): Boolean; static;
    class function Minify(const AJSONString: string): string; static;
  end;

implementation

{ TJSONUtil }
procedure WriteJSONValue(AWriter: TJsonTextWriter; AValue: TJSONValue);
var
  I: Integer;
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  Pair: TJSONPair;
begin
  if AValue is TJSONObject then
  begin
    JSONObject := TJSONObject(AValue);
    AWriter.WriteStartObject;
    try
      for I := 0 to JSONObject.Count - 1 do  // Usando Count em vez de Size
      begin
        Pair := JSONObject.Pairs[I];  // Usando Pairs em vez de Get
        AWriter.WritePropertyName(Pair.JsonString.Value);
        WriteJSONValue(AWriter, Pair.JsonValue);
      end;
    finally
      AWriter.WriteEndObject;
    end;
  end
  else if AValue is TJSONArray then
  begin
    JSONArray := TJSONArray(AValue);
    AWriter.WriteStartArray;
    try
      for I := 0 to JSONArray.Count - 1 do  // Usando Count em vez de Size
      begin
        WriteJSONValue(AWriter, JSONArray.Items[I]);  // Usando Items em vez de Get
      end;
    finally
      AWriter.WriteEndArray;
    end;
  end
  else if AValue is TJSONString then
  begin
    AWriter.WriteValue(TJSONString(AValue).Value);
  end
  else if AValue is TJSONNumber then
  begin
    // Para números, escreve o valor como está
    AWriter.WriteRawValue(TJSONNumber(AValue).ToString);
  end
  else if (AValue is TJSONTrue) or (AValue.ClassName = 'TJSONTrue') then
  begin
    AWriter.WriteValue(True);
  end
  else if (AValue is TJSONFalse) or (AValue.ClassName = 'TJSONFalse') then
  begin
    AWriter.WriteValue(False);
  end
  else if AValue is TJSONNull then
  begin
    AWriter.WriteNull;
  end
  else if AValue is TJSONBool then
  begin
    AWriter.WriteValue(TJSONBool(AValue).AsBoolean);
  end;
end;

class function TJSONUtil.Format(const AJSONString: string; AIndent: Integer = 2): string;
var
  JSONValue: TJSONValue;
  StringWriter: TStringWriter;
  JSONWriter: TJsonTextWriter;
begin
  Result := AJSONString;

  JSONValue := TJSONObject.ParseJSONValue(AJSONString);
  if JSONValue = nil then
    Exit;

  try
    StringWriter := TStringWriter.Create;
    try
      JSONWriter := TJsonTextWriter.Create(StringWriter);
      try
        JSONWriter.Formatting := TJsonFormatting.Indented;
        JSONWriter.Indentation := AIndent;
//        JSONWriter.WriteToken(TJSONToken.String); // Método alternativo
//        JSONWriter.WriteRaw(JSONValue.ToString);
         WriteJSONValue(JSONWriter, JSONValue);
      finally
        JSONWriter.Free;
      end;
      Result := Trim(StringWriter.ToString);
    finally
      StringWriter.Free;
    end;
  finally
    JSONValue.Free;
  end;
end;

class function TJSONUtil.IsValidJSON(const AJSONString: string): Boolean;
var
  JSONValue: TJSONValue;
begin
  JSONValue := TJSONObject.ParseJSONValue(AJSONString);
  Result := JSONValue <> nil;
  if Result then
    JSONValue.Free;
end;

class function TJSONUtil.Minify(const AJSONString: string): string;
var
  JSONValue: TJSONValue;
  StringWriter: TStringWriter;
  JSONWriter: TJsonTextWriter;
begin
  Result := AJSONString;

  JSONValue := TJSONObject.ParseJSONValue(AJSONString);
  if JSONValue = nil then
    Exit;

  try
    StringWriter := TStringWriter.Create;
    try
      JSONWriter := TJsonTextWriter.Create(StringWriter);
      try
        JSONWriter.Formatting := TJsonFormatting.None;
        JSONWriter.WriteRaw(JSONValue.ToString);
      finally
        JSONWriter.Free;
      end;
      Result := Trim(StringWriter.ToString);
    finally
      StringWriter.Free;
    end;
  finally
    JSONValue.Free;
  end;
end;

{ TSkipIfEmptyConverter }

class constructor TSkipIfEmptyConverter.Create;
begin
  FInterceptor := TSimpleSkipEmptyInterceptor.Create;
end;

class destructor TSkipIfEmptyConverter.Destroy;
begin
  FInterceptor.Free;
end;

function TSkipIfEmptyConverter.StringConverter(Data: TObject; Field: string): string;
begin
  Result := FInterceptor.StringConverter(Data, Field);
end;

procedure TSkipIfEmptyConverter.StringReverter(Data: TObject; Field: string; Arg: string);
begin
  FInterceptor.StringReverter(Data, Field, Arg);
end;

{ TSimpleSkipEmptyInterceptor }

function DateTimeToISO8601(const ADateTime: TDateTime;
  AIncludeTime: Boolean = True): string;
begin
  if AIncludeTime then
    Result := FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss', ADateTime)
  else
    Result := FormatDateTime('yyyy"-"mm"-"dd', ADateTime);
end;

function TSimpleSkipEmptyInterceptor.StringConverter(Data: TObject; Field: string): string;
var
  Ctx: TRTTIContext;
  RttiType: TRTTIType;
  RttiField: TRTTIField;
  Value: TValue;
begin
  Ctx := TRTTIContext.Create;
  try
    RttiType := Ctx.GetType(Data.ClassType);
    RttiField := RttiType.GetField(Field);

    if Assigned(RttiField) then
    begin
      Value := RttiField.GetValue(Data);

      // Verificar string vazia
      if (Value.TypeInfo = TypeInfo(string)) and (Value.AsString = '') then
        Exit(''); // Retorna vazio (será omitido)

      // Verificar integer 0
      if (Value.TypeInfo = TypeInfo(Integer)) and (Value.AsInteger = 0) then
        Exit(''); // Retorna vazio (será omitido)

      // Verificar Int64 0
      if (Value.TypeInfo = TypeInfo(Int64)) and (Value.AsInt64 = 0) then
        Exit(''); // Retorna vazio (será omitido)

      // Verificar Double 0
      if (Value.TypeInfo = TypeInfo(Double)) and (Value.AsExtended = 0) then
        Exit(''); // Retorna vazio (será omitido)
    end;

    // Para outros casos, retornar o valor normal
    // O comportamento padrão do Delphi vai converter automaticamente
    case Value.Kind of
      tkInteger: Result := IntToStr(Value.AsInteger);
      tkInt64: Result := IntToStr(Value.AsInt64);
      tkFloat:
        if Value.TypeInfo = TypeInfo(TDateTime) then
          Result := DateTimeToISO8601(Value.AsExtended)
        else
          Result := FloatToStr(Value.AsExtended);
      tkString, tkUString, tkWString, tkLString:
        Result := Value.AsString;
      tkEnumeration:
        if Value.TypeInfo = TypeInfo(Boolean) then
          Result := BoolToStr(Value.AsBoolean, True);
    else
      Result := '';
    end;

  finally
    Ctx.Free;
  end;
end;

procedure TSimpleSkipEmptyInterceptor.StringReverter(Data: TObject; Field: string; Arg: string);
var
  Ctx: TRTTIContext;
  RttiType: TRTTIType;
  RttiField: TRTTIField;
  OldValue: TValue;
begin
  // Ignorar valores vazios ou nulos do JSON
  if (Arg = '') or (Arg = 'null') or (Arg = '""') then
    Exit;

  Ctx := TRTTIContext.Create;
  try
    RttiType := Ctx.GetType(Data.ClassType);
    RttiField := RttiType.GetField(Field);

    if Assigned(RttiField) then
    begin
      // Obter valor atual para comparação
      OldValue := RttiField.GetValue(Data);

      // Para integer, ignorar se for 0
      if (Arg = '0') and (RttiField.FieldType.TypeKind = tkInteger) then
        Exit; // Não atribui o valor 0

      // Para Int64, ignorar se for 0
      if (Arg = '0') and (RttiField.FieldType.TypeKind = tkInt64) then
        Exit; // Não atribui o valor 0

      // Para string vazia explícita
      if (Arg = '""') and (RttiField.FieldType.TypeKind in [tkString, tkUString, tkWString, tkLString]) then
        Exit; // Não atribui string vazia

      // Para valores válidos, converter e atribuir
      case RttiField.FieldType.TypeKind of
        tkInteger:
          RttiField.SetValue(Data, StrToIntDef(Arg, 0));
        tkInt64:
          RttiField.SetValue(Data, StrToInt64Def(Arg, 0));
        tkFloat:
          if RttiField.FieldType.Handle = TypeInfo(TDateTime) then
            // Usar função ISO8601ToDate se disponível, ou converter manualmente
            RttiField.SetValue(Data, StrToFloat(Arg))
          else
            RttiField.SetValue(Data, StrToFloat(Arg));
        tkString, tkUString, tkWString, tkLString:
          // Remove aspas se existirem
          if (Length(Arg) > 1) and (Arg[1] = '"') and (Arg[Length(Arg)] = '"') then
            RttiField.SetValue(Data, Copy(Arg, 2, Length(Arg) - 2))
          else
            RttiField.SetValue(Data, Arg);
        tkEnumeration:
          if RttiField.FieldType.Handle = TypeInfo(Boolean) then
            RttiField.SetValue(Data, StrToBool(Arg));
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

end.
