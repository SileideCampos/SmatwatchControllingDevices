unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, System.Sensors.Components,
  FMX.Maps, FMX.StdCtrls, FMX.EditBox, FMX.SpinBox, System.Generics.Collections,
  FMX.ListBox, FMX.Colors,
  System.Permissions, System.ImageList, FMX.ImgList, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TF_Principal = class(TForm)
    ToolBar: TToolBar;
    edtOrigem: TEdit;
    ListViewDestinos: TListView;
    edtDestino1: TEdit;
    btnIncluiDestino: TSpeedButton;
    lblRotas: TLabel;
    LayPrincipal: TLayout;
    VertScrollBox1: TVertScrollBox;
    layDestino: TLayout;
    layOrigem: TLayout;
    LayEnderecos: TLayout;
    layEnderecoDestino: TLayout;
    ColorBox1: TColorBox;
    layBotaoAvancar: TLayout;
    layEnderecoOrigem: TLayout;
    LocationSensor: TLocationSensor;
    btnAvancar: TSpeedButton;
    btnLocalizacao: TButton;
    ImageList1: TImageList;
    procedure btnIncluiDestinoClick(Sender: TObject);
    procedure btnAvancarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLocalizacaoClick(Sender: TObject);
    procedure lblRotasClick(Sender: TObject);
  private
    procedure OnGeocodeReverseEvent(const Address: TCivicAddress);
    procedure BuscarLocalizacaoAtual;
    procedure validaCampos;
    procedure RequestResult(Sender: TObject; const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>);
    procedure RequisitaPermissoes;
    { Private declarations }
  public
    { Public declarations }
    FOrigem: string;
    FGeocoder: TGeocoder;
  end;

var
  F_Principal: TF_Principal;

implementation

{$R *.fmx}

uses UDM, UBuscaRotas, uFunctions,
{$IFDEF ANDROID}
  Androidapi.Jni.OS,
  FMX.Helpers.Android,
  AndroidApi.JNI.GraphicsContentViewText,
  Androidapi.Jni.Net,
  Androidapi.Jni.JavaTypes,
  AndroidApi.Helpers,
  System.Android.Sensors,
{$ENDIF ANDROID}
UMapa;

procedure TF_Principal.btnAvancarClick(Sender: TObject);
var
  lDestino: TDestino;
begin
  validaCampos;
  Application.CreateForm(TF_BuscaRotas, F_BuscaRotas);
  try
    TRota.Rota.ListaDestinos.Free;
    TRota.Rota.ListaDestinos := TListaDestinos.Create;

    for var cont := 0 to pred(ListViewDestinos.Items.Count) do
    begin
      lDestino := TDestino.Create;
      lDestino.Destino := ListViewDestinos.Items[cont].Text;
      TRota.Rota.ListaDestinos.Add(lDestino);
    end;

    F_BuscaRotas.BuscarRotasPossiveis;
  finally
    F_BuscaRotas.Show;
  end;
end;

procedure TF_Principal.validaCampos;
begin
  if edtOrigem.Text = '' then
    raise Exception.Create('É necessário especificar a origem');
  if FOrigem = '' then
    FOrigem := edtOrigem.Text;
  if ListViewDestinos.Items.Count <=0 then
    raise Exception.Create('É necessário incluir pelo menos 1 destino');
end;

procedure TF_Principal.btnIncluiDestinoClick(Sender: TObject);
var
  lItem: TListViewItem;
begin
  if edtDestino1.Text <> '' then
  begin
    lItem := ListViewDestinos.Items.Add;
    lItem.Text := edtDestino1.Text;
    btnAvancar.Visible := True;
    edtDestino1.Text := '';
  end;
end;

procedure TF_Principal.btnLocalizacaoClick(Sender: TObject);
begin
  BuscarLocalizacaoAtual;
end;

procedure TF_Principal.FormShow(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
  RequisitaPermissoes;
end;

procedure TF_Principal.lblRotasClick(Sender: TObject);
begin
  Application.CreateForm(TF_GMaps, F_GMaps);
  F_GMaps.Show;
end;

procedure TF_Principal.RequisitaPermissoes;
begin
  PermissionsService.RequestPermissions([ JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION) ],
    RequestResult, nil);
end;

procedure TF_Principal.RequestResult(Sender: TObject; const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
begin
  var LocationPermissionGranted :=
    (Length(AGrantResults) = 1) and
    (AGrantResults[0] = TPermissionStatus.Granted);
  if LocationPermissionGranted then
  begin
    LocationSensor.Active := True;
    //Add a chave api em Project -> Options -> Version Info -> (Target Android) apiKey
    DM.KeyMaps := 'AIzaSyDIcwARgoz9Auypf_sGfgeH12AmbuLy_5w';
  end;
end;

procedure TF_Principal.BuscarLocalizacaoAtual;
var
  lCoordenadas: TLocationCoord2D;
begin
  RequisitaPermissoes;
  LocationSensor.Active := True;
  lCoordenadas := TLocationCoord2D.Create(LocationSensor.Sensor.Latitude, LocationSensor.Sensor.Longitude);
  if not lCoordenadas.Latitude.IsNan then
  begin
    //FOrigem := lCoordenadas.Latitude.ToString+','+lCoordenadas.Longitude.ToString;
    FGeocoder := TGeocoder.Current.Create;

    if Assigned(FGeocoder) then
      FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
    if Assigned(FGeocoder) and not FGeocoder.Geocoding then
      FGeocoder.GeocodeReverse(lCoordenadas);

    FGeocoder.Free;
  end;
end;

procedure TF_Principal.OnGeocodeReverseEvent(const Address: TCivicAddress);
begin
  edtOrigem.Text :=  Address.Thoroughfare    +', '+ //Endereco
                     Address.SubThoroughfare +', '+ //Número
                     Address.PostalCode      +', '+ //CEP
                     Address.SubLocality     +', '+ //Bairro
                     Address.AdminArea       +', '+ //Estado
                     Address.CountryName;           //País
end;

end.
