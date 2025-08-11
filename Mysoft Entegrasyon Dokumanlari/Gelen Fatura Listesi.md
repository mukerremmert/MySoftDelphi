# Gelen Fatura Listesi API (ERP Entegrasyon Rehberi)

## 📋 Genel Bakış
Bu endpoint MySoft E-Fatura sisteminde belirli bir tarih aralığındaki gelen faturaları listelemek için kullanılır. ERP sistemleri için kritik bir entegrasyon noktasıdır.

## 🔗 API Detayları
**POST** `/api/invoiceinbox/getinvoiceinboxwithheaderinfolistforperiod`

**Base URL:** `https://edocumentapi.mytest.tr` (Test Ortamı)
**Base URL:** `https://edocumentapi.mysoft.com.tr` (Canlı Ortam)

## 🔐 Authentication
Bearer Token gereklidir. Token almak için önce `/oauth/token` endpoint'ini kullanın.

### Token Alma Örneği
```pascal
// Önce token alın (24 saat geçerli)
Token := TMySoftAPI.GetAccessToken('kullanici_adi', 'sifre');
```

## 📤 Request

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
Accept: application/json
```

### Request Body
```json
{
  "startDate": "2025-01-01",
  "endDate": "2025-01-31",
  "limit": 100,
  "pkAlias": "",
  "sessionStatus": "",
  "tenantIdentifierNumber": "",
  "afterValue": ""
}
```

### Parametreler

| Parametre | Tip | Zorunlu | Açıklama | ERP Kullanımı |
|-----------|-----|---------|----------|---------------|
| `startDate` | string | ✅ | Başlangıç tarihi (YYYY-MM-DD) | Muhasebe dönem filtresi |
| `endDate` | string | ✅ | Bitiş tarihi (YYYY-MM-DD) | Muhasebe dönem filtresi |
| `limit` | integer | ❌ | Kayıt sayısı (max: 1000, default: 50) | Performans optimizasyonu |
| `pkAlias` | string | ❌ | Posta kutusu filtresi | Şube/lokasyon filtresi |
| `sessionStatus` | string | ❌ | Oturum durumu | Devir kayıt kontrolü |
| `tenantIdentifierNumber` | string | ❌ | Müşteri kimlik no | Multi-tenant sistemler |
| `afterValue` | string | ❌ | Pagination token | Büyük veri setleri |

## 📥 Response

### Başarılı Response (200 OK)
```json
{
  "data": [
    {
      "id": 104298,                                    // Sistem ID (Primary Key)
      "profile": "TICARIFATURA",                       // Fatura Profili
      "invoiceStatusText": "KABUL",                    // Fatura Durumu
      "invoiceType": "TEVKIFAT",                       // Fatura Tipi
      "ettn": "8c96ca19-323e-4e18-893b-54d33723f360",  // Elektronik Belge ETTN
      "docNo": "AA52025000000054",                     // Fatura Numarası
      "docDate": "2025-01-10T00:00:00+03:00",         // Fatura Tarihi (ISO 8601)
      "pkAlias": "urn:mail:adpk@ds.com",               // Gönderen Posta Kutusu
      "gbAlias": "urn:mail:asdgb@5",                   // Alıcı Posta Kutusu
      "vknTckn": "6271036106",                         // VKN/TCKN
      "accountName": "MYSOFT DIJITAL DONUSUM",         // Firma Ünvanı
      "lineExtensionAmount": 10000.00,                 // KDV Hariç Tutar
      "taxExclusiveAmount": 10000.00,                  // Vergi Hariç Tutar
      "taxInclusiveAmount": 12000.00,                  // Vergi Dahil Tutar
      "payableRoundingAmount": 0.00,                   // Yuvarlama Tutarı
      "payableAmount": 10600.00,                       // Ödenecek Tutar
      "allowanceTotalAmount": 0.00,                    // İndirim Tutarı
      "taxTotalTra": 600.00                            // KDV Tutarı
    }
  ],
  "success": true,
  "message": "İşlem başarılı",
  "afterValue": "eyJpZCI6MTA0Mjk4fQ=="  // Sonraki sayfa için token
}
```

### 🏢 **ERP Alan Açıklamaları (Detaylı Entegrasyon Rehberi)**

#### **📋 Temel Fatura Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | İş Kuralları | Örnek Değer |
|------|---------------|-----------------|--------------|-------------|
| **`id`** | Sistem ID (Primary Key) | `BIGINT` | Benzersiz, MySoft'tan gelir | `104298` |
| **`docNo`** | Fatura Numarası | `VARCHAR(50)` | Benzersiz, GİB formatı | `AA52025000000054` |
| **`docDate`** | Fatura Tarihi | `DATETIME` | ISO 8601 format | `2025-01-10T00:00:00+03:00` |
| **`ettn`** | Elektronik Belge ETTN | `VARCHAR(36)` | UUID format, belge takibi için | `8c96ca19-323e-4e18-893b...` |

#### **🏢 Firma ve İletişim Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | İş Kuralları | Örnek Değer |
|------|---------------|-----------------|--------------|-------------|
| **`vknTckn`** | Vergi/TC Kimlik No | `VARCHAR(11)` | 10 haneli VKN veya 11 haneli TCKN | `6271036106` |
| **`accountName`** | Firma Ünvanı | `VARCHAR(255)` | Cari hesap eşleştirmesi için | `MYSOFT DIJITAL DÖNÜŞÜM` |
| **`pkAlias`** | Gönderen Posta Kutusu | `VARCHAR(100)` | Şube/lokasyon takibi | `urn:mail:adpk@s.com` |
| **`gbAlias`** | Alıcı Posta Kutusu | `VARCHAR(100)` | Kendi posta kutunuz | `urn:mail:asdgb@5` |

#### **📊 Fatura Tip ve Profil Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | İş Kuralları | Örnek Değer |
|------|---------------|-----------------|--------------|-------------|
| **`profile`** | Fatura Profili | `VARCHAR(20)` | TICARIFATURA/TEMELFATURA | `TICARIFATURA` |
| **`invoiceType`** | Fatura Tipi | `VARCHAR(20)` | TEVKIFAT/SATIS/IADE/ISTISNA | `TEVKIFAT` |
| **`invoiceStatusText`** | Fatura Durumu | `VARCHAR(20)` | KABUL/RED/BEKLEMEDE/İPTAL | `KABUL` |

#### **💰 Tutar Bilgileri (Muhasebe Entegrasyonu)**
| Alan | ERP Kullanımı | Veritabanı Tipi | Muhasebe Hesabı | Örnek Değer |
|------|---------------|-----------------|-----------------|-------------|
| **`lineExtensionAmount`** | Ana Para (KDV Hariç) | `DECIMAL(18,2)` | 600 - Yurtiçi Satışlar | `10000.00` |
| **`taxExclusiveAmount`** | Vergi Hariç Tutar | `DECIMAL(18,2)` | İndirim sonrası ana para | `10000.00` |
| **`taxInclusiveAmount`** | Vergi Dahil Tutar | `DECIMAL(18,2)` | KDV dahil toplam | `12000.00` |
| **`payableAmount`** | Ödenecek Tutar | `DECIMAL(18,2)` | 320 - Satıcılar (Nihai tutar) | `10600.00` |
| **`taxTotalTra`** | KDV Tutarı | `DECIMAL(18,2)` | 191 - İndirilecek KDV | `600.00` |
| **`allowanceTotalAmount`** | İndirim Tutarı | `DECIMAL(18,2)` | 640 - Satış İskontoları | `0.00` |
| **`payableRoundingAmount`** | Yuvarlama Tutarı | `DECIMAL(18,2)` | 679 - Diğer Olağan Gelir/Gider | `0.00` |

#### **🔄 ERP İş Akışı Önerileri**

##### **1. Fatura Durumuna Göre İşlem:**
```sql
-- KABUL durumundaki faturalar için otomatik muhasebe fişi
CASE invoiceStatusText 
  WHEN 'KABUL' THEN 'Muhasebe fişi oluştur'
  WHEN 'RED' THEN 'Red sebebini logla, bildirim gönder'
  WHEN 'BEKLEMEDE' THEN 'Takip listesine ekle'
  WHEN 'İPTAL' THEN 'İptal işlemlerini gerçekleştir'
