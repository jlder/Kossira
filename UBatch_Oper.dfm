object BatchForm: TBatchForm
  Left = 0
  Top = 0
  Caption = 'Batch'
  ClientHeight = 273
  ClientWidth = 930
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 930
    Height = 257
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object Label1: TLabel
      Left = 24
      Top = 19
      Width = 54
      Height = 15
      Caption = 'Directory :'
    end
    object Label2: TLabel
      Left = 432
      Top = 19
      Width = 47
      Height = 15
      Caption = 'Files list :'
    end
    object OverLabel: TLabel
      Left = 216
      Top = 163
      Width = 81
      Height = 45
      Caption = 'Over!'
      Color = clGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -32
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Visible = False
    end
    object FlightTimeLabel: TLabel
      Left = 398
      Top = 163
      Width = 74
      Height = 15
      Caption = 'FlightTime (h)'
    end
    object RLabel: TLabel
      Left = 398
      Top = 184
      Width = 7
      Height = 15
      Caption = 'R'
    end
    object DirectoryListBox1: TDirectoryListBox
      Left = 24
      Top = 75
      Width = 145
      Height = 97
      TabOrder = 0
      OnChange = DirectoryListBox1Change
    end
    object ListBoxFiles: TListBox
      Left = 216
      Top = 40
      Width = 641
      Height = 97
      ItemHeight = 15
      TabOrder = 1
    end
    object RunButton: TButton
      Left = 720
      Top = 9
      Width = 137
      Height = 25
      Caption = 'Run batch and wait'
      TabOrder = 2
      OnClick = RunButtonClick
    end
    object DriveComboBox1: TDriveComboBox
      Left = 24
      Top = 48
      Width = 89
      Height = 21
      DirList = DirectoryListBox1
      TabOrder = 3
    end
  end
end
