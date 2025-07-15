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

uses System.Types;

procedure TBatchForm.FillFileList(const Directory: string);
var
  Files: TStringDynArray;
  FileName: string;
begin
  ListBoxFiles.Clear;
  Files := TDirectory.GetFiles(Directory, 'bin*.TXT');
  // Adapt. masque selon vos fichiers
  for FileName in Files do
    ListBoxFiles.Items.Add(FileName);
end;

procedure TBatchForm.RunButtonClick(Sender: TObject);
Var
  i: Integer;
begin
  OverLabel.Visible:=False;
  for i := 0 to ListBoxFiles.Items.Count - 1 do
  begin
    ListBoxFiles.ItemIndex := i; // Surligne le fichier courant
    ListBoxFiles.TopIndex := i; // Fait défiler la liste si besoin
    Application.ProcessMessages; // Rafraîchit l'IHM
    Sleep(1000);
    // TraiterFichier(ListBoxFiles.Items[i]); // Traitement personnalisé
  end;
  ListBoxFiles.ItemIndex :=-1;
  OverLabel.Visible:=True;
end;

procedure TBatchForm.DirectoryListBox1Change(Sender: TObject);
begin
  Repertoire := DirectoryListBox1.Directory;
  FillFileList(Repertoire);
end;

end.