END
```

##### **2. Fatura Tipine Göre Muhasebe Kodları:**
```sql
-- Fatura tipine göre farklı hesap kodları
CASE invoiceType
  WHEN 'TEVKIFAT' THEN '191.01 - Tevkifata Tabi KDV'
  WHEN 'SATIS' THEN '191.02 - Normal KDV' 
  WHEN 'IADE' THEN '191.03 - İade KDV'
  WHEN 'ISTISNA' THEN '191.04 - İstisna KDV'
END
```

##### **3. VKN/TCKN ile Cari Hesap Eşleştirme:**
```sql
-- Otomatik cari hesap bulma
SELECT CariKod FROM CariHesaplar 
WHERE VergiNo = vknTckn 
   OR TcKimlikNo = vknTckn
   OR Unvan LIKE '%' + accountName + '%'
```

#### **⚡ Performans Optimizasyonu**

##### **Veritabanı İndeksleri:**
```sql
-- Performans için gerekli indeksler
CREATE INDEX IX_Invoices_DocNo ON Invoices(docNo);
CREATE INDEX IX_Invoices_VknTckn ON Invoices(vknTckn);
CREATE INDEX IX_Invoices_DocDate ON Invoices(docDate);
CREATE INDEX IX_Invoices_Status ON Invoices(invoiceStatusText);
CREATE INDEX IX_Invoices_ETTN ON Invoices(ettn);
```

##### **Batch İşleme Önerisi:**
- **100'lü gruplar** halinde fatura çekin
- **Paralel işleme** için thread pool kullanın
- **Memory yönetimi** için büyük listeler işledikten sonra temizleyin

## ⚠️ Hata Kodları

### HTTP Status Kodları
| Kod | Durum | Açıklama | ERP Aksiyonu |
|-----|-------|----------|--------------|
| 200 | OK | Başarılı | Veriyi işle |
| 400 | Bad Request | Geçersiz parametre | Parametreleri kontrol et |
| 401 | Unauthorized | Token geçersiz/süresi dolmuş | Token yenile |
| 403 | Forbidden | Erişim izni yok | Yetki kontrolü |
| 429 | Too Many Requests | Rate limit aşıldı | Bekle ve tekrar dene |
| 500 | Internal Server Error | Sunucu hatası | Tekrar dene, log kaydet |

### Hata Response Formatı
```json
{
  "success": false,
  "message": "Geçersiz tarih formatı",
  "errorCode": "INVALID_DATE_FORMAT",
  "details": {
    "field": "startDate",
    "value": "invalid-date"
  }
}
```

## 💻 Delphi Entegrasyon Örneği

### Basit Kullanım
```pascal
procedure GetInvoiceList;
var
  Token, Response: string;
  JSONObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
