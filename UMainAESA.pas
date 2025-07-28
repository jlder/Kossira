unit UMainAESA;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, Vcl.ComCtrls, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs,
  VCLTee.Chart, Vcl.Grids, Vcl.Menus, Math,UFFT;

const
  APP_COPYRIGHT = '© 2025 GFM & JLD. Copyright. Tous droits réservés.';
  APP_VERSION = 'Version 1.0.0.0';
  Gravity = 9.807;
  TailleMessage = 22; // taille d'un message complet (temps+Accel)
  Taille_Spectrum = 31; // Quantification of loadfactor
  WindowSize = 256; // Taille du buffer circulaire

type
  Table_Spectrum = Array [0 .. Taille_Spectrum] of Integer;
  Table_Kossira = Array [0 .. Taille_Spectrum] of Extended;

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
    Series1: TPointSeries;
    Series2: TPointSeries;
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
    Open1: TMenuItem;
    Save: TMenuItem;
    N1: TMenuItem;
    Run1: TMenuItem;
    Help1: TMenuItem;
    Help2: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Quit1: TMenuItem;
    SaveDialog1: TSaveDialog;
    SaveAs1: TMenuItem;
    Print1: TMenuItem;
    N4: TMenuItem;
    Memo1: TMemo;
    Run2: TMenuItem;
    Run3: TMenuItem;
    RunningLabel: TLabel;
    PrintSpectra1: TMenuItem;
    GraphCheckBox: TCheckBox;
    Series3: TFastLineSeries;
    Series6: TFastLineSeries;
    Batch1: TMenuItem;
    RLabel: TLabel;
    FlightTimeLabel: TLabel;
    procedure RunButtonClick(Sender: TObject);
    procedure ConfButtonClick(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Run2Click(Sender: TObject);
    procedure Run3Click(Sender: TObject);
    procedure MarcovStringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure MarcovStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure PrintSpectra1Click(Sender: TObject);
    procedure Batch1Click(Sender: TObject);
    Procedure ExploitationFichier(Sender: TObject);
  private
    { Déclarations privées }
    LigneAGrossir: Integer;
    // Stocke le numéro de la ligne à renforcer  public
    { Déclarations publiques }
  end;

type
  TTimeMessage = packed record
    Header: array [0 .. 1] of Byte; // 0x55, 0x50
    Year, Month, Day, Hour, Minute, Second: Byte;
    MS_L, MS_H: Byte;
    Checksum: Byte;
  end;

  TAccMessage = packed record
    Header: array [0 .. 1] of Byte; // 0x55, 0x51
    Ax_L, Ax_H, Ay_L, Ay_H, Az_L, Az_H: Byte;
    Temp_L, Temp_H: Byte;
    Checksum: Byte;
  end;

type
  TCircularBuffer = record
    Data: array [0 .. WindowSize - 1] of Extended;
    Index: Integer;
    Count: Integer;
  end;

var
  MainForm: TMainForm;
  FileName: String;
  BinaryFile: File;
  // InputFile: TextFile;
  ResultFile: TextFile;
  Temps, Temps_1, FlightTime, TakeOffTime, LandingTime: Extended;
  Classes, Occurs: Extended;
  Spectrum: Table_Spectrum;
  Repere: Integer; // 1 for ENU   , -1 for NED
  TimeMsg: TTimeMessage;
  AccMsg: TAccMessage;
  inFlight: Boolean;
  TailleFile: LongInt; // taille du fichier, en octets
  Compteur_FFT:Integer;
  R: Extended;
  Signal: array[0..WindowSize-1] of TComplex;

  Function R_Calculation(FlightTime: Extended; Spectrum: Table_Spectrum)
  : Extended;

implementation

{$R *.dfm}

// {$R InfoVersion.res}
uses UConfAesa, UDoc, UAPropos, UBatch;

Const // [col,ligne]
  Kossira_6000h: Array [0 .. 1, 0 .. 19] of Single = (
    // ligne 0, 1, 2, 3, 4, 5, 6
    (-2.5477, -2.2158, -1.7801, -1.4481, -1.0747, -0.7012, -0.3485, 0.0249,
    0.3776, 0.751, 1.1452, 1.4979, 1.8714, 2.2241, 2.556, 3.3029, 3.6971,
    4.0705, 4.4025, 4.7967), // col 0
    (1.0494, 10.3864, 137.3171, 880.2596, 2802.8818, 6366.375, 11637.7296,
    27079.1315, 478234.2968, 6797282.648, 6477049.939, 4195217.591, 501878.7439,
    90487.1326, 32844.8336, 9594.8, 5780.6417, 2367.2902, 140.6707, 5.1591)
    // col 1
    );

procedure InitBuffer(var Buf: TCircularBuffer);
var
  i: Integer;
begin
  for i := 0 to WindowSize - 1 do
    Buf.Data[i] := 0;
  Buf.Index := 0;
  Buf.Count := 0;
end;

procedure AddSample(var Buf: TCircularBuffer; Sample: Double);
begin
  Buf.Data[Buf.Index] := Sample;
  Buf.Index := (Buf.Index + 1) mod WindowSize;
  if Buf.Count < WindowSize then
    Inc(Buf.Count);
end;

function ComputeStdDev(const Buf: TCircularBuffer): Double;
var
  Sum, Sum2: Double;
  i, N: Integer;
  amax:Extended;
begin
  Result := 0;
  N := Buf.Count;
  if N < WindowSize then
    Exit; // Pas assez de données pour calculer

  Sum := 0;
  Sum2 := 0;
  amax:=0;
  for i := 0 to N - 1 do
  begin
    Sum := Sum + Buf.Data[i];
    Sum2 := Sum2 + Sqr(Buf.Data[i]);
  Signal[i].Re:=Buf.Data[i];
  Signal[i].Im:=0.0;
  end;
  Result := Sqrt((Sum2 - Sqr(Sum) / N) / (N - 1));
  Compteur_FFT:=Compteur_FFT+1;
  if (Compteur_FFT mod 32 =0) and (temps>40420) and (temps<40460) then
    begin
    MainForm.Series3.Clear;
    FFT(Signal,False);
    MainForm.Chart1.BottomAxis.Minimum:=0;
    MainForm.Chart1.BottomAxis.Maximum:=10;
    MainForm.Chart1.LeftAxis.Minimum:=0;
    MainForm.Chart1.LeftAxis.Maximum:=10;
    //MainForm.Chart1.LeftAxis.Automatic:=True;
    if temps>40425 then for i := 1 to N div 2 do
      begin
      MainForm.Series3.Addxy(20*i/N,amplitude[i]);
      if amplitude[i]>amax then amax:=amplitude[i];
      end;
    Mainform.Label1.Caption:=FloatToStr(amax);
    Application.ProcessMessages;
    sleep(3000);
    end;
end;

procedure TMainForm.Batch1Click(Sender: TObject);
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

procedure TMainForm.MarcovStringGrid1DrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if ARow = 32 - LigneAGrossir then
  begin
    MarcovStringGrid1.Canvas.Pen.Color := clBlack;
    MarcovStringGrid1.Canvas.Pen.Width := 2; // Largeur renforcée
    MarcovStringGrid1.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    MarcovStringGrid1.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
    MarcovStringGrid1.Canvas.Pen.Width := 1;
    // Remettre à la valeur standard
  end;
end;

procedure TMainForm.MarcovStringGrid2DrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if ARow = 32 - LigneAGrossir then
  begin
    MarcovStringGrid2.Canvas.Pen.Color := clBlack;
    MarcovStringGrid2.Canvas.Pen.Width := 2; // Largeur renforcée
    MarcovStringGrid2.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    MarcovStringGrid2.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
    MarcovStringGrid2.Canvas.Pen.Width := 1;
    // Remettre à la valeur standard
  end;
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
  // Ouverture de la form
  OKRightDlg.Show;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
  if FileOpenTextFileDialog.Execute then
  begin
    AssignFile(BinaryFile, FileOpenTextFileDialog.FileName);
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

procedure TMainForm.SaveAs1Click(Sender: TObject);
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

procedure TMainForm.Print1Click(Sender: TObject);
begin
  Chart1.PrintLandscape;
end;

procedure TMainForm.PrintSpectra1Click(Sender: TObject);
begin
  Chart2.PrintLandscape;
end;

procedure TMainForm.Quit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Run2Click(Sender: TObject);
begin
  RunButtonClick(Sender);
end;

procedure TMainForm.Run3Click(Sender: TObject);
begin
  ConfButtonClick(Sender)
end;

function CalcChecksum(const Buffer: array of Byte; Count: Integer): Byte;
var
  i: Integer;
  Sum: Integer;
begin
  Sum := 0;
  for i := 0 to Count - 1 do
    Sum := Sum + Buffer[i];
  Result := Byte(Sum and $FF);
end;

Function R_Calculation(FlightTime: Extended; Spectrum: Table_Spectrum)
  : Extended;
Const
  K = 6.6; // S/N Slope
  Kossira_Ni: Table_Kossira = (-3.84375, -3.53125, -3.21875, -2.90625, -2.59375,
    -2.28125, -1.96875, -1.65625, -1.34375, -1.03125, -0.71875, -0.40625,
    -0.09375, 0.21875, 0.53125, 0.84375, 1.15625, 1.46875, 1.78125, 2.09375,
    2.40625, 2.71875, 3.03125, 3.34375, 3.65625, 3.96875, 4.28125, 4.59375,
    4.90625, 5.21875, 5.53125, 5.84375);
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

Procedure TMainForm.ExploitationFichier(Sender: TObject);
Var
  i, j, K, col, raw: Integer;
  Count, N, n_1, nq, nq_1, nq_avg, slope, slope_1, minmax, minmax_1: Integer;
  nf, nff, nff_sum, nff_avg: Extended;
  ax, ay, az: Extended;
  Markov1, Markov2: Array [0 .. 31, 0 .. 31] of Integer;
  Debut, Fin: Extended;
  ax_AB, ay_AB, az_AB: TAlphaBeta;
  NAccel, NAccelx: Integer;
  AccelOutlier, AccelMin, AccelMax: Extended;
  Buffer: array [0 .. 9] of Byte; // 10 octets pour chaque message
  Checksum: Byte;
  Buf: TCircularBuffer;
  NewSample, StdDevValue: Extended;
   Vx:Extended;
   VxOffset:Extended;

  Procedure inFlight_Determination(dax, ay, az: Extended; Var inFlight: Boolean;
    Var LandingTime, TakeOffTime: Extended);
  Var
    PullUp, Deceleration, PullUpDelay, DecelerationDelay: Extended;

  Begin
    PullUp := StrToFloat(ConfForm.PullUpLabeledEdit.Text);
    PullUpDelay := StrToFloat(ConfForm.PullUpDelayLabeledEdit.Text);
    Deceleration := StrToFloat(ConfForm.DecelerationLabeledEdit.Text);
    DecelerationDelay := StrToFloat(ConfForm.DecDelayLabeledEdit.Text);
    If Not inFlight then
    begin
      if (az > PullUp) and ((Temps - LandingTime) > PullUpDelay) then
      begin
        inFlight := True;
        TakeOffTime := Temps;
        Writeln(ResultFile, 'TakeOff :', TakeOffTime:10:0);
      end;
    end
    else if (dax < Deceleration) and ((Temps - TakeOffTime > DecelerationDelay))
    then
    begin
      inFlight := False;
      LandingTime := Temps;
      FlightTime := FlightTime + (LandingTime - TakeOffTime) / 3600.0;
      Writeln(ResultFile, 'Landing :', LandingTime:10:0);
    end;
  End;

  Procedure Exploite_data;
  begin
    N := trunc((nff - LowG) / Quantum); // n load factor coded on 10 bits
    if ConfForm.ShowDataCheckBox.Checked then
    begin
      Memo4.Lines.Add(Format('%5.3f' + #9 + '%8.2f', [Temps, nf]));
      // high resolution quantification
      Memo3.Lines.Add(Format('%5.3f' + #9 + '%4d', [Temps, N]));
    end;
    // only process data if difference between n and n_1 is larger than 1
    if (Abs(N - n_1) > 1) then
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
        if ((nq - nq_1) > 0) then
          slope := 1
        else
          slope := -1;
        // if slope changes sign, we have a min or a max
        if ((slope * slope_1) < 0) then
        begin
          minmax := nq;
          Markov1[nq, nq_1] := Markov1[nq, nq_1] + 1;

          // Display results
          // Display n and nq for min/max
          // Series1.AddXY(Temps, n * UnderSample div ClassNumbers);
          if GraphCheckBox.Checked then
            //Series2.AddXY(Temps, nq);

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

begin
  // Exploitation du fichier de données
  Temps := 0.0;
  TakeOffTime := 0.0;
  LandingTime := 0.0;
  Count := 0;
  n_1 := 0;
  nq_1 := 0;
  slope_1 := 1;
  minmax := 1;
  minmax_1 := 1;
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
  for i := 1 to 32 do
    MarcovStringGrid1.Cells[i, 0] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to 32 do
    MarcovStringGrid1.Cells[0, 33 - i] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to 32 do
    MarcovStringGrid2.Cells[i, 0] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to 32 do
    MarcovStringGrid2.Cells[0, 33 - i] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to 1 do
    spectrumStringGrid.Cells[i, 0] := IntToStr(i);
  // initialisation de l'entête des colonnes
  for i := 1 to 32 do
  begin
    spectrumStringGrid.Cells[0, 33 - i] := IntToStr(i);
    // initialisation de l'entête des colonnes
    spectrumStringGrid.Cells[1, 33 - i] := '';
  end;
  for i := 0 to 31 do
  begin
    for j := 0 to 31 do
    begin
      MarcovStringGrid1.Cells[j + 1, 32 - i] := '';
      MarcovStringGrid2.Cells[j + 1, 32 - i] := '';
    end;
  end;
  for i := 0 to 31 do
    for j := 0 to 31 do
    begin
      Markov1[j, i] := 0;
      Markov2[j, i] := 0;
    end;

  for i := 0 to 31 do
    Spectrum[i] := 0;
  Debut := 0.0;
  Chart1.Axes.Left.Automatic := False;
  Chart1.Axes.Left.Maximum := HighG;
  Chart1.Axes.Left.Minimum := LowG;
  NAccel := StrToInt(ConfForm.NAccelLabeledEdit.Text);
  NAccelx := StrToInt(ConfForm.NAccelxLabeledEdit.Text);
  AccelOutlier := StrToFloat(ConfForm.OutlierLabeledEdit.Text);
  AccelMin := StrToFloat(ConfForm.NMinLabeledEdit.Text);
  AccelMax := StrToFloat(ConfForm.NMaxLabeledEdit.Text);
  // Compute nq_avg
  nff_sum := 0;
  Temps := 0.0;
  FlightTime := 0.0;
  ax_AB := TAlphaBeta.Create(NAccel, deltaT, AccelOutlier, AccelMin, AccelMax);
  az_AB := TAlphaBeta.Create(NAccel, deltaT, AccelOutlier, AccelMin, AccelMax);
  Writeln(ResultFile, FileName);
  Series1.Title := 'inFlight';
  Series2.Title := 'nq';
  Series3.Title := 'Ax';
  Series6.Title := 'Az';
  InitBuffer(Buf);
  Vx:=0.0;
  VxOffset:=0.0;
  Compteur_FFT:=0;

  // Average for binary file
  RunningLabel.Caption := 'Averaging';
  Application.ProcessMessages;
  While Not EoF(BinaryFile) do
  begin
    // Lire le header (2 octets)
    BlockRead(BinaryFile, Buffer, 2);
    if Buffer[0] = $55 then
    begin
      if Buffer[1] = $50 then
      begin
        // Message temps
        BlockRead(BinaryFile, Buffer[2], 9);
        // Lire le reste (8 octets)
        Move(Buffer, TimeMsg, SizeOf(TimeMsg));
        Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
        if Checksum = TimeMsg.Checksum then
        begin
          // Message temps valide, traiter ici
          Temps := TimeMsg.Hour * 3600 + TimeMsg.Minute * 60 + TimeMsg.Second +
            SmallInt((TimeMsg.MS_H shl 8) or TimeMsg.MS_L) / 1000.0;
          if TakeOffTime = 0 then
          Begin
            Debut := Temps;
            Temps_1 := Temps;
            TakeOffTime := Temps;
            LandingTime := Temps;
          End;
        end;
      end
      else if Buffer[1] = $51 then
      begin
        // Message accélération
        BlockRead(BinaryFile, Buffer[2], 9);
        // Lire le reste (8 octets)
        Move(Buffer, AccMsg, SizeOf(AccMsg));
        Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
        if Checksum = AccMsg.Checksum then
        begin
          // Message accélération valide, traiter ici
          az := SmallInt((AccMsg.Az_H shl 8) or AccMsg.Az_L) / 2048.0;
          az_AB.ABupdate(deltaT, -az * Repere);
          nff := -az * Repere;
          // sum nff values
          nff_sum := nff_sum + nff;

          Count := Count + 1;
        end;
      end;
      // Graph nf for entire file
      if GraphCheckBox.Checked then
      begin
        //Series3.AddXY(Temps, az_AB.ABPrim);
        //Series6.AddXY(Temps, nff);
      end;
      if Count mod 1000 = 0 then
        ProgressBar1.Position :=
          Round((Count * TailleMessage) / (TailleFile) * 100.0);
    end;
  end;
  // compute average low resolution nq
  if Count > 0 then
    nq_avg := trunc((nff_sum / Count - LowG) / QuantumRough)
  else
  begin
    Application.MessageBox('Aucune mesure valide', 'ATTENTION', IdOk);
    Exit;
  end;
  Label1.Caption := Format('nq_avg = %2d', [nq_avg]);
  LigneAGrossir := nq_avg;
  Fin := Temps;
  // Fin du calcul de la moyenne

  // Calcul KOSSIRA
  RunningLabel.Caption := 'Occuring';
  ProgressBar1.Position := 0;
  Application.ProcessMessages;
  //sleep(10000);

  Series3.Clear;
  Series6.Clear;
  inFlight := False;
  // reset file to begining
  Reset(BinaryFile, 1);
  While Not EoF(BinaryFile) do
  begin
    // Lire le header (2 octets)
    BlockRead(BinaryFile, Buffer, 2);
    if Buffer[0] = $55 then
    begin
      if Buffer[1] = $50 then
      begin
        // Message temps
        BlockRead(BinaryFile, Buffer[2], 9);
        // Lire le reste (8 octets)
        Move(Buffer, TimeMsg, SizeOf(TimeMsg));
        Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
        if Checksum = TimeMsg.Checksum then
        begin
          // Message temps valide, traiter ici
          Temps := TimeMsg.Hour * 3600 + TimeMsg.Minute * 60 + TimeMsg.Second +
            SmallInt((TimeMsg.MS_H shl 8) or TimeMsg.MS_L) / 1000.0;
        end;
      end
      else if Buffer[1] = $51 then
      begin
        // Message accélération
        BlockRead(BinaryFile, Buffer[2], 9);
        // Lire le reste (8 octets)
        Move(Buffer, AccMsg, SizeOf(AccMsg));
        Checksum := CalcChecksum(Buffer, 10); // 9 premiers octets
        if Checksum = AccMsg.Checksum then
        begin
          // Message accélération valide, traiter ici
          ax := SmallInt((AccMsg.Ax_H shl 8) or AccMsg.Ax_L) / 2048.0;
          ay := SmallInt((AccMsg.Ay_H shl 8) or AccMsg.Ay_L) / 2048.0;
          az := SmallInt((AccMsg.Az_H shl 8) or AccMsg.Az_L) / 2048.0;
          ax_AB.ABupdate(deltaT, ax);
          az_AB.ABupdate(deltaT, -az * Repere);
          nff := -az * Repere;
          AddSample(Buf, az_AB.ABfilt);
          StdDevValue := ComputeStdDev(Buf);
          inFlight_Determination(ax - ax_AB.ABfilt, ay, az_AB.ABfilt, inFlight,
            TakeOffTime, LandingTime);
          if StdDevValue<0.1 then VxOffset:=ax_AB.ABFilt;
          if az_AB.ABfilt>1.1 then  Vx:=Vx-(ax-VxOffset)*Gravity*deltat;

          Count := Count + 1;
        end;
      end;
      if (nff >= LowG) and (nff <= HighG) then
      begin
        if GraphCheckBox.Checked then
        begin
          //Series6.AddXY(Temps, nff);
          //Series3.AddXY(Temps, StdDevValue);
          //Series1.Addxy(Temps,Vx/10.0);
        end;
        {if inFlight then
          Series1.AddXY(Temps, 1)
        else
          Series1.AddXY(Temps, 0);}
        if inFlight then
        begin
          Exploite_data;
        end;
      end;
      if Count mod 1000 = 0 then
        ProgressBar1.Position := Round((Temps - Debut) / (Fin - Debut) * 100.0);
    end;
  end;
  ProgressBar1.Position := 100;
  Fin := Temps;
  Writeln(ResultFile, 'StartTime (s) :', Debut:10:3, ' EndTime (s) :', Fin:10:3,
    ' FlightTime (s) :', FlightTime:10:3);
  Writeln(ResultFile, ' Classes (g)', #9, 'occurs');
  for i := 0 to 31 do
    for j := 0 to 31 do
    Begin
      // col,  ligne en partant du bas, donc de la ligne 32 pour i=0
      if Markov1[j, i] <> 0 then
        MarcovStringGrid1.Cells[j + 1, 32 - i] := IntToStr(Markov1[j, i]);
    End;

  // On va calculer markov2 positif

  RunningLabel.Caption := 'Markov';
  Application.ProcessMessages;
  for col := 0 to 31 do
  begin
    // sum cells above diagonal
    if (col < 31) then
    begin
      for raw := col + 1 to 31 do
        // enumerate matrix lines above diagonal
        for K := raw to 31 do
          // add all cells values at and above current cell.
          Markov2[col, raw] := Markov2[col, raw] + Markov1[col, K];
    end;
    // sum cells below diagonal
    if (col > 1) then
    begin
      for raw := col - 1 downto 0 do
        // enumerate matrix lines below diagonal
        for K := raw downto 0 do
          // add all cells values at and below current cell.
          Markov2[col, raw] := Markov2[col, raw] + Markov1[col, K];
    end;
  end;
  for raw := 0 to 31 do
  begin
    // sum cells to the right of the diagonal and below nq_avg
    if (raw < nq_avg) then
    begin
      for col := raw + 1 to 31 do
        if Markov2[col, raw] <> 0 then
          Spectrum[raw] := Spectrum[raw] + Markov2[col, raw];
    end
    // sum cells to the left of the diagonal and above nq_avg
    else
      for col := 0 to raw - 1 do
        if Markov2[col, raw] <> 0 then
          Spectrum[raw] := Spectrum[raw] + Markov2[col, raw];
  end;
  for i := 0 to 31 do
    for j := 0 to 31 do
    Begin
      if Markov2[j, i] <> 0 then
        MarcovStringGrid2.Cells[j + 1, 32 - i] := IntToStr(Markov2[j, i]);
    End;
  Series5.Title := FileName;
  Memo1.Lines.Add('Kossira');
  Memo1.Lines.Add(Format('From %8.1f  to %8.1f s.', [Debut, Fin]));
  Memo1.Lines.Add('Class (g)' + #9'Occurences (-)');
  RunningLabel.Caption := 'Kossira';
  Application.ProcessMessages;
  R := R_Calculation(FlightTime, Spectrum);
  for j := 0 to 31 do
    if Spectrum[j] <> 0 then
    begin
      Classes := ((j + 0.5) * QuantumRough + LowG);
      Occurs := Spectrum[j] * (6000.0) / (FlightTime);
      spectrumStringGrid.Cells[1, 32 - j] := IntToStr(Spectrum[j]);
      Series5.AddXY(Occurs, Classes);
      Memo1.Lines.Add(Format('%8.2f' + #9 + '%8.0f', [Classes, Occurs]));
      Writeln(ResultFile, Classes:8:3, ',', Spectrum[j]:8);
    end;
  for j := 0 to 19 do
    Series4.AddXY((Kossira_6000h[1, j]), (Kossira_6000h[0, j]));
  FlightTimeLabel.Caption := Format('Flight time = %5.1f h', [+FlightTime]);
  RLabel.Caption := Format('R = %8.1f', [R]);
  Writeln(ResultFile, 'R = ', R:5:1);
  { MarcovStringGrid1.Canvas.Pen.Color := clRed;
    MarcovStringGrid1.Canvas.Pen.Width := 2;
    MarcovStringGrid2.Canvas.MoveTo(100, 100);
    MarcovStringGrid2.Canvas.LineTo(200, 100);
    MarcovStringGrid2.Invalidate;
    //MarcovStringGrid1.Canvas.DrawLine(Tpointf.Create(Column.Position.X,row * StrGrid.RowHeight),TPointF.Create(column.Width,row * StrGrid.RowHeight),1,Brush);
  }
  Memo1.Lines.EndUpdate;
  Memo2.Lines.EndUpdate;
  Memo3.Lines.EndUpdate;
  Memo4.Lines.EndUpdate;
  RunningLabel.Caption := 'Complete';
  ax_AB.Free;
  az_AB.Free;
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
begin
  RunningLabel.Caption := 'Running';
  Sleep(50);
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
  if ConfForm.RepereRadioGroup.ItemIndex = 0 then
    Repere := 1
  else
    Repere := -1;

  // Lecture du fichier de données
  FileName := FileNameLabeledEdit.Text;
  if FileExists(FileName) then
  begin
    AssignFile(BinaryFile, FileName);
  end
  else
  begin
    if FileOpenTextFileDialog.Execute then
    begin
      AssignFile(BinaryFile, FileOpenTextFileDialog.FileName);
      FileName := FileOpenTextFileDialog.FileName;
      FileNameLabeledEdit.Text := FileName;
    end
    else
      Exit;
  end;
  FileNameLabeledEdit.Text := FileName;
  FileName := Copy(FileName, 0, Length(FileName) - 4);
  AssignFile(ResultFile, FileName + '.res');
  Rewrite(ResultFile);
  Reset(BinaryFile, 1);
  TailleFile := FileSize(BinaryFile);
  ExploitationFichier(Sender);
  CloseFile(BinaryFile);
  CloseFile(ResultFile);
end;

end.
