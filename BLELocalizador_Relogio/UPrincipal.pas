unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, System.Bluetooth,
  System.Bluetooth.Components, FMX.TabControl, FMX.Objects, FMX.Edit,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.Permissions, System.Rtti;

type
  TFLocalizador = class(TForm)
    BLE: TBluetoothLE;
    lbDevices: TListBox;
    lConnect: TLayout;
    btnConnect: TButton;
    btnLed: TCircle;
    StyleBook1: TStyleBook;
    pUPEnvio: TPopup;
    Layout1: TLayout;
    btnClose: TButton;
    lblAlert: TLabel;
    gbCommands: TGroupBox;
    rbOn: TRadioButton;
    rbOff: TRadioButton;
    procedure btnConnectClick(Sender: TObject);
    procedure BLEEndDiscoverDevices(const Sender: TObject;
      const ADeviceList: TBluetoothLEDeviceList);
    procedure BLEEndDiscoverServices(const Sender: TObject;
      const AServiceList: TBluetoothGattServiceList);
    procedure rbSend_1Click(Sender: TObject);
    procedure rbSend_0Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCloseWriteClick(Sender: TObject);
  private
    { Private declarations }
    FGattService: TBluetoothGattService;
    FBleDevice: TBluetoothLEDevice;
    FCharacteristic: TBluetoothGattCharacteristic;
    procedure enviarDados(pValor: Integer);
    procedure LigaDesliga;
  public
    { Public declarations }
  end;

var
  FLocalizador: TFLocalizador;

const
  CaracterBattery = '2A19';
  CaracterHeartRate = '2A37';

implementation

{$R *.fmx}
{$R *.Moto360.fmx ANDROID}

//PERMISSÃO PARA LOCALIZAÇÃO
procedure TFLocalizador.FormShow(Sender: TObject);
begin
  pUPEnvio.Visible := False;
end;

procedure TFLocalizador.btnConnectClick(Sender: TObject);
begin
  BLE.Enabled := True;
  BLE.DiscoverDevices(800);
end;

procedure TFLocalizador.BLEEndDiscoverDevices(const Sender: TObject;
  const ADeviceList: TBluetoothLEDeviceList);
begin
  lbDevices.Items.Clear;
  for var lDevice in ADeviceList do
  begin
    if not (lDevice.DeviceName.IsEmpty) then
    begin
      lbDevices.Items.AddObject(lDevice.DeviceName+'-'+lDevice.LastRSSI.ToString, lDevice);
      if lDevice.DeviceName = 'iTAG            ' then
      begin
        FBleDevice := lDevice;
        FBleDevice.DiscoverServices;
        LigaDesliga;
      end;
    end;
  end;
end;

procedure TFLocalizador.BLEEndDiscoverServices(const Sender: TObject;
  const AServiceList: TBluetoothGattServiceList);
begin
  if (AServiceList.Count > 0) then
    btnLed.Fill.Color := TAlphaColorRec.Lime;
end;

procedure TFLocalizador.LigaDesliga;
var
  lServico: TBluetoothGattService;
begin
  for var lService in BLE.GetServices(FBleDevice) do
  begin
    btnLed.Fill.Color := TAlphaColorRec.Lime;
    if lService.UUIDName = 'IMMEDIATE ALERT' then
    begin
      lServico := lService;
      FGattService := BLE.GetService(FBleDevice, lServico.UUID);
      for var lCharacteristc in FGattService.Characteristics do
      begin
        if lCharacteristc.UUIDName = 'Alert Level' then
        begin
          FCharacteristic := lCharacteristc;
          pUPEnvio.Visible := True;
        end;
      end;
    end;
  end;
end;

procedure TFLocalizador.btnCloseWriteClick(Sender: TObject);
begin
  pUPEnvio.Visible := False;
end;

procedure TFLocalizador.rbSend_0Click(Sender: TObject);
begin
  enviarDados(TRadioButton(Sender as TFMXObject).Tag);
end;

procedure TFLocalizador.rbSend_1Click(Sender: TObject);
begin
  enviarDados(TRadioButton(Sender as TFMXObject).Tag);
end;

procedure TFLocalizador.enviarDados(pValor: Integer);
begin
  FCharacteristic.SetValueAsInteger(pValor);
  FBleDevice.WriteCharacteristic(FCharacteristic);
end;


end.