begin
  // 1. Token al
  Token := TMySoftAPI.GetAccessToken('kullanici', 'sifre');
  
  // 2. Fatura listesi sorgula
  Response := TMySoftAPI.GetInvoiceInboxList(Token, '2025-01-01', '2025-01-31');
  
  // 3. JSON parse et
  JSONObj := TJSONObject.ParseJSONValue(Response) as TJSONObject;
  try
    DataArray := JSONObj.GetValue('data') as TJSONArray;
    
    // 4. Her faturayı işle
    for i := 0 to DataArray.Count - 1 do
    begin
      ProcessInvoice(DataArray.Items[i] as TJSONObject);
    end;
  finally
    JSONObj.Free;
  end;
end;
```

### ERP Entegrasyon Örneği
```pascal
procedure SyncInvoicesWithERP(const StartDate, EndDate: TDateTime);
var
  Token, Response: string;
  JSONObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
  InvoiceObj: TJSONObject;
  InvoiceData: TInvoiceRecord;
begin
  try
    // Token al (cache'den veya yeni)
    Token := GetCachedTokenOrRefresh();
    
    // API'den fatura listesi al
    Response := TMySoftAPI.GetInvoiceInboxList(
      Token, 
      FormatDateTime('yyyy-mm-dd', StartDate),
      FormatDateTime('yyyy-mm-dd', EndDate)
    );
    
    JSONObj := TJSONObject.ParseJSONValue(Response) as TJSONObject;
    try
      DataArray := JSONObj.GetValue('data') as TJSONArray;
      
      for i := 0 to DataArray.Count - 1 do
      begin
        InvoiceObj := DataArray.Items[i] as TJSONObject;
        
        // JSON'dan ERP record'una dönüştür
        InvoiceData := ConvertJSONToInvoiceRecord(InvoiceObj);
        
        // ERP veritabanına kaydet/güncelle
        if InvoiceExistsInERP(InvoiceData.ID) then
          UpdateInvoiceInERP(InvoiceData)
        else
          InsertInvoiceToERP(InvoiceData);
          
        // İş akışı tetikle
        TriggerInvoiceWorkflow(InvoiceData);
      end;
      
      LogSuccess(Format('Başarıyla %d fatura senkronize edildi', [DataArray.Count]));
      
    finally
      JSONObj.Free;
    end;
    
  except
    on E: Exception do
    begin
      LogError('Fatura senkronizasyon hatası: ' + E.Message);
      raise;
    end;
  end;
