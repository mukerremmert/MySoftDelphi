# 📦 Gelen İrsaliye Listesi API (ERP Entegrasyon Rehberi)

## 📋 API Genel Bilgileri

**Endpoint**: `POST /api/Despatch/GetNewDespatchInboxWithHeaderInfoList`  
**Base URL**: https://edocumentapi.mytest.tr/  
**Authentication**: Bearer Token gerekli  
**Content-Type**: application/json  

## 🎯 Kullanım Amacı

Bu endpoint, MySoft e-İrsaliye sisteminden **gelen irsaliye listesini** çekmek için kullanılır. ERP sistemlerinde:
- 📦 **Mal kabul süreçleri** için
- 📊 **Stok yönetimi** entegrasyonu için  
- 🔄 **Tedarikçi takibi** için
- 📈 **Lojistik raporlaması** için

---

## 🔗 Request Formatı

### HTTP Request
```http
POST https://edocumentapi.mytest.tr/api/Despatch/GetNewDespatchInboxWithHeaderInfoList
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
```

### Request Body
```json
{
  "startDate": "2025-01-01",     // Başlangıç tarihi (YYYY-MM-DD)
  "endDate": "2025-01-31",       // Bitiş tarihi (YYYY-MM-DD)  
  "pageSize": 100,               // Sayfa başına kayıt sayısı (max: 1000)
  "pageNumber": 1,               // Sayfa numarası (1'den başlar)
  "afterValue": ""               // Pagination için (ilk istekte boş)
}
```

### Parametre Açıklamaları
| Parametre | Tip | Zorunlu | Açıklama | Örnek |
|-----------|-----|---------|----------|-------|
| `startDate` | string | ✅ | Başlangıç tarihi (YYYY-MM-DD formatında) | `"2025-01-01"` |
| `endDate` | string | ✅ | Bitiş tarihi (YYYY-MM-DD formatında) | `"2025-01-31"` |
| `pageSize` | integer | ❌ | Sayfa başına kayıt (varsayılan: 100, max: 1000) | `100` |
| `pageNumber` | integer | ❌ | Sayfa numarası (varsayılan: 1) | `1` |
| `afterValue` | string | ❌ | Pagination token (ilk istekte boş) | `""` |

---

## 📄 Response Formatı

### Başarılı Response (HTTP 200)
```json
{
  "data": [
    {
      "id": 205847,                                        // Sistem ID (Primary Key)
      "profile": "TEMELIHRSALIYE",                         // İrsaliye Profili  
      "despatchStatusText": "KABUL",                       // İrsaliye Durumu
      "despatchType": "SEVK",                              // İrsaliye Tipi
      "ettn": "9d78ea25-445f-4c19-a92d-6e4472f4g8h9",     // Elektronik Belge ETTN
      "docNo": "IRS2025000000089",                         // İrsaliye Numarası
      "docDate": "2025-01-12T00:00:00+03:00",             // İrsaliye Tarihi (ISO 8601)
      "pkAlias": "urn:mail:supplier@company.com",          // Gönderen Posta Kutusu
      "gbAlias": "urn:mail:receiver@mycompany.com",        // Alıcı Posta Kutusu
      "vknTckn": "1234567890",                             // VKN/TCKN
      "accountName": "TEDARIKCI FIRMA A.S.",               // Firma Ünvanı
      "shipmentDate": "2025-01-12T00:00:00+03:00",        // Sevk Tarihi
      "deliveryDate": "2025-01-13T00:00:00+03:00",        // Teslimat Tarihi
      "carrierName": "KARGO FIRMASI",                      // Taşıyıcı Firma
      "vehiclePlateNumber": "34 ABC 123",                  // Araç Plaka No
      "totalLineCount": 15,                                // Toplam Kalem Sayısı
      "totalQuantity": 250.00,                             // Toplam Miktar
      "totalAmount": 12500.00,                             // Toplam Tutar (varsa)
      "currencyCode": "TRY",                               // Para Birimi
      "notes": "Acil sevkiyat - Dikkatli taşınacak"       // Notlar
    }
  ],
  "success": true,
  "message": "İşlem başarılı",
  "afterValue": "eyJpZCI6MjA1ODQ3fQ=="  // Sonraki sayfa için token
}
```

### 🏢 **ERP Alan Açıklamaları (Detaylı Entegrasyon Rehberi)**

