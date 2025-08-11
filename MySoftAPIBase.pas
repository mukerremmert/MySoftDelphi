unit MySoftAPIBase;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.NetEncoding, MySoftAPITypes, SettingsManager;

type
  { Base MySoft API Class - Ortak fonksiyonlar }
  TMySoftAPIBase = class(TInterfacedObject, IMySoftAPI)
  private
    FBaseURL: string;
  protected
    class function CreateHTTPClient: THTTPClient; static;
    function BuildTokenRequest(const Username, Password: string): string;
    function ParseTokenResponse(const JSONResponse: string): string;
    function CreateAuthHeaders(const Token: string): TNetHeaders;
    function CreateJSONHeaders: TNetHeaders;
    function HandleHTTPResponse(const Response: IHTTPResponse): string;
  public
    constructor Create;
    
    // IMySoftAPI interface implementation
    function GetAccessToken(const Username, Password: string): string;
    function IsTokenValid(const Token: string): Boolean;
    function GetBaseURL: string;
    procedure SetBaseURL(const URL: string);
  end;

implementation

constructor TMySoftAPIBase.Create;
begin
  inherited Create;
  // Test ortamı varsayılan
  FBaseURL := TMySoftEndpoints.BASE_URL_TEST;
end;

class function TMySoftAPIBase.CreateHTTPClient: THTTPClient;
begin
  Result := THTTPClient.Create;
  Result.ConnectionTimeout := 30000; // 30 saniye
  Result.ResponseTimeout := 30000;
  Result.UserAgent := 'Delphi-EFatura-Client/2.0-Modular';
end;

function TMySoftAPIBase.BuildTokenRequest(const Username, Password: string): string;
begin
  Result := 'username=' + TNetEncoding.URL.Encode(Username) +
            '&password=' + TNetEncoding.URL.Encode(Password) +
            '&grant_type=password';
end;

function TMySoftAPIBase.ParseTokenResponse(const JSONResponse: string): string;
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

function TMySoftAPIBase.CreateAuthHeaders(const Token: string): TNetHeaders;
begin
  SetLength(Result, 2);
  Result[0] := TNetHeader.Create('Content-Type', 'application/json');
  Result[1] := TNetHeader.Create('Authorization', 'Bearer ' + Token);
end;

function TMySoftAPIBase.CreateJSONHeaders: TNetHeaders;
begin
  SetLength(Result, 1);
  Result[0] := TNetHeader.Create('Content-Type', 'application/x-www-form-urlencoded');
end;

function TMySoftAPIBase.HandleHTTPResponse(const Response: IHTTPResponse): string;
begin
  if Response.StatusCode = 200 then
    Result := Response.ContentAsString
  else
    Result := Format('{"error": "HTTP %d - %s"}', [Response.StatusCode, Response.StatusText]);
end;

function TMySoftAPIBase.GetAccessToken(const Username, Password: string): string;
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
      RequestBody := BuildTokenRequest(Username, Password);
      
      // Headers ayarla
      Headers := CreateJSONHeaders;
      
      // Token isteği gönder
      Response := HTTPClient.Post(FBaseURL + TMySoftEndpoints.TOKEN_ENDPOINT, 
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

function TMySoftAPIBase.IsTokenValid(const Token: string): Boolean;
begin
  // Basit token geçerlilik kontrolü
  Result := (Token <> '') and (Pos('HATA:', Token) = 0) and (Pos('BAGLANTI HATASI:', Token) = 0);
end;

function TMySoftAPIBase.GetBaseURL: string;
begin
  Result := FBaseURL;
end;

procedure TMySoftAPIBase.SetBaseURL(const URL: string);
begin
  FBaseURL := URL;
end;

end.
