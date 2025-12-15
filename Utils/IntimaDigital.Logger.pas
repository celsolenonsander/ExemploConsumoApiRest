unit IntimaDigital.Logger;

interface

uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  Windows,
  {$IFNDEF CONSOLE}
  Vcl.StdCtrls, Vcl.Forms, Vcl.Controls,
  {$ENDIF}
  System.SyncObjs;

type
  TLogLevel = (llDebug, llInfo, llWarning, llError, llCritical);

  TIntimaDigitalLogger = class
  private
    {$IFNDEF CONSOLE}
    FMemo: TMemo;
    FForm: TForm;
    {$ENDIF}
    FLogFile: string;
    FCS: TCriticalSection;

    class var FInstance: TIntimaDigitalLogger;
    class var FLogLevel: TLogLevel;
    class var FEnableTimestamp: Boolean;
    class var FEnableFileLog: Boolean;
    class var FLogFilePath: string;

    function GetLogLevelStr(Level: TLogLevel): string;
    function FormatMessage(Level: TLogLevel; const Msg: string): string;

    procedure InternalLog(Level: TLogLevel; const Msg: string);

    procedure WriteToConsole(const Msg: string);
    {$IFNDEF CONSOLE}
    procedure WriteToMemo(const Msg: string);
    {$ENDIF}
    procedure WriteToFile(const Msg: string);

    class constructor Create;
    class destructor Destroy;
  public
    {$IFNDEF CONSOLE}
    constructor Create(Memo: TMemo = nil; Form: TForm = nil);
    {$ELSE}
    constructor Create;
    {$ENDIF}
    destructor Destroy; override;

    procedure Log(Level: TLogLevel; const Msg: string); overload;
    procedure Log(Level: TLogLevel; const Format: string; Args: array of const); overload;

    procedure Debug(const Msg: string); overload;
    procedure Info(const Msg: string); overload;
    procedure Warning(const Msg: string); overload;
    procedure Error(const Msg: string); overload;
    procedure Critical(const Msg: string); overload;

    procedure Debug(const Format: string; Args: array of const); overload;
    procedure Info(const Format: string; Args: array of const); overload;
    procedure Warning(const Format: string; Args: array of const); overload;
    procedure Error(const Format: string; Args: array of const); overload;
    procedure Critical(const Format: string; Args: array of const); overload;

    procedure Separator;
    procedure Section(const Title: string);
    procedure Success(const Msg: string);
    procedure Failure(const Msg: string);

    class procedure SetLogLevel(Level: TLogLevel);
    class procedure EnableTimestamp(Value: Boolean);
    class procedure EnableFileLogging(Enabled: Boolean; const FilePath: string = '');

    {$IFNDEF CONSOLE}
    procedure SetMemo(Memo: TMemo);
    procedure SetForm(Form: TForm);
    {$ENDIF}

    class property Instance: TIntimaDigitalLogger read FInstance;
  end;

procedure LogDebug(const Msg: string); overload;
procedure LogInfo(const Msg: string); overload;
procedure LogSuccess(const Msg: string); overload;
procedure LogWarning(const Msg: string); overload;
procedure LogError(const Msg: string); overload;
procedure LogCritical(const Msg: string); overload;

procedure LogDebug(const Format: string; Args: array of const); overload;
procedure LogInfo(const Format: string; Args: array of const); overload;
procedure LogSuccess(const Format: string; Args: array of const); overload;
procedure LogWarning(const Format: string; Args: array of const); overload;
procedure LogError(const Format: string; Args: array of const); overload;
procedure LogCritical(const Format: string; Args: array of const); overload;

implementation

{ TIntimaDigitalLogger }

class constructor TIntimaDigitalLogger.Create;
begin
  FInstance := nil;
  FLogLevel := llInfo;
  FEnableTimestamp := True;
  FEnableFileLog := False;
  FLogFilePath := ExtractFilePath(ParamStr(0)) + 'logs\';
end;

class destructor TIntimaDigitalLogger.Destroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

{$IFNDEF CONSOLE}
constructor TIntimaDigitalLogger.Create(Memo: TMemo = nil; Form: TForm = nil);
{$ELSE}
constructor TIntimaDigitalLogger.Create;
{$ENDIF}
begin
  FCS := TCriticalSection.Create;
  {$IFNDEF CONSOLE}
  FMemo := Memo;
  FForm := Form;
  {$ENDIF}

  if FEnableFileLog then
  begin
    ForceDirectories(FLogFilePath);
    FLogFile := FLogFilePath + FormatDateTime('yyyy-mm-dd', Now) + '.log';
  end;
