unit uControleEspera;

interface
uses
  System.Classes, FMX.StdCtrls, FMX.Objects, FMX.Filter.Effects, FMX.Types, FMX.Graphics,
  FMX.Forms, System.SysUtils, System.UITypes;

type
  TControleEspera = class(TThread)
  private
    FProc: TProc;
    FParent : TFmxObject;
    FAniIndicator: TAniIndicator;
    FRecWait: TRectangle;
    procedure DoCriarAguarde;
    procedure DoIniciarAguarde;
    procedure DoFinalizarAguarde;
    procedure DoDestruirAguarde;
  protected
    procedure Execute; override;
  public
    constructor Create(const pParent : TFmxObject; const AProc: TProc);
    destructor Destroy; override;
    class function CreateAnonymousThread(const pParent : TFmxObject; const ThreadProc: TProc): TControleEspera; static;
  end;

implementation

{ TControleEspera }

constructor TControleEspera.Create(const pParent: TFmxObject;
  const AProc: TProc);
begin
  inherited Create(True);
  FParent := pParent;
  FProc := AProc;
  FreeOnTerminate := True;
end;

class function TControleEspera.CreateAnonymousThread(const pParent : TFmxObject;
  const ThreadProc: TProc): TControleEspera;
begin
  Result := TControleEspera.Create(pParent, ThreadProc);
end;

destructor TControleEspera.Destroy;
begin
  DoDestruirAguarde;
  inherited;
end;

procedure TControleEspera.DoCriarAguarde;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FRecWait := TRectangle.Create(nil);
      FRecWait.Align := TAlignLayout.Contents;
      FRecWait.Fill.Kind := TBrushKind.None;
      FRecWait.Fill.Color := TAlphaColorRec.pink;
      FRecWait.Stroke.Thickness := 0;
      FRecWait.Visible := False;
      FRecWait.Parent := FParent;

      FAniIndicator := TAniIndicator.Create(FRecWait);
      FAniIndicator.Align := TAlignLayout.Center;
      FAniIndicator.Size.Width := 80;
      FAniIndicator.Size.Height := 80;
      FAniIndicator.Parent := FRecWait;
    end);
end;

procedure TControleEspera.DoDestruirAguarde;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      if FAniIndicator <> nil then
        FreeAndNil(FAniIndicator);
      if FRecWait <> nil then
        FreeAndNil(FRecWait);
    end);
end;

procedure TControleEspera.DoFinalizarAguarde;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FRecWait.Visible := False;
      FAniIndicator.Enabled := False;
    end);
end;

procedure TControleEspera.DoIniciarAguarde;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FRecWait.Visible := True;
      FAniIndicator.Enabled := True;
    end);
end;

procedure TControleEspera.Execute;
begin
  DoCriarAguarde;
  try
    DoIniciarAguarde;
    FProc();
    DoFinalizarAguarde;
  finally
    DoDestruirAguarde;
  end;
end;

end.
