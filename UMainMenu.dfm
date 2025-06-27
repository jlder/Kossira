object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Determination of load spectra'
  ClientHeight = 782
  ClientWidth = 1363
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1363
    Height = 49
    Align = alTop
    TabOrder = 0
    VerticalAlignment = taAlignTop
    DesignSize = (
      1363
      49)
    object Label1: TLabel
      Left = 744
      Top = 28
      Width = 38
      Height = 15
      Caption = 'nq_avg'
    end
    object RunningLabel: TLabel
      Left = 880
      Top = 28
      Width = 77
      Height = 15
      Caption = 'Waiting orders'
    end
    object FileNameLabeledEdit: TLabeledEdit
      Left = 4
      Top = 20
      Width = 362
      Height = 23
      EditLabel.Width = 50
      EditLabel.Height = 15
      EditLabel.Caption = 'FileName'
      TabOrder = 0
      Text = 'serial_20230613_103232.txt'
    end
    object StartLabeledEdit: TLabeledEdit
      Left = 384
      Top = 20
      Width = 65
      Height = 23
      EditLabel.Width = 50
      EditLabel.Height = 15
      EditLabel.Caption = 'StartTime'
      TabOrder = 1
      Text = '297.5'
    end
    object StopLabeledEdit: TLabeledEdit
      Left = 455
      Top = 20
      Width = 65
      Height = 23
      EditLabel.Width = 50
      EditLabel.Height = 15
      EditLabel.Caption = 'StopTime'
      TabOrder = 2
      Text = '8000'
    end
    object RunButton: TButton
      Left = 1320
      Top = 10
      Width = 35
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'Run'
      TabOrder = 3
      OnClick = RunButtonClick
    end
    object ProgressBar1: TProgressBar
      Left = 526
      Top = 26
      Width = 191
      Height = 17
      TabOrder = 4
    end
    object RadioGroup1: TRadioGroup
      Left = 972
      Top = 10
      Width = 278
      Height = 30
      Margins.Top = 0
      Margins.Bottom = 0
      Anchors = [akTop, akRight]
      Caption = 'Test or Real'
      Columns = 4
      DefaultHeaderFont = False
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = 10
      HeaderFont.Name = 'Arial'
      HeaderFont.Pitch = fpFixed
      HeaderFont.Style = []
      HeaderFont.Quality = fqDraft
      ItemIndex = 3
      Items.Strings = (
        'Test1'
        'TextFile'
        'XCVarioFile'
        'Pendule')
      ShowFrame = False
      TabOrder = 5
      StyleName = 'Windows'
    end
    object GraphCheckBox: TCheckBox
      Left = 526
      Top = 3
      Width = 97
      Height = 17
      Caption = 'Graph'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object ParalaxeCheckBox: TCheckBox
      Left = 641
      Top = 3
      Width = 97
      Height = 17
      Caption = 'Paralaxe'
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 49
    Width = 1363
    Height = 733
    ActivePage = GraphTabSheet
    Align = alClient
    TabOrder = 1
    object DataTabSheet: TTabSheet
      Caption = 'Data'
      object Memo2: TMemo
        Left = 274
        Top = 0
        Width = 144
        Height = 703
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
        Height = 703
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
        Height = 703
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
        Height = 703
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
        Width = 1355
        Height = 703
        Legend.Alignment = laBottom
        Title.Text.Strings = (
          'Load factor')
        RightAxis.Automatic = False
        RightAxis.AutomaticMaximum = False
        RightAxis.AutomaticMinimum = False
        RightAxis.Increment = 1.000000000000000000
        RightAxis.Maximum = 36.000000000000000000
        RightAxis.Minimum = -4.000000000000000000
        View3D = False
        Align = alClient
        TabOrder = 0
        DefaultCanvas = ''
        ColorPaletteIndex = 13
        object Series3: TFastLineSeries
          SeriesColor = -1
          Title = 'RawData'
          FastPen = True
          LinePen.Color = -1
          LinePen.EndStyle = esRound
          TreatNulls = tnDontPaint
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series6: TFastLineSeries
          SeriesColor = 16744448
          Title = 'Para'
          FastPen = True
          LinePen.Color = 16744448
          LinePen.EndStyle = esRound
          TreatNulls = tnDontPaint
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series1: TPointSeries
          Marks.Callout.Length = 8
          SeriesColor = 16744448
          Title = 'n'
          VertAxis = aRightAxis
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
        object Series2: TPointSeries
          Marks.Callout.Length = 8
          SeriesColor = clRed
          Title = 'nq'
          VertAxis = aRightAxis
          ClickableLine = False
          Pointer.HorizSize = 2
          Pointer.InflateMargins = True
          Pointer.Pen.Visible = False
          Pointer.Style = psCircle
          Pointer.VertSize = 2
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
        Height = 703
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
        Height = 703
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
        Left = 1234
        Top = 0
        Width = 121
        Height = 703
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
        Width = 1355
        Height = 703
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
    Left = 672
    Top = 392
    object Fichier1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open'
        OnClick = Open1Click
      end
      object Save: TMenuItem
        Caption = 'Save'
        OnClick = SaveClick
      end
      object SaveAs1: TMenuItem
        Caption = 'Save As...'
        OnClick = SaveAs1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Print1: TMenuItem
        Caption = 'Print Graph'
        OnClick = Print1Click
      end
      object PrintSpectra1: TMenuItem
        Caption = 'Print Spectra'
        OnClick = PrintSpectra1Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Quit1: TMenuItem
        Caption = 'Quit'
        OnClick = Quit1Click
      end
    end
    object Run1: TMenuItem
      Caption = 'Run'
      object Run2: TMenuItem
        Caption = 'Run'
        OnClick = Run2Click
      end
      object Run3: TMenuItem
        Caption = 'Configuration'
        OnClick = Run3Click
      end
      object FiltrageAB1: TMenuItem
        Caption = 'Filtrage_AB'
        OnClick = FiltrageAB1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object Help2: TMenuItem
        Caption = 'Doc'
        OnClick = Help2Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object N3: TMenuItem
        Caption = 'A propos'
        OnClick = N3Click
      end
    end
  end
  object SaveDialog1: TSaveDialog
    FileName = 'Kossira.txt'
    Left = 1056
    Top = 136
  end
end
