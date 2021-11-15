unit uMapa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, System.Sensors.Components,
  FMX.Maps, FMX.StdCtrls, FMX.EditBox, FMX.SpinBox, System.Generics.Collections,
  FMX.ListBox, FMX.Colors, FMX.Gestures;

type
  TF_GMaps = class(TForm)
    MapView1: TMapView;
    LocationSensor1: TLocationSensor;
    GestureManager1: TGestureManager;
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure FormShow(Sender: TObject);
  private
    procedure LimpaCirculos;
    { Private declarations }
  public
    { Public declarations }
    FCircles: TList<TMapCircle>;
  end;

var
  F_GMaps: TF_GMaps;

implementation

{$R *.fmx}
{$R *.Moto360.fmx ANDROID}

uses uPrincipal;

procedure TF_GMaps.FormShow(Sender: TObject);
begin
  LocationSensor1.Active := True;
  FCircles := TList<TMapCircle>.Create;
  MapView1.Location.Create(F_Principal.LocationSensor.Sensor.Latitude, F_Principal.LocationSensor.Sensor.Longitude);
  MapView1.Zoom := 15;
  MapView1.ResetFocus;
end;

procedure TF_GMaps.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
  lCircleDescritor: TMapCircleDescriptor;
  lMapCoordinate: TMapCoordinate;
begin
  LimpaCirculos;

  lMapCoordinate := TMapCoordinate.Create(NewLocation.Latitude, NewLocation.Longitude);

  lCircleDescritor := TMapCircleDescriptor.Create(lMapCoordinate, 2);
  lCircleDescritor.Center      := lMapCoordinate;
  lCircleDescritor.FillColor   := TAlphaColorRec.Lightpink;
  lCircleDescritor.StrokeColor := TAlphaColorRec.Hotpink;
  lCircleDescritor.StrokeWidth := 2;

  FCircles.Add(MapView1.AddCircle(lCircleDescritor));

  MapView1.Location := lMapCoordinate;

  MapView1.Zoom := 15;
  MapView1.ResetFocus;
end;

procedure TF_GMaps.LimpaCirculos;
var
  lCircle: TMapCircle;
begin
  for lCircle in FCircles do
    lCircle.Remove;
  FCircles.Clear;
end;


end.
