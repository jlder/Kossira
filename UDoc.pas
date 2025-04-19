unit UDoc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TDocForm = class(TForm)
    Bevel1: TBevel;
    Memo1: TMemo;
    OkButton: TButton;
    procedure OkButtonClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  DocForm: TDocForm;

implementation

{$R *.dfm}

procedure TDocForm.OkButtonClick(Sender: TObject);
begin
Close;
end;

end.
