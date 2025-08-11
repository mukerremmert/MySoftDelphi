unit MySoftAPI;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.NetEncoding, System.DateUtils, 
  System.Generics.Collections, SettingsManager;

type
  TMySoftAPI = class
  private
    class function CreateHTTPClient: THTTPClient; static;
    class function BuildTokenRequest(const Username, Password: string): string; static;
    class function BuildInvoiceListRequest(const StartDate, EndDate: string): string; static;
  public
    { FATURA API METODLARI }
    class function GetAccessToken(const Username, Password: string): string; static;
    class function GetInvoiceInboxList(const Token, StartDate, EndDate: string): string; static;
    class function ParseTokenResponse(const JSONResponse: string): string; static;
    class function FormatInvoiceListForDisplay(const JSONResponse: string): TStringList; static;
    
    { İRSALİYE API METODLARI }
    class function GetDespatchInboxList(const Token, StartDate, EndDate: string; 
      PageSize: Integer = 100; PageNumber: Integer = 1; const AfterValue: string = ''): string; static;
    class function BuildDespatchListRequest(const StartDate, EndDate: string;
      PageSize, PageNumber: Integer; const AfterValue: string): string; static;
    class function FormatDespatchListForDisplay(const JSONResponse: string): TStringList; static;
  end;

implementation

class function TMySoftAPI.CreateHTTPClient: THTTPClient;
begin
  Result := THTTPClient.Create;
  Result.ConnectionTimeout := 30000; // 30 saniye
  Result.ResponseTimeout := 30000;
  Result.UserAgent := 'Delphi-EFatura-Client/1.0';
end;

class function TMySoftAPI.BuildTokenRequest(const Username, Password: string): string;
begin
  Result := 'username=' + TNetEncoding.URL.Encode(Username) +
            '&password=' + TNetEncoding.URL.Encode(Password) +
            '&grant_type=password';
end;

class function TMySoftAPI.BuildInvoiceListRequest(const StartDate, EndDate: string): string;
var
  JSONObj: TJSONObject;
begin
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('startDate', StartDate);
    JSONObj.AddPair('endDate', EndDate);
    JSONObj.AddPair('limit', TJSONNumber.Create(50));
    JSONObj.AddPair('pkAlias', '');
    JSONObj.AddPair('sessionStatus', '');
    Result := JSONObj.ToString;
  finally
    JSONObj.Free;
  end;
end;

class function TMySoftAPI.GetAccessToken(const Username, Password: string): string;
var
  HTTPClient: THTTPClient;
  Response: IHTTPResponse;
  RequestBody: string;
  Headers: TNetHeaders;
begin
  Result := '';
  HTTPClient := CreateHTTPClient;
  try
    try
      // Request body olustur
      RequestBody := BuildTokenRequest(Username, Password);
      
      // Headers ayarla
      SetLength(Headers, 1);
      Headers[0] := TNetHeader.Create('Content-Type', 'application/x-www-form-urlencoded');
      
      // Token isteği gönder
      Response := HTTPClient.Post('https://edocumentapi.mytest.tr/oauth/token', 
                                  TStringStream.Create(RequestBody, TEncoding.UTF8), 
                                  nil, Headers);
      
      if Response.StatusCode = 200 then
        Result := ParseTokenResponse(Response.ContentAsString)
      else
        Result := 'HATA: ' + Response.StatusCode.ToString + ' - ' + Response.StatusText;
        
    except
      on E: Exception do
        Result := 'BAGLANTI HATASI: ' + E.Message;
    end;
  finally
    HTTPClient.Free;
  end;
end;

class function TMySoftAPI.GetInvoiceInboxList(const Token, StartDate, EndDate: string): string;
var
  HTTPClient: THTTPClient;
  Response: IHTTPResponse;
  RequestBody: string;
  Headers: TNetHeaders;
begin
  Result := '';
  HTTPClient := CreateHTTPClient;
  try
    try
      // Request body olustur
      RequestBody := BuildInvoiceListRequest(StartDate, EndDate);
      
      // Headers ayarla
      SetLength(Headers, 2);
      Headers[0] := TNetHeader.Create('Content-Type', 'application/json');
      Headers[1] := TNetHeader.Create('Authorization', 'Bearer ' + Token);
      
      // Fatura listesi isteği gönder
      Response := HTTPClient.Post('https://edocumentapi.mytest.tr/api/invoiceinbox/getinvoiceinboxwithheaderinfolistforperiod', 
                                  TStringStream.Create(RequestBody, TEncoding.UTF8), 
                                  nil, Headers);
      
      if Response.StatusCode = 200 then
        Result := Response.ContentAsString
      else
        Result := '{"error": "HTTP ' + Response.StatusCode.ToString + ' - ' + Response.StatusText + '"}';
        
    except
      on E: Exception do
        Result := '{"error": "BAGLANTI HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

