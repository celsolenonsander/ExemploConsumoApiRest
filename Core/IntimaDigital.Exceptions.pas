unit IntimaDigital.Exceptions;

interface

uses
  System.SysUtils;

type
  EIntimaDigitalException = class(Exception)
  private
    FErrorCode: Integer;
  public
    constructor Create(const AMessage: string; AErrorCode: Integer = 0); overload;
    constructor CreateFmt(const AFormat: string; const Args: array of const; 
      AErrorCode: Integer = 0);
    
    property ErrorCode: Integer read FErrorCode;
  end;

  EIntimaDigitalAuthException = class(EIntimaDigitalException)
  public
    constructor Create(const AMessage: string; AErrorCode: Integer = 0); overload;
  end;

  EIntimaDigitalAPIException = class(EIntimaDigitalException)
  private
    FStatusCode: Integer;
  public
    constructor Create(const AMessage: string; AStatusCode: Integer; 
      AErrorCode: Integer = 0); overload;
    
    property StatusCode: Integer read FStatusCode;
  end;

  EIntimaDigitalValidationException = class(EIntimaDigitalException)
  public
    constructor Create(const AMessage: string; AErrorCode: Integer = 0); overload;
  end;

implementation

{ EIntimaDigitalException }

constructor EIntimaDigitalException.Create(const AMessage: string; 
  AErrorCode: Integer = 0);
begin
  inherited Create(AMessage);
  FErrorCode := AErrorCode;
end;

constructor EIntimaDigitalException.CreateFmt(const AFormat: string; 
  const Args: array of const; AErrorCode: Integer = 0);
begin
  inherited CreateFmt(AFormat, Args);
  FErrorCode := AErrorCode;
end;

{ EIntimaDigitalAuthException }

constructor EIntimaDigitalAuthException.Create(const AMessage: string; 
  AErrorCode: Integer = 0);
begin
  inherited Create(AMessage, AErrorCode);
end;

{ EIntimaDigitalAPIException }

constructor EIntimaDigitalAPIException.Create(const AMessage: string; 
  AStatusCode: Integer; AErrorCode: Integer = 0);
begin
  inherited Create(AMessage, AErrorCode);
  FStatusCode := AStatusCode;
end;

{ EIntimaDigitalValidationException }

constructor EIntimaDigitalValidationException.Create(const AMessage: string; 
  AErrorCode: Integer = 0);
begin
  inherited Create(AMessage, AErrorCode);
end;

end.