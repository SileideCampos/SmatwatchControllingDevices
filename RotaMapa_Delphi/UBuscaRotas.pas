unit UBuscaRotas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.ListView, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts,
  FMX.Colors, Rest.Json, JSON, FMX.Maps, Math, FMX.ListBox, System.RTTI,
  FMX.Objects, FMX.Ani, System.Threading, uControleEspera, uFunctions,
  System.RegularExpressions, System.Generics.Collections, IdGlobal,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TF_BuscaRotas = class(TForm)
    ColorBox1: TColorBox;
    LayPrincipal: TLayout;
    ToolBar: TToolBar;
    lblRotas: TLabel;
    LayRotas: TLayout;
    StyleBook1: TStyleBook;
    layDetalhes: TLayout;
    btnVoltar: TSpeedButton;
    lbRotas: TListBox;
    procedure btnVoltarClick(Sender: TObject);
    procedure lbRotasItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
  private
    FPontosline: System.TArray<FMX.Maps.TMapCoordinate>;
    procedure ListarRotas;
    procedure DesenharRotaMapa(pContListagem: Integer);
    procedure PolylineDecoder(pPolylineCripto: string);
    procedure AddPontosLine(pIndexPontos: integer; pLat, pLong: Double);
    { Private declarations }
  public
    { Public declarations }
    procedure BuscarRotasPossiveis;
  end;

var
  F_BuscaRotas: TF_BuscaRotas;

implementation

{$R *.fmx}

uses UDM, UPrincipal, uMapa;

procedure TF_BuscaRotas.BuscarRotasPossiveis;
begin
  TControleEspera.Synchronize(nil,
    procedure
    var
      lDestino: string;
    begin
      lbRotas.Items.Clear;
      lDestino := TRota.Rota.ListaDestinos.Last.Destino;
      DM.ConfigPolylines(F_Principal.FOrigem, lDestino, TRota.Rota.GetParadas(TRota.Rota.ListaDestinos.Count));
      ListarRotas;
    end);
end;

procedure TF_BuscaRotas.ListarRotas;
var
  LItem: TListBoxItem;
begin
  if DM.GetStatusRetorno('polilyne') then
  begin
    DM.GeraAtributoRota;
    LItem                                    := TListBoxItem.Create(lbRotas);
    LItem.Height                             := 42;
    LItem.StyleLookup                        := 'LayoutRotas';
    LItem.Text                               := DM.FEstimativaRota;
    LItem.StylesData['detail.tag']           := Integer(LItem);
    LItem.StylesData['detail.visible']       := true;
    LItem.StylesData['detail']               := DM.FDescricaoRotas;

    LItem.Tag                                := Integer(LItem);
    lbRotas.AddObject(LItem);
  end;
end;

procedure TF_BuscaRotas.lbRotasItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  Application.CreateForm(TF_GMaps, F_GMaps);
  DesenharRotaMapa(Item.Index);
end;

procedure TF_BuscaRotas.DesenharRotaMapa(pContListagem: Integer);
var
  lDestino: string;
begin
  FPontosline := System.TArray<FMX.Maps.TMapCoordinate>.Create(TMapCoordinate.Create(0,0));
  lDestino := TRota.Rota.ListaDestinos.Last.Destino;
  DM.ConfigPolylines(F_Principal.FOrigem, lDestino, TRota.Rota.GetParadas(pContListagem));
  if DM.getStatusRetorno('polilyne') then
  begin
    PolylineDecoder(DM.getPolilynes);
    TRota.Rota.AddPolyline(FPontosline);
    F_GMaps.Show;
  end;
end;

procedure TF_BuscaRotas.polylineDecoder(pPolylineCripto: String);
var
  index, tamanho, result, shift, b, indexPontos: integer;
  lat, dlat, long, dlong, factor: Double;
  charac: char;
begin
  factor := Math.Power(10, 5);
  indexPontos := 0;
  index := 0;
  tamanho := pPolylineCripto.length;
  lat := 0;
  long := 0;

  while (index < tamanho) do
  begin
    shift := 0;
    result := 0;
    while (True) do
    begin
      index := index + 1;
      charac := pPolylineCripto[index];
      b := Ord(charac) - 63 ;
      result := result or (b and 31) shl shift;
      shift := shift + 5;
      if b < 32 then
        break;
    end;
    if (result and 1) <> 0 then
      dlat := not (result shr 1)
    else
      dlat := (result shr 1);
    lat := lat + dlat;

    shift := 0;
    result := 0;
    while (True) do
    begin
      index := index + 1;
      charac := pPolylineCripto[index];
      b := Ord(charac) - 63 ;
      result := result or (b and 31) shl shift;
      shift := shift + 5;
      if (b < 32) then
        break;
    end;
    if (result and 1) <> 0 then
      dlong := not (result shr 1)
    else
      dlong := (result shr 1);
    long := long + dlong;

    AddPontosLine(indexPontos, (SimpleRoundTo(lat/factor, -5)), (SimpleRoundTo(long/factor, -5)));

    if indexPontos = 0 then
      TRota.Rota.AddCircle(SimpleRoundTo(lat/factor, -5), SimpleRoundTo(long/factor, -5));

    inc(indexPontos);
  end;
  TRota.Rota.AddMarca(SimpleRoundTo(lat/factor, -5), SimpleRoundTo(long/factor, -5), 'Destino');
end;

procedure TF_BuscaRotas.AddPontosLine(pIndexPontos: integer; pLat, pLong: Double);
begin
  SetLength(FPontosline, pIndexPontos+1);
  FPontosline[pIndexPontos] := TMapCoordinate.Create(pLat, pLong);
end;

procedure TF_BuscaRotas.btnVoltarClick(Sender: TObject);
begin
  self.Close;
end;

end.