class function TMySoftAPI.ParseTokenResponse(const JSONResponse: string): string;
var
  JSONObj: TJSONObject;
  AccessToken: TJSONValue;
begin
  Result := '';
  try
    JSONObj := TJSONObject.ParseJSONValue(JSONResponse) as TJSONObject;
    if Assigned(JSONObj) then
    try
      AccessToken := JSONObj.GetValue('access_token');
      if Assigned(AccessToken) then
        Result := AccessToken.Value;
    finally
      JSONObj.Free;
    end;
  except
    on E: Exception do
      Result := 'JSON PARSE HATASI: ' + E.Message;
  end;
end;

class function TMySoftAPI.FormatInvoiceListForDisplay(const JSONResponse: string): TStringList;
var
  JSONObj, InvoiceObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
  FaturaNo, Tarih, VKN, Unvan, Tutar, KDV, Durum: string;
  TutarValue, KDVValue: Double;
  TarihStr: string;
begin
  Result := TStringList.Create;
  
  try
    // Debug mesajlarini temizle
    
    // JSON parse et
    JSONObj := TJSONObject.ParseJSONValue(JSONResponse) as TJSONObject;
    if not Assigned(JSONObj) then
    begin
      Result.Add('❌ JSON PARSE HATASI!');
      Result.Add('Response gecerli JSON degil.');
      Exit;
    end;
    
    try
      // Data array'i al (MySoft response'da direkt data array var)
      DataArray := JSONObj.GetValue('data') as TJSONArray;
      if not Assigned(DataArray) then
      begin
        Result.Add('Data array bulunamadi!');
        Exit;
      end;
      
      // Baslik ekle - ASCII format
      Result.Add('================================================================================');
      Result.Add('                    GELEN FATURALAR LiSTESi (MySoft Test Ortami)              ');
      Result.Add('================================================================================');
      Result.Add('');
      Result.Add('FATURA NO        TARiH       VKN          UNVAN                     TOPLAM TL    KDV TL      DURUM');
      Result.Add('---------------- ----------- ------------ ------------------------- ------------ ----------- -----------');
      
      // Her fatura icin
      for i := 0 to DataArray.Count - 1 do
      begin
        InvoiceObj := DataArray.Items[i] as TJSONObject;
        if Assigned(InvoiceObj) then
        begin
          // API response'dan alanlari cek (gercek field isimleri)
          FaturaNo := InvoiceObj.GetValue<string>('docNo', 'N/A');
          
          // Tarih formatini duzenle (ISO 8601 -> dd.mm.yyyy)
          TarihStr := InvoiceObj.GetValue<string>('docDate', 'N/A');
          try
            // ISO 8601 format: 2025-07-10T00:00:00+03:00
            if Length(TarihStr) >= 10 then
            begin
              Tarih := Copy(TarihStr, 9, 2) + '.' + Copy(TarihStr, 6, 2) + '.' + Copy(TarihStr, 1, 4);
            end
            else
              Tarih := 'N/A';
          except
            Tarih := Copy(TarihStr, 1, 10);
          end;
          
          VKN := InvoiceObj.GetValue<string>('vknTckn', 'N/A');
          Unvan := InvoiceObj.GetValue<string>('accountName', 'N/A');
          
          // Tutar formatini duzenle
          TutarValue := InvoiceObj.GetValue<Double>('payableAmount', 0);
          Tutar := FormatFloat('#,##0.00', TutarValue);
          
          KDVValue := InvoiceObj.GetValue<Double>('taxTotalTra', 0);
          KDV := FormatFloat('#,##0.00', KDVValue);
          
          Durum := InvoiceObj.GetValue<string>('invoiceStatusText', 'BILINMIYOR');
          
          // Tablo satirini formatla - ASCII
          Result.Add(Format('%-16s %-11s %-12s %-25s %12s %11s %-11s', 
            [Copy(FaturaNo, 1, 16), 
             Tarih, 
             VKN, 
             Copy(Unvan, 1, 25), 
             Tutar + ' TL', 
             KDV + ' TL', 
             Copy(Durum, 1, 11)]));
        end;
      end;
      
      Result.Add('================================================================================');
      Result.Add('');
      Result.Add('OZET BiLGiLER:');
      Result.Add('Toplam Fatura Sayisi: ' + IntToStr(DataArray.Count));
      Result.Add('Veri Kaynagi: MySoft Test Ortami');
      Result.Add('Son Guncelleme: ' + FormatDateTime('dd.mm.yyyy hh:nn:ss', Now));
      Result.Add('API Endpoint: /api/invoiceinbox/getinvoiceinboxwithheaderinfolistforperiod');
      Result.Add('');
      Result.Add('Yeniden yuklemek icin "Gelen Faturalar" menusu tiklayin.');
      
    finally
      JSONObj.Free;
    end;
    
  except
    on E: Exception do
    begin
      Result.Add('VERI ISLEME HATASI: ' + E.Message);
      Result.Add('JSON Response Preview: ' + Copy(JSONResponse, 1, 500) + '...');
    end;
  end;
