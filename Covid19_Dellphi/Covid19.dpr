program Covid19;

uses
  System.StartUpCopy,
  FMX.Forms,
  uCovid19 in 'uCovid19.pas' {fPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
