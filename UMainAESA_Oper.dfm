object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Determination of load spectra'
  ClientHeight = 521
  ClientWidth = 1315
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1315
    Height = 49
    Align = alTop
    TabOrder = 0
    VerticalAlignment = taAlignTop
    DesignSize = (
      1315
      49)
    object Label1: TLabel
      Left = 912
      Top = 7
      Width = 38
      Height = 15
      Caption = 'nq_avg'
    end
    object RunningLabel: TLabel
      Left = 1127
      Top = 3
      Width = 77
      Height = 15
      Anchors = [akTop, akRight]
      Caption = 'Waiting orders'
      ExplicitLeft = 1112
    end
    object RLabel: TLabel
      Left = 1024
      Top = 28
      Width = 7
      Height = 15
      Caption = 'R'
    end
    object FlightTimeLabel: TLabel
      Left = 1024
      Top = 7
      Width = 74
      Height = 15
      Caption = 'FlightTime (h)'
    end
    object Label2: TLabel
      Left = 912
      Top = 28
      Width = 38
      Height = 15
      Caption = 'nq_avg'
    end
    object TimeLabel: TLabel
      Left = 730
      Top = 1
      Width = 26
      Height = 15
      Caption = 'Time'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object AccelLabel: TLabel
      Left = 730
      Top = 22
      Width = 29
      Height = 15
      Caption = 'Accel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object GyroLabel: TLabel
      Left = 778
      Top = 1
      Width = 25
      Height = 15
      Caption = 'Gyro'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object AttitudeLabel: TLabel
      Left = 778
      Top = 22
      Width = 43
      Height = 15
      Caption = 'Attitude'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object FileNameLabeledEdit: TLabeledEdit
      Left = 268
      Top = 20
      Width = 101
      Height = 23
      EditLabel.Width = 50
      EditLabel.Height = 15
      EditLabel.Margins.Left = 12
      EditLabel.Margins.Top = 12
      EditLabel.Margins.Right = 12
      EditLabel.Margins.Bottom = 12
      EditLabel.Caption = 'FileName'
      TabOrder = 0
      Text = 'WIT00060.TXT'
    end
    object RunButton: TButton
      Left = 1238
      Top = 0
      Width = 35
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'Run'
      TabOrder = 1
      OnClick = RunButtonClick
    end
    object ProgressBar1: TProgressBar
      Left = 406
      Top = 26
      Width = 311
      Height = 17
      TabOrder = 2
    end
    object GraphCheckBox: TCheckBox
      Left = 406
      Top = 3
      Width = 59
      Height = 17
      Caption = 'Graph'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object SortCheckBox: TCheckBox
      Left = 534
      Top = 3
      Width = 59
      Height = 17
      Caption = 'Sort'
      TabOrder = 4
    end
    object DXLabeledEdit: TLabeledEdit
      Left = 832
      Top = 20
      Width = 41
      Height = 23
      EditLabel.Width = 63
      EditLabel.Height = 15
      EditLabel.Margins.Left = 6
      EditLabel.Margins.Top = 6
      EditLabel.Margins.Right = 6
      EditLabel.Margins.Bottom = 6
      EditLabel.Caption = 'DX (Integer)'
      TabOrder = 5
      Text = '10'
    end
    object Taxi_IncludedCheckBox: TCheckBox
      Left = 599
      Top = 3
      Width = 98
      Height = 17
      Caption = 'Taxi included'
      TabOrder = 6
    end
    object TestButterButton: TButton
      Left = 1236
      Top = 22
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'TestButter'
      TabOrder = 7
    end
    object RepertoireLabeledEdit: TLabeledEdit
      Left = 4
      Top = 20
      Width = 253
      Height = 23
      EditLabel.Width = 80
      EditLabel.Height = 15
      EditLabel.Margins.Left = 12
      EditLabel.Margins.Top = 12
      EditLabel.Margins.Right = 12
      EditLabel.Margins.Bottom = 12
      EditLabel.Caption = 'DirectoryName'
      TabOrder = 8
      Text = 'D:\Data\Jean_Luc_Derouineau\AESA\ASH25\'
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 49
    Width = 1315
    Height = 472
    ActivePage = GraphTabSheet
    Align = alClient
    TabOrder = 1
    object DataTabSheet: TTabSheet
      Caption = 'Data'
      object Memo2: TMemo
        Left = 274
        Top = 0
        Width = 144
        Height = 442
        Align = alLeft
        Lines.Strings = (
          'Resampled Data'
          'Time    Value')
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object Memo3: TMemo
        Left = 137
        Top = 0
        Width = 137
        Height = 442
        Align = alLeft
        Lines.Strings = (
          'Sampled Data'
          'Time    Value')
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object Memo4: TMemo
        Left = 0
        Top = 0
        Width = 137
        Height = 442
        Align = alLeft
        Lines.Strings = (
          'Raw Data'
          'Time    Value')
        ScrollBars = ssVertical
        TabOrder = 2
      end
      object Memo1: TMemo
        Left = 418
        Top = 0
        Width = 167
        Height = 442
        Align = alLeft
        Lines.Strings = (
          'Kossira')
        TabOrder = 3
      end
    end
    object GraphTabSheet: TTabSheet
      Caption = 'Graph'
      ImageIndex = 1
      object Chart1: TChart
        Left = 0
        Top = 0
        Width = 1307
        Height = 442
        Legend.Alignment = laBottom
        Legend.FontSeriesColor = True
        Legend.LegendStyle = lsSeries
        Legend.Symbol.Continuous = True
        Legend.Symbol.Emboss.Smooth = False
        Legend.Symbol.Shadow.Visible = False
        Legend.Symbol.Squared = False
        Legend.Symbol.UseImages = False
        Legend.TextStyle = ltsPlain
        Legend.Title.Visible = False
        Title.Text.Strings = (
          'TChart')
        LeftAxis.Automatic = False
        LeftAxis.AutomaticMaximum = False
        LeftAxis.AutomaticMinimum = False
        LeftAxis.Maximum = 30.000000000000000000
        RightAxis.Automatic = False
        RightAxis.AutomaticMaximum = False
        RightAxis.AutomaticMinimum = False
        RightAxis.Increment = 2.000000000000000000
        RightAxis.Maximum = 0.100000000000000000
        View3D = False
        Align = alClient
        TabOrder = 0
        OnMouseDown = Chart1MouseDown
        DefaultCanvas = ''
        ColorPaletteIndex = 13
        object Series3: TLineSeries
          HoverElement = [heCurrent]
          Selected.Hover.Visible = False
          SeriesColor = clFuchsia
          Title = 'StdDevValueAzh'
          Brush.BackColor = clDefault
          LinePen.Color = clFuchsia
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series6: TLineSeries
          HoverElement = [heCurrent]
          Selected.Hover.Visible = False
          SeriesColor = 16744448
          Title = 'StdDevValueAzd'
          Brush.BackColor = clDefault
          LinePen.Color = 16744448
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series1: TLineSeries
          HoverElement = [heCurrent]
          SeriesColor = clGreen
          Title = 'StdDevValueAxh'
          Brush.BackColor = clDefault
          ClickableLine = False
          Pointer.HorizSize = 1
          Pointer.InflateMargins = True
          Pointer.Pen.Visible = False
          Pointer.Style = psRectangle
          Pointer.VertSize = 1
          Stairs = True
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series2: TPointSeries
          HoverElement = [heCurrent]
          Marks.Callout.Length = 8
          SeriesColor = clRed
          Title = 'Ax (m/s'#178')'
          ClickableLine = False
          Pointer.HorizSize = 2
          Pointer.InflateMargins = True
          Pointer.Pen.Visible = False
          Pointer.Style = psRectangle
          Pointer.VertSize = 2
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series7: TLineSeries
          HoverElement = [heCurrent]
          SeriesColor = 33023
          Title = 'Pitch (rd)'
          Brush.BackColor = clDefault
          Pointer.Brush.Color = 16744448
          Pointer.HorizSize = 2
          Pointer.InflateMargins = True
          Pointer.Pen.Visible = False
          Pointer.Style = psRectangle
          Pointer.VertSize = 2
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series8: TLineSeries
          HoverElement = [heCurrent]
          SeriesColor = 4259584
          Brush.BackColor = clDefault
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
      end
    end
    object Markov1TabSheet: TTabSheet
      Caption = 'Markov1'
      ImageIndex = 2
      object MarcovStringGrid1: TStringGrid
        Left = 0
        Top = 0
        Width = 1233
        Height = 442
        Align = alLeft
        ColCount = 33
        DefaultColWidth = 36
        DefaultRowHeight = 20
        DrawingStyle = gdsClassic
        FixedColor = clMoneyGreen
        RowCount = 33
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goFixedRowDefAlign]
        TabOrder = 0
        OnDrawCell = MarcovStringGrid1DrawCell
      end
    end
    object Marcov2TabSheet: TTabSheet
      Caption = 'Marcov2'
      ImageIndex = 3
      object MarcovStringGrid2: TStringGrid
        Left = 0
        Top = 0
        Width = 1233
        Height = 442
        Align = alLeft
        ColCount = 33
        Ctl3D = False
        DefaultColWidth = 36
        DefaultRowHeight = 20
        DrawingStyle = gdsClassic
        FixedColor = clMoneyGreen
        RowCount = 33
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goFixedRowDefAlign]
        ParentCtl3D = False
        TabOrder = 0
        OnDrawCell = MarcovStringGrid2DrawCell
      end
      object spectrumStringGrid: TStringGrid
        Left = 1186
        Top = 0
        Width = 121
        Height = 442
        Align = alRight
        ColCount = 2
        DefaultColWidth = 63
        DefaultRowHeight = 20
        DrawingStyle = gdsClassic
        FixedColor = clMoneyGreen
        RowCount = 33
        TabOrder = 1
      end
    end
    object SpectraTabSheet: TTabSheet
      Caption = 'Spectra'
      ImageIndex = 4
      object Chart2: TChart
        Left = 0
        Top = 0
        Width = 1307
        Height = 442
        Legend.Alignment = laBottom
        Legend.LegendStyle = lsSeries
        Title.Text.Strings = (
          'Spectra')
        BottomAxis.Automatic = False
        BottomAxis.AutomaticMaximum = False
        BottomAxis.AutomaticMinimum = False
        BottomAxis.AxisValuesFormat = '#"0"  E+0'
        BottomAxis.Logarithmic = True
        BottomAxis.Maximum = 10000000.000000000000000000
        BottomAxis.Minimum = 1.000000000000000000
        BottomAxis.Title.Caption = 'Spectra (-)'
        LeftAxis.Title.Caption = 'Classe (g)'
        View3D = False
        Align = alClient
        TabOrder = 0
        DefaultCanvas = ''
        ColorPaletteIndex = 13
        object Series4: TLineSeries
          HoverElement = [heCurrent]
          Title = 'spectra KOSSIRA ICAS-82-2.8.2.pdf'
          Brush.BackColor = clDefault
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series5: TLineSeries
          HoverElement = [heCurrent]
          SeriesColor = clRed
          Shadow.Visible = False
          Title = 'FileName'
          Brush.BackColor = clDefault
          Dark3D = False
          InflateMargins = False
          LinePen.Width = 3
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
      end
    end
  end
  object FileOpenTextFileDialog: TOpenTextFileDialog
    Ctl3D = False
    Options = [ofReadOnly, ofHideReadOnly, ofNoChangeDir, ofNoValidate, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 1056
    Top = 72
  end
  object MainMenu1: TMainMenu
    Left = 1200
    Top = 88
    object Fichier1: TMenuItem
      Caption = 'File'
      object Open: TMenuItem
        Caption = 'Open'
        OnClick = OpenClick
      end
      object Save: TMenuItem
        Caption = 'Save'
        OnClick = SaveClick
      end
      object SaveAs: TMenuItem
        Caption = 'Save As...'
        OnClick = SaveAsClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Print: TMenuItem
        Caption = 'Print Graph'
        OnClick = PrintClick
      end
      object PrintSpectra: TMenuItem
        Caption = 'Print Spectra'
        OnClick = PrintSpectraClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Quit: TMenuItem
        Caption = 'Quit'
        OnClick = QuitClick
      end
    end
    object Run1: TMenuItem
      Caption = 'Run'
      object Run: TMenuItem
        Caption = 'Run'
        OnClick = RunClick
      end
      object RunConfiguration: TMenuItem
        Caption = 'Configuration'
        OnClick = RunConfigurationClick
      end
      object RunBatch: TMenuItem
        Caption = 'Batch'
        OnClick = RunBatchClick
      end
    end
    object Help: TMenuItem
      Caption = 'Help'
      object Help2: TMenuItem
        Caption = 'Doc'
        OnClick = Help2Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object About: TMenuItem
        Caption = 'About'
        OnClick = AboutClick
      end
    end
  end
  object SaveDialog1: TSaveDialog
    FileName = 'Kossira.txt'
    Left = 1056
    Top = 136
  end
end
