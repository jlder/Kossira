program EASA_Kossira;

{$R 'InfoVersion.res' 'InfoVersion.rc'}

uses
  Vcl.Forms,
  UMainAESA in 'UMainAESA.pas' {MainForm},
  UConf in 'UConf.pas' {ConfForm},
  FilterButterworth in 'FilterButterworth.pas',
  UAPropos in 'UAPropos.PAS' {OKRightDlg},
  UDoc in 'UDoc.pas' {DocForm},
  UFifoSingle in 'UFifoSingle.pas',
  UFiltrages_AB in 'UFiltrages_AB.pas' {Form3},
  UBatch in 'UBatch.pas' {BatchForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfForm, ConfForm);
  Application.CreateForm(TOKRightDlg, OKRightDlg);
  Application.CreateForm(TDocForm, DocForm);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TBatchForm, BatchForm);
  Application.Run;
end.
