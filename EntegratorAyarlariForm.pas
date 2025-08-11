unit EntegratorAyarlariForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.UITypes, SettingsManager;

type
  TfrmEntegratorAyarlari = class(TForm)
    pnlMain: TPanel;
    gbTestOrtami: TGroupBox;
    lblURL: TLabel;
    edtURL: TEdit;
    lblKullaniciAdi: TLabel;
    edtKullaniciAdi: TEdit;
    lblSifre: TLabel;
    edtSifre: TEdit;
    gbEtiketler: TGroupBox;
    lblGidenEtiket: TLabel;
    edtGidenEtiket: TEdit;
    lblGelenEtiket: TLabel;
    edtGelenEtiket: TEdit;
    gbSube: TGroupBox;
    lblSube: TLabel;
    cmbSube: TComboBox;
    pnlButtons: TPanel;
    btnKaydet: TButton;
    btnYukle: TButton;
    btnTemizle: TButton;
    btnIptal: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnYukleClick(Sender: TObject);
    procedure btnTemizleClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
  private
    procedure VarsayilanDegerleriAyarla;
    procedure FormunuTemizle;
    function AyarlariDogrula: Boolean;
  public
    { Public declarations }
  end;

var
  frmEntegratorAyarlari: TfrmEntegratorAyarlari;

implementation

{$R *.dfm}

procedure TfrmEntegratorAyarlari.FormCreate(Sender: TObject);
begin
  Caption := 'Entegrator Ayarlari (Test Ortami)';
  Font.Name := 'Segoe UI';
  Font.Charset := TURKISH_CHARSET;
  
  // Settings klasorunu olustur
  TSettingsManager.CreateSettingsFolder;
  
  // Sube listesini doldur
  cmbSube.Items.Clear;
  cmbSube.Items.Add('Merkez Sube');
  cmbSube.Items.Add('Istanbul Sube');
  cmbSube.Items.Add('Ankara Sube');
  cmbSube.Items.Add('Izmir Sube');
  cmbSube.Items.Add('Bursa Sube');
  cmbSube.Items.Add('Antalya Sube');
  cmbSube.Items.Insert(0, '-- Sube Secin (Opsiyonel) --');
  cmbSube.ItemIndex := 0;
  
  // Varsayilan degerleri ayarla
  VarsayilanDegerleriAyarla;
  
  // Eger ayar dosyasi varsa otomatik yukle
  if TSettingsManager.EntegratorSettingsFileExists then
    btnYukleClick(nil);
end;

procedure TfrmEntegratorAyarlari.VarsayilanDegerleriAyarla;
begin
  edtURL.Text := 'https://efaturatest.gov.tr/';
  edtKullaniciAdi.Text := 'test_kullanici';
  edtSifre.Text := 'test_sifre';
  edtGidenEtiket.Text := ''; // Bos birakabilir
  edtGelenEtiket.Text := ''; // Bos birakabilir
end;

procedure TfrmEntegratorAyarlari.FormunuTemizle;
begin
  edtURL.Text := '';
  edtKullaniciAdi.Text := '';
  edtSifre.Text := '';
  edtGidenEtiket.Text := '';
  edtGelenEtiket.Text := '';
  cmbSube.ItemIndex := 0; // "-- Sube Secin (Opsiyonel) --" secili kalsin
end;

function TfrmEntegratorAyarlari.AyarlariDogrula: Boolean;
begin
  Result := False;
  
  // URL kontrolu
  if Trim(edtURL.Text) = '' then
  begin
    ShowMessage('Test ortami URL bos birakilamaz!');
    edtURL.SetFocus;
    Exit;
  end;
  
  // Kullanici adi kontrolu
  if Trim(edtKullaniciAdi.Text) = '' then
  begin
    ShowMessage('Kullanici adi bos birakilamaz!');
    edtKullaniciAdi.SetFocus;
    Exit;
  end;
  
  // Sifre kontrolu
  if Trim(edtSifre.Text) = '' then
  begin
    ShowMessage('Sifre bos birakilamaz!');
    edtSifre.SetFocus;
    Exit;
  end;
  
  // Etiket kontrolleri - OPSIYONEL (zorunlu degil)
  // Giden ve gelen etiketler bos birakilabilir
  
  Result := True;
end;

procedure TfrmEntegratorAyarlari.btnKaydetClick(Sender: TObject);
var
  EntegratorAyarlari: TEntegratorAyarlari;
begin
  if not AyarlariDogrula then
    Exit;
  
  // Ayarlari doldur
  EntegratorAyarlari.TestURL := Trim(edtURL.Text);
  EntegratorAyarlari.KullaniciAdi := Trim(edtKullaniciAdi.Text);
  EntegratorAyarlari.Sifre := Trim(edtSifre.Text);
  EntegratorAyarlari.GidenEtiket := Trim(edtGidenEtiket.Text);
  EntegratorAyarlari.GelenEtiket := Trim(edtGelenEtiket.Text);
  
  // Sube secimi - opsiyonel mesaji degilse kaydet
  if (cmbSube.ItemIndex > 0) and (cmbSube.ItemIndex < cmbSube.Items.Count) then
    EntegratorAyarlari.Sube := cmbSube.Text
  else
    EntegratorAyarlari.Sube := ''; // Bos birak
  
  try
    TSettingsManager.SaveEntegratorAyarlari(EntegratorAyarlari);
    ShowMessage('Entegrator ayarlari basariyla kaydedildi!' + #13#10 + 
                'Dosya konumu: ' + ExtractFilePath(ParamStr(0)) + 'Settings\');
  except
    on E: Exception do
      ShowMessage('Kayit hatasi: ' + E.Message);
  end;
end;

procedure TfrmEntegratorAyarlari.btnYukleClick(Sender: TObject);
var
  EntegratorAyarlari: TEntegratorAyarlari;
  i: Integer;
begin
  try
    EntegratorAyarlari := TSettingsManager.LoadEntegratorAyarlari;
    
    edtURL.Text := EntegratorAyarlari.TestURL;
    edtKullaniciAdi.Text := EntegratorAyarlari.KullaniciAdi;
    edtSifre.Text := EntegratorAyarlari.Sifre;
    edtGidenEtiket.Text := EntegratorAyarlari.GidenEtiket;
    edtGelenEtiket.Text := EntegratorAyarlari.GelenEtiket;
    
    // Sube secimi
    cmbSube.ItemIndex := 0; // Varsayilan "-- Sube Secin (Opsiyonel) --"
    for i := 1 to cmbSube.Items.Count - 1 do // 0. index opsiyonel mesaji oldugu icin 1'den basla
    begin
      if cmbSube.Items[i] = EntegratorAyarlari.Sube then
      begin
        cmbSube.ItemIndex := i;
        Break;
      end;
    end;
    
    if TSettingsManager.EntegratorSettingsFileExists then
      ShowMessage('Entegrator ayarlari basariyla yuklendi!')
    else
      ShowMessage('Varsayilan ayarlar yuklendi!');
  except
    on E: Exception do
      ShowMessage('Yukleme hatasi: ' + E.Message);
  end;
end;

procedure TfrmEntegratorAyarlari.btnTemizleClick(Sender: TObject);
begin
  if MessageDlg('Tum ayarlar temizlenecek. Emin misiniz?', 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FormunuTemizle;
    ShowMessage('Ayarlar temizlendi!');
  end;
end;

procedure TfrmEntegratorAyarlari.btnIptalClick(Sender: TObject);
begin
  Close;
end;

end.
