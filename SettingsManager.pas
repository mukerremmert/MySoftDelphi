unit SettingsManager;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.IOUtils, Vcl.Forms;

type
  TFirmaAyarlari = record
    VknTckn: string;
    KimlikTipi: string; // 'VKN' veya 'TCKN'
    UnvanIsim: string;
    Soyisim: string;
    Il: string;
    Ilce: string;
    Adres: string;
  end;

  TEntegratorAyarlari = record
    TestURL: string;
    KullaniciAdi: string;
    Sifre: string;
    GidenEtiket: string;
    GelenEtiket: string;
    Sube: string;
  end;

  TSettingsManager = class
  private
    class function GetSettingsPath: string;
    class function GetSettingsFileName: string;
    class function GetEntegratorSettingsFileName: string;
    class function GetBackupFileName: string;
    class function GetEntegratorBackupFileName: string;
    class procedure CreateBackup;
    class procedure CreateEntegratorBackup;
  public
    class procedure CreateSettingsFolder;
    // Firma ayarlari
    class procedure SaveFirmaAyarlari(const AFirmaAyarlari: TFirmaAyarlari);
    class function LoadFirmaAyarlari: TFirmaAyarlari;
    class function SettingsFileExists: Boolean;
    class procedure DeleteSettings;
    // Entegrator ayarlari
    class procedure SaveEntegratorAyarlari(const AEntegratorAyarlari: TEntegratorAyarlari);
    class function LoadEntegratorAyarlari: TEntegratorAyarlari;
    class function EntegratorSettingsFileExists: Boolean;
    class procedure DeleteEntegratorSettings;
  end;

implementation

class function TSettingsManager.GetSettingsPath: string;
begin
  // Proje klasoru altinda Settings klasoru
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Settings');
end;

class function TSettingsManager.GetSettingsFileName: string;
begin
  Result := TPath.Combine(GetSettingsPath, 'FirmaAyarlari.ini');
end;

class function TSettingsManager.GetEntegratorSettingsFileName: string;
begin
  Result := TPath.Combine(GetSettingsPath, 'EntegratorAyarlari.ini');
end;

class function TSettingsManager.GetBackupFileName: string;
begin
  Result := TPath.Combine(GetSettingsPath, 'Backup\FirmaAyarlari_Backup_' + 
    FormatDateTime('yyyymmdd_hhnnss', Now) + '.ini');
end;

class function TSettingsManager.GetEntegratorBackupFileName: string;
begin
  Result := TPath.Combine(GetSettingsPath, 'Backup\EntegratorAyarlari_Backup_' + 
    FormatDateTime('yyyymmdd_hhnnss', Now) + '.ini');
end;

class procedure TSettingsManager.CreateSettingsFolder;
var
  BackupPath: string;
begin
  if not TDirectory.Exists(GetSettingsPath) then
    TDirectory.CreateDirectory(GetSettingsPath);
  
  // Backup klasorunu de olustur
  BackupPath := TPath.Combine(GetSettingsPath, 'Backup');
  if not TDirectory.Exists(BackupPath) then
    TDirectory.CreateDirectory(BackupPath);
end;

class procedure TSettingsManager.SaveFirmaAyarlari(const AFirmaAyarlari: TFirmaAyarlari);
var
  IniFile: TIniFile;
  SettingsFile: string;
begin
  CreateSettingsFolder;
  SettingsFile := GetSettingsFileName;
  
  // Mevcut ayarlar varsa backup al
  if TFile.Exists(SettingsFile) then
    CreateBackup;
  
  IniFile := TIniFile.Create(SettingsFile);
  try
    // Firma bilgileri
    IniFile.WriteString('Firma', 'VknTckn', AFirmaAyarlari.VknTckn);
    IniFile.WriteString('Firma', 'KimlikTipi', AFirmaAyarlari.KimlikTipi);
    IniFile.WriteString('Firma', 'UnvanIsim', AFirmaAyarlari.UnvanIsim);
    IniFile.WriteString('Firma', 'Soyisim', AFirmaAyarlari.Soyisim);
    
    // Adres bilgileri
    IniFile.WriteString('Adres', 'Il', AFirmaAyarlari.Il);
    IniFile.WriteString('Adres', 'Ilce', AFirmaAyarlari.Ilce);
    IniFile.WriteString('Adres', 'AdresDetay', AFirmaAyarlari.Adres);
    
    // Sistem bilgileri
    IniFile.WriteString('System', 'KayitTarihi', DateTimeToStr(Now));
    IniFile.WriteString('System', 'Version', '1.0');
    IniFile.WriteString('System', 'ProjeKlasoru', ExtractFilePath(ParamStr(0)));
    
    // Yedek bilgileri
    IniFile.WriteString('Backup', 'SonYedekTarihi', DateTimeToStr(Now));
    IniFile.WriteInteger('Backup', 'YedekSayisi', 1);
  finally
    IniFile.Free;
  end;
end;

class function TSettingsManager.LoadFirmaAyarlari: TFirmaAyarlari;
var
  IniFile: TIniFile;
  SettingsFile: string;
