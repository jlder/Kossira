program EASA_Kossira_Oper;

uses
  Vcl.Forms,
  UAPropos in 'UAPropos.PAS' {OKRightDlg},
  UBatch_Oper in 'UBatch_Oper.pas' {BatchForm},
  UConfAesa_Oper in 'UConfAesa_Oper.pas' {ConfForm},
  UDoc in 'UDoc.pas' {DocForm},
  UMainAESA_Oper in 'UMainAESA_Oper.pas' {MainForm},
  UFFT in 'UFFT.pas',
  UButterworth in 'UButterworth.pas',
  USort_Oper in 'USort_Oper.pas',
  UDecodeWIT_oper in 'UDecodeWIT_oper.pas',
  UOndelette in 'UOndelette.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TOKRightDlg, OKRightDlg);
  Application.CreateForm(TBatchForm, BatchForm);
  Application.CreateForm(TDocForm, DocForm);
  Application.Run;
end.
