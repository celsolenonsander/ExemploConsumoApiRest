unit IntimaDigital.Types;

interface

type
  TIDApiResponse<T> = record
    Success: Boolean;
    Data: T;
    DataStr: String;
    ErrorMessage: string;
    StatusCode: Integer;

    constructor Create(ASuccess: Boolean; const AData: T;
      const AErrorMessage: string; AStatusCode: Integer);

  end;

  TIDEnvironment = (envHomologation, envProduction);

implementation

{ TIDApiResponse<T> }

constructor TIDApiResponse<T>.Create(ASuccess: Boolean; const AData: T;
  const AErrorMessage: string; AStatusCode: Integer);
begin
  Success := ASuccess;
  Data := AData;
  ErrorMessage := AErrorMessage;
  StatusCode := AStatusCode;
end;

end.
