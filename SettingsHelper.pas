unit SettingsHelper;

interface

uses
  System.SysUtils, System.Classes;

type
  TSettingsHelper = class
  public
    class function GetProjectPath: string;
    class function GetSettingsPath: string;
    class function GetLogsPath: string;
    class function GetBackupPath: string;
    class procedure CreateAllFolders;
    class function GetSettingsInfo: TStringList;
  end;

implementation

uses
  System.IOUtils, Vcl.Forms;

class function TSettingsHelper.GetProjectPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

class function TSettingsHelper.GetSettingsPath: string;
begin
  Result := TPath.Combine(GetProjectPath, 'Settings');
end;

class function TSettingsHelper.GetLogsPath: string;
begin
  Result := TPath.Combine(GetProjectPath, 'Logs');
end;

class function TSettingsHelper.GetBackupPath: string;
begin
  Result := TPath.Combine(GetSettingsPath, 'Backup');
end;

class procedure TSettingsHelper.CreateAllFolders;
begin
  // Gerekli klasorleri olustur
  if not TDirectory.Exists(GetSettingsPath) then
    TDirectory.CreateDirectory(GetSettingsPath);
    
  if not TDirectory.Exists(GetLogsPath) then
    TDirectory.CreateDirectory(GetLogsPath);
    
  if not TDirectory.Exists(GetBackupPath) then
    TDirectory.CreateDirectory(GetBackupPath);
end;

class function TSettingsHelper.GetSettingsInfo: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('Proje Klasor Yapisi:');
  Result.Add('====================');
  Result.Add('');
  Result.Add('Proje Klasoru: ' + GetProjectPath);
  Result.Add('Ayarlar: ' + GetSettingsPath);
  Result.Add('Loglar: ' + GetLogsPath);
  Result.Add('Yedekler: ' + GetBackupPath);
  Result.Add('');
  Result.Add('Dosyalar:');
  Result.Add('- FirmaAyarlari.ini (firma bilgileri)');
  Result.Add('- EntegratorAyarlari.ini (test ortami)');
  Result.Add('- SystemLogs.txt (sistem loglari)');
  Result.Add('- Backup\*.ini (otomatik yedekler)');
end;

end.
