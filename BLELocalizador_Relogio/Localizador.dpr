program Localizador;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPrincipal in 'UPrincipal.pas' {FLocalizador};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFLocalizador, FLocalizador);
  Application.Run;
end.
