unit UFiltrages_AB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask;

type
  TForm3 = class(TForm)
    Panel2: TPanel;
    NAccelLabeledEdit: TLabeledEdit;
    OutlierLabeledEdit: TLabeledEdit;
    NMinLabeledEdit: TLabeledEdit;
    NMaxLabeledEdit: TLabeledEdit;
    NGyroLabeledEdit: TLabeledEdit;
    GOutlierLabeledEdit: TLabeledEdit;
    GMinLabeledEdit: TLabeledEdit;
    GMaxLabeledEdit: TLabeledEdit;
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

type
  TAlphaBeta = class
  private
    dtMax, dtMin, delta, prim, filt, _delta, _prim, _filt: Extended;
    alpha, beta, Threshold, PrimMin, PrimMax, FiltMin, FiltMax: Extended;
    firstpass: Boolean;
    zicket: Integer;
  public
    // constructor Create(N: Word; dtTypical: Extended);
    constructor Create(N: Word; dtTypical: Extended; const _Threshold: Extended = 0.0; const _filtMin: Extended = 0.0; const _filtMax: Extended = 0.0;
      const _primMin: Extended = 0.0; const _primMax: Extended = 0.0);
    procedure ABinit(N: Word; dtTypical: Extended); overload;
    procedure ABinit(N: Word; dtTypical: Extended; _Threshold: Extended); overload;
    procedure ABinit(N: Word; dtTypical: Extended; _Threshold: Extended; _filtMin: Extended; _filtMax: Extended); overload;
    procedure ABinit(N: Word; dtTypical: Extended; _Threshold, _filtMin, _filtMax, _primMin, _primMax: Extended); overload;

    procedure ABupdate(dt: Extended; RawData: Extended);
    function Stable: Boolean;
    property ABfilt:Extended read filt write filt;
    property ABprim:Extended read prim write prim;

  end;

type
  TLowPassFilter = class
  private
    output1: Extended;
    output2: Extended;
    alpha: Extended;
    beta: Extended;
    firstpassdone: Boolean;
  public
    constructor Create(cutoffperiod, dt: Extended);
    procedure LPupdate(input: Extended);
    property LowPass1: Extended read output1 write output1;
    property LowPass2: Extended read output2 write output2;
  end;

const
  MaxZicket = 2; // maximum number of concecuitives zickets to let the filter track the signal. If zicket is higher a step change in signal is suspected

var
  Form3: TForm3;

implementation

{$R *.dfm}

// --------------------------------------
constructor TAlphaBeta.Create(N: Word; dtTypical: Extended; const _Threshold: Extended = 0.0; const _filtMin: Extended = 0.0;
  const _filtMax: Extended = 0.0; const _primMin: Extended = 0.0; const _primMax: Extended = 0.0);
begin
  ABinit(N, dtTypical, _Threshold, _filtMin, _filtMax, _primMin, _primMax);
end;

procedure TAlphaBeta.ABinit(N: Word; dtTypical: Extended);
// constructor TAlphaBeta.Create(N: Word; dtTypical, _Threshold, _filtMin, _filtMax,_primMin,_primMax: Extended);

begin
  ABinit(N, dtTypical, 0.0, 0.0, 0.0, 0.0, 0.0);
end;

procedure TAlphaBeta.ABinit(N: Word; dtTypical: Extended; _Threshold: Extended);
begin
  ABinit(N, dtTypical, _Threshold, 0.0, 0.0, 0.0, 0.0);
end;

procedure TAlphaBeta.ABinit(N: Word; dtTypical: Extended; _Threshold: Extended; _filtMin: Extended; _filtMax: Extended);
begin
  ABinit(N, dtTypical, _Threshold, _filtMin, _filtMax, 0.0, 0.0);
end;