#### **📋 Temel İrsaliye Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | İş Kuralları | Örnek Değer |
|------|---------------|-----------------|--------------|-------------|
| **`id`** | Sistem ID (Primary Key) | `BIGINT` | Benzersiz, MySoft'tan gelir | `205847` |
| **`docNo`** | İrsaliye Numarası | `VARCHAR(50)` | Benzersiz, GİB formatı | `IRS2025000000089` |
| **`docDate`** | İrsaliye Tarihi | `DATETIME` | ISO 8601 format | `2025-01-12T00:00:00+03:00` |
| **`ettn`** | Elektronik Belge ETTN | `VARCHAR(36)` | UUID format, belge takibi için | `9d78ea25-445f-4c19-a92d...` |

#### **🏢 Firma ve İletişim Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | İş Kuralları | Örnek Değer |
|------|---------------|-----------------|--------------|-------------|
| **`vknTckn`** | Vergi/TC Kimlik No | `VARCHAR(11)` | 10 haneli VKN veya 11 haneli TCKN | `1234567890` |
| **`accountName`** | Firma Ünvanı | `VARCHAR(255)` | Tedarikçi hesap eşleştirmesi için | `TEDARIKCI FIRMA A.S.` |
| **`pkAlias`** | Gönderen Posta Kutusu | `VARCHAR(100)` | Tedarikçi lokasyon takibi | `urn:mail:supplier@company.com` |
| **`gbAlias`** | Alıcı Posta Kutusu | `VARCHAR(100)` | Kendi posta kutunuz | `urn:mail:receiver@mycompany.com` |

#### **📊 İrsaliye Tip ve Profil Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | İş Kuralları | Örnek Değer |
|------|---------------|-----------------|--------------|-------------|
| **`profile`** | İrsaliye Profili | `VARCHAR(20)` | TEMELIHRSALIYE/KAMU | `TEMELIHRSALIYE` |
| **`despatchType`** | İrsaliye Tipi | `VARCHAR(20)` | SEVK/MUSTAHSIL/KOMISYON | `SEVK` |
| **`despatchStatusText`** | İrsaliye Durumu | `VARCHAR(20)` | KABUL/RED/BEKLEMEDE/İPTAL | `KABUL` |

#### **🚚 Lojistik ve Sevkiyat Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | Lojistik Entegrasyonu | Örnek Değer |
|------|---------------|-----------------|----------------------|-------------|
| **`shipmentDate`** | Sevk Tarihi | `DATETIME` | Kargo takip sistemi için | `2025-01-12T00:00:00+03:00` |
| **`deliveryDate`** | Teslimat Tarihi | `DATETIME` | SLA hesaplama için | `2025-01-13T00:00:00+03:00` |
| **`carrierName`** | Taşıyıcı Firma | `VARCHAR(100)` | Kargo firma entegrasyonu | `KARGO FIRMASI` |
| **`vehiclePlateNumber`** | Araç Plaka No | `VARCHAR(20)` | Araç takip sistemi için | `34 ABC 123` |

#### **📦 Miktar ve Tutar Bilgileri**
| Alan | ERP Kullanımı | Veritabanı Tipi | Stok Entegrasyonu | Örnek Değer |
|------|---------------|-----------------|-------------------|-------------|
| **`totalLineCount`** | Toplam Kalem Sayısı | `INTEGER` | Stok kalem kontrolü | `15` |
| **`totalQuantity`** | Toplam Miktar | `DECIMAL(18,3)` | Stok giriş miktarı | `250.000` |
| **`totalAmount`** | Toplam Tutar | `DECIMAL(18,2)` | Maliyet hesaplama | `12500.00` |
| **`currencyCode`** | Para Birimi | `VARCHAR(3)` | Döviz kuru entegrasyonu | `TRY` |
| **`notes`** | Notlar | `TEXT` | Özel talimatlar | `Acil sevkiyat - Dikkatli taşınacak` |

#### **🔄 ERP İş Akışı Önerileri**

##### **1. İrsaliye Durumuna Göre İşlem:**
```sql
-- KABUL durumundaki irsaliyeler için otomatik stok giriş
CASE despatchStatusText 
  WHEN 'KABUL' THEN 'Stok giriş fişi oluştur'
  WHEN 'RED' THEN 'Red sebebini logla, tedarikçiye bildir'
  WHEN 'BEKLEMEDE' THEN 'Bekleyen işlemler listesine ekle'
  WHEN 'İPTAL' THEN 'İptal işlemlerini gerçekleştir'
END
```

##### **2. İrsaliye Tipine Göre İşlem:**
```sql
-- İrsaliye tipine göre farklı stok işlemleri
CASE despatchType
  WHEN 'SEVK' THEN 'Normal mal kabul işlemi'
  WHEN 'MUSTAHSIL' THEN 'Tarımsal ürün işlemi' 
  WHEN 'KOMISYON' THEN 'Komisyon mal işlemi'
END
```

