unit UConf;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls;

type
  TConfForm = class(TForm)
    Panel1: TPanel;
    ClassNumbersLabeledEdit: TLabeledEdit;
    UnderSampleLabeledEdit: TLabeledEdit;
    HighgLabeledEdit: TLabeledEdit;
    LowgLabeledEdit: TLabeledEdit;
    Label1: TLabel;
    QuantumLabel: TLabel;
    ValidationButton: TButton;
    Panel2: TPanel;
    FrstLabeledEdit: TLabeledEdit;
    dtLabeledEdit: TLabeledEdit;
    ShowDataCheckBox: TCheckBox;
    DistCdGxLabeledEdit: TLabeledEdit;
    DistCdGzLabeledEdit: TLabeledEdit;
    FifoDepthLabeledEdit: TLabeledEdit;
    procedure ValidationButtonClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  ConfForm: TConfForm;
  Quantum, QuantumRough : Extended;
  HighG, LowG, Dynamique:Extended;
  ClassNumbers, UnderSample:Integer;
  deltaT,distCdGx,distCdGz:Extended;

implementation

{$R *.dfm}

procedure TConfForm.ValidationButtonClick(Sender: TObject);

begin
HighG:=StrToFloat(HighgLabeledEdit.Text);
LowG:=StrToFloat(LowgLabeledEdit.Text);
ClassNumbers:=StrToInt(ClassNumbersLabeledEdit.Text);
UnderSample:=StrToInt(UnderSampleLabeledEdit.Text);
distCdGx:=StrToFloat(DistCdGxLabeledEdit.Text);
distCdGz:=StrToFloat(DistCdGzLabeledEdit.Text);
deltaT := StrToFloat(ConfForm.dtLabeledEdit.Text);

Dynamique:=HighG-LowG;
Quantum:=Dynamique/ClassNumbers;
QuantumRough:=Dynamique/UnderSample;
QuantumLabel.Caption := Format('%5.3f',[Quantum*1000.0]);
Close;
end;

end.
