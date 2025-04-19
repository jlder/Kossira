unit UAPropos;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TOKRightDlg = class(TForm)
    OKBtn: TButton;
    Bevel1: TBevel;
    Memo2: TMemo;
    procedure OKBtnClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  OKRightDlg: TOKRightDlg;

implementation

{$R *.dfm}

procedure TOKRightDlg.OKBtnClick(Sender: TObject);
begin
Close;
end;

end.
