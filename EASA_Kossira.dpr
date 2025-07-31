program EASA_Kossira;

uses
  Vcl.Forms,
  UAPropos in 'UAPropos.PAS' {OKRightDlg},
  UBatch in 'UBatch.pas' {BatchForm},
  UConfAesa in 'UConfAesa.pas' {ConfForm},
  UDoc in 'UDoc.pas' {DocForm},
  UMainAESA in 'UMainAESA.pas' {MainForm},
  UFFT in 'UFFT.pas',
  UButterworth in 'UButterworth.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TOKRightDlg, OKRightDlg);
  Application.CreateForm(TBatchForm, BatchForm);
  Application.CreateForm(TConfForm, ConfForm);
  Application.CreateForm(TDocForm, DocForm);
  Application.Run;
end.
