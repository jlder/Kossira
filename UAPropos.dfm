object OKRightDlg: TOKRightDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'A propos'
  ClientHeight = 79
  ClientWidth = 277
  Color = clBtnFace
  ParentFont = True
  Position = poScreenCenter
  TextHeight = 15
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 281
    Height = 129
    Shape = bsFrame
  end
  object OKBtn: TButton
    Left = 300
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object Memo2: TMemo
    Left = 0
    Top = 0
    Width = 277
    Height = 79
    Align = alClient
    Lines.Strings = (
      'This application is design by J.L. Derouineau '
      'and '
      'implemented with the collaboration of GF '
      'Mesnil')
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitWidth = 348
    ExplicitHeight = 170
  end
end
