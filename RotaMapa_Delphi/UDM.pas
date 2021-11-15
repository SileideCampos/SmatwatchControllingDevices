unit UDM;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, REST.Types, System.JSON,
  System.Generics.Collections, FMX.Dialogs, IDGlobal;

type
  TDM = class(TDataModule)
    RClient: TRESTClient;
    RReqPolilyne: TRESTRequest;
    RRespPolilyne: TRESTResponse;
    RReqMarca: TRESTRequest;
    RRespMarca: TRESTResponse;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FKeyMaps: string;
    function DoGetCount: Integer;
    function DoGetEndereco(const pPosicao: Integer): string;
    function DoGetDistancia(const pPosicao: Integer): Double;
    function DoGetDuracao(const pPosicao: Integer): Double;
    procedure ConfigRClient;
  public
    { Public declarations }
    FDescricaoRotas: string;
    FEstimativaRota: string;
    property KeyMaps: string read FKeyMaps write FKeyMaps;
    procedure ConfigMarcas(pEndereco: string);
    procedure ConfigPolylines(pOrigem, pDestino, pParadas: string);
    function GetStatusRetorno(pTipoDados: string): Boolean;
    function GeraAtributoRota: string;
    function GetPolilynes: string;
    function LocalizarCoordenada(pCoordenada, pPolo: string): Double;
    function GetLatitude: Double;
    function GetLongitude: Double;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses uBuscaRotas;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  ConfigRClient;
end;

procedure TDM.ConfigRClient;
begin
  RClient.ResetToDefaults;
  RClient.BaseURL               := 'https://maps.googleapis.com';
  RClient.Accept                := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  RClient.AcceptCharset         := 'UTF-8, *;q=0.8';
end;

procedure TDM.ConfigMarcas(pEndereco: string);
begin
  RReqMarca.Client              := RClient;
  //RReqMarca.Resource            := 'maps/api/geocode/json?address='+pEndereco+'&key='+FKeyMaps;
  //RReqMarca.Resource            := 'maps/api/geocode/json';
  //RReqMarca.AddParameter('address', )
  RReqMarca.Response            := RRespMarca;
  RReqMarca.SynchronizedEvents  := False;

  RRespMarca.ContentType        := 'application/json';

  try
    RReqMarca.Execute;
  except on E: Exception do
    ShowMessage('Problemas ao acessar dados ');
  end;
end;

procedure TDM.ConfigPolylines(pOrigem, pDestino, pParadas: string);
begin
{  if pParadas <> '' then
    RReqPolilyne.Resource          := 'maps/api/directions/json?origin='+pOrigem+'&destination='+pDestino+'&waypoints='+pParadas+'&key='+FKeyMaps
  else
    RReqPolilyne.Resource          := 'maps/api/directions/json?origin='+pOrigem+'&destination='+pDestino+'&mode=driving&key='+FKeyMaps;
 }
  RReqPolilyne.Resource            := 'maps/api/directions/json';
  RReqPolilyne.AddParameter('origin', pOrigem);
  RReqPolilyne.AddParameter('waypoints', pParadas);
  RReqPolilyne.AddParameter('destination', pDestino);
  RReqPolilyne.AddParameter('mode', 'driving');
  RReqPolilyne.AddParameter('key', FKeyMaps);
  RReqPolilyne.Client              := RClient;
  RReqPolilyne.Response            := RRespPolilyne;
  RReqPolilyne.SynchronizedEvents  := False;

  RRespPolilyne.ContentType        := 'application/json';

  try
    RReqPolilyne.Execute;
  except on E: Exception do
    ShowMessage('Erro: ' + E.Message);
  end;
end;

function TDM.DoGetCount: Integer;
begin
  Result := TJSONArray(TJSONObject(TJSONArray(TJSONObject(RRespPolilyne.JSONValue)
              .Get('routes').JsonValue).Items[0])
              .Get('legs').JsonValue).Count;
end;

function TDM.GetStatusRetorno(pTipoDados: string): Boolean;
begin
  Result := False;
  if (RRespPolilyne.JSONText.Length > 0) or
     (RRespMarca.JSONText.Length > 0) then
  begin
    if (LowerCase(pTipoDados) = 'marca') then
      Result := TJSONObject(RRespMarca.JSONValue).Get('status').JsonValue.Value = 'OK'
    else if (LowerCase(pTipoDados) = 'polilyne') then
      Result := TJSONObject(RRespPolilyne.JSONValue).Get('status').JsonValue.Value = 'OK';
  end;
end;

function TDM.DoGetDistancia(const pPosicao: Integer): Double;
var
  lDistancia: Double;
