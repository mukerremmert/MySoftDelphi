unit MySoftGelenFaturaAPI;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.DateUtils, MySoftAPIBase, MySoftAPITypes;

type
  { MySoft Gelen Fatura API - Specialized class }
  TMySoftGelenFaturaAPI = class(TMySoftAPIBase)
  private
    function BuildInvoiceListRequest(const StartDate, EndDate: string): string;
  public
    // Gelen Fatura API metodları
    function GetInvoiceInboxList(const Token, StartDate, EndDate: string): string;
    function GetInvoiceDetail(const Token, InvoiceID: string): string;
    function FormatInvoiceListForDisplay(const JSONResponse: string): TStringList;
    
    // Utility methods
    function GetInvoiceCount(const JSONResponse: string): Integer;
    function ExtractInvoiceIDs(const JSONResponse: string): TStringList;
  end;

implementation

function TMySoftGelenFaturaAPI.BuildInvoiceListRequest(const StartDate, EndDate: string): string;
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

function TMySoftGelenFaturaAPI.GetInvoiceInboxList(const Token, StartDate, EndDate: string): string;
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
      RequestBody := BuildInvoiceListRequest(StartDate, EndDate);
      
      // Headers ayarla
      Headers := CreateAuthHeaders(Token);
      
      // Fatura listesi isteği gönder
      Response := HTTPClient.Post(GetBaseURL + TMySoftEndpoints.GELEN_FATURA_ENDPOINT, 
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

function TMySoftGelenFaturaAPI.GetInvoiceDetail(const Token, InvoiceID: string): string;
var
  HTTPClient: THTTPClient;
  Response: IHTTPResponse;
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
        JSONObj.AddPair('invoiceId', InvoiceID);
        RequestBody := JSONObj.ToString;
      finally
        JSONObj.Free;
      end;
      
      // Headers ayarla
      Headers := CreateAuthHeaders(Token);
      
      // Fatura detayı isteği gönder (endpoint gelecekte eklenecek)
      // Response := HTTPClient.Post(GetBaseURL + '/api/invoiceinbox/getinvoicedetail', 
      //                             TStringStream.Create(RequestBody, TEncoding.UTF8), 
      //                             nil, Headers);
      
      // Şimdilik placeholder
      Result := '{"message": "Invoice detail endpoint will be implemented"}';
        
    except
      on E: Exception do
        Result := '{"error": "BAGLANTI HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TMySoftGelenFaturaAPI.FormatInvoiceListForDisplay(const JSONResponse: string): TStringList;
var
  JSONObj, InvoiceObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
  FaturaNo, Tarih, VKN, Unvan, Tutar, KDV, Durum: string;
  TutarValue, KDVValue: Double;
  TarihStr: string;
begin
  Result := TStringList.Create;
  
  { BAŞLIK SATIRI
    ERP sistemlerinde fatura listesi görüntüleme için formatlanmış çıktı }
  Result.Add('=== GELEN FATURA LİSTESİ ===');
  Result.Add('');
  Result.Add(Format('%-15s %-10s %-12s %-25s %-15s %-15s %-15s', 
    ['Fatura No', 'Tarih', 'VKN/TCKN', 'Ünvan', 'Tutar', 'KDV', 'Durum']));
  Result.Add(StringOfChar('-', 120));
  
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
        Result.Add('UYARI: Fatura verisi bulunamadı');
        Exit;
      end;
      
      { HER FATURA İÇİN FORMATLAMA }
      for i := 0 to DataArray.Count - 1 do
      begin
        InvoiceObj := DataArray.Items[i] as TJSONObject;
        
        { VERİ ÇIKARTMA (SAFE EXTRACTION) }
        FaturaNo := InvoiceObj.GetValue<string>('docNo', 'N/A');
        TarihStr := InvoiceObj.GetValue<string>('docDate', '');
        Tarih := Copy(TarihStr, 1, 10); // Sadece tarih kısmı (YYYY-MM-DD)
        VKN := InvoiceObj.GetValue<string>('vknTckn', 'N/A');
        Unvan := InvoiceObj.GetValue<string>('accountName', 'N/A');
        Durum := InvoiceObj.GetValue<string>('invoiceStatusText', 'BILINMIYOR');
        
        { TUTARLAR }
        TutarValue := InvoiceObj.GetValue<Double>('payableAmount', 0);
        KDVValue := InvoiceObj.GetValue<Double>('taxAmount', 0);
        
        Tutar := FormatFloat('#,##0.00 TL', TutarValue);
        KDV := FormatFloat('#,##0.00 TL', KDVValue);
        
        { FORMATLAMA VE EKLEME }
        Result.Add(Format('%-15s %-10s %-12s %-25s %-15s %-15s %-15s', 
          [FaturaNo, Tarih, VKN, Copy(Unvan, 1, 25), Tutar, KDV, Durum]));
      end;
      
      { ÖZET BİLGİLER }
      Result.Add('');
      Result.Add(Format('Toplam %d fatura listelendi.', [DataArray.Count]));
      
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

function TMySoftGelenFaturaAPI.GetInvoiceCount(const JSONResponse: string): Integer;
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

function TMySoftGelenFaturaAPI.ExtractInvoiceIDs(const JSONResponse: string): TStringList;
var
  JSONObj, InvoiceObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
  InvoiceID: string;
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
          InvoiceObj := DataArray.Items[i] as TJSONObject;
          InvoiceID := InvoiceObj.GetValue<string>('id', '');
          if InvoiceID <> '' then
            Result.Add(InvoiceID);
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
