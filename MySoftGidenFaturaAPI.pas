unit MySoftGidenFaturaAPI;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.DateUtils, System.Generics.Collections,
  MySoftAPIBase, MySoftAPITypes;

type
  { MySoft Giden Fatura API - Specialized class }
  TMySoftGidenFaturaAPI = class(TMySoftAPIBase)
  private
    function BuildInvoiceDraftRequest(const InvoiceData: TJSONObject): string;
    function BuildInvoiceSendRequest(const DraftID: string): string;
  public
    // Giden Fatura API metodları
    function CreateInvoiceDraft(const Token: string; const InvoiceData: TJSONObject): string;
    function SendInvoice(const Token, DraftID: string): string;
    function GetInvoiceStatus(const Token, InvoiceID: string): string;
    function GetOutgoingInvoiceList(const Token, StartDate, EndDate: string; 
      Limit: Integer = 100): string;
    
    // Utility methods
    function ValidateInvoiceData(const InvoiceData: TJSONObject): string;
    function FormatInvoiceListForDisplay(const JSONResponse: string): TStringList;
  end;

  { Invoice Builder Helper Class }
  TInvoiceBuilder = class
  private
    FInvoiceData: TJSONObject;
    FInvoiceLines: TJSONArray;
  public
    constructor Create;
    destructor Destroy; override;
    
    // Invoice Header
    function SetInvoiceInfo(const InvoiceType, Profile, DocDate, DocNo: string): TInvoiceBuilder;
    function SetBuyerInfo(const VknTckn, Name, Address, City, District: string): TInvoiceBuilder;
    function SetSellerInfo(const VknTckn, Name, Address, City, District: string): TInvoiceBuilder;
    
    // Invoice Lines
    function AddInvoiceLine(const LineNumber: Integer; const ItemName: string; 
      const Quantity: Double; const UnitPrice: Double; const TaxRate: Double): TInvoiceBuilder;
    
    // Build & Validate
    function Build: TJSONObject;
    function Validate: string;
    function ToJSONString: string;
  end;

implementation

{ TMySoftGidenFaturaAPI }