procedure TAlphaBeta.ABinit(N: Word; dtTypical: Extended; _Threshold, _filtMin, _filtMax, _primMin, _primMax: Extended);
begin
  if N <> 0.0 then
  begin
    alpha := (2.0 * (2.0 * N - 1.0) / N / (N + 1.0));
    beta := (6.0 / N / (N + 1.0));
    dtMax := dtTypical * 4.0;
    dtMin := dtTypical / 4.0;
    firstpass := True;
  end;
  Threshold := _Threshold;
  FiltMin := _filtMin;
  FiltMax := _filtMax;
  PrimMin := _primMin;
  PrimMax := _primMax;
end;

procedure TAlphaBeta.ABupdate(dt: Extended; RawData: Extended);
begin
  // process sample if dt above dtMin and below dtMax (dtMin typicaly average dt / 4 and dtMax typicaly 4 x average dt)
  if (dt > dtMin) and (dt < dtMax) then
  begin
    if firstpass then // initialize filter variables when first called
    begin
      filt := RawData;
      _filt := RawData;
      prim := 0.0;
      _prim := 0.0;
      firstpass := False;
      zicket := 4 * MaxZicket;
    end
    else
    begin
      if zicket <= MaxZicket then // if filter stable
      begin
        delta := RawData - filt;
        if (Abs(delta) < Threshold) or (Threshold = 0.0) then // new data below threshold
        begin
          prim := prim + beta * delta / dt;
          if (PrimMin <> 0.0) or (PrimMax <> 0.0) then
          begin
            if prim < PrimMin then
              prim := PrimMin;
            if prim > PrimMax then
              prim := PrimMax;
          end;
          filt := filt + alpha * delta + prim * dt;
          if (FiltMin <> 0.0) or (FiltMax <> 0.0) then
          begin
            if filt < FiltMin then
              filt := FiltMin;
            if filt > FiltMax then
              filt := FiltMax;
          end;
          zicket := 0;
        end
        else // new data above threshold, additional zicket
        begin
          zicket := zicket + 1;
          if zicket > MaxZicket then // if new zicket makes filter unstable (step change), arm and switch to alternate AB filter
          begin
            _prim := prim;
            _filt := filt;
            zicket := 4 * MaxZicket;
          end;
        end;
      end
      else // if filter unstable - step change
      begin
        // update alternate filter to track step change
        _delta := RawData - _filt;
        _prim := _prim + beta * _delta / dt;
        _filt := _filt + alpha * _delta + _prim * dt;
        // if new data below threshold, reduce number of zicket
        if (Abs(_delta) < Threshold) or (Threshold = 0.0) then
          zicket := zicket - 1
        else
          zicket := 4 * MaxZicket;
        if zicket <= MaxZicket then // if number of zicket below stability criteria, arm and switch to primary filter
        begin
          prim := _prim;
          filt := _filt;
          zicket := 0;
        end;
      end;
    end;
  end;
end;

function TAlphaBeta.Stable: Boolean;
begin
  if zicket = 0 then
    Result := True
  else
    Result := False;
end;

constructor TLowPassFilter.Create(cutoffperiod, dt: Extended);
begin
  alpha := cutoffperiod / (cutoffperiod + dt);
  beta := 1.0 - alpha;
end;

procedure TLowPassFilter.LPupdate(input: Extended);
begin
      output1 := alpha * output1 + beta * input;
      output2 := alpha * output2 + beta * output1;
end;

{
  procedure TLowPassFilter.LpUpdate(input: Extended);
  begin
  Foutput1 := alpha * Foutput1 + beta * input;
  Foutput2 := alpha * Foutput2 + beta * Foutput1;
  end;

  Function TLowPassFilter.GetOutput1: Extended;
  begin
  Result :=Foutput1;
  end;

  Function TLowPassFilter.GetOutput2: Extended;
  begin
  Result := Foutput2;
  end;

Function TLowPassFilter.LowPass1: Extended;
begin
  Result := output1;
end;

Function TLowPassFilter.LowPass2: Extended;
begin
  Result := output2;
end;
    }
{ *************************************************************** }

end.
