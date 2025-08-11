unit FirmaAyarlariForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Mask, SettingsManager;

type
  TfrmFirmaAyarlari = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    edtVknTckn: TEdit;
    lblTip: TLabel;
    GroupBox2: TGroupBox;
    lblUnvanIsim: TLabel;
    edtUnvanIsim: TEdit;
    lblSoyisim: TLabel;
    edtSoyisim: TEdit;
    GroupBox3: TGroupBox;
    Label6: TLabel;
    cmbIl: TComboBox;
    Label7: TLabel;
    cmbIlce: TComboBox;
    Label8: TLabel;
    mmoAdres: TMemo;
    Panel3: TPanel;
    btnKaydet: TButton;
    btnIptal: TButton;
    btnTemizle: TButton;
    btnYukle: TButton;
    procedure FormCreate(Sender: TObject);
    procedure edtVknTcknChange(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
    procedure btnTemizleClick(Sender: TObject);
    procedure cmbIlChange(Sender: TObject);
    procedure btnYukleClick(Sender: TObject);
  private
    procedure KimlikTipiKontrol;
    procedure IlceDoldur(const Il: string);
    function VknTcknDogrula(const Kimlik: string): Boolean;
  public
    { Public declarations }
  end;

var
  frmFirmaAyarlari: TfrmFirmaAyarlari;

implementation

{$R *.dfm}

procedure TfrmFirmaAyarlari.FormCreate(Sender: TObject);
begin
  Caption := 'Firma Ayarlari';
  Font.Name := 'Segoe UI';
  Font.Charset := TURKISH_CHARSET;
  
  // Settings klasorunu olustur
  TSettingsManager.CreateSettingsFolder;
  
  // Il listesini doldur
  cmbIl.Items.Clear;
  cmbIl.Items.Add('Istanbul');
  cmbIl.Items.Add('Ankara');
  cmbIl.Items.Add('Izmir');
  cmbIl.Items.Add('Bursa');
  cmbIl.Items.Add('Antalya');
  cmbIl.Items.Add('Adana');
  cmbIl.Items.Add('Konya');
  cmbIl.Items.Add('Gaziantep');
  cmbIl.Items.Add('Mersin');
  cmbIl.Items.Add('Kayseri');
  
  // Baslangic durumu
  KimlikTipiKontrol;
  
  // Kayitli ayarlar varsa yukle
  if TSettingsManager.SettingsFileExists then
    btnYukleClick(nil);
end;

procedure TfrmFirmaAyarlari.edtVknTcknChange(Sender: TObject);
begin
  KimlikTipiKontrol;
end;

procedure TfrmFirmaAyarlari.KimlikTipiKontrol;
var
  Kimlik: string;
  Uzunluk: Integer;
begin
  Kimlik := Trim(edtVknTckn.Text);
  Uzunluk := Length(Kimlik);
  
  if Uzunluk = 11 then
  begin
    // TCKN
    lblTip.Caption := 'TC Kimlik Numarasi (11 hane)';
    lblTip.Font.Color := clBlue;
    
    lblUnvanIsim.Caption := 'Isim:';
    lblSoyisim.Visible := True;
    edtSoyisim.Visible := True;
    
    GroupBox2.Caption := 'Kisi Bilgileri';
  end
  else if Uzunluk = 10 then
  begin
    // VKN
    lblTip.Caption := 'Vergi Kimlik Numarasi (10 hane)';
    lblTip.Font.Color := clGreen;
    
    lblUnvanIsim.Caption := 'Unvan:';
    lblSoyisim.Visible := False;
    edtSoyisim.Visible := False;
    
    GroupBox2.Caption := 'Sirket Bilgileri';
  end
  else
  begin
    // Belirsiz
    lblTip.Caption := 'VKN (10 hane) veya TCKN (11 hane) giriniz';
    lblTip.Font.Color := clRed;
    
    lblUnvanIsim.Caption := 'Unvan/Isim:';
    lblSoyisim.Visible := True;
    edtSoyisim.Visible := True;
    
    GroupBox2.Caption := 'Bilgiler';
  end;
end;

procedure TfrmFirmaAyarlari.cmbIlChange(Sender: TObject);
begin
  if cmbIl.ItemIndex >= 0 then
    IlceDoldur(cmbIl.Text);
end;

procedure TfrmFirmaAyarlari.IlceDoldur(const Il: string);
begin
  cmbIlce.Items.Clear;
  
  if Il = 'Istanbul' then
  begin
    cmbIlce.Items.Add('Kadikoy');
    cmbIlce.Items.Add('Besiktas');
    cmbIlce.Items.Add('Sisli');
    cmbIlce.Items.Add('Uskudar');
    cmbIlce.Items.Add('Fatih');
  end
  else if Il = 'Ankara' then
  begin
    cmbIlce.Items.Add('Cankaya');
    cmbIlce.Items.Add('Kecioren');
    cmbIlce.Items.Add('Yenimahalle');
    cmbIlce.Items.Add('Mamak');
    cmbIlce.Items.Add('Sincan');
  end
  else if Il = 'Izmir' then
  begin
    cmbIlce.Items.Add('Konak');
    cmbIlce.Items.Add('Karsiyaka');
    cmbIlce.Items.Add('Bornova');
    cmbIlce.Items.Add('Buca');
    cmbIlce.Items.Add('Alsancak');
  end
  else
  begin
    cmbIlce.Items.Add('Merkez');
    cmbIlce.Items.Add('Diger');
  end;
end;

function TfrmFirmaAyarlari.VknTcknDogrula(const Kimlik: string): Boolean;
var
  i, Kontrol: Integer;
  Rakam: string;
begin
  Result := False;
  
  if Length(Kimlik) = 11 then
  begin
    // TCKN doğrulama algoritması (basitleştirilmiş)
    // Tüm karakterlerin rakam olup olmadığını kontrol et
    for i := 1 to 11 do
    begin
      Rakam := Copy(Kimlik, i, 1);
      if not TryStrToInt(Rakam, Kontrol) then Exit;
    end;
    Result := True; // Basit kontrol (gerçek TCKN algoritması uygulanabilir)
  end
  else if Length(Kimlik) = 10 then
  begin
    // VKN doğrulama (basit kontrol)
    for i := 1 to 10 do
    begin
      Rakam := Copy(Kimlik, i, 1);
      if not TryStrToInt(Rakam, Kontrol) then Exit;
    end;
    Result := True; // Basit kontrol
  end;
end;

procedure TfrmFirmaAyarlari.btnKaydetClick(Sender: TObject);
var
  Kimlik: string;
  FirmaAyarlari: TFirmaAyarlari;
begin
  Kimlik := Trim(edtVknTckn.Text);
  
  if Kimlik = '' then
  begin
    ShowMessage('VKN veya TCKN bos olamaz!');
    edtVknTckn.SetFocus;
    Exit;
  end;
  
  if not VknTcknDogrula(Kimlik) then
  begin
    ShowMessage('Gecersiz VKN veya TCKN formati!');
    edtVknTckn.SetFocus;
    Exit;
  end;
  
  if Trim(edtUnvanIsim.Text) = '' then
  begin
    if Length(Kimlik) = 11 then
      ShowMessage('Isim bos olamaz!')
    else
      ShowMessage('Unvan bos olamaz!');
    edtUnvanIsim.SetFocus;
    Exit;
  end;
  
  if (Length(Kimlik) = 11) and (Trim(edtSoyisim.Text) = '') then
  begin
    ShowMessage('Soyisim bos olamaz!');
    edtSoyisim.SetFocus;
    Exit;
  end;
  
  // Ayarlari kaydet
  FirmaAyarlari.VknTckn := Kimlik;
  if Length(Kimlik) = 11 then
    FirmaAyarlari.KimlikTipi := 'TCKN'
  else
    FirmaAyarlari.KimlikTipi := 'VKN';
  
  FirmaAyarlari.UnvanIsim := Trim(edtUnvanIsim.Text);
  FirmaAyarlari.Soyisim := Trim(edtSoyisim.Text);
  FirmaAyarlari.Il := cmbIl.Text;
  FirmaAyarlari.Ilce := cmbIlce.Text;
  FirmaAyarlari.Adres := Trim(mmoAdres.Lines.Text);
  
  try
    TSettingsManager.SaveFirmaAyarlari(FirmaAyarlari);
    ShowMessage('Firma ayarlari basariyla kaydedildi!' + #13#10 + 
                'Dosya konumu: ' + ExtractFilePath(ParamStr(0)) + 'Settings\');
  except
    on E: Exception do
      ShowMessage('Kayit hatasi: ' + E.Message);
  end;
end;

procedure TfrmFirmaAyarlari.btnIptalClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFirmaAyarlari.btnTemizleClick(Sender: TObject);
begin
  edtVknTckn.Text := '';
  edtUnvanIsim.Text := '';
  edtSoyisim.Text := '';
  cmbIl.ItemIndex := -1;
  cmbIlce.ItemIndex := -1;
  mmoAdres.Lines.Clear;
  
  KimlikTipiKontrol;
  edtVknTckn.SetFocus;
end;

procedure TfrmFirmaAyarlari.btnYukleClick(Sender: TObject);
var
  FirmaAyarlari: TFirmaAyarlari;
  i: Integer;
begin
  if not TSettingsManager.SettingsFileExists then
  begin
    ShowMessage('Kayitli firma ayarlari bulunamadi!');
    Exit;
  end;
  
  try
    FirmaAyarlari := TSettingsManager.LoadFirmaAyarlari;
    
    // Form alanlarini doldur
    edtVknTckn.Text := FirmaAyarlari.VknTckn;
    edtUnvanIsim.Text := FirmaAyarlari.UnvanIsim;
    edtSoyisim.Text := FirmaAyarlari.Soyisim;
    mmoAdres.Lines.Text := FirmaAyarlari.Adres;
    
    // Il secimi
    for i := 0 to cmbIl.Items.Count - 1 do
    begin
      if cmbIl.Items[i] = FirmaAyarlari.Il then
      begin
        cmbIl.ItemIndex := i;
        IlceDoldur(FirmaAyarlari.Il);
        Break;
      end;
    end;
    
    // Ilce secimi
    for i := 0 to cmbIlce.Items.Count - 1 do
    begin
      if cmbIlce.Items[i] = FirmaAyarlari.Ilce then
      begin
        cmbIlce.ItemIndex := i;
        Break;
      end;
    end;
    
    // Kimlik tipi kontrolu
    KimlikTipiKontrol;
    
    ShowMessage('Firma ayarlari basariyla yuklendi!');
  except
    on E: Exception do
      ShowMessage('Yukleme hatasi: ' + E.Message);
  end;
end;

end.