end;

destructor TIntimaDigitalLogger.Destroy;
begin
  FCS.Free;
  inherited;
end;

function TIntimaDigitalLogger.GetLogLevelStr(Level: TLogLevel): string;
begin
  case Level of
    llDebug:    Result := 'DEBUG';
    llInfo:     Result := 'INFO';
    llWarning:  Result := 'WARN';
    llError:    Result := 'ERROR';
    llCritical: Result := 'CRITICAL';
  else
    Result := 'UNKNOWN';
  end;
end;

function TIntimaDigitalLogger.FormatMessage(Level: TLogLevel; const Msg: string): string;
var
  Timestamp: string;
begin
  if FEnableTimestamp then
    Timestamp := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' '
  else
    Timestamp := '';

  Result := Format('%s[%s] %s', [Timestamp, GetLogLevelStr(Level), Msg]);
end;

procedure TIntimaDigitalLogger.InternalLog(Level: TLogLevel; const Msg: string);
var FormattedMsg :String;
begin
  FCS.Enter;
  try
    FormattedMsg := FormatMessage(Level, Msg);

    {$IFDEF CONSOLE}
    WriteToConsole(FormattedMsg);
    {$ENDIF}

    {$IFNDEF CONSOLE}
    if Assigned(FMemo) then
      WriteToMemo(FormattedMsg);
    {$ENDIF}

    if FEnableFileLog then
      WriteToFile(FormattedMsg);
  finally
    FCS.Leave;
  end;
end;

procedure TextColor(Color: Word);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), Color);
end;

procedure TIntimaDigitalLogger.WriteToConsole(const Msg: string);
begin
  {$IFDEF CONSOLE}
  case FLogLevel of
    llDebug:    begin TextColor(7); end;   // Cinza
    llInfo:     begin TextColor(15); end;  // Branco
    llWarning:  begin TextColor(14); end;  // Amarelo
    llError:    begin TextColor(12); end;  // Vermelho
    llCritical: begin TextColor(4); end;   // Vermelho escuro
  end;

  Writeln(Msg);
  TextColor(7);
  {$ENDIF}
end;

{$IFNDEF CONSOLE}
procedure TIntimaDigitalLogger.WriteToMemo(const Msg: string);
begin
  if Assigned(FMemo) then
  begin
    TThread.Queue(nil,
      procedure
      begin
        FMemo.Lines.BeginUpdate;
        try
          FMemo.Lines.Add(Msg);
          FMemo.SelStart := Length(FMemo.Text);
          FMemo.SelLength := 0;
        finally
          FMemo.Lines.EndUpdate;
        end;
      end
    );
  end
  else if Assigned(FForm) then
  begin
    TThread.Queue(nil,
      procedure
      begin
        FForm.Caption := Copy(Msg, 1, 100);
      end
    );
  end
  else
  begin
    OutputDebugString(PChar(Msg));
  end;
end;
{$ENDIF}

procedure TIntimaDigitalLogger.WriteToFile(const Msg: string);
var
  LogFile: TextFile;
begin
  if FLogFile.IsEmpty then
    Exit;

  AssignFile(LogFile, FLogFile);
  try
    if FileExists(FLogFile) then
      Append(LogFile)
    else
      Rewrite(LogFile);

    Writeln(LogFile, Msg);
  finally
    CloseFile(LogFile);
  end;
end;

procedure TIntimaDigitalLogger.Log(Level: TLogLevel; const Msg: string);
begin
  InternalLog(Level, Msg);
end;

procedure TIntimaDigitalLogger.Log(Level: TLogLevel; const Format: string; Args: array of const);
begin
  InternalLog(Level, System.SysUtils.Format(Format, Args));
end;

procedure TIntimaDigitalLogger.Debug(const Msg: string);
begin
  Log(llDebug, Msg);
end;

procedure TIntimaDigitalLogger.Info(const Msg: string);
begin
  Log(llInfo, Msg);
end;

procedure TIntimaDigitalLogger.Warning(const Msg: string);
begin
  Log(llWarning, Msg);
end;

procedure TIntimaDigitalLogger.Error(const Msg: string);
begin
  Log(llError, Msg);
end;

