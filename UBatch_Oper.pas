unit UBatch_Oper;

interface

uses
  System.IOUtils, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl,
  Vcl.ExtCtrls, UDecodeWIT_Oper;

type
  TBatchForm = class(TForm)
    Panel1: TPanel;
    DirectoryListBox1: TDirectoryListBox;
    ListBoxFiles: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    RunButton: TButton;
    OverLabel: TLabel;
    FlightTimeLabel: TLabel;
    RLabel: TLabel;
    DriveComboBox1: TDriveComboBox;
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure FillFileList(const Directory: string);
    procedure RunButtonClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  BatchForm: TBatchForm;
  Repertoire: String;

implementation

{$R *.dfm}

uses System.Types, UMainAESA_Oper, UConfAESA_Oper;

procedure TBatchForm.FillFileList(const Directory: string);
var
  Files: TStringDynArray;
  FileName: string;
begin
  ListBoxFiles.Clear;
  Files := TDirectory.GetFiles(Directory, '*.bin', TSearchOption.soTopDirectoryOnly);
  for FileName in Files do
    ListBoxFiles.Items.Add(FileName);
end;

procedure TBatchForm.RunButtonClick(Sender: TObject);
Var
  i, j: Integer;
  Cumul_Spectrum: Table_Spectrum;
  Cumul_FlightTime: Extended;
  Classe: Extended;
  Bidon1, bidon2: String;
begin
  for i := 0 to 31 do
  begin
    spectrum[i] := 0;
    Cumul_Spectrum[i] := 0;
  end;
  OverLabel.Visible := False;
  Cumul_FlightTime := 0.0;
  for i := 0 to ListBoxFiles.Items.Count - 1 do
  begin
    ListBoxFiles.ItemIndex := i; // Surligne le fichier courant
    ListBoxFiles.TopIndex := i; // Fait défiler la liste si besoin
    Application.ProcessMessages; // Rafraîchit l'IHM
    Sleep(1000);
    // TraiterFichier(ListBoxFiles.Items[i]); // Traitement personnalisé
    With MainForm do
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
      Series7.Clear;
      MainForm.Label1.Caption := '';
      MainForm.Label2.Caption := '';
      if ConfForm.RepereRadioGroup.ItemIndex = 0 then
        Repere := 1
      else
        Repere := -1;
      // Lecture du fichier de données
      FileName := ListBoxFiles.Items[i];
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
      ResFileName := Copy(FileName, 0, Length(FileName) - 4) + '.res';
      AssignFile(ResultFile, ResFileName);
      if Not FileExists(ResFileName) then
      begin
        Rewrite(ResultFile);
        DataBytes := TFile.ReadAllBytes(FileName);
        FileProcessing(Sender);
        for j := 0 to Taille_Spectrum do
          Cumul_Spectrum[j] := Cumul_Spectrum[j] + spectrum[j];
        Cumul_FlightTime := Cumul_FlightTime + FlightTime;
      end
      else
      begin
        Reset(ResultFile);
        Repeat
          Readln(ResultFile, Bidon1);
          j := Pos('FlightTime', Bidon1);
          if j > 0 then
          begin
            bidon2 := Copy(Bidon1, j, Length(Bidon1) - j);
            j := Pos(':', bidon2);
            bidon2 := Copy(bidon2, j + 1, Length(bidon2) - j);
            FlightTime := StrToFloat(bidon2);
          end;
        Until (Pos('Classes', Bidon1) > 0) or EoF(ResultFile);
        For j := 0 to Taille_Spectrum do
        begin
          Readln(ResultFile, Classe, spectrum[j]);
          Cumul_Spectrum[j] := Cumul_Spectrum[j] + spectrum[j];
        end;
        Cumul_FlightTime := Cumul_FlightTime + FlightTime;
      end;
      CloseFile(ResultFile);
    end;
  end;
  AssignFile(ResultFile, Repertoire + '.res');
  Rewrite(ResultFile);
  Writeln(ResultFile, Repertoire);
  Writeln(ResultFile, 'Total Flight Time (h):', Cumul_FlightTime:10:2);
  Writeln(ResultFile, 'Classes (g)', #9, 'Occurs');
  MainForm.Series5.Title := Repertoire;
  for j := 0 to Taille_Spectrum do
  begin
    Occurs := Cumul_Spectrum[j] * (6000.0) / (Cumul_FlightTime); // Normalisation for 6000h to be compared with the Kossira reference
    Classes := ((j + 0.5) * QuantumRough + LowG);
    if spectrum[j] <> 0 then
    begin
      MainForm.spectrumStringGrid.Cells[1, Taille_Spectrum + 1 - j] := IntToStr(Cumul_Spectrum[j]);
      MainForm.Series5.Addxy(Occurs, Classes);
      MainForm.Memo1.Lines.Add(Format('%8.2f' + #9 + '%8.0f', [Classes, Occurs]));
    end;
    Writeln(ResultFile, Classes:8:3, Cumul_Spectrum[j]:10);
  end;
  for j := 0 to 19 do
    MainForm.Series4.Addxy((Kossira_6000h[1, j]), (Kossira_6000h[0, j])); // Kossira reference plot
  R := R_Calculation(Cumul_FlightTime, Cumul_Spectrum);
  MainForm.FlightTimeLabel.Caption := Format('Flight time = %5.1f h', [Cumul_FlightTime]);
  MainForm.RLabel.Caption := Format('R = %8.1f', [R]);
  MainForm.RunningLabel.Caption := 'Batch complete';
  FlightTimeLabel.Caption := Format('Flight time = %5.1f h', [Cumul_FlightTime]);
  RLabel.Caption := Format('R = %8.1f', [R]);
  Writeln(ResultFile, 'R=', R:5:1);
  CloseFile(ResultFile);
  ListBoxFiles.ItemIndex := -1;
  OverLabel.Visible := True;
end;

procedure TBatchForm.DirectoryListBox1Change(Sender: TObject);
begin
  Repertoire := DirectoryListBox1.Directory;
  FillFileList(Repertoire);
end;

end.