##### **3. VKN/TCKN ile Tedarikçi Eşleştirme:**
```sql
-- Otomatik tedarikçi hesap bulma
SELECT TedarikciKod FROM Tedarikciler 
WHERE VergiNo = vknTckn 
   OR TcKimlikNo = vknTckn
   OR Unvan LIKE '%' + accountName + '%'
```

#### **⚡ Performans Optimizasyonu**

##### **Veritabanı İndeksleri:**
```sql
-- Performans için gerekli indeksler
CREATE INDEX IX_Despatches_DocNo ON Despatches(docNo);
CREATE INDEX IX_Despatches_VknTckn ON Despatches(vknTckn);
CREATE INDEX IX_Despatches_DocDate ON Despatches(docDate);
CREATE INDEX IX_Despatches_Status ON Despatches(despatchStatusText);
CREATE INDEX IX_Despatches_ETTN ON Despatches(ettn);
CREATE INDEX IX_Despatches_ShipmentDate ON Despatches(shipmentDate);
```

---

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
    "value": "2025/01/01",
    "expectedFormat": "YYYY-MM-DD"
  }
}
```

---

## 💻 **Delphi Entegrasyon Örneği**

### 🔧 **MySoftAPI.pas İrsaliye Metodları**

```pascal
// Gelen irsaliye listesi çekme
class function TMySoftAPI.GetIncomingDespatches(const StartDate, EndDate: string; 
  PageSize: Integer = 100; PageNumber: Integer = 1; const AfterValue: string = ''): string;
var
  HTTPClient: THTTPClient;
  Response: IHTTPResponse;
  RequestBody: string;
  Headers: TNetHeaders;
begin
  Result := '';
  
  HTTPClient := CreateHTTPClient;
  try
    // Request body hazırla
    RequestBody := BuildDespatchListRequest(StartDate, EndDate, PageSize, PageNumber, AfterValue);
    
    // Headers ayarla
    SetLength(Headers, 2);
    Headers[0] := TNetHeader.Create('Authorization', 'Bearer ' + GetCurrentToken);
    Headers[1] := TNetHeader.Create('Content-Type', 'application/json');
    
    try
      // API çağrısı
      Response := HTTPClient.Post(
        GetSettings.APIBaseURL + 'api/Despatch/GetNewDespatchInboxWithHeaderInfoList',
        TStringStream.Create(RequestBody, TEncoding.UTF8),
        nil,
        Headers
      );
      
      if Response.StatusCode = 200 then
        Result := Response.ContentAsString(TEncoding.UTF8)
      else
        raise Exception.CreateFmt('API Hatası: %d - %s', [Response.StatusCode, Response.StatusText]);
        
    except
      on E: Exception do
      begin
        LogError('İrsaliye listesi API hatası: ' + E.Message);
        raise;
      end;
    end;
    
  finally
    HTTPClient.Free;
  end;
end;

// İrsaliye listesi request body oluştur
class function TMySoftAPI.BuildDespatchListRequest(const StartDate, EndDate: string;
  PageSize, PageNumber: Integer; const AfterValue: string): string;
var
  JSONObj: TJSONObject;
begin
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('startDate', StartDate);
    JSONObj.AddPair('endDate', EndDate);
    JSONObj.AddPair('pageSize', TJSONNumber.Create(PageSize));
    JSONObj.AddPair('pageNumber', TJSONNumber.Create(PageNumber));
    JSONObj.AddPair('afterValue', AfterValue);
    
    Result := JSONObj.ToString;
  finally
    JSONObj.Free;
  end;
end;
```

### 🖼️ **Ana Form İrsaliye Entegrasyonu**

```pascal
// MainForm.pas'a irsaliye sekmesi ekleme
procedure TForm1.LoadDespatchDataToGrid(StartDate, EndDate: TDateTime);
var
  Token, APIResponse: string;
  JSONObj: TJSONObject;
  DataArray: TJSONArray;
  i, Row: Integer;
  DespatchObj: TJSONObject;