function TMySoftGidenFaturaAPI.BuildInvoiceDraftRequest(const InvoiceData: TJSONObject): string;
begin
  { FATURA DRAFT REQUEST BODY OLUŞTURMA
    MySoft API dokümantasyonuna göre Invoice_InvoiceDraftNew endpoint'i }
  
  // InvoiceData zaten hazır JSON objesi, direkt string'e çevir
  Result := InvoiceData.ToString;
end;

function TMySoftGidenFaturaAPI.BuildInvoiceSendRequest(const DraftID: string): string;
var
  JSONObj: TJSONObject;
begin
  { FATURA GÖNDERIM REQUEST BODY OLUŞTURMA }
  JSONObj := TJSONObject.Create;
  try
    JSONObj.AddPair('draftId', DraftID);
    JSONObj.AddPair('sendType', 'NORMAL');  // NORMAL, HIZLI, vs.
    Result := JSONObj.ToString;
  finally
    JSONObj.Free;
  end;
end;

function TMySoftGidenFaturaAPI.CreateInvoiceDraft(const Token: string; 
  const InvoiceData: TJSONObject): string;
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
      RequestBody := BuildInvoiceDraftRequest(InvoiceData);
      
      // Headers ayarla
      Headers := CreateAuthHeaders(Token);
      
      // Fatura draft isteği gönder
      Response := HTTPClient.Post(GetBaseURL + '/api/Invoice/InvoiceDraftNew', 
                                  TStringStream.Create(RequestBody, TEncoding.UTF8), 
                                  nil, Headers);
      
      Result := HandleHTTPResponse(Response);
        
    except
      on E: Exception do
        Result := '{"error": "FATURA DRAFT HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TMySoftGidenFaturaAPI.SendInvoice(const Token, DraftID: string): string;
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
      RequestBody := BuildInvoiceSendRequest(DraftID);
      
      // Headers ayarla
      Headers := CreateAuthHeaders(Token);
      
      // Fatura gönderim isteği
      Response := HTTPClient.Post(GetBaseURL + '/api/Invoice/InvoiceSend', 
                                  TStringStream.Create(RequestBody, TEncoding.UTF8), 
                                  nil, Headers);
      
      Result := HandleHTTPResponse(Response);
        
    except
      on E: Exception do
        Result := '{"error": "FATURA GÖNDERIM HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TMySoftGidenFaturaAPI.GetInvoiceStatus(const Token, InvoiceID: string): string;
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
      
      // Fatura durum sorgusu
      Response := HTTPClient.Post(GetBaseURL + '/api/Invoice/GetInvoiceStatus', 
                                  TStringStream.Create(RequestBody, TEncoding.UTF8), 
                                  nil, Headers);
      
      Result := HandleHTTPResponse(Response);
        
    except
      on E: Exception do
        Result := '{"error": "FATURA DURUM SORGU HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TMySoftGidenFaturaAPI.GetOutgoingInvoiceList(const Token, StartDate, EndDate: string; 
  Limit: Integer = 100): string;
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
        JSONObj.AddPair('startDate', StartDate);
        JSONObj.AddPair('endDate', EndDate);
        JSONObj.AddPair('limit', TJSONNumber.Create(Limit));
        JSONObj.AddPair('pkAlias', '');
        JSONObj.AddPair('sessionStatus', '');
        JSONObj.AddPair('tenantIdentifierNumber', '');
        JSONObj.AddPair('afterValue', '');
        RequestBody := JSONObj.ToString;
      finally
        JSONObj.Free;
      end;
      
      // Headers ayarla
      Headers := CreateAuthHeaders(Token);
      
      // Giden fatura listesi sorgusu
      Response := HTTPClient.Post(GetBaseURL + TMySoftEndpoints.GIDEN_FATURA_ENDPOINT, 
                                  TStringStream.Create(RequestBody, TEncoding.UTF8), 
                                  nil, Headers);
      
      Result := HandleHTTPResponse(Response);
        
    except
      on E: Exception do
        Result := '{"error": "GIDEN FATURA LİSTESİ HATASI: ' + E.Message + '"}';
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TMySoftGidenFaturaAPI.ValidateInvoiceData(const InvoiceData: TJSONObject): string;
var
  InvoiceInfo, BuyerInfo, SellerInfo: TJSONObject;
  InvoiceLines: TJSONArray;
begin
  Result := '';
  
  if not Assigned(InvoiceData) then
  begin
    Result := 'Fatura verisi boş!';
    Exit;
  end;
  
  // Invoice Info kontrolü
  if not InvoiceData.TryGetValue<TJSONObject>('invoiceInfo', InvoiceInfo) then
  begin
    Result := 'invoiceInfo eksik!';
    Exit;
  end;
  
  // Buyer Info kontrolü
  if not InvoiceData.TryGetValue<TJSONObject>('buyerInfo', BuyerInfo) then
  begin
    Result := 'buyerInfo eksik!';
    Exit;
  end;
  
  // Seller Info kontrolü
  if not InvoiceData.TryGetValue<TJSONObject>('sellerInfo', SellerInfo) then
  begin
    Result := 'sellerInfo eksik!';
    Exit;
  end;
  
  // Invoice Lines kontrolü
  if not InvoiceData.TryGetValue<TJSONArray>('invoiceLines', InvoiceLines) then
  begin
    Result := 'invoiceLines eksik!';
    Exit;
  end;
  
  if InvoiceLines.Count = 0 then
  begin
    Result := 'En az 1 fatura kalemi gerekli!';
    Exit;
  end;
  
  // Validasyon başarılı
  Result := '';
end;

function TMySoftGidenFaturaAPI.FormatInvoiceListForDisplay(const JSONResponse: string): TStringList;
var
  JSONObj, InvoiceObj: TJSONObject;
  DataArray: TJSONArray;
  i: Integer;
  
  // Fatura temel bilgileri
  ID, FaturaNo, Tarih, VknTckn, Unvan, Durum: string;
  Profil, InvoiceType, ETTN: string;
  
  // Tutar bilgileri
  PayableAmount: Double;
  
  TarihStr: string;
