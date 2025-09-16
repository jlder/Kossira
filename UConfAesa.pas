unit UConfAesa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.CheckLst;

type
  TConfForm = class(TForm)
    Panel1: TPanel;
    ClassNumbersLabeledEdit: TLabeledEdit;
    UnderSampleLabeledEdit: TLabeledEdit;
    HighgLabeledEdit: TLabeledEdit;
    LowgLabeledEdit: TLabeledEdit;
    Label1: TLabel;
    QuantumLabel: TLabel;
    ValidationButton: TButton;
    Panel2: TPanel;
    dtLabeledEdit: TLabeledEdit;
    NAccelLabeledEdit: TLabeledEdit;
    OutlierLabeledEdit: TLabeledEdit;
    NMinLabeledEdit: TLabeledEdit;
    NMaxLabeledEdit: TLabeledEdit;
    NAccelxLabeledEdit: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    Panel3: TPanel;
    DecelerationLabeledEdit: TLabeledEdit;
    PullUpLabeledEdit: TLabeledEdit;
    PullUpDelayLabeledEdit: TLabeledEdit;
    DecDelayLabeledEdit: TLabeledEdit;
    RepereRadioGroup: TRadioGroup;
    ButterWorthRadioGroup: TRadioGroup;
    Panel4: TPanel;
    w1LabeledEdit: TLabeledEdit;
    w2LabeledEdit: TLabeledEdit;
    w3LabeledEdit: TLabeledEdit;
    w4LabeledEdit: TLabeledEdit;
    TouchLabeledEdit: TLabeledEdit;
    IntegratorThresholdLabeledEdit: TLabeledEdit;
    NewFlightDelayLabeledEdit: TLabeledEdit;
    ShowDataCheckBox: TCheckBox;
    PullUpTimeOutLabeledEdit: TLabeledEdit;
    IntegDelayLabeledEdit: TLabeledEdit;
    MinFlightDurationLabeledEdit: TLabeledEdit;
    IntegTouchDelayLabeledEdit: TLabeledEdit;
    TouchTimeOutLabeledEdit: TLabeledEdit;
    StopLabeledEdit: TLabeledEdit;
    procedure ValidationButtonClick(Sender: TObject);
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
const
  MaxZicket = 2; // maximum number of concecuitives zickets to let the filter track the signal. If zicket is higher a step change in signal is suspected

var
  ConfForm: TConfForm;
  Quantum, QuantumRough : Extended;
  HighG, LowG, Dynamique:Extended;
  ClassNumbers, UnderSample:Integer;
  deltaT,distCdGx,distCdGz:Extended;
var // fusion parameters
  w1,w2,w3,w4:Integer;

function CountCheckedItems(CheckListBox: TCheckListBox): Integer;

implementation

{$R *.dfm}
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


procedure TConfForm.ValidationButtonClick(Sender: TObject);

begin
HighG:=StrToFloat(HighgLabeledEdit.Text);
LowG:=StrToFloat(LowgLabeledEdit.Text);
ClassNumbers:=StrToInt(ClassNumbersLabeledEdit.Text);
UnderSample:=StrToInt(UnderSampleLabeledEdit.Text);
deltaT := StrToFloat(ConfForm.dtLabeledEdit.Text);

Dynamique:=HighG-LowG;
Quantum:=Dynamique/ClassNumbers;
QuantumRough:=Dynamique/UnderSample;
QuantumLabel.Caption := Format('%5.3f',[Quantum*1000.0]);
Close;
end;
function CountCheckedItems(CheckListBox: TCheckListBox): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to CheckListBox.Count - 1 do
    if CheckListBox.Checked[i] then
      Inc(Result);
end;

end.
