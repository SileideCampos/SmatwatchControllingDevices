unit uCovid19;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TfPrincipal = class(TForm)
    rTitle: TRectangle;
    rAlert: TRectangle;
    lblVacinada: TLabel;
    rDoses: TRectangle;
    rQRCode: TRectangle;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.fmx}
{$R *.Moto360.fmx ANDROID}
{$R *.SSW3.fmx ANDROID}

end.
