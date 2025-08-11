object frmEntegratorAyarlari: TfrmEntegratorAyarlari
  Left = 0
  Top = 0
  Caption = 'Entegrator Ayarlari (Test Ortami)'
  ClientHeight = 400
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 464
    Height = 344
    BevelOuter = bvNone
    TabOrder = 0
    object gbTestOrtami: TGroupBox
      Left = 0
      Top = 0
      Width = 464
      Height = 120
      Align = alTop
      Caption = ' Test Ortami Baglanti Bilgileri '
      TabOrder = 0
      object lblURL: TLabel
        Left = 16
        Top = 24
        Width = 84
        Height = 13
        Caption = 'Test Ortami URL:'
      end
      object lblKullaniciAdi: TLabel
        Left = 16
        Top = 56
        Width = 66
        Height = 13
        Caption = 'Kullanici Adi:'
      end
      object lblSifre: TLabel
        Left = 16
        Top = 88
        Width = 28
        Height = 13
        Caption = 'Sifre:'
      end
      object edtURL: TEdit
        Left = 120
        Top = 21
        Width = 320
        Height = 21
        TabOrder = 0
        Text = 'https://efaturatest.gov.tr/'
      end
      object edtKullaniciAdi: TEdit
        Left = 120
        Top = 53
        Width = 200
        Height = 21
        TabOrder = 1
        Text = 'test_kullanici'
      end
      object edtSifre: TEdit
        Left = 120
        Top = 85
        Width = 200
        Height = 21
        PasswordChar = '*'
        TabOrder = 2
        Text = 'test_sifre'
      end
    end
    object gbEtiketler: TGroupBox
      Left = 0
      Top = 120
      Width = 464
      Height = 104
      Align = alTop
      Caption = ' Etiket Ayarlari '
      TabOrder = 1
      object lblGidenEtiket: TLabel
        Left = 16
        Top = 24
        Width = 70
        Height = 13
        Caption = 'Giden Etiket:'
      end
      object lblGelenEtiket: TLabel
        Left = 16
        Top = 56
        Width = 68
        Height = 13
        Caption = 'Gelen Etiket:'
      end
      object edtGidenEtiket: TEdit
        Left = 120
        Top = 21
        Width = 200
        Height = 21
        TabOrder = 0
        Text = ''
      end
      object edtGelenEtiket: TEdit
        Left = 120
        Top = 53
        Width = 200
        Height = 21
        TabOrder = 1
        Text = ''
      end
    end
    object gbSube: TGroupBox
      Left = 0
      Top = 224
      Width = 464
      Height = 80
      Align = alTop
      Caption = ' Sube Secimi '
      TabOrder = 2
      object lblSube: TLabel
        Left = 16
        Top = 32
        Width = 28
        Height = 13
        Caption = 'Sube:'
      end
      object cmbSube: TComboBox
        Left = 120
        Top = 29
        Width = 200
        Height = 21
        Style = csDropDownList
        TabOrder = 0
      end
    end
  end
  object pnlButtons: TPanel
    Left = 8
    Top = 360
    Width = 464
    Height = 32
    BevelOuter = bvNone
    TabOrder = 1
    object btnKaydet: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 32
      Caption = 'Kaydet'
      TabOrder = 0
      OnClick = btnKaydetClick
    end
    object btnYukle: TButton
      Left = 85
      Top = 0
      Width = 75
      Height = 32
      Caption = 'Yukle'
      TabOrder = 1
      OnClick = btnYukleClick
    end
    object btnTemizle: TButton
      Left = 170
      Top = 0
      Width = 75
      Height = 32
      Caption = 'Temizle'
      TabOrder = 2
      OnClick = btnTemizleClick
    end
    object btnIptal: TButton
      Left = 389
      Top = 0
      Width = 75
      Height = 32
      Caption = 'Iptal'
      TabOrder = 3
      OnClick = btnIptalClick
    end
  end
end
