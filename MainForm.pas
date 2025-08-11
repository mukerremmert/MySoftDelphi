unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, System.StrUtils, System.JSON, FirmaAyarlariForm, 
  EntegratorAyarlariForm, SettingsManager, MySoftAPITypes, MySoftAPIBase, 
  MySoftGelenFaturaAPI;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    TreeView1: TTreeView;
    Panel2: TPanel;
    Label1: TLabel;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    pnlTarihFiltre: TPanel;
    lblBaslangic: TLabel;
    dtpBaslangic: TDateTimePicker;
    lblBitis: TLabel;
    dtpBitis: TDateTimePicker;
    btnFiltrele: TButton;
    btnTumunu: TButton;
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnFiltreleClick(Sender: TObject);
    procedure btnTumunuClick(Sender: TObject);
  private
    { Private declarations }
    FGelenFaturaAPI: TMySoftGelenFaturaAPI;
    
    procedure GelenFaturalariGoster;
    procedure SetupDataGrid;
    procedure LoadInvoiceDataToGrid(StartDate, EndDate: TDateTime);
    procedure AddInvoiceToGrid(const InvoiceObj: TJSONObject; Row: Integer);
    procedure ClearDataGrid;
    function FormatCurrencyTL(const Value: Double): string;
    function FormatDateTR(const DateStr: string): string;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  NodeFaturalar, NodeIrsaliyeler, NodeAyarlar: TTreeNode;
begin
  // MySoft API sınıflarını initialize et
  FGelenFaturaAPI := TMySoftGelenFaturaAPI.Create;
  
  // Form ayarları
  Caption := 'E-Fatura Delphi Örnek Proje';
  Font.Name := 'Segoe UI';
  Font.Charset := TURKISH_CHARSET;
  
  // Memo font'unu monospace yap
  Memo1.Font.Name := 'Consolas';
  Memo1.Font.Size := 9;
  
  // TreeView ayarları
  TreeView1.ReadOnly := True;
  TreeView1.ShowLines := True;
  TreeView1.ShowRoot := False;
  
  // Menü öğelerini ekle
  NodeFaturalar := TreeView1.Items.Add(nil, 'Faturalar');
  TreeView1.Items.AddChild(NodeFaturalar, 'Gelen Faturalar');
  TreeView1.Items.AddChild(NodeFaturalar, 'Giden Faturalar');
  
  NodeIrsaliyeler := TreeView1.Items.Add(nil, 'İrsaliyeler');
  TreeView1.Items.AddChild(NodeIrsaliyeler, 'Gelen İrsaliyeler');
  TreeView1.Items.AddChild(NodeIrsaliyeler, 'Giden İrsaliyeler');
  
  NodeAyarlar := TreeView1.Items.Add(nil, 'Ayarlar');
  TreeView1.Items.AddChild(NodeAyarlar, 'Firma Ayarları');
  TreeView1.Items.AddChild(NodeAyarlar, 'Entegratör Ayarları');
  TreeView1.Items.AddChild(NodeAyarlar, 'Log Kayıtları');
  
  // Tüm node'ları aç
  TreeView1.FullExpand;
  
  // İlk seçim
  Label1.Caption := 'E-Fatura Delphi Örnek Proje';
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Hoş geldiniz!');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Sol taraftan işlem yapmak istediğiniz bölümü seçiniz.');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Bu örnek proje e-fatura ve e-irsaliye işlemleri için');
  Memo1.Lines.Add('temel yapıyı göstermektedir.');
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  NodeText: string;
  EntegratorAyarlari: TEntegratorAyarlari;
