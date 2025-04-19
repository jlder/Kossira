unit UMainMenu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, Vcl.ComCtrls, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs,
  VCLTee.Chart, Vcl.Grids, Math, Vcl.Menus;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    FileNameLabeledEdit: TLabeledEdit;
    StartLabeledEdit: TLabeledEdit;
    StopLabeledEdit: TLabeledEdit;
    RunButton: TButton;
    FileOpenTextFileDialog: TOpenTextFileDialog;
    PageControl1: TPageControl;
    DataTabSheet: TTabSheet;
    GraphTabSheet: TTabSheet;
    Memo2: TMemo;
    Memo3: TMemo;
    ConfButton: TButton;
    Memo4: TMemo;
    Chart1: TChart;
    Series1: TPointSeries;
    Series2: TPointSeries;
    ProgressBar1: TProgressBar;
    Series3: TLineSeries;
    Markov1TabSheet: TTabSheet;
    MarcovStringGrid1: TStringGrid;
    Marcov2TabSheet: TTabSheet;
    MarcovStringGrid2: TStringGrid;
    spectrumStringGrid: TStringGrid;
    SpectraTabSheet: TTabSheet;
    Chart2: TChart;
    Series4: TLineSeries;
    Series5: TLineSeries;
    RadioGroup1: TRadioGroup;
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
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
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
    procedure MarcovStringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure MarcovStringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure PrintSpectra1Click(Sender: TObject);
  private
    { Déclarations privées }
    LigneAGrossir: Integer; // Stocke le numéro de la ligne à renforcer  public
    { Déclarations publiques }
  end;

const
  APP_COPYRIGHT = '© 2025 GFM & JLD. Copyright. Tous droits réservés.';
  APP_VERSION = 'Version 1.0.0.0';

var
  MainForm: TMainForm;
  FileName: String;
  InputFile: TextFile;
  Temps, StartTime, StopTime: Extended;
  Classes, Occurs: Extended;
var
  Start, EndTime1, Duration1, EndTime2, Duration2, EndTime3, Duration3: Cardinal;

implementation

{$R *.dfm}

// {$R InfoVersion.res}
uses UConf, UDoc, FilterButterworth, UAPropos;

Const // [col,ligne]
  Markov1_test: Array [0 .. 5, 0 .. 5] of Integer = (
    // ligne 0, 1, 2, 3, 4, 5, 6
    (0, 1, 0, 0, 1, 0), // col 0
    (0, 0, 3, 4, 1, 0), // col 1
    (0, 2, 0, 5, 2, 1), // col 2
    (0, 3, 7, 0, 1, 0), // col 3
    (1, 0, 1, 4, 0, 0), // col 4
    (0, 0, 0, 0, 1, 0) // col 5
    );
  Kossira_6000h: Array [0 .. 1, 0 .. 19] of Single = (
    // ligne 0, 1, 2, 3, 4, 5, 6
    (-2.5477, -2.2158, -1.7801, -1.4481, -1.0747, -0.7012, -0.3485, 0.0249, 0.3776, 0.751, 1.1452, 1.4979, 1.8714, 2.2241, 2.556, 3.3029, 3.6971, 4.0705,
    4.4025, 4.7967), // col 0
    (1.0494, 10.3864, 137.3171, 880.2596, 2802.8818, 6366.375, 11637.7296, 27079.1315, 478234.2968, 6797282.648, 6477049.939, 4195217.591, 501878.7439,
    90487.1326, 32844.8336, 9594.8, 5780.6417, 2367.2902, 140.6707, 5.1591) // col 1
    );

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
  if ARow = LigneAGrossir then
  begin
    MarcovStringGrid1.Canvas.Pen.Color := clBlack;
    MarcovStringGrid1.Canvas.Pen.Width := 2; // Largeur renforcée
    MarcovStringGrid1.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    MarcovStringGrid1.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
    MarcovStringGrid1.Canvas.Pen.Width := 1; // Remettre à la valeur standard
  end;
end;

procedure TMainForm.MarcovStringGrid2DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if ARow = LigneAGrossir then
  begin
    MarcovStringGrid2.Canvas.Pen.Color := clBlack;
    MarcovStringGrid2.Canvas.Pen.Width := 2; // Largeur renforcée
    MarcovStringGrid2.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    MarcovStringGrid2.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
    MarcovStringGrid2.Canvas.Pen.Width := 1; // Remettre à la valeur standard
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
    AssignFile(InputFile, FileOpenTextFileDialog.FileName);
    FileName := FileOpenTextFileDialog.FileName;
    FileNameLabeledEdit.Text := FileName;
  end
  else
    exit;
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

