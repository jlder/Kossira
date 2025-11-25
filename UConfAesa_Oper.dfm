object ConfForm: TConfForm
  Left = 0
  Top = 0
  Caption = 'Configuration Oper'
  ClientHeight = 639
  ClientWidth = 653
  Color = clBtnFace
  ParentFont = True
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 653
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
    object ShowDataCheckBox: TCheckBox
      Left = 544
      Top = 16
      Width = 97
      Height = 17
      Caption = 'ShowData'
      TabOrder = 5
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 81
    Width = 653
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
      Text = '4'
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
      Text = '6'
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
    object ButterWorthRadioGroup: TRadioGroup
      Left = 408
      Top = 6
      Width = 105
      Height = 116
      Caption = 'ButterWorth order'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 2
      Items.Strings = (
        'Order 0'
        'Order2'
        'Order4')
      ParentFont = False
      TabOrder = 9
    end
    object FcRadioGroup: TRadioGroup
      Left = 519
      Top = 6
      Width = 105
      Height = 116
      Caption = 'Freq coupure'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 2
      Items.Strings = (
        '1 Hz'
        '2 Hz'
        '3 Hz'
        '4 Hz'
        '5 Hz')
      ParentFont = False
      TabOrder = 10
    end
    object Enveloppe_TAuLabeledEdit: TLabeledEdit
      Left = 16
      Top = 90
      Width = 73
      Height = 23
      EditLabel.Width = 77
      EditLabel.Height = 15
      EditLabel.Caption = 'Time cste (ms)'
      TabOrder = 11
      Text = '20'
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 209
    Width = 653
    Height = 328
    Align = alTop
    Caption = 'Takeoff and landing threshold'
    TabOrder = 2
    VerticalAlignment = taAlignTop
    object PullUpLabeledEdit: TLabeledEdit
      Left = 3
      Top = 34
      Width = 49
      Height = 23
      EditLabel.Width = 52
      EditLabel.Height = 15
      EditLabel.Caption = 'Pullup (g)'
      TabOrder = 0
      Text = '10'
    end
    object IntegratorThresholdLabeledEdit: TLabeledEdit
      Left = 115
      Top = 34
      Width = 49
      Height = 23
      EditLabel.Width = 70
      EditLabel.Height = 15
      EditLabel.Caption = 'Integrator (g)'
      TabOrder = 1
      Text = '1.5'
    end
    object DecelerationLabeledEdit: TLabeledEdit
      Left = 212
      Top = 34
      Width = 40
      Height = 23
      EditLabel.Width = 84
      EditLabel.Height = 15
      EditLabel.Caption = 'Deceleration (g)'
      TabOrder = 2
      Text = '8'
    end
    object MinFlightDurationLabeledEdit: TLabeledEdit
      Left = 307
      Top = 34
      Width = 41
      Height = 23
      EditLabel.Width = 113
      EditLabel.Height = 15
      EditLabel.Caption = 'MinFlightDuration (s)'
      TabOrder = 3
      Text = '600'
    end
    object TouchLabeledEdit: TLabeledEdit
      Left = 451
      Top = 34
      Width = 49
      Height = 23
      EditLabel.Width = 50
      EditLabel.Height = 15
      EditLabel.Caption = 'Touch (g)'
      TabOrder = 4
      Text = '17.5'
    end
    object StopLabeledEdit: TLabeledEdit
      Left = 556
      Top = 34
      Width = 40
      Height = 23
      EditLabel.Width = 69
      EditLabel.Height = 15
      EditLabel.Caption = 'StopLevel (g)'
      TabOrder = 5
      Text = '0.01'
    end
    object NewFlightDelayLabeledEdit: TLabeledEdit
      Left = 555
      Top = 82
      Width = 41
      Height = 23
      EditLabel.Width = 70
      EditLabel.Height = 15
      EditLabel.Caption = 'InterFlight (s)'
      TabOrder = 6
      Text = '60'
    end
    object PullUpDelayLabeledEdit: TLabeledEdit
      Left = 11
      Top = 82
      Width = 73
      Height = 23
      EditLabel.Width = 81
      EditLabel.Height = 15
      EditLabel.Caption = 'Pullup delay (s)'
      TabOrder = 7
      Text = '30'
    end
    object FilterTypeRadioGroup: TRadioGroup
      Left = 224
      Top = 126
      Width = 105
      Height = 116
      Caption = 'Filtering type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 2
      Items.Strings = (
        'Butterworth'
        'FFT'
        'Ondelette')
      ParentFont = False
      TabOrder = 8
    end
    object OndeletteOrderRadioGroup: TRadioGroup
      Left = 376
      Top = 126
      Width = 105
      Height = 116
      Caption = 'ButterWorth order'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 1
      Items.Strings = (
        'Db2'
        'Db4'
        'Cf3')
      ParentFont = False
      TabOrder = 9
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 537
    Width = 653
    Height = 80
    Align = alTop
    Caption = 'Fusion parameters'
    TabOrder = 3
    VerticalAlignment = taAlignTop
    DesignSize = (
      653
      80)
    object w1LabeledEdit: TLabeledEdit
      Left = 16
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 15
      EditLabel.Height = 15
      EditLabel.Caption = 'w1'
      TabOrder = 0
      Text = '0'
    end
    object w2LabeledEdit: TLabeledEdit
      Left = 152
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 15
      EditLabel.Height = 15
      EditLabel.Caption = 'w2'
      TabOrder = 1
      Text = '0'
    end
    object w3LabeledEdit: TLabeledEdit
      Left = 296
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 15
      EditLabel.Height = 15
      EditLabel.Caption = 'w3'
      TabOrder = 2
      Text = '0'
    end
    object w4LabeledEdit: TLabeledEdit
      Left = 432
      Top = 42
      Width = 73
      Height = 23
      EditLabel.Width = 15
      EditLabel.Height = 15
      EditLabel.Caption = 'w4'
      TabOrder = 3
      Text = '1'
    end
    object RepereRadioGroup: TRadioGroup
      Left = 521
      Top = 28
      Width = 120
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
end
