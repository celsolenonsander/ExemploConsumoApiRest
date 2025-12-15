unit IntimaDigital.Models.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.Json,
  System.TypInfo,
  System.Generics.Collections,
  System.Rtti,
  REST.JsonReflect,
  IntimaDigital.Utils.JSon,
  REST.Json.Types;

type

  TIntimaDigitalBaseModel = class
  private
    function ToJsonFiltered: string;
    function IsEmptyValue(Value: TValue): Boolean;
    procedure AddValueToJson(AJsonObject: TJSONObject;
      const AFieldName: string; AValue: TValue; AFilterEmpty: Boolean);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToJson(JSONSkipIfEmpty :Boolean = True): string; virtual;
    procedure ToJsonObject(AJsonObject: TJSONObject; JSONSkipIfEmpty: Boolean = False); virtual;
    class function FromJson<T: class, constructor>(const AJson: string): T; overload;
    procedure FromJson(const AJson: string); overload; virtual;
  end;

  TIntimaDigitalBaseList<T: TIntimaDigitalBaseModel> = class(TObjectList<T>)
  public
    function ToJson: string; virtual;
  end;

  function TryCallToJsonViaRTTI(AObject: TObject): string;

implementation

{ TIntimaDigitalBaseModel }


function TryCallToJsonViaRTTI(AObject: TObject): string;
var
  Context: TRttiContext;
  RttiType: TRttiType;
  Method: TRttiMethod;
begin
  Result := '';

  Context := TRttiContext.Create;
  try
    RttiType := Context.GetType(AObject.ClassType);

    Method := RttiType.GetMethod('ToJson');

    if Assigned(Method) then
    begin
      try
        Result := Method.Invoke(AObject, []).AsString;
      except
        on E: Exception do
        begin
          Result := '';
        end;
      end;
    end
    else
    begin
    end;
  finally
    Context.Free;
  end;
end;

constructor TIntimaDigitalBaseModel.Create;
begin
  inherited;
end;

destructor TIntimaDigitalBaseModel.Destroy;
begin
  inherited;
end;

procedure TIntimaDigitalBaseModel.FromJson(const AJson: string);
var
  JSONObj: TJSONObject;
begin
  JSONObj := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
  try
    if Assigned(JSONObj) then
      TJson.JsonToObject(Self, JSONObj);
  finally
    JSONObj.Free;
  end;
end;

class function TIntimaDigitalBaseModel.FromJson<T>(const AJson: string): T;
var
  JSONObj: TJSONObject;
begin
  Result := nil;

  try
    JSONObj := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
    if Assigned(JSONObj) then
    begin
      try
        Result := TJson.JsonToObject<T>(JSONObj);
      except
        on E: Exception do
        begin
          if Assigned(Result) then
            Result.Free;
          raise Exception.CreateFmt('Erro ao converter JSON para %s: %s',
            [T.ClassName, E.Message]);
        end;
      end;
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('Erro ao analisar JSON: %s', [E.Message]);
  end;
end;

function TIntimaDigitalBaseModel.ToJson(JSONSkipIfEmpty: Boolean): String;
var
  LJsonObject: TJSONObject;
begin
  if JSONSkipIfEmpty then
    Result := ToJsonFiltered
  else
  begin
    LJsonObject := TJSONObject.Create;
    try
      ToJsonObject(LJsonObject, JSONSkipIfEmpty);
      Result := LJsonObject.ToJSON;
    finally
      LJsonObject.Free;
    end;
  end;
end;

procedure TIntimaDigitalBaseModel.ToJsonObject(AJsonObject: TJSONObject;
  JSONSkipIfEmpty: Boolean);
var
  Ctx: TRTTIContext;
  RttiType: TRTTIType;
  RttiField: TRTTIField;
  RttiFields: TArray<TRTTIField>;
  JsonFieldName: string;
  HasSkipAttribute: Boolean;
  Attr: TCustomAttribute;
  JSONNameAttr: JSONNameAttribute;
  Value: TValue;
  JsonArray: TJSONArray;
  JsonObject: TJSONObject;
  I: Integer;
  Obj: TObject;