procedure TMainForm.RunButtonClick(Sender: TObject);
Var
  i, j, k, col, raw: Integer;
  deltaT: Extended;
  Line: String;
  LinePosition: Integer;
  ss: TStringList;
  count, n, n_1, nq, nq_1, nq_avg, slope, slope_1, minmax, minmax_1: Integer;
  nf, nff, nff_sum, nff_avg: Extended;
  fc: Extended; // Freq de coupure du passe bas
  Filter: TFilterButterworth;
  spectrum: Array [0 .. 31] of Integer;
  Markov1, Markov2: Array [0 .. 31, 0 .. 31] of Integer;
  Debut, Fin: Extended;

  Procedure Exploite_data;
  begin
    // filter data to remove noise
    if fc > 0 then
      Filter.ProcessData(deltaT, nf, nff) // nff corresponds to filtered load factor nf
    else
      nff := nf;
    if nff < LowG then
      nff := LowG;
    if nff > HighG then
      nff := HighG;
    if ConfForm.ShowDataCheckBox.Checked then
      Memo4.Lines.Add(Format('%5.3f' + #9 + '%8.2f', [Temps, nf]));
    // high resolution quantification
    n := trunc((nff - LowG) / Quantum); // n load factor coded on 10 bits
    if ConfForm.ShowDataCheckBox.Checked then
      Memo3.Lines.Add(Format('%5.3f' + #9 + '%4d', [Temps, n]));
    // only process data if difference between n and n_1 is larger than 1
    if (abs(n - n_1) > 1) then
    begin
      // low resolution quantification
      nq := trunc((nff - LowG) / QuantumRough); // nq load factor coded on 5 bits
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
          Series1.AddXY(Temps, n * UnderSample div ClassNumbers);
          Series2.AddXY(Temps, nq);

          // keep track of last minmax
          minmax_1 := minmax;
        end;
        // keep track of last slope and nq
        slope_1 := slope;
        nq_1 := nq;
      end;
    end;
    // keep track of last n
    n_1 := n;
    ProgressBar1.Position := Round((Temps - StartTime) / (StopTime - StartTime) * 100.0);
  end;

begin
  RunningLabel.Caption := 'Running';
  Sleep(500);
  Application.ProcessMessages;
  // Cleaning memos and curves
  Start := GetTickCount;
  Memo1.Clear;
  Memo2.Clear;
  Memo3.Clear;
  Memo4.Clear;
  Series1.Clear;
  Series2.Clear;
  Series3.Clear;
  Series4.Clear;
  Series5.Clear;
  // Lecture du fichier de données
  FileName := FileNameLabeledEdit.Text;
  if FileExists(FileName) then
  begin
    AssignFile(InputFile, FileName);
  end
  else
  begin
    if FileOpenTextFileDialog.Execute then
    begin
      AssignFile(InputFile, FileOpenTextFileDialog.FileName);
      FileName := FileOpenTextFileDialog.FileName;
      FileNameLabeledEdit.Text := FileName;
    end
    else
      exit;
  end;
  Reset(InputFile);
  ss := TStringList.Create;
  // Read the file first two lines
  Readln(InputFile, Line);
  Readln(InputFile, Line);
  Temps := 0.0;
  count := 0;
  n_1 := 0;
  nq_1 := 0;
  slope_1 := 1;
  minmax := 1;
  minmax_1 := 1;
  LinePosition := 0;
  StartTime := StrToFloat(StartLabeledEdit.Text);
  StopTime := StrToFloat(StopLabeledEdit.Text);
  deltaT := StrToFloat(ConfForm.dtLabeledEdit.Text);
  fc := StrToFloat(ConfForm.FrstLabeledEdit.Text);
  if fc > 0.5 / deltaT then
  Begin
    fc := 0.5 / deltaT;
    ConfForm.FrstLabeledEdit.Text := Format('%5.1f', [fc]);
    Application.MessageBox('Fc too High', 'Attention', IdOk);
  end;
  Filter := TFilterButterworth.Create;
  if fc > 0 then
    Filter.DesignFilter(deltaT, fc, a, b);

  // Création d'une Fifo au cas où il faudrait se souvenir du passé
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
    MarcovStringGrid1.Cells[i, 0] := IntToStr(i); // initialisation de l'entête des colonnes
  for i := 1 to 32 do
    MarcovStringGrid1.Cells[0, 33 - i] := IntToStr(i); // initialisation de l'entête des colonnes
  for i := 1 to 32 do
    MarcovStringGrid2.Cells[i, 0] := IntToStr(i); // initialisation de l'entête des colonnes
  for i := 1 to 32 do
    MarcovStringGrid2.Cells[0, 33 - i] := IntToStr(i); // initialisation de l'entête des colonnes
  for i := 1 to 1 do
    spectrumStringGrid.Cells[i, 0] := IntToStr(i); // initialisation de l'entête des colonnes
  for i := 1 to 32 do
    spectrumStringGrid.Cells[0, 33 - i] := IntToStr(i); // initialisation de l'entête des colonnes
  for i := 0 to 31 do
  begin
    for j := 0 to 31 do
    begin
      MarcovStringGrid1.Cells[j + 1, 32 - i] := '';
      MarcovStringGrid2.Cells[j + 1, 32 - i] := '';
    end;
    spectrumStringGrid.Cells[i, 1] := '';
  end;
  for i := 0 to 31 do
    for j := 0 to 31 do
    begin
      Markov1[j, i] := 0;
      Markov2[j, i] := 0;
    end;

  for i := 0 to 31 do
    spectrum[i] := 0;
  Fin := 0.0;
  Debut := 0.0;
  Chart1.Axes.Left.Automatic := False;
  Chart1.Axes.Left.Maximum := HighG;
  Chart1.Axes.Left.Minimum := LowG;
  EndTime1 := GetTickCount;
  Duration1:=EndTime1-Start;
  // Compute nq_avg
  if RadioGroup1.ItemIndex = 0 then
  begin
    for i := 0 to 5 do
      for j := 0 to 5 do
      Begin
        Markov1[j, i] := Markov1_test[j, i]; // i=n°col, j=N° ligne
      End;
    nq_avg := 3;
  end
  else
  begin
    // TODO passer au format $I pour facilement traiter tous les fichiers de vol
    nff_sum := 0;
    Temps := 0.0;
    // compute average load factor
    While Not EoF(InputFile) do
    begin
      Readln(InputFile, Line);
      ss.CommaText := Line;
      i := ss.count;
      if (Temps <= StartTime) then
        Inc(LinePosition); // Mémorisation du nombre de lignes où Temps=Startime
      if RadioGroup1.ItemIndex = 2 then
      begin
        if (Pos('$I', Line) > 0) and (Pos('$S', Line) = 0) and ((i = 9) or (i = 10)) and (Line.CountChar('$') = 1) then
        begin
          Temps := StrToFloat(ss[2]) / 1000.0;
          nf := -StrToFloat(ss[5]) / 10000.0 / 9.807;
          if (Temps >= StartTime) and (Temps <= StopTime) then
          begin
            // filter data to remove noise
            if fc > 0 then
              Filter.ProcessData(deltaT, nf, nff) // nff corresponds to filtered load factor nf
            else
              nff := nf;
            // sum nff values
            nff_sum := nff_sum + nff;
            count := count + 1;
          end;
        end;
      end
      else
      begin
        Temps := StrToFloat(ss[0]);
        nf := -StrToFloat(ss[1]);
        // filter data to remove noise
        if (Temps >= StartTime) and (Temps <= StopTime) then
        begin
          if fc > 0 then
            Filter.ProcessData(deltaT, nf, nff) // nff corresponds to filtered load factor nf
          else
            nff := nf;

          // sum nff values
          nff_sum := nff_sum + nff;
          count := count + 1;
        end;
      end;
      // Graph nf for entire file
      if GraphCheckBox.Checked then
        Series3.AddXY(Temps, nf);
      ProgressBar1.Position := Round(Temps / StopTime * 100.0);
    end;
    // compute average low resolution nq
    nq_avg := trunc((nff_sum / count - LowG) / QuantumRough);
    Label1.Caption := Format('nq_avg = %8d', [nq_avg]);
    LigneAGrossir := nq_avg;
    Application.ProcessMessages;
  EndTime2 := GetTickCount;
  Duration2:=EndTime2-EndTime1;

    Sleep(1000);
    ProgressBar1.Position := 0;
    // reset file to begining
    Reset(InputFile);
    // Read the file first two lines
    Readln(InputFile, Line);
    Readln(InputFile, Line);
    // skip records until start time is reached
    Temps := StartTime;
    i := 0;
    // skip records until start time is reached
    Repeat
      Inc(i);
      Readln(InputFile, Line);
    until (i >= LinePosition) or EoF(InputFile);

    While Not EoF(InputFile) and (Temps >= StartTime) and (Temps <= StopTime) do
    begin
      Readln(InputFile, Line);
      ss.CommaText := Line;
      i := ss.count;
      if RadioGroup1.ItemIndex = 2 then
      begin
        if (Pos('$I', Line) > 0) and (Pos('$S', Line) = 0) and ((i = 9) or (i = 10)) and (Line.CountChar('$') = 1) then
        begin
          Temps := StrToFloat(ss[2]) / 1000.0;
          nf := -StrToFloat(ss[5]) / 10000.0 / 9.807;
          if (nf >= LowG) and (nf <= HighG) then
            Exploite_data;
        end;
      end
      else
      begin
        Temps := StrToFloat(ss[0]);
        nf := -StrToFloat(ss[1]);
        if (nf >= LowG) and (nf <= HighG) then
          Exploite_data;
      end;
      if Debut = 0 then
        Debut := Temps;
    end;
  end;
  if EoF(InputFile) then
  begin
    ProgressBar1.Position := 100;
    StopTime := Temps;
  End;
  Fin := StopTime;

  EndTime3 := GetTickCount;
  Duration3:=EndTime3-EndTime2;
  for i := 0 to 31 do
    for j := 0 to 31 do
    Begin
      // col,  ligne en partant du bas, donc de la ligne 32 pour i=0
      if Markov1[j, i] <> 0 then
        MarcovStringGrid1.Cells[j + 1, 32 - i] := IntToStr(Markov1[j, i]);
    End;

  // On va calculer markov2 positif

  for col := 0 to 31 do
  begin
    // sum cells above diagonal
    if (col < 31) then
    begin
      for raw := col + 1 to 31 do // enumerate matrix lines above diagonal
        for k := raw to 31 do // add all cells values at and above current cell.
          Markov2[col, raw] := Markov2[col, raw] + Markov1[col, k];
    end;
    // sum cells below diagonal
    if (col > 1) then
    begin
      for raw := col - 1 downto 0 do // enumerate matrix lines below diagonal
        for k := raw downto 0 do // add all cells values at and below current cell.
          Markov2[col, raw] := Markov2[col, raw] + Markov1[col, k];
    end;
  end;
  for raw := 0 to 31 do
  begin
    // sum cells to the right of the diagonal and below nq_avg
    if (raw < nq_avg) then
    begin
      for col := raw + 1 to 31 do
        if Markov2[col, raw] <> 0 then
          spectrum[raw] := spectrum[raw] + Markov2[col, raw];
    end
    // sum cells to the left of the diagonal and above nq_avg
    else
      for col := 0 to raw - 1 do
        if Markov2[col, raw] <> 0 then
          spectrum[raw] := spectrum[raw] + Markov2[col, raw];
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
  for j := 0 to 31 do
    if spectrum[j] <> 0 then
    begin
      Classes := ((j + 0.5) * QuantumRough + LowG);
      Occurs := spectrum[j] * (6000.0 * 3600.0) / (Fin - Debut);
      spectrumStringGrid.Cells[1, 32 - j] := IntToStr(spectrum[j]);
      Series5.AddXY(Occurs, Classes);
      Memo1.Lines.Add(Format('%8.2f' + #9 + '%8.0f', [Classes, Occurs]));
    end;
  for j := 0 to 19 do
    Series4.AddXY((Kossira_6000h[1, j]), (Kossira_6000h[0, j]));

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
  EndTime2 := GetTickCount;
  Label1.Caption:=IntToStr(Duration1);
  Label2.Caption:=IntToStr(Duration2);
  Label3.Caption:=IntToStr(Duration3);
  Label4.Caption:=IntToStr(EndTime2-EndTime3);
end;

end.
