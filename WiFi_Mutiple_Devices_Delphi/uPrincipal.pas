unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, IdComponent,
  IdBaseComponent, IdUDPBase, IdUDPClient, FMX.Edit, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, FMX.Objects, FMX.ListBox,
  System.ImageList, FMX.ImgList;

type
  TForm1 = class(TForm)
    UDPEscritorio: TIdUDPClient;
    UDPSonoffV2: TIdUDPClient;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    lblTitle: TLabel;
    UDPLuminaria: TIdUDPClient;
    Circle1: TCircle;
    UDPCameraTelegram: TIdUDPClient;
    lbDevices: TListBox;
    bliEscritorio: TListBoxItem;
    btnEscritorio: TSwitch;
    lbiSonoff: TListBoxItem;
    btnSonoff: TSwitch;
    lbiLuminaria: TListBoxItem;
    btnLuminaria: TSwitch;
    lbiSendNudes: TListBoxItem;
    lbiSound1: TListBoxItem;
    btnPlay: TButton;
    btnVolMais: TButton;
    btnVolMenos: TButton;
    lbiSound2: TListBoxItem;
    btnMusMenos: TButton;
    btnMusMais: TButton;
    btnModo: TButton;
    StyleBook1: TStyleBook;
    btnNuds: TSpeedButton;
    UDPSom: TIdUDPClient;
    lImagens: TImageList;
    cPwrEscritorio: TCircle;
    cPwrSonoff: TCircle;
    cPwrLuminaria: TCircle;
    ListBoxItem7: TListBoxItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Switch3Switch(Sender: TObject);
    procedure btnNudsClick(Sender: TObject);
    procedure btnEscritorioSwitch(Sender: TObject);
    procedure btnSonoffSwitch(Sender: TObject);
    procedure btnLuminariaSwitch(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnVolMaisClick(Sender: TObject);
    procedure btnModoClick(Sender: TObject);
    procedure btnVolMenosClick(Sender: TObject);
    procedure btnMusMenosClick(Sender: TObject);
    procedure btnMusMaisClick(Sender: TObject);
  private
    FThread: TThread;
    FTam_image: TSizeF;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  IdGlobal;

{$R *.fmx}
{$R *.Moto360.fmx ANDROID}
{$R *.SSW3.fmx ANDROID}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FThread.Destroy;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  FTam_image := TSizeF.Create(24,24);
  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      retorno,
      retornoLuminaria: TIdBytes;
      lStatus: string;
    begin
      while (not FThread.CheckTerminated) do
      begin
        if not UDPEscritorio.Connected then
          UDPEscritorio.Connect;
        UDPEscritorio.Send('STS');
        SetLength(retorno, 1);
        UDPEscritorio.ReceiveBuffer(retorno);
        btnEscritorio.OnSwitch := nil;
        FThread.Synchronize(nil,
          procedure
          begin
            if BytesToString(retorno) = '1' then
              btnEscritorio.IsChecked := False
            else
              btnEscritorio.IsChecked := True;
          end);
        btnEscritorio.OnSwitch := btnEscritorioSwitch;

        {UDPSonoffV2.Send('STS');
        SetLength(retornoSonoffV1, 1);
        UDPSonoffV2.ReceiveBuffer(retornoSonoffV1);
        btnSonoff.OnSwitch := nil;
        FThread.Synchronize(nil,
          procedure
          begin
            if BytesToString(retornoSonoffV1) = '1' then
              btnSonoff.IsChecked := True
            else
              btnSonoff.IsChecked := False;
          end);
        btnSonoff.OnSwitch := btnSonoffSwitch;}

        if not UDPSonoffV2.Connected then
          UDPSonoffV2.Connect;
        UDPSonoffV2.Send('STS');
        lStatus := UDPSonoffV2.ReceiveString(1500);
        btnSonoff.OnSwitch := nil;
        FThread.Synchronize(nil,
          procedure
          begin
            if lStatus = '' then
              cPwrSonoff.Fill.Bitmap.Bitmap := lImagens.Bitmap(FTam_image, 3)
            else
            begin
              cPwrSonoff.Fill.Bitmap.Bitmap := lImagens.Bitmap(FTam_image, 2);
              btnSonoff.IsChecked := (lStatus = '1');
            end;
          end);
        btnSonoff.OnSwitch := btnSonoffSwitch;
      end;
    end
  );
  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

procedure TForm1.btnEscritorioSwitch(Sender: TObject);
begin
  if not UDPEscritorio.Connected then
    UDPEscritorio.Connect;
  if btnEscritorio.IsChecked then
    UDPEscritorio.Send('OON')
  else
    UDPEscritorio.Send('OFF');
end;

procedure TForm1.btnSonoffSwitch(Sender: TObject);
begin
  if not UDPSonoffV2.Connected then
    UDPSonoffV2.Connect;
  if btnSonoff.IsChecked then
    UDPSonoffV2.Send('OON')
  else
    UDPSonoffV2.Send('OFF');
end;

procedure TForm1.btnLuminariaSwitch(Sender: TObject);
begin
  //RGD LED
  if not UDPLuminaria.Connected then
    UDPLuminaria.Connect;
  if btnLuminaria.IsChecked then
    UDPLuminaria.Send('200020100')
  else
    UDPLuminaria.Send('000000000');
end;

procedure TForm1.btnNudsClick(Sender: TObject);
begin
  UDPCameraTelegram.Send('1')
end;

procedure TForm1.btnModoClick(Sender: TObject);
begin
  UDPSom.Send('1');
end;

procedure TForm1.btnVolMaisClick(Sender: TObject);
begin
  UDPSom.Send('2');
end;

procedure TForm1.btnVolMenosClick(Sender: TObject);
begin
  UDPSom.Send('3');
end;

procedure TForm1.btnPlayClick(Sender: TObject);
begin
  UDPSom.Send('4');
end;

procedure TForm1.btnMusMaisClick(Sender: TObject);
begin
  UDPSom.Send('5');
end;

procedure TForm1.btnMusMenosClick(Sender: TObject);
begin
  UDPSom.Send('6');
end;

procedure TForm1.Switch3Switch(Sender: TObject);
var
  comando: string;
begin
  (*if Switch2.IsChecked then
  comando := '{ "data": {"switch": "on"  } }'
  else
    comando := '{ "data": {"switch": "off"  } }';
  RESTClient1.BaseURL := 'http://192.168.0.124:8081/zeroconf/switch';
  RESTRequest1.Params.AddItem('dados', comando, pkREQUESTBODY, [], ctAPPLICATION_JSON);
  RESTRequest1.Execute;
  *)
end;

end.
