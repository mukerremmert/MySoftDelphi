unit MySoftGelenIrsaliyeAPI;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.DateUtils, System.Generics.Collections,
  MySoftAPIBase, MySoftAPITypes;

type
  { MySoft Gelen İrsaliye API - Specialized class }
  TMySoftGelenIrsaliyeAPI = class(TMySoftAPIBase)
  private
    function BuildDespatchListRequest(const StartDate, EndDate: string; 
      Limit: Integer = 100): string;
  public
    // Gelen İrsaliye API metodları
    function GetDespatchInboxList(const Token, StartDate, EndDate: string; 
      Limit: Integer = 100): string;
    function GetDespatchDetail(const Token, DespatchID: string): string;
    function FormatDespatchListForDisplay(const JSONResponse: string): TStringList;
    
    // Utility methods
    function GetDespatchCount(const JSONResponse: string): Integer;
    function ExtractDespatchIDs(const JSONResponse: string): TStringList;
  end;

implementation

function TMySoftGelenIrsaliyeAPI.BuildDespatchListRequest(const StartDate, EndDate: string; 
  Limit: Integer = 100): string;
var
  JSONObj: TJSONObject;
begin
  { İRSALİYE LİSTESİ REQUEST BODY OLUŞTURMA
    Fatura API'sine benzer format kullanıyoruz }
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('startDate', StartDate);           // YYYY-MM-DD formatı
    JSONObj.AddPair('endDate', EndDate);               // YYYY-MM-DD formatı
    JSONObj.AddPair('limit', TJSONNumber.Create(Limit));     // Kayıt sayısı
    JSONObj.AddPair('pkAlias', '');                    // Posta kutusu filtresi
    JSONObj.AddPair('sessionStatus', '');              // Oturum durumu
    JSONObj.AddPair('tenantIdentifierNumber', '');     // Müşteri kimlik no
    JSONObj.AddPair('afterValue', '');                 // Pagination token
    Result := JSONObj.ToString;
  finally
    JSONObj.Free;
  end;
end;

function TMySoftGelenIrsaliyeAPI.GetDespatchInboxList(const Token, StartDate, EndDate: string; 
  Limit: Integer = 100): string;
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
      // Request body oluştur
      RequestBody := BuildDespatchListRequest(StartDate, EndDate, Limit);
      
      // Headers ayarla
      Headers := CreateAuthHeaders(Token);
      
      // İrsaliye listesi isteği gönder
      Response := HTTPClient.Post(GetBaseURL + TMySoftEndpoints.GELEN_IRSALIYE_ENDPOINT, 
                                  TStringStream.Create(RequestBody, TEncoding.UTF8), 
                                  nil, Headers);
      
      Result := HandleHTTPResponse(Response);
        
    except
      on E: Exception do
        Result := '{"error": "BAGLANTI HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TMySoftGelenIrsaliyeAPI.GetDespatchDetail(const Token, DespatchID: string): string;
var
  HTTPClient: THTTPClient;
  RequestBody: string;
  Headers: TNetHeaders;
  JSONObj: TJSONObject;
begin
  Result := '';
  HTTPClient := CreateHTTPClient;
  try
    try
      // Request body oluştur
      JSONObj := TJSONObject.Create;
      try
        JSONObj.AddPair('despatchId', DespatchID);
        RequestBody := JSONObj.ToString;
      finally
        JSONObj.Free;
      end;
      
      // Headers ayarla
      Headers := CreateAuthHeaders(Token);
      
      // İrsaliye detayı isteği gönder (endpoint gelecekte eklenecek)
      // Response := HTTPClient.Post(GetBaseURL + '/api/despatchinbox/getdespatchdetail', 
      //                             TStringStream.Create(RequestBody, TEncoding.UTF8), 
      //                             nil, Headers);
      
      // Şimdilik placeholder
      Result := '{"message": "Despatch detail endpoint will be implemented"}';
        
    except
      on E: Exception do
        Result := '{"error": "BAGLANTI HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TMySoftGelenIrsaliyeAPI.FormatDespatchListForDisplay(const JSONResponse: string): TStringList;
var
  JSONObj, DespatchObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
  
  // İrsaliye temel bilgileri
  ID, IrsaliyeNo, Tarih, VknTckn, Unvan, Durum: string;
  Profil, DespatchType, ETTN: string;
  
  // Sayısal veriler
  TotalLineCount: Integer;
  TotalQuantity, TotalAmount: Double;
  CurrencyCode: string;
  
  // Lojistik bilgiler
  CarrierName, VehiclePlate: string;
  
  TarihStr: string;
begin
  Result := TStringList.Create;
  
  { BAŞLIK SATIRI
    ERP sistemlerinde irsaliye listesi görüntüleme için formatlanmış çıktı }
  Result.Add('=== GELEN İRSALİYE LİSTESİ ===');
  Result.Add('');
  Result.Add(Format('%-8s %-15s %-10s %-12s %-25s %-12s %-8s %-10s %-12s %-15s %-12s', 
    ['ID', 'İrsaliye No', 'Tarih', 'VKN/TCKN', 'Ünvan', 'Durum', 'Kalem', 'Miktar', 'Tutar', 'Taşıyıcı', 'Plaka']));
  Result.Add(StringOfChar('-', 140));
  
  try
    { JSON PARSE ETME }
    JSONObj := TJSONObject.ParseJSONValue(JSONResponse) as TJSONObject;
    if not Assigned(JSONObj) then
    begin
      Result.Add('HATA: Geçersiz JSON formatı');
      Exit;
    end;
    
    try
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
        
        { TARİH FORMATINI DÜZENLE }
        TarihStr := DespatchObj.GetValue<string>('docDate', '');
        try
          if Length(TarihStr) >= 10 then
            Tarih := Copy(TarihStr, 9, 2) + '.' + Copy(TarihStr, 6, 2) + '.' + Copy(TarihStr, 1, 4)
          else
            Tarih := 'N/A';
        except
          Tarih := Copy(TarihStr, 1, 10);
        end;
        
        VknTckn := DespatchObj.GetValue<string>('vknTckn', 'N/A');
        Unvan := DespatchObj.GetValue<string>('accountName', 'N/A');
        Durum := DespatchObj.GetValue<string>('despatchStatusText', 'BILINMIYOR');
        Profil := DespatchObj.GetValue<string>('profile', 'N/A');
        DespatchType := DespatchObj.GetValue<string>('despatchType', 'N/A');
        ETTN := DespatchObj.GetValue<string>('ettn', 'N/A');
        
        { SAYISAL VERİLER - GÜVENLİ PARSING }
        try
          TotalLineCount := StrToIntDef(DespatchObj.GetValue<string>('totalLineCount', '0'), 0);
        except
          TotalLineCount := 0;
        end;
        
        try
          TotalQuantity := StrToFloatDef(DespatchObj.GetValue<string>('totalQuantity', '0'), 0);
        except
          TotalQuantity := 0;
        end;
        
        try
          TotalAmount := StrToFloatDef(DespatchObj.GetValue<string>('totalAmount', '0'), 0);
        except
          TotalAmount := 0;
        end;
        
        CurrencyCode := DespatchObj.GetValue<string>('currencyCode', 'TRY');
        
        { LOJİSTİK BİLGİLER }
        CarrierName := Copy(DespatchObj.GetValue<string>('carrierName', 'N/A'), 1, 15);
        VehiclePlate := DespatchObj.GetValue<string>('vehiclePlateNumber', 'N/A');
        
        { FORMATLAMA VE EKLEME }
        Result.Add(Format('%-8s %-15s %-10s %-12s %-25s %-12s %-8d %-10s %-12s %-15s %-12s', 
          [ID, 
           Copy(IrsaliyeNo, 1, 15),
           Tarih, 
           VknTckn, 
           Copy(Unvan, 1, 25), 
           Copy(Durum, 1, 12),
           TotalLineCount,
           FormatFloat('#,##0.000', TotalQuantity),
           FormatFloat('#,##0.00', TotalAmount) + ' ' + CurrencyCode,
           CarrierName,
           Copy(VehiclePlate, 1, 12)]));
      end;
      
      { ÖZET BİLGİLER }
      Result.Add('');
      Result.Add(Format('Toplam %d irsaliye listelendi.', [DataArray.Count]));
      Result.Add('Veri Kaynağı: MySoft Test Ortamı');
      Result.Add('Son Güncelleme: ' + FormatDateTime('dd.mm.yyyy hh:nn:ss', Now));
      Result.Add('API Endpoint: /api/DespatchInbox/getDespatchInboxListForPeriod');
      
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

function TMySoftGelenIrsaliyeAPI.GetDespatchCount(const JSONResponse: string): Integer;
var
  JSONObj: TJSONObject;
  DataArray: TJSONArray;
begin
  Result := 0;
  try
    JSONObj := TJSONObject.ParseJSONValue(JSONResponse) as TJSONObject;
    if Assigned(JSONObj) then
    try
      DataArray := JSONObj.GetValue('data') as TJSONArray;
      if Assigned(DataArray) then
        Result := DataArray.Count;
    finally
      JSONObj.Free;
    end;
  except
    Result := 0;
  end;
end;

function TMySoftGelenIrsaliyeAPI.ExtractDespatchIDs(const JSONResponse: string): TStringList;
var
  JSONObj, DespatchObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
  DespatchID: string;
begin
  Result := TStringList.Create;
  
  try
    JSONObj := TJSONObject.ParseJSONValue(JSONResponse) as TJSONObject;
    if Assigned(JSONObj) then
    try
      DataArray := JSONObj.GetValue('data') as TJSONArray;
      if Assigned(DataArray) then
      begin
        for i := 0 to DataArray.Count - 1 do
        begin
          DespatchObj := DataArray.Items[i] as TJSONObject;
          DespatchID := DespatchObj.GetValue<string>('id', '');
          if DespatchID <> '' then
            Result.Add(DespatchID);
        end;
      end;
    finally
      JSONObj.Free;
    end;
  except
    // Hata durumunda boş liste döner
  end;
end;

end.