begin
  if Node = nil then Exit;
  
  NodeText := Node.Text;
  Label1.Caption := NodeText;
  Memo1.Lines.Clear;
  
  
  if NodeText = 'Gelen Faturalar' then
  begin
    // Ana ekranda DataTable goster (ama veri yuklemeden)
    GelenFaturalariGoster;
    SetupDataGrid;
    ClearDataGrid; // Bos grid goster
    pnlTarihFiltre.Visible := True;
    StringGrid1.Visible := True;
    
    // Varsayilan tarih araligi (son 30 gun)
    dtpBaslangic.Date := Now - 30;
    dtpBitis.Date := Now;
    // LoadInvoiceDataToGrid cagrisi kaldirildi - sadece Sorgula butonunda calisacak
  end
  else if NodeText = 'Giden Faturalar' then
  begin
    StringGrid1.Visible := False;
    pnlTarihFiltre.Visible := False;
    Memo1.Lines.Add('Giden Faturalar Modülü');
    Memo1.Lines.Add('========================');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('• Yeni e-fatura oluşturma');
    Memo1.Lines.Add('• UBL-TR formatında XML üretme');
    Memo1.Lines.Add('• E-imza ile imzalama');
    Memo1.Lines.Add('• Entegratör üzerinden gönderme');
  end
  else if NodeText = 'Gelen İrsaliyeler' then
  begin
    StringGrid1.Visible := False;
    pnlTarihFiltre.Visible := False;
    Memo1.Lines.Add('Gelen İrsaliyeler Modülü');
    Memo1.Lines.Add('==========================');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('• Size gelen e-irsaliyeleri görüntüleme');
    Memo1.Lines.Add('• İrsaliye detaylarını inceleme');
    Memo1.Lines.Add('• Stok hareketlerini takip etme');
    Memo1.Lines.Add('• Depo sistemine aktarma');
  end
  else if NodeText = 'Giden İrsaliyeler' then
  begin
    StringGrid1.Visible := False;
    pnlTarihFiltre.Visible := False;
    Memo1.Lines.Add('Giden İrsaliyeler Modülü');
    Memo1.Lines.Add('===========================');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('• Yeni e-irsaliye oluşturma');
    Memo1.Lines.Add('• Sevkiyat bilgilerini girme');
    Memo1.Lines.Add('• XML formatında hazırlama');
    Memo1.Lines.Add('• Elektronik ortamda gönderme');
  end
  else if NodeText = 'Ayarlar' then
  begin
    StringGrid1.Visible := False;
    pnlTarihFiltre.Visible := False;
    Memo1.Lines.Add('Sistem Ayarları');
    Memo1.Lines.Add('================');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Sol menüden ayar kategorisini seçiniz:');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('• Firma Ayarları - Şirket bilgileri ve vergi dairesi');
    Memo1.Lines.Add('• Entegratör Ayarları - Test ortamı bağlantı ayarları');
    Memo1.Lines.Add('• Log Kayıtları - Sistem logları ve hata kayıtları');
  end
  else if NodeText = 'Firma Ayarları' then
  begin
    StringGrid1.Visible := False;
    pnlTarihFiltre.Visible := False;
    // Firma ayarları formunu aç
    if not Assigned(frmFirmaAyarlari) then
      frmFirmaAyarlari := TfrmFirmaAyarlari.Create(Self);
    
    frmFirmaAyarlari.ShowModal;
    
    // Memo'ya bilgi mesajı
    Memo1.Lines.Add('Firma Ayarları');
    Memo1.Lines.Add('===============');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Firma ayarları formu açıldı.');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Özellikler:');
    Memo1.Lines.Add('• VKN (10 hane) / TCKN (11 hane) dinamik kontrol');
    Memo1.Lines.Add('• VKN ise: Ünvan + Adres');
    Memo1.Lines.Add('• TCKN ise: İsim + Soyisim + Adres');
    Memo1.Lines.Add('• İl-İlçe seçimi');
    Memo1.Lines.Add('• Otomatik doğrulama');
  end
  else if NodeText = 'Entegratör Ayarları' then
  begin
    StringGrid1.Visible := False;
    pnlTarihFiltre.Visible := False;
    if not Assigned(frmEntegratorAyarlari) then
      frmEntegratorAyarlari := TfrmEntegratorAyarlari.Create(Self);

    frmEntegratorAyarlari.ShowModal;

    EntegratorAyarlari := TSettingsManager.LoadEntegratorAyarlari;
    
    Memo1.Lines.Add('Entegrator Ayarlari (Test Ortami)');
    Memo1.Lines.Add('==================================');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Entegrator ayarlari formu acildi.');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Mevcut Ayarlar:');
    Memo1.Lines.Add('• Test Ortami URL: ' + EntegratorAyarlari.TestURL);
    Memo1.Lines.Add('• Kullanici Adi: ' + EntegratorAyarlari.KullaniciAdi);
    Memo1.Lines.Add('• Sifre: ' + StringOfChar('*', Length(EntegratorAyarlari.Sifre)));
    Memo1.Lines.Add('• Giden Etiket: ' + EntegratorAyarlari.GidenEtiket);
    Memo1.Lines.Add('• Gelen Etiket: ' + EntegratorAyarlari.GelenEtiket);
    Memo1.Lines.Add('• Sube: ' + EntegratorAyarlari.Sube);
    Memo1.Lines.Add('');
    if TSettingsManager.EntegratorSettingsFileExists then
      Memo1.Lines.Add('Durum: Ayarlar dosyadan yuklendi')
    else
      Memo1.Lines.Add('Durum: Varsayilan ayarlar kullaniliyor');
  end
  else if NodeText = 'Log Kayıtları' then
  begin
    StringGrid1.Visible := False;
    pnlTarihFiltre.Visible := False;
    Memo1.Lines.Add('Log Kayıtları');
    Memo1.Lines.Add('==============');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('• Sistem Logları');
    Memo1.Lines.Add('• Hata Kayıtları');
    Memo1.Lines.Add('• API İstekleri');
    Memo1.Lines.Add('• Gönderilen Faturalar');
    Memo1.Lines.Add('• Alınan Faturalar');
    Memo1.Lines.Add('• Log Dosyası Konumu: C:\Logs\EFatura\');
    Memo1.Lines.Add('• Maksimum Log Boyutu: 10 MB');
    Memo1.Lines.Add('• Log Saklama Süresi: 30 gün');
  end;
end;

procedure TForm1.GelenFaturalariGoster;
var
  EntegratorAyarlari: TEntegratorAyarlari;
begin
  Memo1.Lines.Clear;
  
  // Entegrator ayarlarini yukle
  EntegratorAyarlari := TSettingsManager.LoadEntegratorAyarlari;
  
  Memo1.Lines.Add('BAGLANTI BiLGiLERi:');
  Memo1.Lines.Add('Test URL: ' + EntegratorAyarlari.TestURL);
  Memo1.Lines.Add('Kullanici: ' + EntegratorAyarlari.KullaniciAdi);
  Memo1.Lines.Add('Durum: ' + IfThen(TSettingsManager.EntegratorSettingsFileExists, 'Ayarlar yuklendi', 'Varsayilan ayarlar'));
  Memo1.Lines.Add('');
  Memo1.Lines.Add('MySoft API Baglantisi: HAZIR (GERCEK API)');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('KULLANIM:');
  Memo1.Lines.Add('1. Entegrator ayarlarindan kullanici bilgilerini kontrol edin');
  Memo1.Lines.Add('2. "Sorgula" butonuna basin');
  Memo1.Lines.Add('3. GERCEK MySoft API''den faturalar cekilecek');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('NOT: ARTIK SiMULASYON YOK - GERCEK API BAGLANTISI!');
end;





{ ============================================================================
  GENIŞLETILMIŞ DATAGRID KURULUMU (TÜM MySoft API ALANLARI)
  ============================================================================
  
  MySoft API'den gelen tüm response alanlarını göstermek için genişletilmiş
  StringGrid konfigürasyonu. ERP entegrasyonlarında tüm veri görünürlüğü
  sağlar.
  ============================================================================ }
procedure TForm1.SetupDataGrid;
begin
  // Grid ayarlari - TUM ALANLAR ICIN GENISLETILDI
  StringGrid1.ColCount := 18; // 18 kolon (tüm MySoft API alanları)
  StringGrid1.RowCount := 2;  // Header + 1 boş satır (minimum gereksinim)
  StringGrid1.FixedRows := 1;
  StringGrid1.FixedCols := 0;
  StringGrid1.Options := StringGrid1.Options + [goRowSelect];
  
  // ========================================================================
  // KOLON BAŞLIKLARI (MySoft API Response Alanları)
  // ========================================================================
  StringGrid1.Cells[0, 0] := 'ID';                    // Sistem ID
  StringGrid1.Cells[1, 0] := 'Fatura No';             // docNo
  StringGrid1.Cells[2, 0] := 'Tarih';                 // docDate
  StringGrid1.Cells[3, 0] := 'VKN/TCKN';              // vknTckn
  StringGrid1.Cells[4, 0] := 'Unvan';                 // accountName
  StringGrid1.Cells[5, 0] := 'Durum';                 // invoiceStatusText
  StringGrid1.Cells[6, 0] := 'Profil';                // profile
  StringGrid1.Cells[7, 0] := 'Tip';                   // invoiceType
  StringGrid1.Cells[8, 0] := 'ETTN';                  // ettn
  StringGrid1.Cells[9, 0] := 'Gonderen PK';           // pkAlias
  StringGrid1.Cells[10, 0] := 'Alici GB';             // gbAlias
  StringGrid1.Cells[11, 0] := 'Ana Para';             // lineExtensionAmount
  StringGrid1.Cells[12, 0] := 'Vergi Haric';          // taxExclusiveAmount
  StringGrid1.Cells[13, 0] := 'Vergi Dahil';          // taxInclusiveAmount
  StringGrid1.Cells[14, 0] := 'Odenecek';             // payableAmount
  StringGrid1.Cells[15, 0] := 'KDV Tutari';           // taxTotalTra
  StringGrid1.Cells[16, 0] := 'Indirim';              // allowanceTotalAmount
  StringGrid1.Cells[17, 0] := 'Yuvarlama';            // payableRoundingAmount

  // ========================================================================
  // KOLON GENİŞLİKLERİ (Optimal görünüm için)
  // ========================================================================
  StringGrid1.ColWidths[0] := 60;    // ID
  StringGrid1.ColWidths[1] := 140;   // Fatura No
  StringGrid1.ColWidths[2] := 80;    // Tarih
  StringGrid1.ColWidths[3] := 90;    // VKN/TCKN
  StringGrid1.ColWidths[4] := 180;   // Ünvan
  StringGrid1.ColWidths[5] := 80;    // Durum
  StringGrid1.ColWidths[6] := 100;   // Profil
  StringGrid1.ColWidths[7] := 80;    // Tip
  StringGrid1.ColWidths[8] := 120;   // ETTN (kısaltılacak)
  StringGrid1.ColWidths[9] := 120;   // Gönderen PK (kısaltılacak)
  StringGrid1.ColWidths[10] := 120;  // Alıcı GB (kısaltılacak)
  StringGrid1.ColWidths[11] := 90;   // Ana Para
  StringGrid1.ColWidths[12] := 90;   // Vergi Hariç
  StringGrid1.ColWidths[13] := 90;   // Vergi Dahil
  StringGrid1.ColWidths[14] := 90;   // Ödenecek
  StringGrid1.ColWidths[15] := 80;   // KDV Tutarı
  StringGrid1.ColWidths[16] := 70;   // İndirim
  StringGrid1.ColWidths[17] := 70;   // Yuvarlama
end;

{ ============================================================================
  GELEN FATURA SORGULAMA PROSEDURU (ERP ENTEGRASYON REHBERI)
  ============================================================================
  
  Bu prosedur MySoft API'den gelen faturaları sorgulamak için kullanılır.
  ERP firmalarının kendi sistemlerine entegre edebilmeleri için detaylı 
  açıklamalar eklenmiştir.
  
  KULLANIM ALANLARI:
  - E-Fatura gelen kutusu sorgulama
  - Belirli tarih aralığında fatura listesi alma
  - Fatura durumu kontrolü (KABUL, RED, vs.)
  - Toplu fatura işleme
  
  API ENDPOINT'LER:
  - Token: https://edocumentapi.mytest.tr/oauth/token
  - Fatura Listesi: https://edocumentapi.mytest.tr/api/invoiceinbox/getinvoiceinboxwithheaderinfolistforperiod
  
  PARAMETRELER:
  - StartDate: Başlangıç tarihi (TDateTime)
  - EndDate: Bitiş tarihi (TDateTime)
  
  DONUŞ DEGERI: Yok (DataGrid'e direkt yükleme yapar)
  ============================================================================ }
procedure TForm1.LoadInvoiceDataToGrid(StartDate, EndDate: TDateTime);
var
  APIResponse, Token: string;          // API yanıtı ve OAuth token
  JSONObj: TJSONObject;                // Ana JSON nesnesi
  DataArray: TJSONArray;               // Fatura listesi array'i
  i, RowIndex: Integer;                // Döngü sayaçları
  EntegratorAyarlari: TEntegratorAyarlari;  // Bağlantı ayarları
  StartDateStr, EndDateStr: string;    // API için tarih formatları
begin
  try
    // ========================================================================
    // ADIM 1: HAZIRLIK İŞLEMLERİ
    // ========================================================================
    
    ClearDataGrid; // Mevcut grid verilerini temizle
    
    { ENTEGRATOR AYARLARINI YUKLE
      Bu ayarlar Settings/EntegratorAyarlari.ini dosyasından okunur
      ERP sistemlerinde bu bilgiler genellikle veritabanında saklanır }
    EntegratorAyarlari := TSettingsManager.LoadEntegratorAyarlari;
    
    { TARİH FORMATLARİNI HAZIRLA
      MySoft API tarih formatı: YYYY-MM-DD
      Delphi TDateTime'dan string'e dönüşüm }
    StartDateStr := FormatDateTime('yyyy-mm-dd', StartDate);
    EndDateStr := FormatDateTime('yyyy-mm-dd', EndDate);
    
    // Kullanıcıya işlem bilgisi ver
    Memo1.Lines.Add('GERCEK MySoft API Baglantisi Baslatiliyor...');
    Memo1.Lines.Add('URL: ' + EntegratorAyarlari.TestURL);
    Memo1.Lines.Add('Kullanici: ' + EntegratorAyarlari.KullaniciAdi);
    
    // ========================================================================
    // ADIM 2: OAUTH 2.0 TOKEN ALMA
    // ========================================================================
    
    { TOKEN ALMA İŞLEMİ
      MySoft API OAuth 2.0 kullanır. Her API çağrısından önce token alınmalı.
      Token 24 saat geçerlidir. ERP sistemlerinde token cache'lenebilir. }
    Memo1.Lines.Add('1. Token aliniyor...');
    Token := FGelenFaturaAPI.GetAccessToken(EntegratorAyarlari.KullaniciAdi, EntegratorAyarlari.Sifre);
    
    { TOKEN HATA KONTROLU
      API'den hata dönerse işlemi durdur }
    if Pos('HATA:', Token) > 0 then
    begin
      Memo1.Lines.Add('TOKEN HATASI: ' + Token);
      Exit; // İşlemi sonlandır
    end;
    
    Memo1.Lines.Add('Token basariyla alindi! (Uzunluk: ' + IntToStr(Length(Token)) + ' karakter)');
    
    // ========================================================================
    // ADIM 3: FATURA LİSTESİ SORGULAMA
    // ========================================================================
    
    { FATURA LİSTESİ API ÇAĞRISI
      Bu çağrı belirtilen tarih aralığındaki tüm gelen faturaları getirir
      Pagination desteği var (limit, afterValue parametreleri) }
    Memo1.Lines.Add('2. Gelen faturalar getiriliyor...');
    Memo1.Lines.Add('Tarih araligi: ' + StartDateStr + ' - ' + EndDateStr);
    
    APIResponse := FGelenFaturaAPI.GetInvoiceInboxList(Token, StartDateStr, EndDateStr);
    
    { API YANIT HATA KONTROLU }
    if Pos('HATA:', APIResponse) > 0 then
    begin
      Memo1.Lines.Add('FATURA LiSTESi HATASI: ' + APIResponse);
      Exit; // İşlemi sonlandır
    end;
    
    // ========================================================================
    // ADIM 4: JSON PARSING VE VERİ İŞLEME
    // ========================================================================
    
    { JSON PARSING - MySoft API Response formatı örneği:
      data array içinde fatura objeler var
      Her fatura objesi: id, docNo, docDate, vknTckn, accountName, payableAmount, invoiceStatusText
      API'den gelen JSON response'u parse ediyoruz }
    JSONObj := TJSONObject.ParseJSONValue(APIResponse) as TJSONObject;
    if Assigned(JSONObj) then
    try
      { DATA ARRAY'İNİ AL
        API'den gelen fatura listesi "data" array'inde bulunur }
      DataArray := JSONObj.GetValue('data') as TJSONArray;
      if Assigned(DataArray) then
      begin
        RowIndex := 1; // Grid satır sayacı (0 = header)
        
        { HER FATURA İÇİN DÖNGÜ
          ERP sistemlerinde bu veriler genellikle veritabanına kaydedilir }
        for i := 0 to DataArray.Count - 1 do
        begin
          // Grid boyutunu dinamik olarak artır
          StringGrid1.RowCount := RowIndex + 1;
          
          { FATURA VERİSİNİ GRID'E EKLE
            Bu fonksiyon JSON objesini parse eder ve grid hücresine yazar }
          AddInvoiceToGrid(DataArray.Items[i] as TJSONObject, RowIndex);
          
          Inc(RowIndex); // Sonraki satıra geç
        end;
        
        // İşlem sonucu bilgisi
        Memo1.Lines.Add('GERCEK API SONUCU: ' + IntToStr(RowIndex - 1) + ' fatura yuklendi');
        Memo1.Lines.Add('Kaynak: MySoft Test Ortami (GERCEK VERILER)');
      end
      else
        Memo1.Lines.Add('API''den veri donmedi (data array bos)');
    finally
      JSONObj.Free; // Bellek temizliği
    end
    else
      Memo1.Lines.Add('API response JSON parse edilemedi!');
      
  except
    on E: Exception do
    begin
      { GENEL HATA YAKALAMA
        ERP sistemlerinde bu hatalar log dosyasına yazılmalı }
      Memo1.Lines.Add('API BAGLANTI HATASI: ' + E.Message);
    end;
  end;
end;

{ ============================================================================
  FATURA VERİSİNİ GRID'E EKLEME PROSEDURU (ERP ENTEGRASYON REHBERİ)
  ============================================================================
  
  Bu prosedur MySoft API'den gelen tek bir fatura verisini StringGrid'e ekler.
  ERP firmalarının kendi veri yapılarına uyarlamaları için detaylı açıklamalar.
  
  KULLANIM ALANLARI:
  - JSON fatura verisini UI'da gösterme
  - Veri formatı dönüşümleri
  - Hata durumlarında varsayılan değer atama
  
  PARAMETRELER:
  - InvoiceObj: MySoft API'den gelen JSON fatura objesi
  - Row: Grid'de eklenecek satır numarası
  
  MYSQL/MSSQL ÖRNEĞİ:
  INSERT INTO Invoices (ID, DocNo, DocDate, VknTckn, AccountName, Amount, Status)
  VALUES (@ID, @FaturaNo, @Tarih, @VKN, @Unvan, @TutarValue, @Durum)
  ============================================================================ }
procedure TForm1.AddInvoiceToGrid(const InvoiceObj: TJSONObject; Row: Integer);
var
  // Temel fatura bilgileri
  ID, FaturaNo, Tarih, VKN, Unvan, Durum: string;
  Profile, InvoiceType, ETTN, PkAlias, GbAlias: string;
  
  // Tutar alanları (MySoft API'den gelen tüm tutar alanları)
  LineExtensionAmount, TaxExclusiveAmount, TaxInclusiveAmount: Double;
  PayableAmount, TaxTotalTra, AllowanceTotalAmount, PayableRoundingAmount: Double;
begin
  // ========================================================================
  // GÜVENLİK KONTROLÜ
  // ========================================================================
  if not Assigned(InvoiceObj) then Exit; // Null pointer kontrolü
  
  // ========================================================================
  // JSON VERİLERİNİ ÇIKART - TÜM ALANLAR (SAFE EXTRACTION)
  // ========================================================================
  
  { TEMEL BİLGİLER }
  ID := InvoiceObj.GetValue<string>('id', '0');
  FaturaNo := InvoiceObj.GetValue<string>('docNo', 'N/A');
  Tarih := FormatDateTR(InvoiceObj.GetValue<string>('docDate', ''));
  VKN := InvoiceObj.GetValue<string>('vknTckn', 'N/A');
  Unvan := InvoiceObj.GetValue<string>('accountName', 'N/A');
  Durum := InvoiceObj.GetValue<string>('invoiceStatusText', 'BILINMIYOR');
  
  { FATURA TİP VE PROFİL BİLGİLERİ }
  Profile := InvoiceObj.GetValue<string>('profile', 'N/A');           // TICARIFATURA, TEMELFATURA
  InvoiceType := InvoiceObj.GetValue<string>('invoiceType', 'N/A');   // TEVKIFAT, SATIS, vb.
  
  { ELEKTRONİK BELGE BİLGİLERİ }
  ETTN := InvoiceObj.GetValue<string>('ettn', 'N/A');                 // Elektronik belge ETTN
  PkAlias := InvoiceObj.GetValue<string>('pkAlias', 'N/A');           // Gönderen posta kutusu
  GbAlias := InvoiceObj.GetValue<string>('gbAlias', 'N/A');           // Alıcı posta kutusu
  
  { TUTAR BİLGİLERİ - MySoft API'deki tüm tutar alanları }
  LineExtensionAmount := InvoiceObj.GetValue<Double>('lineExtensionAmount', 0);     // Ana para (KDV hariç)
  TaxExclusiveAmount := InvoiceObj.GetValue<Double>('taxExclusiveAmount', 0);       // Vergi hariç tutar
  TaxInclusiveAmount := InvoiceObj.GetValue<Double>('taxInclusiveAmount', 0);       // Vergi dahil tutar
  PayableAmount := InvoiceObj.GetValue<Double>('payableAmount', 0);                 // Ödenecek tutar
  TaxTotalTra := InvoiceObj.GetValue<Double>('taxTotalTra', 0);                     // KDV tutarı
  AllowanceTotalAmount := InvoiceObj.GetValue<Double>('allowanceTotalAmount', 0);   // İndirim tutarı
  PayableRoundingAmount := InvoiceObj.GetValue<Double>('payableRoundingAmount', 0); // Yuvarlama tutarı
  
  // ========================================================================
  // VERİLERİ GRID'E YAZMA - TÜM ALANLAR (18 KOLON)
  // ========================================================================
  
  { TEMEL BİLGİLER (0-5) }
  StringGrid1.Cells[0, Row] := ID;                                    // Sistem ID
  StringGrid1.Cells[1, Row] := FaturaNo;                              // Fatura No
  StringGrid1.Cells[2, Row] := Tarih;                                 // Fatura Tarihi
  StringGrid1.Cells[3, Row] := VKN;                                   // VKN/TCKN
  StringGrid1.Cells[4, Row] := Copy(Unvan, 1, 25);                   // Ünvan (25 karakter)
  StringGrid1.Cells[5, Row] := Durum;                                 // Fatura Durumu
  
  { FATURA TİP BİLGİLERİ (6-7) }
  StringGrid1.Cells[6, Row] := Profile;                               // Profil (TICARIFATURA/TEMELFATURA)
  StringGrid1.Cells[7, Row] := InvoiceType;                           // Tip (TEVKIFAT/SATIS/vb.)
  
  { ELEKTRONİK BELGE BİLGİLERİ (8-10) }
  StringGrid1.Cells[8, Row] := Copy(ETTN, 1, 15) + '...';            // ETTN (kısaltılmış)
  StringGrid1.Cells[9, Row] := Copy(PkAlias, 1, 15) + '...';         // Gönderen PK (kısaltılmış)
  StringGrid1.Cells[10, Row] := Copy(GbAlias, 1, 15) + '...';        // Alıcı GB (kısaltılmış)
  
  { TUTAR BİLGİLERİ (11-17) - TÜM MySoft API TUTAR ALANLARI }
  StringGrid1.Cells[11, Row] := FormatCurrencyTL(LineExtensionAmount);   // Ana Para
  StringGrid1.Cells[12, Row] := FormatCurrencyTL(TaxExclusiveAmount);     // Vergi Hariç
  StringGrid1.Cells[13, Row] := FormatCurrencyTL(TaxInclusiveAmount);     // Vergi Dahil
  StringGrid1.Cells[14, Row] := FormatCurrencyTL(PayableAmount);          // Ödenecek Tutar
  StringGrid1.Cells[15, Row] := FormatCurrencyTL(TaxTotalTra);            // KDV Tutarı
  StringGrid1.Cells[16, Row] := FormatCurrencyTL(AllowanceTotalAmount);   // İndirim Tutarı
  StringGrid1.Cells[17, Row] := FormatCurrencyTL(PayableRoundingAmount);  // Yuvarlama Tutarı
  
  { ERP ENTEGRASYONİ İÇİN NOT:
    Artık MySoft API'den gelen tüm alanlar görünür durumda:
    - Fatura profil ve tip bilgileri iş akışı kuralları için
    - ETTN bilgisi belge takibi için
    - Posta kutusu bilgileri şube/lokasyon yönetimi için
    - Detaylı tutar bilgileri muhasebe entegrasyonu için
    
    ERP sistemlerinde bu verilerle yapılabilecekler:
    - Profil bazında farklı iş akışları (TICARIFATURA vs TEMELFATURA)
    - Tip bazında farklı muhasebe kodları (TEVKIFAT vs SATIS)
    - ETTN ile belge doğrulama ve takip
    - Tutar detayları ile otomatik muhasebe fişi oluşturma }
end;

function TForm1.FormatCurrencyTL(const Value: Double): string;
begin
  Result := FormatFloat('#,##0.00', Value);
end;

function TForm1.FormatDateTR(const DateStr: string): string;
begin
  try
    // ISO 8601 format: 2025-07-10T00:00:00+03:00 -> dd.mm.yyyy
    if Length(DateStr) >= 10 then
      Result := Copy(DateStr, 9, 2) + '.' + Copy(DateStr, 6, 2) + '.' + Copy(DateStr, 1, 4)
    else
      Result := 'N/A';
  except
    Result := 'N/A';
  end;
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  // Header row'u bold yap
  if ARow = 0 then
  begin
    StringGrid1.Canvas.Font.Style := [fsBold];
    StringGrid1.Canvas.Brush.Color := clBtnFace;
  end
  else
  begin
    StringGrid1.Canvas.Font.Style := [];
    if gdSelected in State then
      StringGrid1.Canvas.Brush.Color := clHighlight
    else
      StringGrid1.Canvas.Brush.Color := clWindow;
  end;
  
  // Hucre icerigi ciz
  StringGrid1.Canvas.FillRect(Rect);
  StringGrid1.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, StringGrid1.Cells[ACol, ARow]);
end;

{ ============================================================================
  GENIŞLETILMIŞ DATAGRID TEMIZLEME (18 KOLON)
  ============================================================================ }
procedure TForm1.ClearDataGrid;
var
  i: Integer;
begin
  StringGrid1.RowCount := 2; // Header + 1 boş satır (minimum gereksinim)
  StringGrid1.FixedRows := 1;
  
  // Tüm 18 kolonu temizle
  for i := 0 to StringGrid1.ColCount - 1 do
    StringGrid1.Cells[i, 1] := '';
end;



procedure TForm1.btnFiltreleClick(Sender: TObject);
begin
  if dtpBitis.Date < dtpBaslangic.Date then
  begin
    ShowMessage('Bitis tarihi baslangic tarihinden kucuk olamaz!');
    Exit;
  end;
  
  // GERCEK API sorgulama baslatiliyor
  Memo1.Lines.Add('');
  Memo1.Lines.Add('=== GERCEK MySoft API SORGULAMA ===');
  
  LoadInvoiceDataToGrid(dtpBaslangic.Date, dtpBitis.Date);
  
  Memo1.Lines.Add('=== API SORGULAMA TAMAMLANDI ===');
end;

procedure TForm1.btnTumunuClick(Sender: TObject);
begin
  Memo1.Lines.Add('');
  Memo1.Lines.Add('=== TUM KAYITLAR (GERCEK API) ===');
  Memo1.Lines.Add('Tarih araligi: 01.01.2024 - 31.12.2025 (Genis arama)');
  
  // Tum kayitlari goster (genis tarih araligi)
  LoadInvoiceDataToGrid(EncodeDate(2024, 1, 1), EncodeDate(2025, 12, 31));
  
  Memo1.Lines.Add('=== GERCEK API SORGULAMA TAMAMLANDI ===');
end;

end.