begin
  Ctx := TRTTIContext.Create;
  try
    RttiType := Ctx.GetType(Self.ClassType);
    RttiFields := RttiType.GetFields;

    for RttiField in RttiFields do
    begin
      JsonFieldName := RttiField.Name;
      JSONNameAttr := nil;
      HasSkipAttribute := False;

      // Verificar atributos
      for Attr in RttiField.GetAttributes do
      begin
        if Attr is JSONNameAttribute then
          JSONNameAttr := JSONNameAttribute(Attr)
        else if Attr is JSONSkipIfEmptyAttribute then
          HasSkipAttribute := True;
      end;

      if Assigned(JSONNameAttr) then
        JsonFieldName := JSONNameAttr.Name;

      Value := RttiField.GetValue(Self);

      // Verificar se deve pular campos vazios
      if HasSkipAttribute and IsEmptyValue(Value) then
        Continue;

      // Tratar diferentes tipos de valores
      case Value.Kind of
        tkClass:
          begin
            Obj := Value.AsObject;
            if Obj <> nil then
            begin
              if Obj is TIntimaDigitalBaseModel then
              begin
                // Usar ToJsonObject recursivamente
                JsonObject := TJSONObject.Create;
                try
                  TIntimaDigitalBaseModel(Obj).ToJsonObject(JsonObject, JSONSkipIfEmpty);
                  AJsonObject.AddPair(JsonFieldName, JsonObject);
                except
                  JsonObject.Free;
                  raise;
                end;
              end
              else
              begin
                // Para outras classes, usar o método padrão
                AJsonObject.AddPair(JsonFieldName,
                  TJSONObject.ParseJSONValue(
                    TJson.ObjectToJsonString(Obj, [joDateIsUTC, joDateFormatISO8601])
                  ) as TJSONObject);
              end;
            end;
          end;

        tkArray, tkDynArray:
          begin
            JsonArray := TJSONArray.Create;
            try
              for I := 0 to Value.GetArrayLength - 1 do
              begin
                if Value.GetArrayElement(I).Kind = tkClass then
                begin
                  Obj := Value.GetArrayElement(I).AsObject;
                  if (Obj <> nil) and (Obj is TIntimaDigitalBaseModel) then
                  begin
                    JsonObject := TJSONObject.Create;
                    TIntimaDigitalBaseModel(Obj).ToJsonObject(JsonObject, JSONSkipIfEmpty);
                    JsonArray.AddElement(JsonObject);
                  end
                  else if Obj <> nil then
                  begin
                    JsonArray.AddElement(
                      TJSONObject.ParseJSONValue(
                        TJson.ObjectToJsonString(Obj, [joDateIsUTC, joDateFormatISO8601])
                      ) as TJSONObject
                    );
                  end;
                end;
              end;
              AJsonObject.AddPair(JsonFieldName, JsonArray);
            except
              JsonArray.Free;
              raise;
            end;
          end;

        tkString, tkUString, tkWString, tkLString:
          begin
            if not (HasSkipAttribute and (Value.AsString = '')) then
              AJsonObject.AddPair(JsonFieldName, Value.AsString);
          end;

        tkInteger, tkInt64:
          begin
            if not (HasSkipAttribute and (Value.AsInt64 = 0)) then
              AJsonObject.AddPair(JsonFieldName, TJSONNumber.Create(Value.AsInt64));
          end;

        tkFloat:
          begin
            if not (HasSkipAttribute and (Value.AsExtended = 0)) then
            begin
              if Value.TypeInfo = TypeInfo(TDateTime) then
                AJsonObject.AddPair(JsonFieldName,
                  FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', Value.AsExtended))
              else
                AJsonObject.AddPair(JsonFieldName, TJSONNumber.Create(Value.AsExtended));
            end;
          end;

        tkEnumeration:
          begin
            if Value.TypeInfo = TypeInfo(Boolean) then
            begin
              if not (HasSkipAttribute and (not Value.AsBoolean)) then
                AJsonObject.AddPair(JsonFieldName, TJSONBool.Create(Value.AsBoolean));
            end;
          end;
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

function TIntimaDigitalBaseModel.ToJsonFiltered: string;
var
  Ctx: TRTTIContext;
  RttiType: TRTTIType;
  RttiField: TRTTIField;
  JSONFiltered: TJSONObject;
  JsonFieldName: string;
  HasSkipAttribute: Boolean;
  Attr: TCustomAttribute;
  JSONNameAttr: JSONNameAttribute;
  Value: TValue;
begin
  Ctx := TRTTIContext.Create;
  JSONFiltered := TJSONObject.Create;
  try
    RttiType := Ctx.GetType(Self.ClassType);

    for RttiField in RttiType.GetFields do
    begin
      JsonFieldName := RttiField.Name;
      JSONNameAttr := nil;
      HasSkipAttribute := False;

      // Verificar atributos
      for Attr in RttiField.GetAttributes do
      begin
        if Attr is JSONNameAttribute then
          JSONNameAttr := JSONNameAttribute(Attr)
        else if Attr is JSONSkipIfEmptyAttribute then
          HasSkipAttribute := True;
      end;

      if Assigned(JSONNameAttr) then
        JsonFieldName := JSONNameAttr.Name;

      Value := RttiField.GetValue(Self);

      // Verificar se deve pular campos vazios
      if HasSkipAttribute and IsEmptyValue(Value) then
        Continue;

      // Adicionar ao JSON baseado no tipo
      AddValueToJson(JSONFiltered, JsonFieldName, Value, True);
    end;

    Result := JSONFiltered.ToJSON;
  finally
    JSONFiltered.Free;
    Ctx.Free;
  end;
end;

procedure TIntimaDigitalBaseModel.AddValueToJson(AJsonObject: TJSONObject;
  const AFieldName: string; AValue: TValue; AFilterEmpty: Boolean);
var
  JsonArray: TJSONArray;
  JsonObject: TJSONObject;
  I: Integer;
  Obj: TObject;
begin
  case AValue.Kind of
    tkClass:
      begin
        Obj := AValue.AsObject;
        if Obj <> nil then
        begin
          if Obj is TIntimaDigitalBaseModel then
          begin
            // Chamar ToJsonFiltered recursivamente
            JsonObject := TJSONObject.ParseJSONValue(
              TIntimaDigitalBaseModel(Obj).ToJsonFiltered
            ) as TJSONObject;
            AJsonObject.AddPair(AFieldName, JsonObject);
          end
          else
          begin
            // Para outras classes
            JsonObject := TJSONObject.ParseJSONValue(
              TJson.ObjectToJsonString(Obj, [joDateIsUTC, joDateFormatISO8601])
            ) as TJSONObject;
            AJsonObject.AddPair(AFieldName, JsonObject);
          end;
        end;
      end;

    tkArray, tkDynArray:
      begin
        JsonArray := TJSONArray.Create;
        try
          for I := 0 to AValue.GetArrayLength - 1 do
          begin
            if AValue.GetArrayElement(I).Kind = tkClass then
            begin
              Obj := AValue.GetArrayElement(I).AsObject;
              if (Obj <> nil) and (Obj is TIntimaDigitalBaseModel) then
              begin
                JsonArray.AddElement(
                  TJSONObject.ParseJSONValue(
                    TIntimaDigitalBaseModel(Obj).ToJsonFiltered
                  ) as TJSONObject
                );
              end
              else if Obj <> nil then
              begin
                JsonArray.AddElement(
                  TJSONObject.ParseJSONValue(
                    TJson.ObjectToJsonString(Obj, [joDateIsUTC, joDateFormatISO8601])
                  ) as TJSONObject
                );
              end;
            end;
          end;
          AJsonObject.AddPair(AFieldName, JsonArray);
        except
          JsonArray.Free;
          raise;
        end;
      end;

    tkString, tkUString, tkWString, tkLString:
      begin
        if not (AFilterEmpty and (AValue.AsString = '')) then
          AJsonObject.AddPair(AFieldName, AValue.AsString);
      end;

    tkInteger, tkInt64:
      begin
        if not (AFilterEmpty and (AValue.AsInt64 = 0)) then
          AJsonObject.AddPair(AFieldName, TJSONNumber.Create(AValue.AsInt64));
      end;

    tkFloat:
      begin
        if not (AFilterEmpty and (AValue.AsExtended = 0)) then
        begin
          if AValue.TypeInfo = TypeInfo(TDateTime) then
          begin
            // Verificar se é uma data válida
            if AValue.AsExtended > 0 then
              AJsonObject.AddPair(AFieldName,
                FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', AValue.AsExtended))
          end
          else
          begin
            AJsonObject.AddPair(AFieldName, TJSONNumber.Create(AValue.AsExtended));
          end;
        end;
      end;

    tkEnumeration:
      begin
        if AValue.TypeInfo = TypeInfo(Boolean) then
        begin
          if not (AFilterEmpty and (not AValue.AsBoolean)) then
            AJsonObject.AddPair(AFieldName, TJSONBool.Create(AValue.AsBoolean));
        end;
      end;
  end;
end;

function TIntimaDigitalBaseModel.IsEmptyValue(Value: TValue): Boolean;
begin
  Result := False;

  case Value.Kind of
    tkInteger, tkInt64:
      Result := Value.AsInt64 = 0;

    tkFloat:
      begin
        if Value.TypeInfo = TypeInfo(TDateTime) then
          // Datas no Delphi são armazenadas como Double, 0 = 30/12/1899
          Result := (Value.AsExtended = 0) or (Value.AsExtended < 2); // Ignorar datas muito antigas
      end;

    tkString, tkUString, tkWString, tkLString:
      Result := Value.AsString = '';

    tkEnumeration:
      if Value.TypeInfo = TypeInfo(Boolean) then
        Result := not Value.AsBoolean;

    tkClass:
      Result := Value.AsObject = nil;

    tkArray, tkDynArray:
      Result := Value.GetArrayLength = 0;
  end;
end;

{ TIntimaDigitalBaseList<T> }

function TIntimaDigitalBaseList<T>.ToJson: string;
var
  JsonArray: TJSONArray;
  Item: T;
begin
  JsonArray := TJSONArray.Create;
  try
    for Item in Self do
    begin
      JsonArray.AddElement(TJSONObject.ParseJSONValue(Item.ToJson) as TJSONObject);
    end;
    Result := JsonArray.ToJSON;
  finally
    JsonArray.Free;
  end;
end;

end.
