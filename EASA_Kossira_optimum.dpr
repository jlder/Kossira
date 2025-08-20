program EASA_Kossira_optimum;

uses
  Vcl.Forms,
  UAPropos in 'UAPropos.PAS' {OKRightDlg},
  UBatch_Opt in 'UBatch_Opt.pas' {BatchForm},
  UConfAesa in 'UConfAesa.pas' {ConfForm},
  UDoc in 'UDoc.pas' {DocForm},
  UMainAESA_Opt in 'UMainAESA_Opt.pas' {MainForm},
  UFFT in 'UFFT.pas',
  UButterworth in 'UButterworth.pas',
  USort in 'USort.pas',
  UDecodeWIT_opt in 'UDecodeWIT_opt.pas';

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