begin
  Result := TStringList.Create;
  
  { BAŞLIK SATIRI }
  Result.Add('=== GİDEN FATURA LİSTESİ ===');
  Result.Add('');
  Result.Add(Format('%-8s %-15s %-10s %-12s %-25s %-12s %-12s %-15s', 
    ['ID', 'Fatura No', 'Tarih', 'VKN/TCKN', 'Ünvan', 'Durum', 'Tutar', 'ETTN']));
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
      if not JSONObj.TryGetValue<TJSONArray>('data', DataArray) then
      begin
        Result.Add('UYARI: Fatura verisi bulunamadı');
        Exit;
      end;
      
      { HER FATURA İÇİN FORMATLAMA }
      for i := 0 to DataArray.Count - 1 do
      begin
        InvoiceObj := DataArray.Items[i] as TJSONObject;
        
        { VERİ ÇIKARTMA (SAFE EXTRACTION) }
        ID := InvoiceObj.GetValue<string>('id', '0');
        FaturaNo := InvoiceObj.GetValue<string>('docNo', 'N/A');
        
        { TARİH FORMATINI DÜZENLE }
        TarihStr := InvoiceObj.GetValue<string>('docDate', '');
        try
          if Length(TarihStr) >= 10 then
            Tarih := Copy(TarihStr, 9, 2) + '.' + Copy(TarihStr, 6, 2) + '.' + Copy(TarihStr, 1, 4)
          else
            Tarih := 'N/A';
        except
          Tarih := Copy(TarihStr, 1, 10);
        end;
        
        VknTckn := InvoiceObj.GetValue<string>('vknTckn', 'N/A');
        Unvan := InvoiceObj.GetValue<string>('accountName', 'N/A');
        Durum := InvoiceObj.GetValue<string>('invoiceStatusText', 'BILINMIYOR');
        Profil := InvoiceObj.GetValue<string>('profile', 'N/A');
        InvoiceType := InvoiceObj.GetValue<string>('invoiceType', 'N/A');
        ETTN := InvoiceObj.GetValue<string>('ettn', 'N/A');
        
        { TUTAR BİLGİSİ }
        try
          PayableAmount := InvoiceObj.GetValue<Double>('payableAmount', 0);
        except
          PayableAmount := 0;
        end;
        
        { FORMATLAMA VE EKLEME }
        Result.Add(Format('%-8s %-15s %-10s %-12s %-25s %-12s %-12s %-15s', 
          [ID, 
           Copy(FaturaNo, 1, 15),
           Tarih, 
           VknTckn, 
           Copy(Unvan, 1, 25), 
           Copy(Durum, 1, 12),
           FormatFloat('#,##0.00', PayableAmount) + ' TL',
           Copy(ETTN, 1, 15) + '...']));
      end;
      
      { ÖZET BİLGİLER }
      Result.Add('');
      Result.Add(Format('Toplam %d fatura listelendi.', [DataArray.Count]));
      Result.Add('Veri Kaynağı: MySoft Test Ortamı');
      Result.Add('Son Güncelleme: ' + FormatDateTime('dd.mm.yyyy hh:nn:ss', Now));
      Result.Add('API Endpoint: /api/InvoiceOutbox/GetInvoiceOutboxWithHeaderInfoList');
      
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

{ TInvoiceBuilder }

constructor TInvoiceBuilder.Create;
begin
  inherited Create;
  FInvoiceData := TJSONObject.Create;
  FInvoiceLines := TJSONArray.Create;
  
  // Varsayılan yapı oluştur
  FInvoiceData.AddPair('invoiceInfo', TJSONObject.Create);
  FInvoiceData.AddPair('buyerInfo', TJSONObject.Create);
  FInvoiceData.AddPair('sellerInfo', TJSONObject.Create);
  FInvoiceData.AddPair('invoiceLines', FInvoiceLines);
end;

destructor TInvoiceBuilder.Destroy;
begin
  FInvoiceData.Free;
  inherited Destroy;
end;

function TInvoiceBuilder.SetInvoiceInfo(const InvoiceType, Profile, DocDate, DocNo: string): TInvoiceBuilder;
var
  InvoiceInfo: TJSONObject;