begin
  ClearDespatchGrid;
  
  try
    // Token al
    Token := TMySoftAPI.GetToken(
      SettingsManager.GetSetting('Username', ''),
      SettingsManager.GetSetting('Password', ''),
      SettingsManager.GetSetting('APIBaseURL', 'https://edocumentapi.mytest.tr/')
    );
    
    if Token = '' then
    begin
      ShowMessage('Token alınamadı! Lütfen ayarları kontrol edin.');
      Exit;
    end;
    
    // İrsaliye listesi çek
    APIResponse := TMySoftAPI.GetIncomingDespatches(
      FormatDateTime('yyyy-mm-dd', StartDate),
      FormatDateTime('yyyy-mm-dd', EndDate)
    );
    
    // JSON parse et
    JSONObj := TJSONObject.ParseJSONValue(APIResponse) as TJSONObject;
    if Assigned(JSONObj) then
    try
      DataArray := JSONObj.GetValue('data') as TJSONArray;
      if Assigned(DataArray) then
      begin
        // Grid satır sayısını ayarla
        StringGridDespatches.RowCount := DataArray.Count + 1; // +1 header için
        
        // Her irsaliye için grid'e ekle
        for i := 0 to DataArray.Count - 1 do
        begin
          DespatchObj := DataArray.Items[i] as TJSONObject;
          Row := i + 1; // Header'dan sonra
          
          AddDespatchToGrid(DespatchObj, Row);
        end;
        
        StatusBar1.Panels[0].Text := Format('Toplam %d irsaliye yüklendi.', [DataArray.Count]);
      end;
    finally
      JSONObj.Free;
    end;
    
  except
    on E: Exception do
    begin
      ShowMessage('İrsaliye yüklenirken hata: ' + E.Message);
      StatusBar1.Panels[0].Text := 'Hata: İrsaliye yüklenemedi.';
    end;
  end;
end;
```

---

## 🏢 **ERP Firmaları İçin Pratik Entegrasyon Örnekleri**

### 📦 **1. Stok Yönetimi Entegrasyonu**

#### **Otomatik Stok Giriş Fişi Oluşturma:**
```pascal
procedure CreateStockEntryFromDespatch(const DespatchObj: TJSONObject);
var
  FisNo: string;
  VknTckn, AccountName: string;
  TotalQuantity: Double;
  DespatchStatus: string;
begin
  // İrsaliye bilgilerini al
  VknTckn := DespatchObj.GetValue<string>('vknTckn');
  AccountName := DespatchObj.GetValue<string>('accountName');
  TotalQuantity := DespatchObj.GetValue<Double>('totalQuantity');
  DespatchStatus := DespatchObj.GetValue<string>('despatchStatusText');
  
  // Sadece kabul edilmiş irsaliyeler için stok girişi
  if DespatchStatus = 'KABUL' then
  begin
    // Yeni stok giriş fişi numarası oluştur
    FisNo := GenerateFisNo('STG'); // Stok Giriş
    
    // Stok giriş kaydı oluştur
    CreateStockEntry(FisNo, VknTckn, AccountName, TotalQuantity);
    
    // Bekleyen mal kabul listesinden çıkar
    RemoveFromPendingReceiptsList(DespatchObj.GetValue<string>('docNo'));
    
    LogInfo('Stok girişi oluşturuldu: ' + FisNo + ' - ' + AccountName);
  end;
end;
```

### 🚚 **2. Lojistik Takip Entegrasyonu**

#### **Kargo Takip Sistemi:**
```pascal
procedure TrackShipmentStatus(const DespatchObj: TJSONObject);
var
  CarrierName, VehiclePlate: string;
  ShipmentDate, DeliveryDate: TDateTime;
  TrackingInfo: TTrackingInfo;
begin
  CarrierName := DespatchObj.GetValue<string>('carrierName');
  VehiclePlate := DespatchObj.GetValue<string>('vehiclePlateNumber');
  ShipmentDate := ISO8601ToDateTime(DespatchObj.GetValue<string>('shipmentDate'));
  DeliveryDate := ISO8601ToDateTime(DespatchObj.GetValue<string>('deliveryDate'));
  
  // Kargo firması API entegrasyonu
  case CarrierName of
    'ARAS KARGO': TrackingInfo := GetArasTrackingInfo(VehiclePlate);
    'MNG KARGO': TrackingInfo := GetMNGTrackingInfo(VehiclePlate);
    'PTT KARGO': TrackingInfo := GetPTTTrackingInfo(VehiclePlate);
  end;
  
  // SLA kontrolü
  if Now > DeliveryDate then
  begin
    SendDelayNotification(DespatchObj, TrackingInfo);
    LogWarning('Teslimat gecikmesi: ' + DespatchObj.GetValue<string>('docNo'));
  end;
  
  // Takip bilgilerini veritabanında güncelle
  UpdateShipmentTracking(DespatchObj.GetValue<string>('id'), TrackingInfo);
