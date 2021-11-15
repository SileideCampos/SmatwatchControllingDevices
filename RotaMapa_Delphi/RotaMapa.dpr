program RotaMapa;

uses
  System.StartUpCopy,
  FMX.Forms,
  uControleEspera in 'uControleEspera.pas',
  uMapa in 'uMapa.pas' {F_GMaps},
  UBuscaRotas in 'UBuscaRotas.pas' {F_BuscaRotas},
  UDM in 'UDM.pas' {DM: TDataModule},
  uFunctions in 'uFunctions.pas',
  UPrincipal in 'UPrincipal.pas' {F_Principal};


{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TF_Principal, F_Principal);
  Application.Run;
end.