begin
  InvoiceInfo := FInvoiceData.GetValue('invoiceInfo') as TJSONObject;
  
  InvoiceInfo.RemovePair('invoiceType').Free;
  InvoiceInfo.RemovePair('profile').Free;
  InvoiceInfo.RemovePair('docDate').Free;
  InvoiceInfo.RemovePair('docNo').Free;
  
  InvoiceInfo.AddPair('invoiceType', InvoiceType);  // SATIS, TEVKIFAT, vs.
  InvoiceInfo.AddPair('profile', Profile);          // TICARIFATURA, TEMELFATURA
  InvoiceInfo.AddPair('docDate', DocDate);          // YYYY-MM-DD
  InvoiceInfo.AddPair('docNo', DocNo);              // Fatura numarası
  
  Result := Self;
end;

function TInvoiceBuilder.SetBuyerInfo(const VknTckn, Name, Address, City, District: string): TInvoiceBuilder;
var
  BuyerInfo: TJSONObject;
begin
  BuyerInfo := FInvoiceData.GetValue('buyerInfo') as TJSONObject;
  
  BuyerInfo.RemovePair('vknTckn').Free;
  BuyerInfo.RemovePair('name').Free;
  BuyerInfo.RemovePair('address').Free;
  BuyerInfo.RemovePair('city').Free;
  BuyerInfo.RemovePair('district').Free;
  
  BuyerInfo.AddPair('vknTckn', VknTckn);
  BuyerInfo.AddPair('name', Name);
  BuyerInfo.AddPair('address', Address);
  BuyerInfo.AddPair('city', City);
  BuyerInfo.AddPair('district', District);
  
  Result := Self;
end;

function TInvoiceBuilder.SetSellerInfo(const VknTckn, Name, Address, City, District: string): TInvoiceBuilder;
var
  SellerInfo: TJSONObject;
begin
  SellerInfo := FInvoiceData.GetValue('sellerInfo') as TJSONObject;
  
  SellerInfo.RemovePair('vknTckn').Free;
  SellerInfo.RemovePair('name').Free;
  SellerInfo.RemovePair('address').Free;
  SellerInfo.RemovePair('city').Free;
  SellerInfo.RemovePair('district').Free;
  
  SellerInfo.AddPair('vknTckn', VknTckn);
  SellerInfo.AddPair('name', Name);
  SellerInfo.AddPair('address', Address);
  SellerInfo.AddPair('city', City);
  SellerInfo.AddPair('district', District);
  
  Result := Self;
end;

function TInvoiceBuilder.AddInvoiceLine(const LineNumber: Integer; const ItemName: string; 
  const Quantity: Double; const UnitPrice: Double; const TaxRate: Double): TInvoiceBuilder;
var
  LineObj: TJSONObject;
begin
  LineObj := TJSONObject.Create;
  
  LineObj.AddPair('lineNumber', TJSONNumber.Create(LineNumber));
  LineObj.AddPair('itemName', ItemName);
  LineObj.AddPair('quantity', TJSONNumber.Create(Quantity));
  LineObj.AddPair('unitPrice', TJSONNumber.Create(UnitPrice));
  LineObj.AddPair('taxRate', TJSONNumber.Create(TaxRate));
  LineObj.AddPair('lineAmount', TJSONNumber.Create(Quantity * UnitPrice));
  LineObj.AddPair('taxAmount', TJSONNumber.Create(Quantity * UnitPrice * TaxRate / 100));
  
  FInvoiceLines.AddElement(LineObj);
  
  Result := Self;
end;

function TInvoiceBuilder.Build: TJSONObject;
begin
  Result := FInvoiceData.Clone as TJSONObject;
end;

function TInvoiceBuilder.Validate: string;
var
  API: TMySoftGidenFaturaAPI;
begin
  API := TMySoftGidenFaturaAPI.Create;
  try
    Result := API.ValidateInvoiceData(FInvoiceData);
  finally
    API.Free;
  end;
end;

function TInvoiceBuilder.ToJSONString: string;
begin
  Result := FInvoiceData.ToString;
end;

end.