end;
```

### 📧 **3. Bildirim Sistemi Entegrasyonu**

#### **İrsaliye Bildirimleri:**
```pascal
procedure SendDespatchNotifications(const DespatchObj: TJSONObject);
var
  TotalQuantity: Double;
  AccountName, DocNo, DespatchStatus: string;
  EmailBody, SmsText: string;
begin
  TotalQuantity := DespatchObj.GetValue<Double>('totalQuantity');
  AccountName := DespatchObj.GetValue<string>('accountName');
  DocNo := DespatchObj.GetValue<string>('docNo');
  DespatchStatus := DespatchObj.GetValue<string>('despatchStatusText');
  
  case DespatchStatus of
    'KABUL':
    begin
      // E-posta bildirimi
      EmailBody := Format(
        'Yeni e-irsaliye kabul edildi:' + sLineBreak +
        'İrsaliye No: %s' + sLineBreak +
        'Tedarikçi: %s' + sLineBreak +
        'Toplam Miktar: %s' + sLineBreak +
        'Mal kabul işlemi için depoya bilgi verildi.',
        [DocNo, AccountName, FormatFloat('#,##0.000', TotalQuantity)]
      );
      
      SendEmail('depo@firma.com', 'Yeni E-İrsaliye - Mal Kabul', EmailBody);
      
      // Büyük miktarlar için SMS bildirimi
      if TotalQuantity > 1000 then
      begin
        SmsText := Format('Büyük sevkiyat: %s - %.0f adet - Mal kabul gerekli', 
          [Copy(AccountName, 1, 20), TotalQuantity]);
        SendSMS('+905551234567', SmsText);
      end;
    end;
    
    'RED':
    begin
      SendEmail('satin-alma@firma.com', 'E-İrsaliye Reddedildi: ' + DocNo, 
        'İrsaliye reddedildi. Tedarikçi ile iletişime geçiniz.');
    end;
  end;
end;
```

### 🔄 **4. İş Akışı Yönetimi**

#### **Mal Kabul Onay Süreci:**
```pascal
procedure ProcessDespatchApproval(const DespatchObj: TJSONObject);
var
  TotalQuantity, TotalAmount: Double;
  VknTckn, Status: string;
  ApprovalLevel: Integer;
begin
  TotalQuantity := DespatchObj.GetValue<Double>('totalQuantity');
  TotalAmount := DespatchObj.GetValue<Double>('totalAmount');
  VknTckn := DespatchObj.GetValue<string>('vknTckn');
  Status := DespatchObj.GetValue<string>('despatchStatusText');
  
  // Onay seviyesi belirleme
  if (TotalQuantity <= 100) and (TotalAmount <= 5000) then
    ApprovalLevel := 1      // Depo sorumlusu onayı yeterli
  else if (TotalQuantity <= 1000) and (TotalAmount <= 50000) then
    ApprovalLevel := 2      // Depo sorumlusu + Satın alma müdürü
  else
    ApprovalLevel := 3;     // Genel müdür onayı gerekli
  
  // İş akışı başlat
  case Status of
    'KABUL': 
    begin
      StartReceiptApprovalWorkflow(DespatchObj, ApprovalLevel);
      SendNotification('Yeni irsaliye mal kabul bekliyor: ' + VknTckn);
    end;
    
    'RED':
    begin
      LogRejection(DespatchObj);
      SendSupplierNotification('İrsaliye reddedildi: ' + VknTckn);
    end;
  end;
end;
```

---

## 📞 **ERP Firmaları İçin Teknik Destek**

### 🤝 **Entegrasyon Desteği:**
- **📧 E-posta**: info@mertbilisim.com.tr
- **🔧 Özelleştirme**: İrsaliye iş akışları için özel geliştirme
- **📚 Eğitim**: Lojistik entegrasyon eğitimleri
- **🚀 Danışmanlık**: Stok yönetimi entegrasyon stratejileri

### 💡 **En İyi Uygulamalar:**
1. **İrsaliye durumları** için otomatik iş akışları oluşturun
2. **Stok seviyelerini** gerçek zamanlı güncelleyin
3. **Kargo takip** entegrasyonları yapın
4. **SLA takibi** için otomatik uyarılar kurun
5. **Tedarikçi performans** raporları oluşturun

---

**Son Güncelleme**: 2025-01-15  
**API Versiyonu**: v1.0  
**ERP İrsaliye Entegrasyon Rehberi**: v1.0  
**Test Ortamı**: https://edocumentapi.mytest.tr/