begin
  lDistancia := 0;
  var distancia := TJSONObject(TJSONObject(TJSONArray(TJSONObject(TJSONArray(TJSONObject(RRespPolilyne.JSONValue)
                      .Get('routes').JsonValue).Items[0])
                      .Get('legs').JsonValue).Items[pPosicao])
                      .Get('distance').JsonValue)
                      .Get('text').JsonValue.Value;
  distancia := Fetch(distancia, ' ');
  try
    lDistancia := lDistancia + StrToCurr(distancia);
  except
    lDistancia := lDistancia + StrToCurr(StringReplace(distancia, '.', ',', [rfReplaceAll]));
  end;
  Result := lDistancia;
end;

function TDM.DoGetDuracao(const pPosicao: Integer): Double;
var
  lDuracao: Double;
begin
  lDuracao := 0;
  var duracao := TJSONObject(TJSONObject(TJSONArray(TJSONObject(TJSONArray(TJSONObject(RRespPolilyne.JSONValue)
                    .Get('routes').JsonValue).Items[0])
                    .Get('legs').JsonValue).Items[pPosicao])
                    .Get('duration').JsonValue)
                    .Get('text').JsonValue.Value;
  //Atenção para o formato de conversão do Android -> English aceita com . (ponto) e em Portugês, aceita com , (vírgula)
  duracao := Fetch(duracao, ' ');
  try
    lDuracao := lDuracao + StrToFloat(duracao);
  except
    lDuracao := lDuracao + StrToCurr(StringReplace(duracao, '.', ',', [rfReplaceAll]));
  end;
  Result := lDuracao;
end;

function TDM.DoGetEndereco(const pPosicao: Integer): string;
begin
  Result := TJSONObject(TJSONArray(TJSONObject(TJSONArray(TJSONObject(RRespPolilyne.JSONValue)
              .Get('routes').JsonValue).Items[0])
              .Get('legs').JsonValue).Items[pPosicao])
              .Get('end_address').JsonValue.Value;
end;

function TDM.GetLatitude: Double;
begin
  Result := StrToFloatDef((((((RRespMarca.JSONValue as TJSONObject)
              .Get('results').JsonValue as TJSONArray).Items[0] as TJSONObject)
              .GetValue('geometry') as TJSONObject)
              .GetValue('location') as TJSONObject)
              .GetValue('lat').ToString, 0);
end;

function TDM.GetLongitude: Double;
begin
  Result := StrToFloatDef((((((RRespMarca.JSONValue as TJSONObject)
              .Get('results').JsonValue as TJSONArray).Items[0] as TJSONObject)
              .GetValue('geometry') as TJSONObject)
              .GetValue('location') as TJSONObject)
              .GetValue('lng').ToString, 0);
end;

function TDM.GeraAtributoRota: string;
var
  lDistancia, lDuracao: Double;
  lEndereco: string;
begin
    lDuracao := 0;
    lDistancia := 0;
    for var count := 0 to pred(DoGetCount) do
    begin
      lEndereco  := lEndereco  + DoGetEndereco(count) +#13;
      lDistancia := lDistancia + DoGetDistancia(count);
      lDuracao   := lDuracao   + DoGetDuracao(count);
    end;
    FEstimativaRota := lDistancia.ToString +' km em '+ lDuracao.toString +' min';
    FDescricaoRotas := lEndereco;
end;

function TDM.GetPolilynes: string;
begin
  result := TJSONObject((((RRespPolilyne.JSONValue as TJSONObject)
              .Get('routes').JsonValue as TJSONArray).Items[0] as TJSONObject)
              .Get('overview_polyline').JsonValue)
              .GetValue('points').ToString;
  result := copy(result, 2, Length(result)-1);
  result := StringReplace(result, '\\', '\', [rfReplaceAll]);
end;

function TDM.LocalizarCoordenada(pCoordenada, pPolo: string): Double;
begin
  if pCoordenada <> '' then
    Result := StrToFloat((((((RRespPolilyne.JSONValue as TJSONObject)
                                  .Get('routes' ).JsonValue as TJSONArray)
                                    .Items[0] as TJSONObject)
                                  .Get('bounds').JsonValue as TJSONObject)
                                  .Get(pCoordenada).JsonValue as TJSONObject)
                                  .Get(pPolo).JsonValue.Value)
  else
    Result := StrToFloat((((((RRespMarca.JSONValue as TJSONObject)
                                  .Get('results').JsonValue as TJSONArray)
                                    .Items[0] as TJSONObject)
                                  .GetValue('geometry') as TJSONObject)
                                  .GetValue('location') as TJSONObject)
                                  .GetValue(pPolo).ToString);
end;

end.
