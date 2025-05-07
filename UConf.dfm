object ConfForm: TConfForm
  Left = 0
  Top = 0
  Caption = 'Configuration'
  ClientHeight = 160
  ClientWidth = 626
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 626
    Height = 81
    Align = alTop
    Caption = 'Discretization'
    TabOrder = 0
    VerticalAlignment = taAlignTop
    object Label1: TLabel
      Left = 432
      Top = 24
      Width = 80
      Height = 15
      Caption = 'Quantum (mg)'
    end
    object QuantumLabel: TLabel
      Left = 432
      Top = 45
      Width = 6
      Height = 15
      Caption = '1'
    end
    object ClassNumbersLabeledEdit: TLabeledEdit
      Left = 16
      Top = 40
      Width = 73
      Height = 23
      EditLabel.Width = 77
      EditLabel.Height = 15
      EditLabel.Caption = 'Class numbers'
      TabOrder = 0
      Text = '1024'
    end
    object UnderSampleLabeledEdit: TLabeledEdit
      Left = 120
      Top = 40
      Width = 73
      Height = 23
      EditLabel.Width = 74
      EditLabel.Height = 15
      EditLabel.Caption = 'Under Sample'
      TabOrder = 1
      Text = '32'
    end
    object HighgLabeledEdit: TLabeledEdit
      Left = 224
      Top = 40
      Width = 73
      Height = 23
      EditLabel.Width = 81
      EditLabel.Height = 15
      EditLabel.Caption = 'High g number'
      TabOrder = 2
      Text = '+6'
    end
    object LowgLabeledEdit: TLabeledEdit
      Left = 320
      Top = 40
      Width = 73
      Height = 23
      EditLabel.Width = 77
      EditLabel.Height = 15
      EditLabel.Caption = 'Low g number'
      TabOrder = 3
      Text = '-4'
    end
    object ValidationButton: TButton
      Left = 544
      Top = 39
      Width = 75
      Height = 25
      Caption = 'Validation'
      TabOrder = 4
      OnClick = ValidationButtonClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 81
    Width = 626
    Height = 72
    Align = alTop
    Caption = 'Filtering'
    TabOrder = 1
    VerticalAlignment = taAlignTop
    object FrstLabeledEdit: TLabeledEdit
      Left = 16
      Top = 33
      Width = 73
      Height = 23
      EditLabel.Width = 78
      EditLabel.Height = 15
      EditLabel.Caption = 'First order (Hz)'
      TabOrder = 0
      Text = '5'
    end
    object dtLabeledEdit: TLabeledEdit
      Left = 120
      Top = 33
      Width = 73
      Height = 23
      EditLabel.Width = 66
      EditLabel.Height = 15
      EditLabel.Cursor = crAppStart
      EditLabel.Caption = 'Sample time'
      TabOrder = 1
      Text = '0.025'
    end
    object ShowDataCheckBox: TCheckBox
      Left = 544
      Top = 32
      Width = 75
      Height = 17
      Caption = 'Show data'
      TabOrder = 2
    end
    object DistCdGxLabeledEdit: TLabeledEdit
      Left = 224
      Top = 33
      Width = 73
      Height = 23
      EditLabel.Width = 49
      EditLabel.Height = 15
      EditLabel.Cursor = crAppStart
      EditLabel.Caption = 'DistxCdG'
      TabOrder = 3
      Text = '0'
    end
    object DistCdGzLabeledEdit: TLabeledEdit
      Left = 320
      Top = 33
      Width = 73
      Height = 23
      EditLabel.Width = 48
      EditLabel.Height = 15
      EditLabel.Cursor = crAppStart
      EditLabel.Caption = 'DistzCdG'
      TabOrder = 4
      Text = '1.69'
    end
    object FifoDepthLabeledEdit: TLabeledEdit
      Left = 432
      Top = 33
      Width = 57
      Height = 23
      EditLabel.Width = 55
      EditLabel.Height = 15
      EditLabel.Caption = 'Fifo Depth'
      TabOrder = 5
      Text = '7'
    end
  end
end
