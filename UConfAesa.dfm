object ConfForm: TConfForm
  Left = 0
  Top = 0
  Caption = 'Configuration'
  ClientHeight = 377
  ClientWidth = 626
  Color = clBtnFace
  ParentFont = True
  DesignSize = (
    626
    377)
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
    Height = 128
    Align = alTop
    Caption = 'Filtering'
    TabOrder = 1
    VerticalAlignment = taAlignTop
    object dtLabeledEdit: TLabeledEdit
      Left = 16
      Top = 33
      Width = 73
      Height = 23
      EditLabel.Width = 66
      EditLabel.Height = 15
      EditLabel.Cursor = crAppStart
      EditLabel.Caption = 'Sample time'
      TabOrder = 0
      Text = '0.05'
    end
    object NAccelLabeledEdit: TLabeledEdit
      Left = 120
      Top = 33
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta pneumatique CAS.'
      EditLabel.Width = 46
      EditLabel.Height = 15
      EditLabel.Caption = 'N Accelz'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '6'
    end
    object OutlierLabeledEdit: TLabeledEdit
      Left = 200
      Top = 33
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta barom'#233'trique statique.'
      EditLabel.Width = 36
      EditLabel.Height = 15
      EditLabel.Caption = 'Outlier'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '10.0'
    end
    object NMinLabeledEdit: TLabeledEdit
      Left = 256
      Top = 33
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 21
      EditLabel.Height = 15
      EditLabel.Caption = 'Min'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '-4.0'
    end
    object NMaxLabeledEdit: TLabeledEdit
      Left = 312
      Top = 33
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 23
      EditLabel.Height = 15
      EditLabel.Caption = 'Max'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      Text = '6.0'
    end
    object NAccelxLabeledEdit: TLabeledEdit
      Left = 120
      Top = 73
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta pneumatique CAS.'
      EditLabel.Width = 47
      EditLabel.Height = 15
      EditLabel.Caption = 'N Accelx'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      Text = '18'
    end
    object LabeledEdit2: TLabeledEdit
      Left = 200
      Top = 73
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta barom'#233'trique statique.'
      EditLabel.Width = 36
      EditLabel.Height = 15
      EditLabel.Caption = 'Outlier'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Text = '10.0'
    end
    object LabeledEdit3: TLabeledEdit
      Left = 256
      Top = 73
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 21
      EditLabel.Height = 15
      EditLabel.Caption = 'Min'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = '-4.0'
    end
    object LabeledEdit4: TLabeledEdit
      Left = 312
      Top = 73
      Width = 33
      Height = 23
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 23
      EditLabel.Height = 15
      EditLabel.Caption = 'Max'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      Text = '6.0'
    end
  end
  object ShowDataCheckBox: TCheckBox
    Left = 40
    Top = 322
    Width = 97
    Height = 17
    Caption = 'ShowData'
    TabOrder = 2
  end
  object Panel3: TPanel
    Left = 0
    Top = 209
    Width = 626
    Height = 80
    Align = alTop
    Caption = 'Takeoff and landing threshold'
    TabOrder = 3
    VerticalAlignment = taAlignTop
    object DecelerationLabeledEdit: TLabeledEdit
      Left = 16
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 84
      EditLabel.Height = 15
      EditLabel.Caption = 'Deceleration (g)'
      TabOrder = 0
      Text = '0.2'
    end
    object PullUpLabeledEdit: TLabeledEdit
      Left = 152
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 52
      EditLabel.Height = 15
      EditLabel.Caption = 'Pullup (g)'
      TabOrder = 1
      Text = '1.0'
    end
    object PullUpDelayLabeledEdit: TLabeledEdit
      Left = 296
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 81
      EditLabel.Height = 15
      EditLabel.Caption = 'Pullup delay (s)'
      TabOrder = 2
      Text = '5'
    end
    object DecDelayLabeledEdit: TLabeledEdit
      Left = 432
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 113
      EditLabel.Height = 15
      EditLabel.Caption = 'Deceleration delay (s)'
      TabOrder = 3
      Text = '2'
    end
  end
  object RepereRadioGroup: TRadioGroup
    Left = 447
    Top = 322
    Width = 123
    Height = 36
    Margins.Top = 0
    Margins.Bottom = 0
    Anchors = [akTop, akRight]
    Caption = 'NED or ENU Frame'
    Columns = 2
    DefaultHeaderFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = 10
    HeaderFont.Name = 'Arial'
    HeaderFont.Pitch = fpFixed
    HeaderFont.Style = []
    HeaderFont.Quality = fqDraft
    ItemIndex = 1
    Items.Strings = (
      'NED'
      'ENU')
    ParentFont = False
    ShowFrame = False
    TabOrder = 4
    StyleName = 'Windows'
  end
end
