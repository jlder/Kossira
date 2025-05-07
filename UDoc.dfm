object DocForm: TDocForm
  Left = 0
  Top = 0
  Caption = 'Document'
  ClientHeight = 82
  ClientWidth = 381
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 337
    Height = 73
  end
  object Memo1: TMemo
    Left = 16
    Top = 16
    Width = 313
    Height = 49
    Lines.Strings = (
      'This application is designed upon the basis of :'
      'Determination of load spectra KOSSIRA ICAS-82-2.8.2.pdf')
    TabOrder = 0
  end
  object OkButton: TButton
    Left = 367
    Top = 8
    Width = 42
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 1
    OnClick = OkButtonClick
  end
end
