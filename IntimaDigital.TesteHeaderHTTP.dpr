program IntimaDigital.TesteHeaderHTTP;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  IntimaDigital.Utils.HeadersHTTP in 'Utils\IntimaDigital.Utils.HeadersHTTP.pas';

procedure TestarHelpers;
var
  HttpClient: THTTPClient;
  Headers: THeaderArray;
  I: Integer;
  StringList: TStringList;
  AuthHeader: THeaderItem;  // Declarado aqui
begin
  Writeln('=== TESTE DOS HELPERS ===');
  Writeln;

  HttpClient := THTTPClient.Create;
  try
    // 1. Configurar propriedades padrão
    HttpClient.Accept := 'application/json';
    HttpClient.ContentType := 'application/json';
    HttpClient.UserAgent := 'TesteApp/1.0';

    // 2. Adicionar headers customizados
    HttpClient.AddCustomHeader('X-Custom-Header', 'MeuValor');
    HttpClient.AddCustomHeader('Authorization', 'Bearer token123');

    // 3. Obter headers como THeaderArray
    Headers := HttpClient.GetCustomHeaders;
    Writeln('1. Headers como THeaderArray:');
    Writeln('   Count: ', Headers.Count);
    for I := 0 to Headers.Count - 1 do
      Writeln('   [', I, '] ', Headers[I].ToString);
    Writeln;

    // 4. Usar o helper do THeaderArray
    Writeln('2. Métodos do THeaderArrayHelper:');
    Writeln('   Contém "Authorization": ', Headers.Contains('Authorization'));
    Writeln('   Contém "X-Inexistente": ', Headers.Contains('X-Inexistente'));

    // Corrigido: sem variável inline
    AuthHeader := Headers.Find('Authorization');
    Writeln('   Find Authorization: ', AuthHeader.ToString);
    Writeln;

    // 5. Converter para StringList
    Writeln('3. Como StringList:');
    StringList := Headers.ToStringList;
    try
      Writeln('   Count: ', StringList.Count);
      for I := 0 to StringList.Count - 1 do
        Writeln('   [', I, '] ', StringList[I]);
    finally
      StringList.Free;
    end;
    Writeln;

    // 6. Formatar bonito
    Writeln('4. Formatação customizada:');
    Writeln(HttpClient.FormatCustomHeaders);
    Writeln;

    // 7. Remover um header
    Writeln('5. Removendo header:');
    Writeln('   Antes - Count: ', HttpClient.CustomHeaderCount);
    HttpClient.RemoveCustomHeader('X-Custom-Header');
    Writeln('   Depois - Count: ', HttpClient.CustomHeaderCount);
    Writeln('   Contém "X-Custom-Header": ', HttpClient.HasCustomHeader('X-Custom-Header'));
    Writeln;

    // 8. Limpar todos
    Writeln('6. Limpando todos os headers:');
    HttpClient.ClearCustomHeaders;
    Writeln('   Count após Clear: ', HttpClient.CustomHeaderCount);

  finally
    HttpClient.Free;
  end;

  Writeln('=== FIM DO TESTE ===');
  Readln;
end;

begin
  try
    TestarHelpers;
  except
    on E: Exception do
    begin
      Writeln('Erro: ', E.Message);
      Readln;
    end;
  end;
end.
