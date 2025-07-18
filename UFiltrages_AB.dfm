object Form3: TForm3
  Left = 0
  Top = 0
  Caption = ' Alpha/Beta filters'
  ClientHeight = 166
  ClientWidth = 267
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 267
    Height = 166
    Align = alClient
    Caption = 'Filtrage constants'
    TabOrder = 0
    VerticalAlignment = taAlignTop
    ExplicitWidth = 348
    ExplicitHeight = 129
    object NAccelLabeledEdit: TLabeledEdit
      Left = 13
      Top = 39
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta pneumatique CAS.'
      EditLabel.Width = 40
      EditLabel.Height = 13
      EditLabel.Caption = 'N Accelz'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = '38'
    end
    object OutlierLabeledEdit: TLabeledEdit
      Left = 93
      Top = 39
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta barom'#233'trique statique.'
      EditLabel.Width = 32
      EditLabel.Height = 13
      EditLabel.Caption = 'Outlier'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '10.0'
    end
    object NMinLabeledEdit: TLabeledEdit
      Left = 149
      Top = 39
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 16
      EditLabel.Height = 13
      EditLabel.Caption = 'Min'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '-4.0'
    end
    object NMaxLabeledEdit: TLabeledEdit
      Left = 205
      Top = 39
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 20
      EditLabel.Height = 13
      EditLabel.Caption = 'Max'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '6.0'
    end
    object NGyroLabeledEdit: TLabeledEdit
      Left = 13
      Top = 124
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta pneumatique CAS.'
      EditLabel.Width = 33
      EditLabel.Height = 13
      EditLabel.Caption = 'N Gyro'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      Text = '7'
    end
    object GOutlierLabeledEdit: TLabeledEdit
      Left = 93
      Top = 124
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta barom'#233'trique statique.'
      EditLabel.Width = 32
      EditLabel.Height = 13
      EditLabel.Caption = 'Outlier'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      Text = '1.0'
    end
    object GMinLabeledEdit: TLabeledEdit
      Left = 149
      Top = 124
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 16
      EditLabel.Height = 13
      EditLabel.Caption = 'Min'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Text = '-4.0'
    end
    object GMaxLabeledEdit: TLabeledEdit
      Left = 205
      Top = 124
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 20
      EditLabel.Height = 13
      EditLabel.Caption = 'Max'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = '4.0'
    end
    object NAccelxLabeledEdit: TLabeledEdit
      Left = 13
      Top = 79
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta pneumatique CAS.'
      EditLabel.Width = 41
      EditLabel.Height = 13
      EditLabel.Caption = 'N Accelx'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      Text = '4000'
    end
    object LabeledEdit2: TLabeledEdit
      Left = 93
      Top = 79
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta barom'#233'trique statique.'
      EditLabel.Width = 32
      EditLabel.Height = 13
      EditLabel.Caption = 'Outlier'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      Text = '10.0'
    end
    object LabeledEdit3: TLabeledEdit
      Left = 149
      Top = 79
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 16
      EditLabel.Height = 13
      EditLabel.Caption = 'Min'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      Text = '-4.0'
    end
    object LabeledEdit4: TLabeledEdit
      Left = 205
      Top = 79
      Width = 33
      Height = 21
      Hint = 'Filtrage Alpha/Beta module n et roll.'
      EditLabel.Width = 20
      EditLabel.Height = 13
      EditLabel.Caption = 'Max'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
      Text = '6.0'
    end
  end
end
