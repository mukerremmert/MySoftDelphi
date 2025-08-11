# ERP Firmaları için MySoft E-Fatura Entegrasyon Rehberi

## 📋 İçindekiler
1. [Genel Bakış](#genel-bakış)
2. [Teknik Gereksinimler](#teknik-gereksinimler)
3. [API Entegrasyon Adımları](#api-entegrasyon-adımları)
4. [Kod Örnekleri](#kod-örnekleri)
5. [Hata Yönetimi](#hata-yönetimi)
6. [Best Practices](#best-practices)
7. [Test Senaryoları](#test-senaryoları)

## 🎯 Genel Bakış

Bu rehber ERP firmalarının MySoft E-Fatura API'sini kendi sistemlerine entegre etmeleri için hazırlanmıştır.

### Entegrasyon Kapsamı
- **Gelen Fatura Sorgulama**: Müşteriye gelen e-faturaları listeleme
- **Token Yönetimi**: OAuth 2.0 authentication
- **Veri Formatları**: JSON parsing ve dönüşümler
- **Hata Yönetimi**: API hatalarını yakalama ve işleme

### Desteklenen Operasyonlar
- ✅ Gelen fatura listesi sorgulama
- ✅ Tarih aralığı filtreleme
- ✅ Fatura durumu kontrolü
- ✅ Pagination desteği
- 🔄 Giden fatura gönderimi (gelecek versiyonda)

## 🔧 Teknik Gereksinimler

### Sistem Gereksinimleri
- **Framework**: Delphi 10.x+ (VCL/FMX)
- **HTTP Client**: `System.Net.HttpClient`
- **JSON Parser**: `System.JSON`
- **Encoding**: UTF-8 desteği

### Gerekli Unit'ler
```pascal
uses
  System.Net.HttpClient,      // HTTP istekleri
  System.Net.URLClient,       // URL encoding
  System.NetEncoding,         // Base64, URL encoding
  System.JSON,                // JSON parsing
  System.DateUtils,           // Tarih işlemleri
  System.SysUtils;            // String işlemleri
```

### Bağımlılıklar
- İnternet bağlantısı
- MySoft test/canlı hesabı
- SSL/TLS desteği

## 🚀 API Entegrasyon Adımları

### Adım 1: Konfigürasyon Yönetimi

```pascal
type
  TEntegratorAyarlari = record
    TestURL: string;        // API base URL
    KullaniciAdi: string;   // MySoft kullanıcı adı
    Sifre: string;          // MySoft şifresi
    GidenEtiket: string;    // Opsiyonel
    GelenEtiket: string;    // Opsiyonel
    Sube: string;           // Opsiyonel
  end;
```

**ERP Entegrasyonu için Öneri:**
- Konfigürasyon verilerini veritabanında saklayın
- Şifreleri encrypt edin
- Environment bazlı ayarlar yapın (test/prod)

### Adım 2: OAuth 2.0 Token Alma

```pascal
function GetAccessToken(const Username, Password: string): string;
var
  HTTPClient: THTTPClient;
  Request: TStringStream;
  Response: IHTTPResponse;
  JSONObj: TJSONObject;
begin
  HTTPClient := THTTPClient.Create;
  try
    Request := TStringStream.Create(
      'username=' + TNetEncoding.URL.Encode(Username) +
      '&password=' + TNetEncoding.URL.Encode(Password) +
      '&grant_type=password', TEncoding.UTF8);
    try
      HTTPClient.ContentType := 'application/x-www-form-urlencoded';
      Response := HTTPClient.Post('https://edocumentapi.mytest.tr/oauth/token', Request);
      
      if Response.StatusCode = 200 then
      begin
        JSONObj := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
        try
          Result := JSONObj.GetValue<string>('access_token', '');
        finally
          JSONObj.Free;
        end;
      end
      else
        raise Exception.Create('Token alma hatası: ' + IntToStr(Response.StatusCode));
    finally
      Request.Free;
    end;
  finally
    HTTPClient.Free;
  end;
end;
```

**ERP Entegrasyonu için Öneri:**
- Token'ları cache'leyin (24 saat geçerli)
- Refresh token mekanizması kullanın
- Token yenileme işlemini otomatikleştirin

### Adım 3: Fatura Listesi Sorgulama

```pascal
function GetInvoiceInboxList(const Token, StartDate, EndDate: string): string;
var
  HTTPClient: THTTPClient;
  RequestJSON: TJSONObject;
  RequestStream: TStringStream;
  Response: IHTTPResponse;
begin
  HTTPClient := THTTPClient.Create;
  try
    HTTPClient.CustomHeaders['Authorization'] := 'Bearer ' + Token;
    HTTPClient.ContentType := 'application/json';

    RequestJSON := TJSONObject.Create;
    try
      RequestJSON.AddPair('startDate', StartDate);
      RequestJSON.AddPair('endDate', EndDate);
      RequestJSON.AddPair('limit', 100);  // Pagination

      RequestStream := TStringStream.Create(RequestJSON.ToString, TEncoding.UTF8);
      try
        Response := HTTPClient.Post(
          'https://edocumentapi.mytest.tr/api/invoiceinbox/getinvoiceinboxwithheaderinfolistforperiod',
          RequestStream);
          
        if Response.StatusCode = 200 then
          Result := Response.ContentAsString
        else
          raise Exception.Create('API Hatası: ' + IntToStr(Response.StatusCode));
      finally
        RequestStream.Free;
      end;
    finally
      RequestJSON.Free;
    end;
  finally
    HTTPClient.Free;
  end;
end;
```

## 💾 Veri Yapıları

### MySoft API Response Format
```json
{
  "data": [
    {
      "id": 104298,
      "profile": "TICARIFATURA",
      "invoiceStatusText": "KABUL",
      "invoiceType": "TEVKIFAT",
      "ettn": "8c96ca19-323e-4e18-893b-54d33723f360",
      "docNo": "AA52025000000054",
      "docDate": "2025-01-10T00:00:00+03:00",
      "pkAlias": "urn:mail:adpk@ds.com",
      "gbAlias": "urn:mail:asdgb@5",
      "vknTckn": "6271036106",
      "accountName": "MYSOFT DIJITAL DONUSUM (E-BELGE)",
      "lineExtensionAmount": 10000.00,
      "taxExclusiveAmount": 10000.00,
      "taxInclusiveAmount": 12000.00,
      "payableAmount": 10600.00,
      "taxTotalTra": 600.00
    }
  ]
}
```

### ERP Veritabanı Önerisi (SQL)
```sql
CREATE TABLE EInvoices (
    ID BIGINT PRIMARY KEY,
    DocNo VARCHAR(50) NOT NULL,
    DocDate DATETIME NOT NULL,
    VknTckn VARCHAR(11) NOT NULL,
    AccountName VARCHAR(255),
    PayableAmount DECIMAL(18,2),
    TaxAmount DECIMAL(18,2),
    InvoiceStatus VARCHAR(20),
    ETTN VARCHAR(36),
    Profile VARCHAR(20),
    InvoiceType VARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ProcessedDate DATETIME,
    INDEX IX_DocDate (DocDate),
    INDEX IX_VknTckn (VknTckn),
    INDEX IX_Status (InvoiceStatus)
);
```

## ⚠️ Hata Yönetimi

### Yaygın Hatalar ve Çözümleri

#### 1. Token Alma Hataları
```pascal
// Hata Kodu: 401 - Unauthorized
if Response.StatusCode = 401 then
  raise Exception.Create('Kullanıcı adı veya şifre hatalı');

// Hata Kodu: 429 - Rate Limit
if Response.StatusCode = 429 then
  raise Exception.Create('Çok fazla istek. Lütfen bekleyin.');
```

#### 2. API Çağrı Hataları
```pascal
try
  APIResponse := GetInvoiceInboxList(Token, StartDate, EndDate);
except
  on E: ENetHTTPException do
  begin
    case E.ErrorCode of
      400: ShowMessage('Geçersiz parametre');
      403: ShowMessage('Erişim reddedildi');
      500: ShowMessage('Sunucu hatası');
    else
      ShowMessage('Bilinmeyen hata: ' + E.Message);
    end;
  end;
end;
```

#### 3. JSON Parse Hataları
```pascal
function SafeJSONParse(const JSONStr: string): TJSONObject;
begin
  Result := nil;
  try
    Result := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
    if not Assigned(Result) then
      raise Exception.Create('Geçersiz JSON formatı');
  except
    on E: Exception do
    begin
      LogError('JSON Parse Hatası: ' + E.Message);
      raise;
    end;
  end;
end;
```

## 🎯 Best Practices

### 1. Performance Optimizasyonu
- **Connection Pooling**: HTTP bağlantılarını yeniden kullanın
- **Async Processing**: Büyük veri setleri için asenkron işleme
- **Caching**: Token ve metadata'yı cache'leyin
- **Pagination**: Büyük listelerde sayfalama kullanın

### 2. Güvenlik
- **HTTPS Only**: Tüm API çağrıları HTTPS üzerinden
- **Credential Security**: Şifreleri encrypt edin
- **Token Security**: Token'ları güvenli saklayın
- **Input Validation**: Tüm girişleri doğrulayın

### 3. Monitoring ve Logging
```pascal
procedure LogAPICall(const Operation, Request, Response: string; 
  ResponseTime: Cardinal);
begin
  // ERP sistemlerinde API çağrılarını logla
  WriteToLog(Format('[%s] %s - Duration: %dms', 
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), Operation, ResponseTime]));
  WriteToLog('Request: ' + Request);
  WriteToLog('Response: ' + Copy(Response, 1, 1000)); // İlk 1000 karakter
end;
```

### 4. Error Recovery
```pascal
function CallAPIWithRetry(const APIFunc: TFunc<string>; MaxRetries: Integer = 3): string;
var
  Attempt: Integer;
  LastError: string;
begin
  for Attempt := 1 to MaxRetries do
  begin
    try
      Result := APIFunc();
      Exit; // Başarılı
    except
      on E: Exception do
      begin
        LastError := E.Message;
        if Attempt < MaxRetries then
        begin
          Sleep(1000 * Attempt); // Exponential backoff
          Continue;
        end
        else
          raise Exception.Create('API çağrısı başarısız: ' + LastError);
      end;
    end;
  end;
end;
```

## 🧪 Test Senaryoları

### Test Case 1: Başarılı Fatura Sorgulama
```pascal
procedure TestSuccessfulInvoiceQuery;
var
  Token: string;
  Response: string;
begin
  // Token al
  Token := GetAccessToken('test_user', 'test_password');
  Assert(Token <> '', 'Token alınamadı');
  
  // Fatura listesi sorgula
  Response := GetInvoiceInboxList(Token, '2025-01-01', '2025-01-31');
  Assert(Pos('"data":', Response) > 0, 'Geçersiz response format');
  
  WriteLn('✅ Test başarılı');
end;
```

### Test Case 2: Hatalı Kimlik Bilgileri
```pascal
procedure TestInvalidCredentials;
begin
  try
    GetAccessToken('invalid_user', 'invalid_password');
    Assert(False, 'Hata beklentisi karşılanmadı');
  except
    on E: Exception do
      WriteLn('✅ Beklenen hata yakalandı: ' + E.Message);
  end;
end;
```

### Test Case 3: Büyük Veri Seti
```pascal
procedure TestLargeDataSet;
var
  Token: string;
  Response: string;
  JSONObj: TJSONObject;
  DataArray: TJSONArray;
begin
  Token := GetAccessToken('test_user', 'test_password');
  Response := GetInvoiceInboxList(Token, '2024-01-01', '2025-12-31');
  
  JSONObj := TJSONObject.ParseJSONValue(Response) as TJSONObject;
  try
    DataArray := JSONObj.GetValue('data') as TJSONArray;
    WriteLn(Format('✅ %d fatura başarıyla alındı', [DataArray.Count]));
  finally
    JSONObj.Free;
  end;
end;
```

## 📞 Destek ve İletişim

### MySoft Destek
- **Dokümantasyon**: https://edocumentapi.mytest.tr/
- **Postman Collection**: [Mysoft API Collection](https://www.postman.com/smartlifeerp/test-e-fatura/documentation/k4ueh7b/mysoft-edocumentapi)
- **Test Ortamı**: https://edocumentapi.mytest.tr/

### Bu Proje Hakkında
- **Kaynak Kod**: MainForm.pas, MySoftAPI.pas
- **Örnek Kullanım**: Gelen Faturalar modülü
- **Lisans**: Açık kaynak (referans amaçlı)

---

**Not**: Bu rehber MySoft E-Fatura API v1.0 için hazırlanmıştır. API güncellemeleri için resmi dokümantasyonu takip ediniz.
