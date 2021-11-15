unit uFunctions;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, REST.Types, System.JSON,
  System.Generics.Collections, FMX.Maps, System.UITypes, uMapa, uDM;

type
  TDestino = class
    private
      FDestino: string;
    public
      property Destino: string read FDestino write FDestino;
  end;
  TListaDestinos = TObjectList<TDestino>;

  TAtributosRotas = class
    private
      FKeyMaps: string;
      FListaDestinos: TListaDestinos;
    public
      property ListaDestinos: TListaDestinos read FListaDestinos write FListaDestinos;
      procedure AddCircle(pLatitude, pLongitude: Double);
      procedure AddMarca(pLatitude, pLongitude: Double; pDescricao: string);
      procedure AddPolyline(pPontosline: System.TArray<FMX.Maps.TMapCoordinate>);
      procedure BuscarCoordenadasMarcas(pEndereco, pDescricao: string);
      function GetParadas(pOrdem: Integer): string;
  end;

  TRota = class
    private
      class var FRota: TAtributosRotas;
      class function GetRota: TAtributosRotas; static;
    public
      class destructor Destroy;
      class property Rota: TAtributosRotas read GetRota;
  end;

implementation

uses
  FMX.Graphics;

{ TAtributosRotas }

procedure TAtributosRotas.AddCircle(pLatitude, pLongitude: Double);
var
  lCircleDescritor: TMapCircleDescriptor;
  lMapCoordinate: TMapCoordinate;
begin
  lMapCoordinate := TMapCoordinate.Create(pLatitude, pLongitude);

  lCircleDescritor := TMapCircleDescriptor.Create(lMapCoordinate, 2);
  lCircleDescritor.Center      := lMapCoordinate;
  lCircleDescritor.FillColor   := TAlphaColorRec.Lightpink;
  lCircleDescritor.StrokeColor := TAlphaColorRec.Hotpink;
  lCircleDescritor.StrokeWidth := 2;

  if Assigned(F_GMaps.MapView1) then
    F_GMaps.MapView1.AddCircle(lCircleDescritor);
end;

procedure TAtributosRotas.AddMarca(pLatitude, pLongitude: Double; pDescricao: string);
var
  lMarca: TMapMarkerDescriptor;
begin
  lMarca := TMapMarkerDescriptor.Create(TMapCoordinate.Create(pLatitude, pLongitude), pDescricao);
  lMarca.Rotation := 0;
  lMarca.Snippet := 'Detalhes '+pDescricao;
  lMarca.Appearance := TMarkerAppearance.Billboard;

  if Assigned(F_GMaps.MapView1) then
    F_GMaps.MapView1.AddMarker(lMarca);
end;

procedure TAtributosRotas.AddPolyline(pPontosline: System.TArray<FMX.Maps.TMapCoordinate>);
var
  lPolyline: TMapPolylineDescriptor;
begin
  lPolyline               := TMapPolylineDescriptor.Create(pPontosline);
  lPolyline.Points.Points := pPontosline;
  lPolyline.StrokeColor   := TAlphaColorRec.steelblue;
  lPolyline.StrokeWidth   := 10;
  lPolyline.Geodesic      := true;
  F_GMaps.MapView1.AddPolyline(lPolyline);
end;

function TAtributosRotas.GetParadas(pOrdem: Integer): string;
var
  lParadas: string;
begin
  if ListaDestinos.Count > 1 then
  begin
    lParadas := ListaDestinos[0].Destino;
    for var cont := 1 to ListaDestinos.Count-2 do
      lParadas := lParadas +'|'+ ListaDestinos[cont].Destino;
  end;
  Result := lParadas;
end;

procedure TAtributosRotas.BuscarCoordenadasMarcas(pEndereco, pDescricao: string);
begin
  DM.ConfigMarcas(pEndereco);
  if DM.GetStatusRetorno('marca') then
  begin
    AddMarca(DM.GetLatitude,
             DM.GetLongitude,
             pDescricao);
  end;
end;

{ TRotas }

class destructor TRota.Destroy;
begin
  FRota.Free;
end;

class function TRota.GetRota: TAtributosRotas;
begin
  if FRota = nil then
    FRota := TAtributosRotas.Create;
  Result := FRota;
end;

end.
