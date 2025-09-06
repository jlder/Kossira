unit UMainAESA_Opt;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.IOUtils, // ← pour TFile et ReadAllBytes

  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, Vcl.ComCtrls, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs,
  VCLTee.Chart, Vcl.Grids, Vcl.Menus, Math, UFFT, UButterworth, USort,
  UConfAesa, UDecodeWIT_opt, VCLTee.TeeGDIPlus;

const
  APP_COPYRIGHT = '© 2025 GFM & JLD. Copyright. Tous droits réservés.';
  APP_VERSION = 'Version 1.0.0.0';
  Gravity = 9.807;
  // TailleMessage = 22; // taille d'un message complet (temps+Accel)
  Taille_Spectrum = 31; // Quantification of loadfactor
  WindowSize = 64; // Taille du buffer circulaire

type
  Table_Spectrum = Array [0 .. Taille_Spectrum] of Integer;
  Table_Kossira = Array [0 .. Taille_Spectrum] of Extended;

type
  TCircularBuffer = record
    Data: array [0 .. WindowSize - 1] of Extended;
    Index: Integer;
    Count: Integer;
  end;

type
  TFlights = array of TFlightInfo;

type
  TFusion_Coef = array [0 .. 3] of Integer;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    FileNameLabeledEdit: TLabeledEdit;
    RunButton: TButton;
    FileOpenTextFileDialog: TOpenTextFileDialog;
    PageControl1: TPageControl;
    DataTabSheet: TTabSheet;
    GraphTabSheet: TTabSheet;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Chart1: TChart;
    ProgressBar1: TProgressBar;
    Markov1TabSheet: TTabSheet;
    MarcovStringGrid1: TStringGrid;
    Marcov2TabSheet: TTabSheet;
    MarcovStringGrid2: TStringGrid;
    spectrumStringGrid: TStringGrid;
    SpectraTabSheet: TTabSheet;
    Chart2: TChart;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Open: TMenuItem;
    Save: TMenuItem;
    N1: TMenuItem;
    Run1: TMenuItem;
    Help: TMenuItem;
    Help2: TMenuItem;
    N2: TMenuItem;
    About: TMenuItem;
    Quit: TMenuItem;
    SaveDialog1: TSaveDialog;
    SaveAs: TMenuItem;
    Print: TMenuItem;
    N4: TMenuItem;
    Memo1: TMemo;
    Run: TMenuItem;
    RunConfiguration: TMenuItem;
    RunningLabel: TLabel;
    PrintSpectra: TMenuItem;
    GraphCheckBox: TCheckBox;
    RunBatch: TMenuItem;
    RLabel: TLabel;
    FlightTimeLabel: TLabel;
    Label2: TLabel;
    FFTCheckBox: TCheckBox;
    SortCheckBox: TCheckBox;
    Series3: TLineSeries;
    Series6: TLineSeries;
    Series1: TLineSeries;
    Series7: TLineSeries;
    Series8: TLineSeries;
    Series2: TPointSeries;
    DXLabeledEdit: TLabeledEdit;
    Procedure Initialisation(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
    procedure ConfButtonClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure QuitClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure PrintClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure RunClick(Sender: TObject);
    procedure RunConfigurationClick(Sender: TObject);
    procedure MarcovStringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure MarcovStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure PrintSpectraClick(Sender: TObject);
    procedure RunBatchClick(Sender: TObject);
    Procedure FileProcessing(Sender: TObject);
    Procedure Data_Processing(Sender: TObject);
    procedure InitBuffer(var Buf: TCircularBuffer);
  private
    { Déclarations privées }
    LigneAGrossir: Integer;
    // Stocke le numéro de la ligne à renforcer  public
    { Déclarations publiques }
  end;

Const // [col,ligne]
  Kossira_6000h: Array [0 .. 1, 0 .. 19] of Single = (
    // ligne 0, 1, 2, 3, 4, 5, 6
    (-2.5477, -2.2158, -1.7801, -1.4481, -1.0747, -0.7012, -0.3485, 0.0249, 0.3776, 0.751, 1.1452, 1.4979, 1.8714, 2.2241, 2.556, 3.3029, 3.6971, 4.0705, 4.4025, 4.7967), // col 0
    (1.0494, 10.3864, 137.3171, 880.2596, 2802.8818, 6366.375, 11637.7296, 27079.1315, 478234.2968, 6797282.648, 6477049.939, 4195217.591, 501878.7439, 90487.1326, 32844.8336, 9594.8, 5780.6417, 2367.2902, 140.6707, 5.1591)
    // col 1
    );

Const
  Kp = 0.5;
  Ki = 0.05;

var
  MainForm: TMainForm;
  FileName, ResFileName: String;
  FlightTime: Extended;
  Classes, Occurs: Extended;
  Spectrum: Table_Spectrum;
  Flights: TFlights;
  flightIdx: Integer;
  GyroPresent, AttPresent: Boolean;
  StdDevValueAxd, StdDevValueAxh, StdDevValueAzd, StdDevValueAzh: Extended;
  PullUp, PullUpDelay, PullUpTimeOut: Extended;
  IntegratorThreshold, IntegDelay: Extended;
  Deceleration, DecelerationDelay, Touching, IntegTouchDelay, TouchTimeOut, MinFlightDuration, NewFlightDelay: Extended;
  phase: (Idle, Taxi, TaxiConfirm, Air, Taxi2, Landing);
  Velocity: Extended;
  Offset: Extended; // Offset for avoiding velocity error

  Count, n_1, nq_1, slope_1, minmax, minmax_1: Integer;
  Markov1, Markov2: Array [0 .. Taille_Spectrum, 0 .. Taille_Spectrum] of Integer;
  BufAxd, BufAxh, BufAzd, BufAzh: TCircularBuffer;
  Vx: Extended;
  VxOffset: Extended;
  AccelOutlier, AccelMin, AccelMax, nff_sum: Extended;
  ax_AB, ay_AB, az_AB: TAlphaBeta;
  NAccel, NAccelx: Integer;

  Compteur_FFT: Integer;
  R: Extended;
  Signal: array [0 .. WindowSize - 1] of TComplex;
  Fusion_Result_1: Extended;
  Fusion_Coef: TFusion_Coef;
  DX:Integer;

var // Butterworth variables
  HPBuf2: THighPassFilter2;
  HPBuf4: THighPassFilter4;
  THPBuf4x: THighPassFilter4;
  THPBuf4z: THighPassFilter4;
  nfh: Extended;
  IAxh, Iazh: Extended;
  Temps0, Temps, Maxnfh: Extended;

var // Time profiler variables
  StartCount, EndCount, Frequency: Int64;
  ElapsedTime: Double;

Function R_Calculation(FlightTime: Extended; Spectrum: Table_Spectrum): Extended;

implementation

{$R *.dfm}

// {$R InfoVersion.res}
uses UDoc, UAPropos, UBatch_Opt;

procedure TMainForm.InitBuffer(var Buf: TCircularBuffer);
var
  i: Integer;
begin
  for i := 0 to WindowSize - 1 do
    Buf.Data[i] := 0;
  Buf.Index := 0;
  Buf.Count := 0;
end;

Procedure TMainForm.Initialisation(Sender: TObject);
Var
  i, j: Integer;
begin
  Count := 0;
  n_1 := 0;
  nq_1 := 0;
  slope_1 := 1;
  minmax := 1;
  minmax_1 := 16;
  // Configuration Recall
  ConfForm.ValidationButtonClick(Sender);
  ProgressBar1.Position := 0;
  ProgressBar1.Max := 100;
  Memo1.Lines.BeginUpdate;
  Memo2.Lines.BeginUpdate;
  Memo3.Lines.BeginUpdate;
  Memo4.Lines.BeginUpdate;
  Memo2.Lines.Add('Resampled data');
  Memo2.Lines.Add('Time' + #9 + 'Data');
  Memo3.Lines.Add('Sampled data');
  Memo3.Lines.Add('Time' + #9 + 'Data');
  Memo4.Lines.Add('Raw data');
  Memo4.Lines.Add('Time' + #9 + 'Data (g)');
  MarcovStringGrid1.ColWidths[0] := 20;
  MarcovStringGrid2.ColWidths[0] := 20;
  spectrumStringGrid.ColWidths[0] := 20;
  for i := 1 to Taille_Spectrum + 1 do
    MarcovStringGrid1.Cells[i, 0] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to Taille_Spectrum + 1 do
    MarcovStringGrid1.Cells[0, Taille_Spectrum + 2 - i] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to Taille_Spectrum + 1 do
    MarcovStringGrid2.Cells[i, 0] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to Taille_Spectrum + 1 do
    MarcovStringGrid2.Cells[0, Taille_Spectrum + 2 - i] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to 1 do
    spectrumStringGrid.Cells[i, 0] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to Taille_Spectrum + 1 do
  begin
    spectrumStringGrid.Cells[0, Taille_Spectrum + 2 - i] := IntToStr(i);
    // initialisation de l'entête des colonnes
    spectrumStringGrid.Cells[1, Taille_Spectrum + 2 - i] := '';
  end;
  for i := 0 to Taille_Spectrum do
  begin
    for j := 0 to Taille_Spectrum do
    begin
      MarcovStringGrid1.Cells[j + 1, Taille_Spectrum + 1 - i] := '';
      MarcovStringGrid2.Cells[j + 1, Taille_Spectrum + 1 - i] := '';
    end;
  end;
  for i := 0 to Taille_Spectrum do
    for j := 0 to Taille_Spectrum do
    begin
      Markov1[j, i] := 0;
      Markov2[j, i] := 0;
    end;

  for i := 0 to Taille_Spectrum do
    Spectrum[i] := 0;
  Chart1.Axes.Left.Automatic := False;
  // Chart1.Axes.Left.Automatic := True;
  Chart1.Axes.Left.Maximum := HighG;
  Chart1.Axes.Left.Minimum := LowG;
  Fusion_Coef[0] := 1;
  Fusion_Coef[1] := 0;
  Fusion_Coef[2] := 0;
  Fusion_Coef[3] := 1;
  DX := StrToInt(DXLabeledEdit.Text);
  NAccel := StrToInt(ConfForm.NAccelLabeledEdit.Text);
  NAccelx := StrToInt(ConfForm.NAccelxLabeledEdit.Text);
  AccelOutlier := StrToFloat(ConfForm.OutlierLabeledEdit.Text);
  AccelMin := StrToFloat(ConfForm.NMinLabeledEdit.Text);
  AccelMax := StrToFloat(ConfForm.NMaxLabeledEdit.Text);
  // Compute nq_avg
  nff_sum := 0;
  FlightTime := 0.0;
  Temps0 := 0.0;
  deltaT := StrToFloat(ConfForm.dtLabeledEdit.Text);
  ax_AB := TAlphaBeta.Create(NAccelx, deltaT, AccelOutlier, AccelMin, AccelMax);
  az_AB := TAlphaBeta.Create(NAccel, deltaT, AccelOutlier, AccelMin, AccelMax);
  // Writeln(ResultFile, FileName);
  InitBuffer(BufAxd);
  InitBuffer(BufAzd);
  InitBuffer(BufAxh);
  InitBuffer(BufAzh);
  Vx := 0.0;
  VxOffset := 0.0;
  Compteur_FFT := 0;
  // Initialiser HPBuf à zéro avant le début du traitement
  HPBuf2.x1 := 0;
  HPBuf2.x2 := 0;
  HPBuf2.y1 := 0;
  HPBuf2.y2 := 0;
  HPBuf4.x1 := 0;
  HPBuf4.x2 := 0;
  HPBuf4.x3 := 0;
  HPBuf4.x4 := 0;
  HPBuf4.y1 := 0;
  HPBuf4.y2 := 0;
  HPBuf4.y3 := 0;
  HPBuf4.y4 := 0;
  THPBuf4x.x1 := 0;
  THPBuf4x.x2 := 0;
  THPBuf4x.x3 := 0;
  THPBuf4x.x4 := 0;
  THPBuf4x.y1 := 0;
  THPBuf4x.y2 := 0;
  THPBuf4x.y3 := 0;
  THPBuf4x.y4 := 0;
  THPBuf4z.x1 := 0;
  THPBuf4z.x2 := 0;
  THPBuf4z.x3 := 0;
  THPBuf4z.x4 := 0;
  THPBuf4z.y1 := 0;
  THPBuf4z.y2 := 0;
  THPBuf4z.y3 := 0;
  THPBuf4z.y4 := 0;
  Fusion_Result_1 := 0.0;

  GyroPresent := ConfForm.DataCheckListBox.Checked[2];
  AttPresent := ConfForm.DataCheckListBox.Checked[3];

  flightIdx := 0;
  setlength(Flights, 1);
  Flights[0].TaxiStart := 0;
  Flights[0].TakeOff := 0;
  Flights[0].TouchDown := 0;
  Flights[0].TaxiStop := 0;
  Flights[0].idxTaxiStart := 0;
  Flights[0].idxTakeOff := 0;
  Flights[0].idxTouchDown := 0;
  Flights[0].idxTaxiStop := 0;

  PullUp := StrToFloat(ConfForm.PullUpLabeledEdit.Text);
  PullUpDelay := StrToFloat(ConfForm.PullUpDelayLabeledEdit.Text);
  PullUpTimeOut := StrToFloat(ConfForm.PullUpTimeOutLabeledEdit.Text);
  IntegratorThreshold := StrToFloat(ConfForm.IntegratorThresholdLabeledEdit.Text);
  IntegDelay := StrToFloat(ConfForm.IntegDelayLabeledEdit.Text);
  Deceleration := StrToFloat(ConfForm.DecelerationLabeledEdit.Text);
  DecelerationDelay := StrToFloat(ConfForm.DecDelayLabeledEdit.Text);
  MinFlightDuration := StrToFloat(ConfForm.MinFlightDurationLabeledEdit.Text);
  Touching := StrToFloat(ConfForm.TouchLabeledEdit.Text);
  IntegTouchDelay := StrToFloat(ConfForm.IntegTouchDelayLabeledEdit.Text);
  TouchTimeOut := StrToFloat(ConfForm.TouchTimeOutLabeledEdit.Text);
  NewFlightDelay := StrToFloat(ConfForm.NewFlightDelayLabeledEdit.Text);
  QueryPerformanceCounter(EndCount);
  ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
  Writeln(ResultFile, Format('Durée de l''initialisation: %.6f secondes', [ElapsedTime]));
  QueryPerformanceCounter(StartCount);
  phase := Idle;
  Velocity := 0.0;
  FlightTimeLabel.Caption := '';
  Label1.Caption := '';
  Label2.Caption := '';
end;

procedure AddSample(var Buf: TCircularBuffer; Sample: Double);
begin
  Buf.Data[Buf.Index] := Sample;
  Buf.Index := (Buf.Index + 1) mod WindowSize;
  if Buf.Count < WindowSize then
    Inc(Buf.Count);
end;

function ComputeStdDev(Temps: Extended; const Buf: TCircularBuffer): Double;
var
  Sum, Sum2: Double;
  i, N: Integer;
begin
  Result := 0;
  N := Buf.Count;
  if N < WindowSize then
    Exit; // Pas assez de données pour calculer

  Sum := 0;
  Sum2 := 0;
  for i := 0 to N - 1 do
  begin
    Sum := Sum + Buf.Data[i];
    Sum2 := Sum2 + Sqr(Buf.Data[i]);
  end;
  Result := Sqrt((Sum2 - Sqr(Sum) / N) / (N - 1));
end;

function ComputeFFT(const Buf: TCircularBuffer): Boolean;
var
  Sum, Sum2: Double;
  i, N: Integer;
  amax1, amax2: Extended;
begin
  N := Buf.Count;
  if N < WindowSize then
    Exit; // Pas assez de données pour calculer

  amax1 := 0;
  amax2 := 0;
  for i := 0 to N - 1 do
  begin
    Signal[i].Re := Buf.Data[i];
    Signal[i].Im := 0.0;
  end;
  Compteur_FFT := Compteur_FFT + 1;
  if (Compteur_FFT mod 16 = 0) then
  begin
    MainForm.Series3.Clear;
    FFT(Signal, False);
    MainForm.Chart1.BottomAxis.Automatic := False;
    MainForm.Chart1.BottomAxis.Minimum := 0;
    MainForm.Chart1.BottomAxis.Maximum := 10;
    MainForm.Chart1.LeftAxis.Automatic := False;
    MainForm.Chart1.LeftAxis.Minimum := 0;
    MainForm.Chart1.LeftAxis.Maximum := 10;
    // MainForm.Chart1.LeftAxis.Automatic:=True;
    for i := 1 to N div 2 do
    begin
      MainForm.Series3.Addxy(20 * i / N, amplitude[i]);
      if (i <= 3 * N div 20) and (amplitude[i] > amax1) then
        amax1 := amplitude[i];
      if (i > 3 * N div 20) and (amplitude[i] > amax2) then
        amax2 := amplitude[i];
    end;
    MainForm.Label1.Caption := FloatToStr(amax1);
    MainForm.Label2.Caption := FloatToStr(amax2);
    // Writeln(ResultFile, Temps:10:2, ',', amax1:5:3, ',', amax2:5:2);
    Application.ProcessMessages;
    Result := True;
    // sleep(3000);
  end;
end;

procedure TMainForm.RunBatchClick(Sender: TObject);
begin
  BatchForm.Show;
end;

procedure TMainForm.ConfButtonClick(Sender: TObject);
begin
  ConfForm.Show;
end;

procedure TMainForm.Help2Click(Sender: TObject);
begin
  DocForm.Show;
end;

procedure TMainForm.MarcovStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if ARow = Taille_Spectrum + 1 - LigneAGrossir then
  begin
    MarcovStringGrid1.Canvas.Pen.Color := clBlack;
    MarcovStringGrid1.Canvas.Pen.Width := 2; // Largeur renforcée
    MarcovStringGrid1.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    MarcovStringGrid1.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
    MarcovStringGrid1.Canvas.Pen.Width := 1;
    // Remettre à la valeur standard
  end;
end;

procedure TMainForm.MarcovStringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if ARow = Taille_Spectrum + 1 - LigneAGrossir then
  begin
    MarcovStringGrid2.Canvas.Pen.Color := clBlack;
    MarcovStringGrid2.Canvas.Pen.Width := 2; // Largeur renforcée
    MarcovStringGrid2.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    MarcovStringGrid2.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
    MarcovStringGrid2.Canvas.Pen.Width := 1;
    // Remettre à la valeur standard
  end;
end;

procedure TMainForm.AboutClick(Sender: TObject);
begin
  // Ouverture de la form
  OKRightDlg.Show;
end;

procedure TMainForm.OpenClick(Sender: TObject);
begin
  if FileOpenTextFileDialog.Execute then
  begin
    FileName := FileOpenTextFileDialog.FileName;
    FileNameLabeledEdit.Text := FileName;
  end
  else
    Exit;
end;

procedure TMainForm.SaveClick(Sender: TObject);
begin
  if FileExists(SaveDialog1.FileName) then
  begin
    Memo1.Lines.SaveToFile(SaveDialog1.FileName);
  end
  else
    SaveClick(Sender);

end;

procedure TMainForm.SaveAsClick(Sender: TObject);
begin
  SaveDialog1.Title := 'Save file';
  SaveDialog1.Filter := 'Text File (*.txt)|*.txt';
  SaveDialog1.DefaultExt := 'txt';
  SaveDialog1.InitialDir := GetCurrentDir;
  if SaveDialog1.Execute then
  begin
    Memo1.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TMainForm.PrintClick(Sender: TObject);
begin
  Chart1.PrintLandscape;
end;

procedure TMainForm.PrintSpectraClick(Sender: TObject);
begin
  Chart2.PrintLandscape;
end;

procedure TMainForm.QuitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.RunClick(Sender: TObject);
begin
  RunButtonClick(Sender);
end;

procedure TMainForm.RunConfigurationClick(Sender: TObject);
begin
  ConfButtonClick(Sender)
end;

procedure DetectFlights(Index: Integer; Time64: Int64; Ax, IAxh, Iazh, StdDevValueAzh: Extended; var Fusion_Result, Fusion_Result_1: Extended; var Flights: TFlights; var Fusion_Coef: TFusion_Coef);
var
  currFlight: TFlightInfo;
  Function DetectTaxiStart(Time64: Int64; Fusion: Extended): Boolean;
  begin
    if (Fusion > PullUp) then
      DetectTaxiStart := True
    else
      DetectTaxiStart := False;
  end;
  Function DetectTakeOff(Time64: Int64; Fusion, Deceleration, PullUpDelay: Extended): Boolean;
  begin
    if (Fusion < Deceleration) and ((Time64 - currFlight.TakeOff) / 1000.0 > DecelerationDelay) then
      DetectTakeOff := True
    else
      DetectTakeOff := False;
  end;
  Function DetectTouchDown(Time64: Int64; Fusion: Extended): Boolean;
  begin
    if (Fusion > Touching) and ((Time64 - currFlight.TakeOff) / 1000.0 > IntegTouchDelay) then
      DetectTouchDown := True
    else
      DetectTouchDown := False;
  end;
  Function DetectTaxiStop(Time64: Int64; Fusion, DecelerationDelay: Extended): Boolean;
  begin
    if (Fusion < Deceleration) or ((Time64 - currFlight.TouchDown) / 1000.0 > TouchTimeOut) then
      DetectTaxiStop := True
    else
      DetectTaxiStop := False;
  end;

begin
  Var
    Fusion: Extended;
  currFlight := Flights[flightIdx];
  // Fusion := (Fusion_Coef[0] * Ax + Fusion_Coef[1] * IAxh + Fusion_Coef[2] * Iazh + Fusion_Coef[3] * StdDevValueAzh) { / (Fusion_Coef[0] + Fusion_Coef[1] + Fusion_Coef[2] + Fusion_Coef[3]) };
  Fusion := StdDevValueAzh { / (Fusion_Coef[0] + Fusion_Coef[1] + Fusion_Coef[2] + Fusion_Coef[3]) };
  Fusion_Result_1 := Fusion;
  case phase of
    Idle:
      begin
        Fusion_Result := 0.0;
        if DetectTaxiStart(Time64, Fusion) then
        begin
          // Début roulage détecté
          if (currFlight.TaxiStart = 0) then
          begin
            currFlight.TaxiStart := Time64;
            currFlight.idxTaxiStart := Index;
            Flights[flightIdx] := currFlight;
            phase := Taxi;
            Writeln(ResultFile, (Time64 / 1000.0):8:3, ',', 'Taxi confirmed?');
          end;
        end;

      end;
    Taxi:
      begin
        Fusion_Result := IAxh + Iazh;
        if ((Time64 - currFlight.TaxiStart) / 1000.0 >= IntegDelay) then
          // if (Fusion_Result < IntegratorThreshold) or ((Time64 - currFlight.TaxiStart) / 1000.0 >= PullUpTimeOut) then
          if (Fusion < Deceleration) or ((Time64 - currFlight.TaxiStart) / 1000.0 >= PullUpTimeOut) then
          begin
            phase := Idle;
            currFlight.TaxiStart := 0;
            Flights[flightIdx] := currFlight;
          end
          else
          begin
            phase := TaxiConfirm;
            Writeln(ResultFile, (Time64 / 1000.0) - PullUpDelay:8:3, ',', 'Taxi');
          end;
      end;
    TaxiConfirm:
      if DetectTakeOff(Time64, Fusion, Deceleration, PullUpDelay) then
      begin
        Fusion_Result := 0.0;
        currFlight.TakeOff := Time64;
        currFlight.idxTakeOff := Index;
        Flights[flightIdx] := currFlight;
        phase := Air;
        Writeln(ResultFile, Time64 / 1000.0:8:3, 'Air');
        Fusion_Coef[0] := StrToInt(ConfForm.w1LabeledEdit.Text);
        Fusion_Coef[1] := StrToInt(ConfForm.w2LabeledEdit.Text);
        Fusion_Coef[2] := StrToInt(ConfForm.w3LabeledEdit.Text);
        Fusion_Coef[3] := StrToInt(ConfForm.w4LabeledEdit.Text);
      end;

    Air:
      if DetectTouchDown(Time64, Fusion) and ((Time64 - currFlight.TakeOff) / 1000.0 > MinFlightDuration) then
      begin
        currFlight.TouchDown := Time64;
        currFlight.idxTouchDown := Index;
        Flights[flightIdx] := currFlight;
        phase := Taxi2;
        Writeln(ResultFile, Time64 / 1000.0:8:3, ',', 'Taxi2');
      end;

    Taxi2:
      if DetectTaxiStop(Time64, Fusion, DecelerationDelay) then
      begin
        currFlight.TaxiStop := Time64;
        currFlight.FlightTime := currFlight.TouchDown - currFlight.TakeOff;
        currFlight.idxTaxiStop := Index;
        // Ajouter le vol détecté
        Flights[flightIdx] := currFlight;
        phase := Landing;
        Writeln(ResultFile, Time64 / 1000.0:8:3, ',', 'Landing');
      end;
    Landing:
      // Attente d'un nouveau départ
      if (Time64 - currFlight.TaxiStop) / 1000.0 > NewFlightDelay then
      begin
        phase := Idle;
        flightIdx := flightIdx + 1;
        setlength(Flights, flightIdx + 1);
        // Repart en Idle pour vol suivant s’il y en a
        currFlight.TaxiStart := 0;
        currFlight.TakeOff := 0;
        currFlight.TouchDown := 0;
        currFlight.TaxiStop := 0;
        currFlight.idxTaxiStart := 0;
        currFlight.idxTakeOff := 0;
        currFlight.idxTouchDown := 0;
        currFlight.idxTaxiStop := 0;
        Flights[flightIdx] := currFlight;
        Fusion_Coef[0] := 1;
        Fusion_Coef[3] := 1;
      end;
  end;
end;

Function R_Calculation(FlightTime: Extended; Spectrum: Table_Spectrum): Extended;
Const
  K = 6.6; // S/N Slope
  Kossira_Ni: Table_Kossira = (-3.84375, -3.53125, -3.21875, -2.90625, -2.59375, -2.28125, -1.96875, -1.65625, -1.34375, -1.03125, -0.71875, -0.40625, -0.09375, 0.21875, 0.53125, 0.84375, 1.15625, 1.46875, 1.78125, 2.09375, 2.40625, 2.71875, 3.03125,
    3.34375, 3.65625, 3.96875, 4.28125, 4.59375, 4.90625, 5.21875, 5.53125, 5.84375);
  NiSum = 13915563.42; // Somme de référence KOSSIRA

Var
  avg_n: Extended; // moyenne des ni (g)
  Kossiraxocc_normalise: Table_Kossira; // Table kossira
  Kossiraxocc: Table_Kossira; // Table kossira * occuri
  Sum_Kossira: Extended;
  KossiraFlight: Table_Kossira; // Table kossira * occuri
  KossiraForRcalc: Table_Kossira;
  sum_KossiraForRcalc: Extended;
  i: Integer;

begin
  // Calcul de la moyenne des ni
  avg_n := 0.0;
  Sum_Kossira := 0.0;
  for i := 0 to Taille_Spectrum do
  begin
    Kossiraxocc[i] := 0.0;
    Kossiraxocc_normalise[i] := 0.0;
    KossiraForRcalc[i] := 0.0;
  end;
  for i := 0 to Taille_Spectrum do
  begin
    Kossiraxocc[i] := Spectrum[i] * Kossira_Ni[i];
    avg_n := avg_n + Spectrum[i];
    Sum_Kossira := Sum_Kossira + Kossiraxocc[i];
  end;
  avg_n := Sum_Kossira / avg_n;
  // Normalisation 6000h
  for i := 0 to Taille_Spectrum do
  begin
    Kossiraxocc_normalise[i] := Spectrum[i] * 6000.0 / FlightTime;
  end;
  // Clacul de la table Kossira et KossiraForRcalc
  sum_KossiraForRcalc := 0;
  for i := 0 to Taille_Spectrum do
  begin
    KossiraFlight[i] := power(Abs(Kossira_Ni[i] - avg_n), K);
    KossiraForRcalc[i] := Kossiraxocc_normalise[i] * KossiraFlight[i];
    sum_KossiraForRcalc := sum_KossiraForRcalc + KossiraForRcalc[i];
  end;
  // avg_KossiraForRcalc:=avg_KossiraForRcalc/(taille_spectrum+1);
  Result := NiSum / sum_KossiraForRcalc;
end;

Procedure TMainForm.FileProcessing(Sender: TObject);
Var
  i, j: Integer;
  N, nq, nq_avg, slope: Integer;
  nf, nff, nff_avg: Extended;
  { ax, ay, az, Temperature: Extended;
    gx, gy, gz, Voltage: Extended;
    Roll, Pitch, Yaw, Version: Extended; }
  Buffer: TBuffer; // 10 octets pour chaque message
  Checksum: Byte;
  NewSample: Extended;

  Procedure Transitions_Computation(Temps, nff: Extended);
  begin
    N := trunc((nff - LowG) / Quantum); // n load factor coded on 10 bits
    if ConfForm.ShowDataCheckBox.Checked then
    begin
      Memo4.Lines.Add(Format('%5.3f' + #9 + '%8.2f', [Temps, nff]));
      // high resolution quantification
      Memo3.Lines.Add(Format('%5.3f' + #9 + '%4d', [Temps, N]));
    end;
    // only process data if difference between n and n_1 is larger than 1
    if (Abs(N - n_1) > DX) then
    begin
      // low resolution quantification
      nq := trunc((nff - LowG) / QuantumRough);
      // nq load factor coded on 5 bits
      if ConfForm.ShowDataCheckBox.Checked then
        Memo2.Lines.Add(Format('%5.3f' + #9 + '%3d', [Temps, nq]));
      // only consider nq if it is different from nq_1
      if (nq_1 <> nq) then
      begin
        // look for min max by checking slope sign change
        if GraphCheckBox.Checked then
          begin
          Series2.Title := 'nq';
          Series2.Addxy(Temps, nq);
          end;
        if ((nq - nq_1) > 0) then
          slope := 1
        else
          slope := -1;
        // if slope changes sign, we have a min or a max
        if ((slope * slope_1) < 0) then
        begin
          minmax := nq_1;
          Markov1[minmax, minmax_1] := Markov1[minmax, minmax_1] + 1;

          // Display results
          // Display n and nq for min/max
          // Series1.AddXY(Temps, n * UnderSample div ClassNumbers);
          if GraphCheckBox.Checked then
            begin
            Series7.Title := 'minmax';
            Series7.Addxy(Temps, minmax);
            end;
          // keep track of last minmax
          minmax_1 := minmax;
        end;
        // keep track of last slope and nq
        slope_1 := slope;
        nq_1 := nq;
      end;
    end;
    // keep track of last n
    n_1 := N;
  end;

  Procedure Matrixes_elaboration;
  Var
    j, K: Integer;
    col, row: Integer;
  begin
    for K := 0 to Taille_Spectrum do
      for j := 0 to Taille_Spectrum do
      Begin
        // col,  ligne en partant du bas, donc de la ligne 32 pour i=0
        if Markov1[j, K] <> 0 then
          MarcovStringGrid1.Cells[j + 1, Taille_Spectrum + 1 - K] := IntToStr(Markov1[j, K]);
      End;

    RunningLabel.Caption := 'Markov';
    Application.ProcessMessages;
    for col := 0 to Taille_Spectrum do
    begin
      // sum cells above diagonal
      if (col < Taille_Spectrum) then
      begin
        for row := col + 1 to Taille_Spectrum do
          // enumerate matrix lines above diagonal
          for K := row to Taille_Spectrum do
            // add all cells values at and above current cell.
            Markov2[col, row] := Markov2[col, row] + Markov1[col, K];
      end;
      // sum cells below diagonal
      if (col > 1) then
      begin
        for row := col - 1 downto 0 do
          // enumerate matrix lines below diagonal
          for K := row downto 0 do
            // add all cells values at and below current cell.
            Markov2[col, row] := Markov2[col, row] + Markov1[col, K];
      end;
    end;
    for row := 0 to Taille_Spectrum do
    begin
      // sum cells to the right of the diagonal and below nq_avg
      if (row < nq_avg) then
      begin
        for col := row + 1 to Taille_Spectrum do
          if Markov2[col, row] <> 0 then
            Spectrum[row] := Spectrum[row] + Markov2[col, row];
      end
      // sum cells to the left of the diagonal and above nq_avg
      else
        for col := 0 to row - 1 do
          if Markov2[col, row] <> 0 then
            Spectrum[row] := Spectrum[row] + Markov2[col, row];
    end;
    for K := 0 to Taille_Spectrum do
      for j := 0 to Taille_Spectrum do
      Begin
        if Markov2[j, K] <> 0 then
          MarcovStringGrid2.Cells[j + 1, Taille_Spectrum + 1 - K] := IntToStr(Markov2[j, K]);
      End;
  end;

begin
  Initialisation(Sender);
  Maxnfh := 0.0;
  QueryPerformanceCounter(StartCount);
  // Data processing
  // Loading RAM memory with all data from File in Sentences record
  ParseData(DataBytes, GyroPresent, AttPresent);
  ProgressBar1.Position := 20;
  // Preliminary step : Max value
  // Looking for max value of StdDevValueAzh
  for i := 0 to High(Samples) do // Scanning throw all the data
  begin
    if (Samples[i].Acc.Success) and (Samples[i].Time.Success_t) then // If accelerations are valid
    begin
      Temps := Samples[i].Time.Temps;
      If Temps0 = 0.0 then
        Temps0 := Temps;
      deltaT := (Samples[i].Time.Temps - Samples[i].Time.Temps_1);
      nff := Samples[i].Acc.az; // Taking account of the frame NED or not
      nfh := Abs(HighPass_Filter4(HPBuf4, nff)); // Butterworth order 4
      AddSample(BufAzh, nfh); // add the absolute value of the butterworth output
      StdDevValueAzh := ComputeStdDev(Temps, BufAzh);
      if StdDevValueAzh > Maxnfh then
        Maxnfh := StdDevValueAzh;
      Series6.Title := 'Maxnfh';
      Series6.Addxy(Temps, Maxnfh); // black curve
    end
    else
    begin
      Application.MessageBox('Invalid message', 'Attention', IDOK);
      Halt(0);
    end;
  end;

  ProgressBar1.Position := 10;
  QueryPerformanceCounter(EndCount);
  ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
  Writeln(ResultFile, Format('Durée du calcul des maxs: %.6f secondes', [ElapsedTime]));
  Application.ProcessMessages;

  // First step : Flight status determination
  // Looking for flight status
  QueryPerformanceCounter(StartCount);
  RunningLabel.Caption := 'Flight Status';
  Initialisation(Sender);
  Var
    Pitch, Ax, Ay, axh, ax_abs, Fusion_Result, Ax0: Extended;
  Ax0 := 0.0;
  for i := 0 to High(Samples) do // Scanning throw all the data
  begin
    if (Samples[i].Acc.Success) and (Samples[i].Time.Success_t) then // If accelerations are valid
    begin
      Temps := Samples[i].Time.Temps;
      If Temps0 = 0.0 then
        Temps0 := Temps;
      deltaT := (Samples[i].Time.Temps - Samples[i].Time.Temps_1);
      // Writeln(ResultFile,Temps:8:3,',',deltaT:8:3);
      // deltaT:=0.05;
      nff := Samples[i].Acc.az; // Taking account of the frame NED or not
      Ax := Samples[i].Acc.Ax * Gravity;
      If (Temps - Temps0 < 10) then
        Ax0 := 0.9 * Ax0 + 0.1 * Ax;
      Ay := Samples[i].Acc.Ay * Gravity;
      Pitch := Samples[i].Att.Pitch;
      ax_abs := Ax * cos(Pitch) + (nff - 1) * Gravity * sin(Pitch);
      ax_AB.ABupdate(deltaT, ax_abs);
      if IsNan(deltaT) or IsInfinite(deltaT) or (deltaT <= 0) then
        deltaT := 0.05;
      if Temps < 110.0 then
        Velocity := 0.0;
      // Offset := Ki * Velocity + Kp * ax_AB.ABfilt;
      Velocity := Velocity + (ax_AB.ABfilt { - Offset } ) * deltaT;
      az_AB.ABupdate(deltaT, nff); // use alphabeta filter to get the variation
      AddSample(BufAzd, az_AB.ABprim); // and add this variation in the circular buffer for standard deviation computing
      AddSample(BufAxd, ax_AB.ABfilt);
      StdDevValueAxd := ComputeStdDev(Temps, BufAxd);
      StdDevValueAzd := ComputeStdDev(Temps, BufAzd);
      if FFTCheckBox.Checked then
      begin
        Var
          FFT_Success: Boolean;
        FFT_Success := ComputeFFT(BufAzd);
      end
      else
      begin;
        // Butterworth high pass
        case ConfForm.ButterWorthRadioGroup.ItemIndex of // acceleration high pass filtering in accordance with the butterworth order 2 or 4
          0:
            nfh := nff; // No flitrage
          1:
            nfh := Abs(HighPass_Filter2(HPBuf2, nff)); // Butterworth order 2
          2:
            nfh := Abs(HighPass_Filter4(HPBuf4, nff)); // Butterworth order 4
          3:
            nfh := Abs(HighPass_Filter4(THPBuf4z, az_AB.ABprim)); // Butterworth order 4
        end;
        AddSample(BufAzh, nfh); // add the absolute value of the butterworth output
        StdDevValueAzh := ComputeStdDev(Temps, BufAzh) / Maxnfh;

        axh := Abs(THighPass_Filter4(THPBuf4x, Ax)); // Butterworth order 4
        AddSample(BufAxh, axh); // add the absolute value of the butterworth output
        StdDevValueAxh := ComputeStdDev(Temps, BufAxh);
        // ax_AB.ABupdate(deltaT, nfh);

        // inFlight_Determination
        DetectFlights(i, Samples[i].Time.TimeMs, Ax - Ax0, IAxh, Iazh, StdDevValueAzh, Fusion_Result, Fusion_Result_1, Flights, Fusion_Coef);
        if GraphCheckBox.Checked and Not MainForm.FFTCheckBox.Checked then
        begin
          Series1.Title := 'inFlight';
          // Series2.Title := 'StdDevValueAxd';
          // Series7.Title := 'Ay';
          // Series3.Title := 'StdDevValueAzh';
          Series3.Title := 'AZ';
          // Series6.Title := 'StdDevValueAzd';
          // Series6.Title := 'IAzh';
          // Series7.Title := 'StdDevValueAzh';
          Series8.Title := 'StdDevValueAzh';
          // Series1.Addxy(Temps, StdDevValueAxh);
          // Series2.Addxy(Temps, StdDevValueAxd);
          Series3.Addxy(Temps, nff, '', clpurple); // purple curve
          // Series6.Addxy(Temps, StdDevValueAzd); // black curve
          // Series7.Addxy(Temps, StdDevValueAxh); // black curve
          // Series7.Addxy(Temps, StdDevValueAzh); // black curve
          Series8.Addxy(Temps, StdDevValueAzh); // red curve
          // Series3.Addxy(Temps, (nff)); // purple curve
          // Series6.Addxy(Temps, Iazh); // blue curve
          // Series3.Addxy(Temps, StdDevValueAzh,'',clPurple; // purple curve
          case phase of
            Idle:
              begin
                Series1.Addxy(Temps, 0);
                IAxh := 0.0;
                Iazh := 0.0;
              end;
            TaxiConfirm:
              begin
                Series1.Addxy(Temps, 1);
                IAxh := IAxh + StdDevValueAxh * 0.5;
                Iazh := Iazh + StdDevValueAzh * 0.5;
              end;
            Taxi:
              begin
                Series1.Addxy(Temps, 2);
                IAxh := IAxh + StdDevValueAxh * 0.5;
                Iazh := Iazh + StdDevValueAzh * 0.5;
              end;
            Air:
              begin
                Series1.Addxy(Temps, 3);
                IAxh := 0.0;
                Iazh := 0.0;
              end;
            Taxi2:
              begin
                Series1.Addxy(Temps, 4);
                IAxh := IAxh + axh * 0.05;
                Iazh := 0.0;
              end;
            Landing:
              begin
                Series1.Addxy(Temps, 5);
                IAxh := 0.0;
                Iazh := 0.0;
              end;
          end;
        end;
      end;
    end
    else
    begin
      Application.MessageBox('Invalid message', 'Attention', IDOK);
      Halt(0);
    end;
  end;
  // Summing the total flight time
  FlightTime := 0.0;
  For i := 0 to High(Flights) do // Scanning of the flights inside the record
    FlightTime := FlightTime + Flights[i].FlightTime / 3600000.0; // addinf partial flight time and convert in hour
  ProgressBar1.Position := 40;
  QueryPerformanceCounter(EndCount);
  ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
  Writeln(ResultFile, Format('Durée du calcul de la durée des vols: %.6f secondes', [ElapsedTime]));

  // Second step : Average for flight status = inFlight
  QueryPerformanceCounter(StartCount);
  RunningLabel.Caption := 'Averaging';
  Application.ProcessMessages;
  for j := 0 to High(Flights) do // Scanning of the flights inside the record
    for i := Flights[j].idxTakeOff to Flights[j].idxTouchDown do // flights only are processed
    begin
      if Samples[i].Acc.Success then
      begin
        Count := Count + 1;
        nff_sum := nff_sum + Samples[i].Acc.az; // Sum of all accelerations measured during flight only
      end;
    end;

  // compute average low resolution nq
  if Count > 0 then
    nq_avg := trunc((nff_sum / Count - LowG) / QuantumRough)
  else
  begin // if count is null meaning that there are no acceleration valid during any flight
    Application.MessageBox('No acceleration are valid', 'ATTENTION', IDOK);
    // Halt(0);
  end;
  Label1.Caption := Format('nq_avg = %2d', [nq_avg]);
  LigneAGrossir := nq_avg;
  // Mean computation completed
  ProgressBar1.Position := 60;
  QueryPerformanceCounter(EndCount);
  ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
  Writeln(ResultFile, Format('Durée du averaging: %.6f secondes', [ElapsedTime]));

  // Third step : Acceleration transitions counting
  QueryPerformanceCounter(StartCount);
  RunningLabel.Caption := 'Occuring';
  Application.ProcessMessages;
  if High(Flights) >= 0 then
  begin
    for j := 0 to High(Flights) do // Scanning of the flights inside the record
      for i := Flights[j].idxTakeOff to Flights[j].idxTouchDown do // flights only are processed
      begin
        Temps := Samples[i].Time.Temps;
        Transitions_Computation(Temps, Samples[i].Acc.az);
      end;
    ProgressBar1.Position := 80;
    QueryPerformanceCounter(EndCount);
    ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
    Writeln(ResultFile, Format('Durée du exploite data: %.6f secondes', [ElapsedTime]));

    // Fourth step : Markov matrixes elaboration
    QueryPerformanceCounter(StartCount);
    Writeln(ResultFile, 'StartTime (s) :', Flights[0].TaxiStart / 3600000:10:3, ' EndTime (h) :', Flights[High(Flights)].TaxiStop / 3600000:10:3, ' FlightTime (h) :', FlightTime:10:3);
    Writeln(ResultFile, ' Classes (g)', #9, 'occurs');
    Matrixes_elaboration; // Markov matrixes computation
    // Kossira'curve and Memo1 title
    Series5.Title := FileName;
    Memo1.Lines.Add('Kossira');
    Memo1.Lines.Add(Format('From %8.1f  to %8.1f h.', [Flights[0].TaxiStart / 3600000, Flights[High(Flights)].TaxiStop / 3600000]));
    Memo1.Lines.Add('Class (g)' + #9'Occurences (-)');

    // Fifth ans last step : Kossira estimation and gain factor R
    RunningLabel.Caption := 'Kossira';
    R := R_Calculation(FlightTime, Spectrum); // R coefficient computation
    for j := 0 to Taille_Spectrum do
    begin
      Occurs := Spectrum[j] * (6000.0) / (FlightTime); // Normalisation for 6000h to be compared with the Kossira reference
      Classes := ((j + 0.5) * QuantumRough + LowG);
      Writeln(ResultFile, Classes:8:3, #9, Spectrum[j]:12);
      if Spectrum[j] <> 0 then
      begin
        spectrumStringGrid.Cells[1, Taille_Spectrum + 1 - j] := IntToStr(Spectrum[j]);
        Series5.Addxy(Occurs, Classes);
        Memo1.Lines.Add(Format('%8.2f' + #9 + '%8.0f', [Classes, Occurs]));
      end;
    end;
    for j := 0 to 19 do
      Series4.Addxy((Kossira_6000h[1, j]), (Kossira_6000h[0, j])); // Kossira reference plot
    FlightTimeLabel.Caption := Format('Flight time = %5.1f h', [FlightTime]);
    RLabel.Caption := Format('R = %8.1f', [R]);
    Writeln(ResultFile, 'R = ', R:5:1);
    QueryPerformanceCounter(EndCount);
    ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
    Writeln(ResultFile, Format('Durée du Kossira: %.6f secondes', [ElapsedTime]));
    QueryPerformanceCounter(StartCount);
    // Loading the content of all memo(s)
    Memo1.Lines.EndUpdate;
    Memo2.Lines.EndUpdate;
    Memo3.Lines.EndUpdate;
    Memo4.Lines.EndUpdate;
  end;
  RunningLabel.Caption := 'Complete';
  ProgressBar1.Position := 100;
  ax_AB.Free;
  // az_AB.Free;
  QueryPerformanceCounter(EndCount);
  ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
  Writeln(ResultFile, Format('Durée de l''affichage: %.6f secondes', [ElapsedTime]));
end;

procedure TMainForm.Data_Processing(Sender: TObject);
begin
  QueryPerformanceFrequency(Frequency);
  RunningLabel.Caption := 'Running';
  Application.ProcessMessages;
  ConfForm.ValidationButtonClick(Sender);
  // Cleaning memos and curves
  Memo1.Clear;
  Memo2.Clear;
  Memo3.Clear;
  Memo4.Clear;
  Series1.Clear;
  Series2.Clear;
  Series3.Clear;
  Series4.Clear;
  Series5.Clear;
  Series6.Clear;
  Series7.Clear;
  Series8.Clear;
  if ConfForm.RepereRadioGroup.ItemIndex = 0 then
    Repere := 1
  else
    Repere := -1;

  // Lecture du fichier de données
  FileName := FileNameLabeledEdit.Text;
  if not FileExists(FileName) then
  begin
    if FileOpenTextFileDialog.Execute then
    begin
      // AssignFile(BinaryFile, FileOpenTextFileDialog.FileName);
      FileName := FileOpenTextFileDialog.FileName;
      FileNameLabeledEdit.Text := FileName;
    end
    else
      Exit;
  end;
  FileNameLabeledEdit.Text := FileName;
  Chart1.Title.Caption := FileName;
  QueryPerformanceCounter(StartCount);
  DataBytes := TFile.ReadAllBytes(FileName);

  if SortCheckBox.Checked then
  begin
    FlightTimeLabel.Caption := 'Sorting';
    Application.ProcessMessages;
    Sort(DataBytes);
    TFile.WriteAllBytes(FileName, DataBytes);
    FlightTimeLabel.Caption := 'Sort completed';
    Application.ProcessMessages;
  end;
  ResFileName := Copy(FileName, 0, Length(FileName) - 4) + '.res';
  AssignFile(ResultFile, ResFileName);
  Rewrite(ResultFile);
  QueryPerformanceCounter(EndCount);
  ElapsedTime := (EndCount - StartCount) / Frequency; // temps en secondes
  Writeln(ResultFile, Format('Durée du chargement du fichier: %.6f secondes', [ElapsedTime]));
  FileProcessing(Sender);
  CloseFile(ResultFile);
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
begin
  Data_Processing(Sender);
end;

end.
