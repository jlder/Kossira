object ConfForm: TConfForm
  Left = 0
  Top = 0
  Caption = 'Configuration'
  ClientHeight = 548
  ClientWidth = 653
  Color = clBtnFace
  ParentFont = True
  OnCreate = FormCreate
  DesignSize = (
    653
    548)
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
      Left = 416
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
        'Order4'
        'THOrder4')
      ParentFont = False
      TabOrder = 9
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 209
    Width = 653
    Height = 160
    Align = alTop
    Caption = 'Takeoff and landing threshold'
    TabOrder = 2
    VerticalAlignment = taAlignTop
    object DecelerationLabeledEdit: TLabeledEdit
      Left = 225
      Top = 42
      Width = 40
      Height = 23
      EditLabel.Width = 84
      EditLabel.Height = 15
      EditLabel.Caption = 'Deceleration (g)'
      TabOrder = 0
      Text = '0.15'
    end
    object PullUpLabeledEdit: TLabeledEdit
      Left = 24
      Top = 42
      Width = 49
      Height = 23
      EditLabel.Width = 52
      EditLabel.Height = 15
      EditLabel.Caption = 'Pullup (g)'
      TabOrder = 1
      Text = '0.25'
    end
    object PullUpDelayLabeledEdit: TLabeledEdit
      Left = 24
      Top = 90
      Width = 73
      Height = 23
      EditLabel.Width = 81
      EditLabel.Height = 15
      EditLabel.Caption = 'Pullup delay (s)'
      TabOrder = 2
      Text = '10.0'
    end
    object DecDelayLabeledEdit: TLabeledEdit
      Left = 224
      Top = 91
      Width = 41
      Height = 23
      EditLabel.Width = 78
      EditLabel.Height = 15
      EditLabel.Caption = 'Dectimeout (s)'
      TabOrder = 3
      Text = '20'
    end
    object TouchLabeledEdit: TLabeledEdit
      Left = 464
      Top = 42
      Width = 49
      Height = 23
      EditLabel.Width = 50
      EditLabel.Height = 15
      EditLabel.Caption = 'Touch (g)'
      TabOrder = 4
      Text = '0.5'
    end
    object IntegratorThresholdLabeledEdit: TLabeledEdit
      Left = 128
      Top = 42
      Width = 49
      Height = 23
      EditLabel.Width = 70
      EditLabel.Height = 15
      EditLabel.Caption = 'Integrator (g)'
      TabOrder = 5
      Text = '5'
    end
    object NewFlightDelayLabeledEdit: TLabeledEdit
      Left = 578
      Top = 90
      Width = 41
      Height = 23
      EditLabel.Width = 70
      EditLabel.Height = 15
      EditLabel.Caption = 'InterFlight (s)'
      TabOrder = 6
      Text = '500'
    end
    object PullUpTimeOutLabeledEdit: TLabeledEdit
      Left = 24
      Top = 131
      Width = 73
      Height = 23
      EditLabel.Width = 99
      EditLabel.Height = 15
      EditLabel.Caption = 'Pullup TimeOut (s)'
      TabOrder = 7
      Text = '20.0'
    end
    object IntegDelayLabeledEdit: TLabeledEdit
      Left = 128
      Top = 90
      Width = 49
      Height = 23
      EditLabel.Width = 72
      EditLabel.Height = 15
      EditLabel.Caption = 'IntegDelay (s)'
      TabOrder = 8
      Text = '5'
    end
    object MinFlightDurationLabeledEdit: TLabeledEdit
      Left = 328
      Top = 90
      Width = 41
      Height = 23
      EditLabel.Width = 113
      EditLabel.Height = 15
      EditLabel.Caption = 'MinFlightDuration (s)'
      TabOrder = 9
      Text = '500'
    end
    object IntegTouchDelayLabeledEdit: TLabeledEdit
      Left = 464
      Top = 90
      Width = 49
      Height = 23
      EditLabel.Width = 72
      EditLabel.Height = 15
      EditLabel.Caption = 'IntegDelay (s)'
      TabOrder = 10
      Text = '5'
    end
    object TouchTimeOutLabeledEdit: TLabeledEdit
      Left = 464
      Top = 131
      Width = 41
      Height = 23
      EditLabel.Width = 96
      EditLabel.Height = 15
      EditLabel.Caption = 'Touchtimeout (s)T'
      TabOrder = 11
      Text = '20'
    end
  end
  object RepereRadioGroup: TRadioGroup
    Left = 485
    Top = 482
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
    TabOrder = 3
    StyleName = 'Windows'
  end
  object DataCheckListBox: TCheckListBox
    Left = 224
    Top = 463
    Width = 121
    Height = 66
    ItemHeight = 15
    Items.Strings = (
      'Time'
      'Accelerometer'
      'Gyrometer'
      'Attitude')
    TabOrder = 4
  end
  object Panel4: TPanel
    Left = 0
    Top = 369
    Width = 653
    Height = 80
    Align = alTop
    Caption = 'Fusion parameters'
    TabOrder = 5
    VerticalAlignment = taAlignTop
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
  end
end