end;
```

## 🚀 Pagination Kullanımı

Büyük veri setleri için pagination kullanın:

```pascal
procedure GetAllInvoicesWithPagination;
var
  Token, Response, AfterValue: string;
  HasMore: Boolean;
  TotalCount: Integer;
begin
  Token := TMySoftAPI.GetAccessToken('kullanici', 'sifre');
  AfterValue := '';
  HasMore := True;
  TotalCount := 0;
  
  while HasMore do
  begin
    Response := TMySoftAPI.GetInvoiceInboxListWithPagination(
      Token, '2025-01-01', '2025-01-31', 100, AfterValue);
      
    // Response'u işle
    ProcessInvoicePage(Response, TotalCount);
    
    // Sonraki sayfa var mı kontrol et
    AfterValue := ExtractAfterValueFromResponse(Response);
    HasMore := (AfterValue <> '');
  end;
  
  WriteLn(Format('Toplam %d fatura işlendi', [TotalCount]));
end;
```

## 📊 Performance Önerileri

### ERP Sistemleri İçin Best Practices

1. **Token Yönetimi**
   ```pascal
   // Token'ı cache'le (24 saat geçerli)
   if TokenExpired(CachedToken) then
     CachedToken := GetNewToken();
   ```

2. **Batch Processing**
   ```pascal
   // Büyük veri setlerini batch'lerde işle
   const BATCH_SIZE = 100;
   ProcessInvoicesInBatches(InvoiceList, BATCH_SIZE);
   ```

3. **Error Recovery**
   ```pascal
   // Retry mekanizması
   function CallAPIWithRetry(APIFunc: TFunc<string>): string;
   begin
     // 3 deneme, exponential backoff
   end;
   ```

4. **Async Processing**
   ```pascal
   // Büyük senkronizasyonları async yap
   TTask.Run(procedure
   begin
     SyncInvoicesWithERP(StartDate, EndDate);
   end);
   ```

## 📝 ERP Entegrasyon Checklist

- [ ] Token yönetimi implementasyonu
- [ ] Hata yakalama ve logging
- [ ] Pagination desteği
- [ ] Retry mekanizması
- [ ] Veritabanı schema hazırlığı
- [ ] İş akışı entegrasyonu
- [ ] Performance monitoring
- [ ] Test senaryoları

---

## 🏢 **ERP Firmaları İçin Pratik Entegrasyon Örnekleri**

### 📊 **1. Muhasebe Sistemi Entegrasyonu**

#### **Otomatik Muhasebe Fişi Oluşturma:**
```pascal
procedure CreateAccountingEntryFromInvoice(const InvoiceObj: TJSONObject);
var
  FisNo: string;
  Borc, Alacak: Double;
  VknTckn, AccountName: string;
  InvoiceType: string;
begin
  // Fatura bilgilerini al
  VknTckn := InvoiceObj.GetValue<string>('vknTckn');
  AccountName := InvoiceObj.GetValue<string>('accountName');
  InvoiceType := InvoiceObj.GetValue<string>('invoiceType');
  
  // Yeni fiş numarası oluştur
  FisNo := GenerateFisNo('ALF'); // Alış Faturası
  
  // Ana para kaydı
  Borc := InvoiceObj.GetValue<Double>('lineExtensionAmount');
  CreateAccountingEntry(FisNo, '153.001', Borc, 0, 'Alış Maliyeti'); // Borç
  
  // KDV kaydı (eğer tevkifat değilse)
  if InvoiceType <> 'TEVKIFAT' then
  begin
    Alacak := InvoiceObj.GetValue<Double>('taxTotalTra');
    CreateAccountingEntry(FisNo, '191.001', Alacak, 0, 'İndirilecek KDV'); // Borç
  end;
  
  // Satıcı kaydı
  Alacak := InvoiceObj.GetValue<Double>('payableAmount');
  CreateAccountingEntry(FisNo, '320.001.' + VknTckn, 0, Alacak, AccountName); // Alacak
  
  // Fiş onayı
  ApproveAccountingEntry(FisNo);
end;
```

### 🔄 **2. İş Akışı Yönetimi**

#### **Fatura Onay Süreci:**
```pascal
procedure ProcessInvoiceApproval(const InvoiceObj: TJSONObject);
var
  Amount: Double;
  VknTckn, Status: string;
  ApprovalLevel: Integer;
