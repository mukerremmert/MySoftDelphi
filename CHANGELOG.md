# 📋 Değişiklik Günlüğü (Changelog)

Bu dosya, EFaturaDelphi projesinin tüm önemli değişikliklerini içerir.

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardına uygun olarak hazırlanmıştır.
Versiyonlama [Semantic Versioning](https://semver.org/spec/v2.0.0.html) kurallarını takip eder.

---

## [v1.2.0] - 2025-01-12 - Giden Fatura API Desteği 📤

### ✅ Eklenen Özellikler
- **Giden Fatura API entegrasyonu** - MySoft e-Fatura gönderim sistemi desteği
- **TMySoftGidenFaturaAPI sınıfı** - Özel giden fatura API wrapper'ı
- **15 sütunlu giden fatura görünümü** - Detaylı gönderim bilgileri
  - ID, Fatura No, Tarih, VKN/TCKN, Ünvan, Durum
  - Profil, Tip, ETTN, Ana Para, Vergi Hariç/Dahil, Ödenecek, KDV, Gönderim
- **TInvoiceBuilder helper sınıfı** - Fluent API ile fatura oluşturma
  - SetInvoiceInfo(), SetBuyerInfo(), SetSellerInfo()
  - AddInvoiceLine(), Build(), Validate()
- **Fatura validation sistemi** - Veri doğrulama ve hata kontrolü
- **CreateInvoiceDraft API** - Fatura taslağı oluşturma
- **SendInvoice API** - Fatura gönderim işlemi
- **GetInvoiceStatus API** - Fatura durum sorgulama
- **GetOutgoingInvoiceList API** - Giden fatura listesi

### 🔧 Düzeltmeler
- **Doğru endpoint kullanımı** - `/api/InvoiceOutbox/GetInvoiceOutboxWithHeaderInfoList`
- **MySoftAPITypes.pas** - GIDEN_FATURA_ENDPOINT sabiti eklendi
- **MainForm güncellemeleri** - Giden Faturalar sekmesi aktif
- **Button handler'ları** - Giden fatura sorgulama desteği

### 📚 Dokümantasyon
- **README.md güncellendi** - Giden Fatura API dokümantasyonu
- **API endpoint'leri** - 5 yeni endpoint dokümante edildi
- **TInvoiceBuilder kullanım örnekleri** - Fatura oluşturma rehberi
- **Sınıf diyagramı genişletildi** - Giden fatura sınıfları eklendi
- **Response formatları** - Giden fatura API yanıtları

### 🏗️ Teknik İyileştirmeler
- **Tam çift yönlü sistem** - Gelen + Giden fatura desteği
- **Fluent API pattern** - TInvoiceBuilder ile kolay kullanım
- **Validation framework** - Fatura veri doğrulama sistemi
- **Error handling** - Detaylı hata yönetimi
- **Code organization** - Modüler yapı korundu

---

## [v1.1.0] - 2025-01-12 - İrsaliye API Desteği 📦

### ✅ Eklenen Özellikler
- **Gelen İrsaliye API entegrasyonu** - MySoft e-İrsaliye sistemi desteği
- **TMySoftGelenIrsaliyeAPI sınıfı** - Özel irsaliye API wrapper'ı
- **12 sütunlu irsaliye görünümü** - Detaylı irsaliye bilgileri
  - ID, İrsaliye No, Tarih, VKN/TCKN, Ünvan, Durum
  - Profil, Tip, ETTN, Kalem Sayısı, Toplam Miktar, Taşıyıcı
- **Modüler API mimarisi** - TMySoftAPIBase base sınıfı
- **Güvenli JSON parsing** - TryGetValue kullanımı ile hata önleme
- **Gelişmiş hata yakalama** - Debug bilgileri ve detaylı error handling
- **MySoftAPITypes.pas** - Ortak tipler ve sabitler
- **System.Generics.Collections** desteği - Inline function optimizasyonu

### 🔧 Düzeltmeler
- **StringGrid "Fixed row count" hatası** - RowCount minimum 2 olarak ayarlandı
- **JSON typecast hatası** - Güvenli casting ile çözüldü
- **HTTP 405 Method Not Allowed** - Doğru endpoint kullanımı
- **İrsaliye API endpoint** - `/api/despatchinbox/getdespatchinboxwithheaderinfolistforperiod`
- **Request parametreleri** - Fatura API'sine uyumlu format
- **Kullanılmayan değişkenler** - Code cleanup yapıldı

### 📚 Dokümantasyon
- **README.md güncellendi** - İrsaliye API dokümantasyonu eklendi
- **Sınıf diyagramı güncellendi** - Modüler mimari yansıtıldı
- **API endpoint'leri dokümante edildi** - Gelen İrsaliye API detayları
- **Proje yapısı güncellendi** - Yeni dosyalar eklendi
- **Versiyon badge'i güncellendi** - v1.1.0 yansıtıldı

### 🏗️ Teknik İyileştirmeler
- **Try-except blokları** - Doğru yerleşim ve hata yakalama
- **JSON response handling** - Daha güvenli parsing
- **Code organization** - Modüler yapı ve separation of concerns
- **Error messaging** - Kullanıcı dostu hata mesajları
- **Memory management** - JSON nesnelerinin güvenli free edilmesi

---

## [v1.0.0] - 2025-01-11 - İlk Sürüm 🚀

### ✅ Eklenen Özellikler
- **MySoft API Token yönetimi** - OAuth 2.0 token sistemi
- **Gelen Fatura listesi sorgulama** - Tarih aralığı ile filtreleme
- **18 sütunlu detaylı fatura görünümü** - Tüm MySoft API alanları
  - ID, Fatura No, Tarih, VKN/TCKN, Ünvan, Durum, Profil, Tip
  - ETTN, Gönderen PK, Alıcı GB, Ana Para, Vergi Hariç/Dahil
  - Ödenecek Tutar, KDV Tutarı, İndirim, Yuvarlama
- **Firma ayarları yönetimi** - VKN/TCKN doğrulama sistemi
- **Entegratör ayarları** - MySoft API bağlantı bilgileri
- **INI dosyası ayar sistemi** - Kalıcı ayar saklama
- **Türkçe karakter desteği** - TURKISH_CHARSET kullanımı
- **Tarih filtreleme** - DateTimePicker ile aralık seçimi
- **StringGrid optimizasyonu** - Performanslı veri gösterimi

### 🏗️ Teknik Altyapı
- **TMainForm** - Ana uygulama formu
- **TfrmFirmaAyarlari** - Firma bilgileri yönetimi
- **TfrmEntegratorAyarlari** - API bağlantı ayarları
- **TSettingsManager** - Ayar kaydetme/yükleme sınıfı
- **TMySoftGelenFaturaAPI** - Fatura API wrapper'ı
- **HTTP Client** - HTTPS güvenli iletişim
- **JSON parsing** - System.JSON kullanımı

### 📚 Dokümantasyon
- **Token Oluşturma.md** - OAuth token alma rehberi
- **Gelen Fatura Listesi.md** - Fatura API dokümantasyonu
- **ERP Entegrasyon Rehberi.md** - ERP firmaları için rehber
- **README.md** - Proje dokümantasyonu
- **MIT Lisansı** - Açık kaynak lisanslama

### 🎯 ERP Entegrasyon Desteği
- **Postman koleksiyonu** - API test dokümantasyonu
- **Kod örnekleri** - ERP entegrasyon şablonları
- **Error handling** - Güvenli hata yönetimi
- **Logging sistemi** - İşlem takibi
- **Multi-tenant hazırlığı** - Çoklu firma desteği altyapısı

---

## Gelecek Sürümler 🔮

### [v1.3.0] - Planlanan - Giden İrsaliye Gönderimi
- İrsaliye XML oluşturma
- Lojistik bilgileri yönetimi
- Taşıyıcı entegrasyonu
- Mal kabul süreçleri

### [v1.4.0] - Planlanan - Fatura Oluşturma UI
- Fatura oluşturma formu
- TInvoiceBuilder UI entegrasyonu
- Müşteri seçimi
- Ürün katalog yönetimi

### [v1.5.0] - Planlanan - PDF ve Yazdırma
- PDF indirme API'si
- Yazdırma modülü
- Belge arşivleme
- E-posta gönderimi

### [v1.6.0] - Planlanan - Veritabanı Entegrasyonu
- MySQL/MSSQL/PostgreSQL desteği
- ORM entegrasyonu
- Veri senkronizasyonu
- Backup/restore sistemi

### [v2.0.0] - Planlanan - Multi-Provider Desteği
- Foriba API entegrasyonu
- Kolaysoft API entegrasyonu
- ICE API entegrasyonu
- Provider factory pattern
- Unified API interface

---

## Katkıda Bulunanlar 👥

- **Mukerrem Mert** - Proje kurucusu ve ana geliştirici
- **Mert Bilişim** - Sponsorluk ve teknik destek

## Lisans 📄

Bu proje MIT Lisansı altında yayınlanmıştır. Detaylar için [LICENSE](LICENSE) dosyasını inceleyiniz.

---

*Son güncelleme: 2025-01-12*
