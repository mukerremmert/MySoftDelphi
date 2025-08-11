object frmFirmaAyarlari: TfrmFirmaAyarlari
  Left = 0
  Top = 0
  Caption = 'Firma Ayarlari'
  ClientHeight = 450
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 12
      Width = 81
      Height = 17
      Caption = 'Firma Ayarlari'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 500
    Height = 368
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 16
      Top = 16
      Width = 468
      Height = 80
      Caption = 'Kimlik Bilgileri'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object Label2: TLabel
        Left = 16
        Top = 24
        Width = 71
        Height = 13
        Caption = 'VKN / TCKN:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblTip: TLabel
        Left = 16
        Top = 56
        Width = 166
        Height = 13
        Caption = 'VKN (10 hane) veya TCKN (11 hane)'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtVknTckn: TEdit
        Left = 120
        Top = 21
        Width = 150
        Height = 21
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        MaxLength = 11
        NumbersOnly = True
        ParentFont = False
        TabOrder = 0
        OnChange = edtVknTcknChange
      end
    end
    object GroupBox2: TGroupBox
      Left = 16
      Top = 112
      Width = 468
      Height = 100
      Caption = 'Bilgiler'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      object lblUnvanIsim: TLabel
        Left = 16
        Top = 28
        Width = 70
        Height = 13
        Caption = 'Unvan/Isim:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblSoyisim: TLabel
        Left = 16
        Top = 60
        Width = 44
        Height = 13
        Caption = 'Soyisim:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtUnvanIsim: TEdit
        Left = 120
        Top = 25
        Width = 300
        Height = 21
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object edtSoyisim: TEdit
        Left = 120
        Top = 57
        Width = 200
        Height = 21
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object GroupBox3: TGroupBox
      Left = 16
      Top = 228
      Width = 468
      Height = 120
      Caption = 'Adres Bilgileri'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      object Label6: TLabel
        Left = 16
        Top = 28
        Width = 14
        Height = 13
        Caption = 'Il:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Label7: TLabel
        Left = 200
        Top = 28
        Width = 26
        Height = 13
        Caption = 'Ilce:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Left = 16
        Top = 60
        Width = 36
        Height = 13
        Caption = 'Adres:'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object cmbIl: TComboBox
        Left = 50
        Top = 25
        Width = 120
        Height = 21
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = cmbIlChange
      end
      object cmbIlce: TComboBox
        Left = 240
        Top = 25
        Width = 120
        Height = 21
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object mmoAdres: TMemo
        Left = 16
        Top = 80
        Width = 436
        Height = 25
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        Lines.Strings = (
          '')
        ParentFont = False
        TabOrder = 2
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 409
    Width = 500
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnKaydet: TButton
      Left = 320
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Kaydet'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnKaydetClick
    end
    object btnIptal: TButton
      Left = 409
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Iptal'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnIptalClick
    end
    object btnTemizle: TButton
      Left = 150
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Temizle'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnTemizleClick
    end
    object btnYukle: TButton
      Left = 235
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Yukle'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnYukleClick
    end
  end
end