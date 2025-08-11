object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'E-Fatura Delphi Örnek Proje'
  ClientHeight = 500
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 500
    Align = alLeft
    BevelOuter = bvLowered
    Caption = ''
    TabOrder = 0
    object TreeView1: TTreeView
      Left = 1
      Top = 1
      Width = 198
      Height = 498
      Align = alClient
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      Indent = 19
      ParentFont = False
      ReadOnly = True
      ShowLines = True
      ShowRoot = False
      TabOrder = 0
      OnChange = TreeView1Change
    end
  end
  object Panel2: TPanel
    Left = 200
    Top = 0
    Width = 600
    Height = 500
    Align = alClient
    BevelOuter = bvLowered
    Caption = ''
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 137
      Height = 19
      Caption = 'E-Fatura Örnek Proje'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Memo1: TMemo
      Left = 16
      Top = 48
      Width = 568
      Height = 140
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = []
      Lines.Strings = (
        'Hoş geldiniz!'
        ''
        'Sol taraftan işlem yapmak istediğiniz bölümü seçiniz.')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object pnlTarihFiltre: TPanel
      Left = 16
      Top = 194
      Width = 568
      Height = 40
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      Color = clBtnFace
      ParentBackground = False
      TabOrder = 2
      Visible = False
      object lblBaslangic: TLabel
        Left = 8
        Top = 12
        Width = 79
        Height = 13
        Caption = 'Baslangic Tarihi:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblBitis: TLabel
        Left = 200
        Top = 12
        Width = 54
        Height = 13
        Caption = 'Bitis Tarihi:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object dtpBaslangic: TDateTimePicker
        Left = 93
        Top = 8
        Width = 100
        Height = 21
        Date = 45657.000000000000000000
        Time = 0.000000000000000000
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object dtpBitis: TDateTimePicker
        Left = 260
        Top = 8
        Width = 100
        Height = 21
        Date = 45657.000000000000000000
        Time = 0.000000000000000000
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object btnFiltrele: TButton
        Left = 370
        Top = 6
        Width = 100
        Height = 25
        Caption = 'Sorgula'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnFiltreleClick
      end
      object btnTumunu: TButton
        Left = 480
        Top = 6
        Width = 80
        Height = 25
        Caption = 'Tumunu Goster'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = btnTumunuClick
      end
    end
    object StringGrid1: TStringGrid
      Left = 16
      Top = 240
      Width = 568
      Height = 244
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 7
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 1
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 1
      Visible = False
    end
  end
end
