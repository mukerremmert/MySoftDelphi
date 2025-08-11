unit MySoftAPITypes;

interface

uses
  System.SysUtils, System.Classes;

const
  { MySoft Delphi API Sürüm Bilgileri }
  MYSOFT_DELPHI_API_VERSION = '1.1.0';
  MYSOFT_DELPHI_API_NAME = 'MySoft E-Fatura/E-İrsaliye Delphi API';
  MYSOFT_DELPHI_API_AUTHOR = 'Mert Bilişim - info@mertbilisim.com.tr';
  MYSOFT_DELPHI_API_DATE = '2025-01-12';

type
  { MySoft API için ortak tipler ve kayıt yapıları }
  
  // API Response için base record
  TMySoftAPIResponse = record
    Success: Boolean;
    Message: string;
    ErrorCode: string;
    Data: string;
  end;
  
  // Token bilgileri
  TMySoftTokenInfo = record
    AccessToken: string;
    TokenType: string;
    ExpiresIn: Integer;
    RefreshToken: string;
    IsValid: Boolean;
  end;
  
  // Tarih aralığı
  TDateRange = record
    StartDate: TDateTime;
    EndDate: TDateTime;
    function ToString: string;
  end;
  
  // API Endpoint URLs
  TMySoftEndpoints = class
  public
    const BASE_URL_TEST = 'https://edocumentapi.mytest.tr';
    const BASE_URL_PROD = 'https://edocumentapi.mysoft.com.tr';
    
    const TOKEN_ENDPOINT = '/oauth/token';
    const GELEN_FATURA_ENDPOINT = '/api/invoiceinbox/getinvoiceinboxwithheaderinfolistforperiod';
    const GELEN_IRSALIYE_ENDPOINT = '/api/despatchinbox/getdespatchinboxwithheaderinfolistforperiod';
  end;
  
  // Base MySoft API Interface
  IMySoftAPI = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-123456789ABC}']
    function GetAccessToken(const Username, Password: string): string;
    function IsTokenValid(const Token: string): Boolean;
    function GetBaseURL: string;
    procedure SetBaseURL(const URL: string);
  end;

implementation

function TDateRange.ToString: string;
begin
  Result := FormatDateTime('yyyy-mm-dd', StartDate) + ' - ' + 
            FormatDateTime('yyyy-mm-dd', EndDate);
end;

end.