end;

{ ============================================================================
  İRSALİYE API METODLARI (ERP ENTEGRASYON İÇİN)
  ============================================================================
  
  MySoft e-İrsaliye API entegrasyonu için gerekli metodlar.
  ERP sistemlerinde mal kabul süreçleri, stok yönetimi ve lojistik takibi
  için kullanılır.
  ============================================================================ }

class function TMySoftAPI.GetDespatchInboxList(const Token, StartDate, EndDate: string; 
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
    { REQUEST BODY HAZIRLAMA
      İrsaliye listesi için gerekli parametreler:
      - startDate, endDate: Tarih aralığı
      - pageSize: Sayfa başına kayıt (max 1000)
      - pageNumber: Sayfa numarası
      - afterValue: Pagination token }
    RequestBody := BuildDespatchListRequest(StartDate, EndDate, PageSize, PageNumber, AfterValue);
    
    { HEADERS AYARLAMA
      Authorization: Bearer token gerekli
      Content-Type: application/json }
    SetLength(Headers, 2);
    Headers[0] := TNetHeader.Create('Authorization', 'Bearer ' + Token);
    Headers[1] := TNetHeader.Create('Content-Type', 'application/json');
    
    try
      { API ÇAĞRISI
        MySoft İrsaliye Inbox Endpoint:
        POST /api/Despatch/GetNewDespatchInboxWithHeaderInfoList }
      Response := HTTPClient.Post(
        TSettingsManager.GetSetting('APIBaseURL', 'https://edocumentapi.mytest.tr/') + 
        'api/Despatch/GetNewDespatchInboxWithHeaderInfoList',
        TStringStream.Create(RequestBody, TEncoding.UTF8),
        Headers
      );
      
      { RESPONSE KONTROLÜ }
      if Response.StatusCode = 200 then
        Result := Response.ContentAsString(TEncoding.UTF8)
      else
        raise Exception.CreateFmt('İrsaliye API Hatası: %d - %s', 
          [Response.StatusCode, Response.StatusText]);
        
    except
      on E: Exception do
      begin
        // Hata loglaması
        raise Exception.Create('İrsaliye listesi çekilirken hata: ' + E.Message);
      end;
    end;
    
  finally
    HTTPClient.Free;
  end;
end;

class function TMySoftAPI.BuildDespatchListRequest(const StartDate, EndDate: string;
  PageSize, PageNumber: Integer; const AfterValue: string): string;
var
  JSONObj: TJSONObject;
begin
  { İRSALİYE LİSTESİ REQUEST BODY OLUŞTURMA
    MySoft API formatına uygun JSON hazırlama }
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('startDate', StartDate);        // YYYY-MM-DD formatı
    JSONObj.AddPair('endDate', EndDate);            // YYYY-MM-DD formatı
    JSONObj.AddPair('pageSize', TJSONNumber.Create(PageSize));      // Varsayılan: 100
    JSONObj.AddPair('pageNumber', TJSONNumber.Create(PageNumber));  // Varsayılan: 1
    JSONObj.AddPair('afterValue', AfterValue);      // Pagination için (ilk istekte boş)
    
    Result := JSONObj.ToString;
  finally
    JSONObj.Free;
  end;
end;

class function TMySoftAPI.FormatDespatchListForDisplay(const JSONResponse: string): TStringList;
var
  JSONObj: TJSONObject;
  DataArray: TJSONArray;
  DespatchObj: TJSONObject;
  i: Integer;
  
  // İrsaliye bilgileri
  ID, IrsaliyeNo, Tarih, VknTckn, Unvan, Durum: string;
  IrsaliyeTip, Profil, ETTN: string;
  ToplamMiktar, ToplamTutar: Double;
  KalemSayisi: Integer;
  TaşıyıcıFirma, PlakaNo: string;
  
  FormattedLine: string;
begin
  Result := TStringList.Create;
  
  { BAŞLIK SATIRI
    ERP sistemlerinde irsaliye listesi görüntüleme için formatlanmış çıktı }
  Result.Add('=== GELEN İRSALİYE LİSTESİ ===');
  Result.Add('');
  Result.Add(Format('%-8s %-15s %-10s %-12s %-25s %-10s %-15s %-8s %-10s %-15s %-12s', 
    ['ID', 'İrsaliye No', 'Tarih', 'VKN/TCKN', 'Ünvan', 'Durum', 'Tip', 'Kalem', 'Miktar', 'Taşıyıcı', 'Plaka']));
  Result.Add(StringOfChar('-', 150));
  
  try
    { JSON PARSE ETME }
    JSONObj := TJSONObject.ParseJSONValue(JSONResponse) as TJSONObject;
    if not Assigned(JSONObj) then
    begin
      Result.Add('HATA: Geçersiz JSON formatı');
      Exit;
    end;
    
    try
      { SUCCESS KONTROLÜ }
      if not JSONObj.GetValue<Boolean>('success', False) then
      begin
        Result.Add('API HATASI: ' + JSONObj.GetValue<string>('message', 'Bilinmeyen hata'));
        Exit;
      end;
      
      { DATA ARRAY'İNİ AL }
      DataArray := JSONObj.GetValue('data') as TJSONArray;
      if not Assigned(DataArray) then
      begin
        Result.Add('UYARI: İrsaliye verisi bulunamadı');
        Exit;
      end;
      
      { HER İRSALİYE İÇİN FORMATLAMA }
      for i := 0 to DataArray.Count - 1 do
      begin
        DespatchObj := DataArray.Items[i] as TJSONObject;
        
        { VERİ ÇIKARTMA (SAFE EXTRACTION) }
        ID := DespatchObj.GetValue<string>('id', '0');
        IrsaliyeNo := DespatchObj.GetValue<string>('docNo', 'N/A');
        Tarih := Copy(DespatchObj.GetValue<string>('docDate', ''), 1, 10); // Sadece tarih kısmı
        VknTckn := DespatchObj.GetValue<string>('vknTckn', 'N/A');
        Unvan := DespatchObj.GetValue<string>('accountName', 'N/A');
        Durum := DespatchObj.GetValue<string>('despatchStatusText', 'BILINMIYOR');
        IrsaliyeTip := DespatchObj.GetValue<string>('despatchType', 'N/A');
        Profil := DespatchObj.GetValue<string>('profile', 'N/A');
        ETTN := DespatchObj.GetValue<string>('ettn', 'N/A');
        
        { SAYISAL VERİLER }
        ToplamMiktar := DespatchObj.GetValue<Double>('totalQuantity', 0);
        ToplamTutar := DespatchObj.GetValue<Double>('totalAmount', 0);
        KalemSayisi := DespatchObj.GetValue<Integer>('totalLineCount', 0);
        
        { LOJİSTİK BİLGİLER }
        TaşıyıcıFirma := Copy(DespatchObj.GetValue<string>('carrierName', 'N/A'), 1, 15);
        PlakaNo := DespatchObj.GetValue<string>('vehiclePlateNumber', 'N/A');
        
        { FORMATLAMA VE EKLEME }
        FormattedLine := Format('%-8s %-15s %-10s %-12s %-25s %-10s %-15s %-8d %-10s %-15s %-12s', 
          [ID, IrsaliyeNo, Tarih, VknTckn, Copy(Unvan, 1, 25), Durum, IrsaliyeTip, 
           KalemSayisi, FormatFloat('#,##0.000', ToplamMiktar), TaşıyıcıFirma, PlakaNo]);
           
        Result.Add(FormattedLine);
      end;
      
      { ÖZET BİLGİLER }
      Result.Add('');
      Result.Add(Format('Toplam %d irsaliye listelendi.', [DataArray.Count]));
      
    finally
      JSONObj.Free;
    end;
    
  except
    on E: Exception do
    begin
      Result.Add('VERİ İŞLEME HATASI: ' + E.Message);
      Result.Add('JSON Response Preview: ' + Copy(JSONResponse, 1, 500) + '...');
    end;
  end;
end;

end.