begin
  // Varsayilan degerler
  FillChar(Result, SizeOf(Result), 0);
  
  SettingsFile := GetSettingsFileName;
  if not TFile.Exists(SettingsFile) then
    Exit;
  
  IniFile := TIniFile.Create(SettingsFile);
  try
    // Firma bilgileri
    Result.VknTckn := IniFile.ReadString('Firma', 'VknTckn', '');
    Result.KimlikTipi := IniFile.ReadString('Firma', 'KimlikTipi', '');
    Result.UnvanIsim := IniFile.ReadString('Firma', 'UnvanIsim', '');
    Result.Soyisim := IniFile.ReadString('Firma', 'Soyisim', '');
    
    // Adres bilgileri
    Result.Il := IniFile.ReadString('Adres', 'Il', '');
    Result.Ilce := IniFile.ReadString('Adres', 'Ilce', '');
    Result.Adres := IniFile.ReadString('Adres', 'AdresDetay', '');
  finally
    IniFile.Free;
  end;
end;

class function TSettingsManager.SettingsFileExists: Boolean;
begin
  Result := TFile.Exists(GetSettingsFileName);
end;

class procedure TSettingsManager.DeleteSettings;
var
  SettingsFile: string;
begin
  SettingsFile := GetSettingsFileName;
  if TFile.Exists(SettingsFile) then
    TFile.Delete(SettingsFile);
end;

class procedure TSettingsManager.CreateBackup;
var
  SourceFile, BackupFile: string;
begin
  SourceFile := GetSettingsFileName;
  BackupFile := GetBackupFileName;
  
  if TFile.Exists(SourceFile) then
    TFile.Copy(SourceFile, BackupFile);
end;

class procedure TSettingsManager.CreateEntegratorBackup;
var
  SourceFile, BackupFile: string;
begin
  SourceFile := GetEntegratorSettingsFileName;
  BackupFile := GetEntegratorBackupFileName;
  
  if TFile.Exists(SourceFile) then
    TFile.Copy(SourceFile, BackupFile);
end;

// Entegrator Ayarlari Fonksiyonlari
class procedure TSettingsManager.SaveEntegratorAyarlari(const AEntegratorAyarlari: TEntegratorAyarlari);
var
  IniFile: TIniFile;
  SettingsFile: string;
begin
  CreateSettingsFolder;
  SettingsFile := GetEntegratorSettingsFileName;
  
  // Mevcut ayarlar varsa backup al
  if TFile.Exists(SettingsFile) then
    CreateEntegratorBackup;
  
  IniFile := TIniFile.Create(SettingsFile);
  try
    // Test ortami bilgileri
    IniFile.WriteString('TestOrtami', 'URL', AEntegratorAyarlari.TestURL);
    IniFile.WriteString('TestOrtami', 'KullaniciAdi', AEntegratorAyarlari.KullaniciAdi);
    IniFile.WriteString('TestOrtami', 'Sifre', AEntegratorAyarlari.Sifre);
    
    // Etiket bilgileri
    IniFile.WriteString('Etiketler', 'GidenEtiket', AEntegratorAyarlari.GidenEtiket);
    IniFile.WriteString('Etiketler', 'GelenEtiket', AEntegratorAyarlari.GelenEtiket);
    
    // Sube bilgileri
    IniFile.WriteString('Sube', 'SubeAdi', AEntegratorAyarlari.Sube);
    
    // Sistem bilgileri
    IniFile.WriteString('System', 'KayitTarihi', DateTimeToStr(Now));
    IniFile.WriteString('System', 'Version', '1.0');
    IniFile.WriteString('System', 'OrtamTipi', 'TEST');
  finally
    IniFile.Free;
  end;
end;

class function TSettingsManager.LoadEntegratorAyarlari: TEntegratorAyarlari;
var
  IniFile: TIniFile;
  SettingsFile: string;
begin
  // Varsayilan degerler
  FillChar(Result, SizeOf(Result), 0);
  
  SettingsFile := GetEntegratorSettingsFileName;
  if not TFile.Exists(SettingsFile) then
  begin
    // Varsayilan degerler
    Result.TestURL := 'https://efaturatest.gov.tr/';
    Result.KullaniciAdi := 'test_kullanici';
    Result.Sifre := 'test_sifre';
    Result.GidenEtiket := 'EARSIVFATURA';
    Result.GelenEtiket := 'EINVOICE';
    Result.Sube := 'Merkez Sube';
    Exit;
  end;
  
  IniFile := TIniFile.Create(SettingsFile);
  try
    // Test ortami bilgileri
    Result.TestURL := IniFile.ReadString('TestOrtami', 'URL', 'https://efaturatest.gov.tr/');
    Result.KullaniciAdi := IniFile.ReadString('TestOrtami', 'KullaniciAdi', 'test_kullanici');
    Result.Sifre := IniFile.ReadString('TestOrtami', 'Sifre', 'test_sifre');
    
    // Etiket bilgileri
    Result.GidenEtiket := IniFile.ReadString('Etiketler', 'GidenEtiket', 'EARSIVFATURA');
    Result.GelenEtiket := IniFile.ReadString('Etiketler', 'GelenEtiket', 'EINVOICE');
    
    // Sube bilgileri
    Result.Sube := IniFile.ReadString('Sube', 'SubeAdi', 'Merkez Sube');
  finally
    IniFile.Free;
  end;
end;

class function TSettingsManager.EntegratorSettingsFileExists: Boolean;
begin
  Result := TFile.Exists(GetEntegratorSettingsFileName);
end;

class procedure TSettingsManager.DeleteEntegratorSettings;
var
  SettingsFile: string;
begin
  SettingsFile := GetEntegratorSettingsFileName;
  if TFile.Exists(SettingsFile) then
    TFile.Delete(SettingsFile);
end;

end.