procedure TIntimaDigitalLogger.Critical(const Msg: string);
begin
  Log(llCritical, Msg);
end;

procedure TIntimaDigitalLogger.Debug(const Format: string; Args: array of const);
begin
  Log(llDebug, Format, Args);
end;

procedure TIntimaDigitalLogger.Info(const Format: string; Args: array of const);
begin
  Log(llInfo, Format, Args);
end;

procedure TIntimaDigitalLogger.Warning(const Format: string; Args: array of const);
begin
  Log(llWarning, Format, Args);
end;

procedure TIntimaDigitalLogger.Error(const Format: string; Args: array of const);
begin
  Log(llError, Format, Args);
end;

procedure TIntimaDigitalLogger.Critical(const Format: string; Args: array of const);
begin
  Log(llCritical, Format, Args);
end;

procedure TIntimaDigitalLogger.Separator;
begin
  Log(llInfo, '----------------------------------------');
end;

procedure TIntimaDigitalLogger.Section(const Title: string);
begin
  Log(llInfo, '');
  Log(llInfo, '===== ' + UpperCase(Title) + ' =====');
  Log(llInfo, '');
end;

procedure TIntimaDigitalLogger.Success(const Msg: string);
begin
  {$IFDEF CONSOLE}
  TextColor(10); // Verde
  Writeln('✓ ' + Msg);
  TextColor(7);
  {$ELSE}
  Info('✓ ' + Msg);
  {$ENDIF}
end;

procedure TIntimaDigitalLogger.Failure(const Msg: string);
begin
  {$IFDEF CONSOLE}
  TextColor(12); // Vermelho
  Writeln('✗ ' + Msg);
  TextColor(7);
  {$ELSE}
  Error('✗ ' + Msg);
  {$ENDIF}
end;

class procedure TIntimaDigitalLogger.SetLogLevel(Level: TLogLevel);
begin
  FLogLevel := Level;
end;

class procedure TIntimaDigitalLogger.EnableTimestamp(Value: Boolean);
begin
  FEnableTimestamp := Value;
end;

class procedure TIntimaDigitalLogger.EnableFileLogging(Enabled: Boolean; const FilePath: string = '');
begin
  FEnableFileLog := Enabled;
  if not FilePath.IsEmpty then
    FLogFilePath := IncludeTrailingPathDelimiter(FilePath);
end;

{$IFNDEF CONSOLE}
procedure TIntimaDigitalLogger.SetMemo(Memo: TMemo);
begin
  FMemo := Memo;
end;

procedure TIntimaDigitalLogger.SetForm(Form: TForm);
begin
  FForm := Form;
end;
{$ENDIF}

procedure LogDebug(const Msg: string);
begin
  TIntimaDigitalLogger.Instance.Debug(Msg);
end;

procedure LogInfo(const Msg: string);
begin
  TIntimaDigitalLogger.Instance.Info(Msg);
end;

procedure LogSuccess(const Msg: string); overload;
begin
  TIntimaDigitalLogger.Instance.Success(Msg);
end;

procedure LogWarning(const Msg: string);
begin
  TIntimaDigitalLogger.Instance.Warning(Msg);
end;

procedure LogError(const Msg: string);
begin
  TIntimaDigitalLogger.Instance.Error(Msg);
end;

procedure LogCritical(const Msg: string);
begin
  TIntimaDigitalLogger.Instance.Critical(Msg);
end;

procedure LogDebug(const Format: string; Args: array of const);
begin
  TIntimaDigitalLogger.Instance.Debug(Format, Args);
end;

procedure LogInfo(const Format: string; Args: array of const);
begin
  TIntimaDigitalLogger.Instance.Info(Format, Args);
end;

procedure LogSuccess(const Format: string; Args: array of const); overload;
begin
  TIntimaDigitalLogger.Instance.Info(Format, Args);
end;

procedure LogWarning(const Format: string; Args: array of const);
begin
  TIntimaDigitalLogger.Instance.Warning(Format, Args);
end;

procedure LogError(const Format: string; Args: array of const);
begin
  TIntimaDigitalLogger.Instance.Error(Format, Args);
end;

procedure LogCritical(const Format: string; Args: array of const);
begin
  TIntimaDigitalLogger.Instance.Critical(Format, Args);
end;

initialization
  TIntimaDigitalLogger.FInstance := TIntimaDigitalLogger.Create;

finalization
  FreeAndNil(TIntimaDigitalLogger.FInstance);

end.