begin
  Amount := InvoiceObj.GetValue<Double>('payableAmount');
  VknTckn := InvoiceObj.GetValue<string>('vknTckn');
  Status := InvoiceObj.GetValue<string>('invoiceStatusText');
  
  // Onay seviyesi belirleme
  if Amount <= 1000 then
    ApprovalLevel := 1      // Muhasebe onayı yeterli
  else if Amount <= 10000 then
    ApprovalLevel := 2      // Muhasebe + Mali İşler Müdürü
  else
    ApprovalLevel := 3;     // Genel Müdür onayı gerekli
  
  // İş akışı başlat
  case Status of
    'KABUL': 
    begin
      StartApprovalWorkflow(InvoiceObj, ApprovalLevel);
      SendNotification('Yeni fatura onay bekliyor: ' + VknTckn);
    end;
    
    'RED':
    begin
      LogRejection(InvoiceObj);
      SendAlert('Fatura reddedildi: ' + VknTckn);
    end;
  end;
end;
```

### 📧 **3. Bildirim Sistemi Entegrasyonu**

#### **E-posta/SMS Bildirimleri:**
```pascal
procedure SendInvoiceNotifications(const InvoiceObj: TJSONObject);
var
  Amount: Double;
  AccountName, DocNo: string;
  EmailBody, SmsText: string;
begin
  Amount := InvoiceObj.GetValue<Double>('payableAmount');
  AccountName := InvoiceObj.GetValue<string>('accountName');
  DocNo := InvoiceObj.GetValue<string>('docNo');
  
  // E-posta bildirimi
  EmailBody := Format(
    'Yeni e-fatura alındı:' + sLineBreak +
    'Fatura No: %s' + sLineBreak +
    'Firma: %s' + sLineBreak +
    'Tutar: %s TL' + sLineBreak +
    'Onay için sisteme giriş yapınız.',
    [DocNo, AccountName, FormatFloat('#,##0.00', Amount)]
  );
  
  SendEmail('muhasebe@firma.com', 'Yeni E-Fatura', EmailBody);
  
  // SMS bildirimi (büyük tutarlar için)
  if Amount > 10000 then
  begin
    SmsText := Format('Yeni e-fatura: %s - %.2f TL - Onay gerekli', 
      [Copy(AccountName, 1, 20), Amount]);
    SendSMS('+905551234567', SmsText);
  end;
end;
```

### 🚀 **4. Toplu İşlemler**

#### **Çoklu Fatura Onaylama:**
```pascal
procedure BatchApproveInvoices(const InvoiceIds: TArray<string>);
var
  i: Integer;
  SuccessCount, ErrorCount: Integer;
  InvoiceId: string;
begin
  SuccessCount := 0;
  ErrorCount := 0;
  
  for i := 0 to High(InvoiceIds) do
  begin
    InvoiceId := InvoiceIds[i];
    try
      // Fatura onaylama işlemi
      ApproveInvoice(InvoiceId);
      CreateAccountingEntry(InvoiceId);
      
      Inc(SuccessCount);
      LogInfo('Fatura onaylandı: ' + InvoiceId);
      
    except
      on E: Exception do
      begin
        Inc(ErrorCount);
        LogError('Fatura onaylama hatası [' + InvoiceId + ']: ' + E.Message);
      end;
    end;
  end;
  
  // Sonuç bildirimi
  ShowMessage(Format('Toplu onaylama tamamlandı. Başarılı: %d, Hatalı: %d', 
    [SuccessCount, ErrorCount]));
end;
```

---

## 📞 **ERP Firmaları İçin Teknik Destek**

### 🤝 **Entegrasyon Desteği:**
- **📧 E-posta**: info@mertbilisim.com.tr
- **🔧 Özelleştirme**: Firma ihtiyaçlarına göre özel geliştirme
- **📚 Eğitim**: Geliştirici ekipleriniz için teknik eğitim
- **🚀 Danışmanlık**: ERP entegrasyon stratejileri

### 💡 **En İyi Uygulamalar:**
1. **Token yönetimi** için cache mekanizması kullanın
2. **Hata durumlarında** retry logic implementasyonu yapın  
3. **Büyük veri setleri** için pagination kullanın
4. **Performans** için veritabanı indekslerini optimize edin
5. **Güvenlik** için tüm API çağrılarını loglayın

---

**Son Güncelleme**: 2025-01-15  
**API Versiyonu**: v1.0  
**ERP Entegrasyon Rehberi**: v2.0
**Test Ortamı**: https://edocumentapi.mytest.tr/