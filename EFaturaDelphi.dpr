program EFaturaDelphi;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  FirmaAyarlariForm in 'FirmaAyarlariForm.pas' {frmFirmaAyarlari},
  EntegratorAyarlariForm in 'EntegratorAyarlariForm.pas' {frmEntegratorAyarlari},
  SettingsManager in 'SettingsManager.pas',
  SettingsHelper in 'SettingsHelper.pas',
  MySoftAPITypes in 'MySoftAPITypes.pas',
  MySoftAPIBase in 'MySoftAPIBase.pas',
  MySoftGelenFaturaAPI in 'MySoftGelenFaturaAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'E-Fatura Örnek Proje';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.