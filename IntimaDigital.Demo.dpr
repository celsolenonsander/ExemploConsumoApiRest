program IntimaDigital.Demo;

uses
  Vcl.Forms,
  View.Demo in 'View\View.Demo.pas' {ViewDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewDemo, ViewDemo);
  Application.Run;
end.
