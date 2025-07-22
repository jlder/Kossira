unit UBatch;

interface

uses
  System.IOUtils, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl,
  Vcl.ExtCtrls;

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

uses System.Types, UMainAESA, UConfAESA;

procedure TBatchForm.FillFileList(const Directory: string);
var
  Files: TStringDynArray;
  FileName: string;
begin
  ListBoxFiles.Clear;
  Files := TDirectory.GetFiles(Directory, '*bin*.txt');
  // Adapt. masque selon vos fichiers
  for FileName in Files do
    ListBoxFiles.Items.Add(FileName);
end;

procedure TBatchForm.RunButtonClick(Sender: TObject);
Var
  i, j: Integer;
  Cumul_Spectrum: Table_Spectrum;
  Cumul_FlightTime: Extended;
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
      if ConfForm.RepereRadioGroup.ItemIndex = 0 then
        Repere := 1
      else
        Repere := -1;
      // Lecture du fichier de données
      FileName := ListBoxFiles.Items[i];
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
          exit;
      end;
      FileNameLabeledEdit.Text := FileName;
      FileName := Copy(FileName, 0, Length(FileName) - 4);
      AssignFile(ResultFile, FileName + '.res');
      Rewrite(ResultFile);
      Reset(BinaryFile, 1);
      TailleFile := FileSize(BinaryFile);
      ExploitationFichier(Sender);
      for j := 0 to Taille_Spectrum do
        Cumul_Spectrum[j] := Cumul_Spectrum[j] + spectrum[j];
      Cumul_FlightTime := Cumul_FlightTime + FlightTime;
      CloseFile(BinaryFile);
      CloseFile(ResultFile);
    end;
  end;
  AssignFile(ResultFile, Repertoire + '.res');
  Rewrite(ResultFile);
  Writeln(ResultFile, Repertoire);
  Writeln(ResultFile, 'Total Flight Time (h):', Cumul_FlightTime:10:2);
  Writeln(ResultFile, 'Classes (g)', #9, 'Occurs');
  for j := 0 to Taille_Spectrum do
  begin
    Classes := ((j + 0.5) * QuantumRough + LowG);
    Writeln(ResultFile, Classes:8:3, Cumul_Spectrum[j]:10);
  end;
  R := R_Calculation(Cumul_FlightTime, Cumul_Spectrum);
  FlightTimeLabel.Caption:=Format('Flight time = %5.1f h',[Cumul_FlightTime]);
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
