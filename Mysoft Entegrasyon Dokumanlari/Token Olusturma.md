# Token Oluşturma İşlemi

## 🔐 OAuth 2.0 Altyapısı

API'de OAuth 2.0 altyapısı kullanılmaktadır. Bu yüzden ilgili metodlar çağrılmadan önce, bir token oluşturulmalı ve ilgili metod requestlerine, header olarak geçilmelidir. 

## ⏰ Token Geçerlilik Süresi

Oluşturulan token **24 saat** geçerlidir. 24 saat sonra mevcut token ya yenilenmeli ya da tamamen yeni bir token alınmalıdır.

## 👤 Kullanıcı Bilgileri

Buradaki kullanıcı adı şifre bilgisi, canlı ortamdayken, portala girişte kullanılan kullanıcı adı şifredir. Bu yüzden, ilgili müşteriden serviste kullanılmak üzere, portalde bir kullanıcı oluşturması istenir.

## 📋 Token Oluşturma Örneği (C#)

Token oluşturma için örnek olarak C# kodu kullanılmıştır. RestSharp library kullanılmıştır.

```csharp
var client = new RestClient("https://edocumentapi.mytest.tr/oauth/token?");

client.Timeout = -1;

var request = new RestRequest(Method.POST);

request.AddHeader("Content-Type", "application/x-www-form-urlencoded");

request.AddParameter("username", "******");

request.AddParameter("password", "*******");

request.AddParameter("grant_type", "password");

IRestResponse response = client.Execute(request);

Console.WriteLine(response.Content);
```

## 📄 Token Response Formatı

Bu çağrı sonrası dönen JSON değeri aşağıdaki gibidir. Burada kullanılacak değer, **access_token** değeridir.

```json
{
    "access_token": "TRqkQO1Dg0sHtlC8I6-WoWl-y5QiDqKeqqc4RXV0ZtMdFckFHMfBVsh_El5I7YQguRKVjJhC7z_4lVccOg0SxEagTXCR-TcnWuRwwzfmoFxAfze4pbNMXc-zINvsIKx9CRISk7TGuxquYOQUq5xPAtOqPYjWi4MVLMv7IvZUY2Gy_qEY9OMgc98pkQQMWudf78wiTgSt3Qr0K2oBEgdrqV88c52_hnY7psr7sZyNaNyfroZZJ5riq2X96NsIzk6ebYJ16-kiCnyaMSRWL3IcYN0hpOsN-tlalF8kKRmxKdeaTbQmLwaooqOzuigLDtRhoDDiym8E15Pqo9CtGFAmlmFW6G9oYgG8vWE5AJxpy5ouRIM4pQOWIMez0UHReXi9cIWMTDmrUgz4_dBWJX7Tlm8DmgyrxV_qjXogA6WtbyhIfCknOmTYH3j3RIFmmqkQxaoTsoMxvr0qbb6Fqz-XUf_aJ5-fMfW46H_TwwvAx6VNN9xqPRgPvI67kN65qWPT02cQtQpqNv5I2DsATjWxmxfZQDxtIYxm1WIxxAuaiX1y_HIp-0MpRXCIvnSwsu_J",
    "token_type": "bearer",
    "expires_in": 86399,
    "refresh_token": "F7nLzvuwkJCG_HnGmkQSX_7xrxrWOZsYq31vqm7lxSikcPpg16RSoSmBFbA2V5wMPxE8oaC8ztkDFFTnLHKhT1P5RwlpFzFHMYIgg1FaMGXnv4B7DSH8VS7tnp40EIxyIr-0WtPze42XH5ijOqpMIAHzwWbPlW7CHcsIvJpHrwMMxcJCac3J9oYI0-js-59a8T-2BWYEZp47X0BM-7Zjj2HSJoA0cx5oJcW_7AoTxjdpDQxXRcxM3sNq6HSYTgt27orsht8Adl0siPZpzvMiAFJAQ8bsJDLdwVZk-aA0FOqbdFHx86pTn09_UyRf4oWUaQGLiBd9aCO7eqy8_aLcfXHR0G2E3OXWWtz3hfAfiG9aForTbHlajPX1GsdFAqxo-hbc_LdkxrfAeub74kDhKa2k48U6ZEoJktdhf7rELxcNavmFTJ-zDyAIRC-LA2cQWNxTvpu6NZXUejdcXMM_fTDjnqgIOnHv8Dj_rZNClH1kTKReKGDkB_y3GLC87YH-TPbcMHfxvIL7WL2smLFfN7D48CrfqHxL4Q9FmhbEId5mh4MNDFSkNNIxmSnuvvZi"
}
```

## 🔑 Önemli Parametreler

### 📥 Request Parametreleri:
- **username**: Portal kullanıcı adı
- **password**: Portal şifresi  
- **grant_type**: "password" (sabit değer)

### 📤 Response Parametreleri:
- **access_token**: API çağrılarında kullanılacak token
- **token_type**: "bearer" (sabit değer)
- **expires_in**: Token geçerlilik süresi (saniye cinsinden)
- **refresh_token**: Token yenileme için kullanılacak

## 🔧 Delphi Implementation Notları

### HTTP Headers:
```
Content-Type: application/x-www-form-urlencoded
Authorization: Bearer {access_token}
```

### URL Endpoint:
```
POST https://edocumentapi.mytest.tr/oauth/token
```

### Form Data:
```
username={portal_username}
password={portal_password}
grant_type=password
```

## ⚠️ Güvenlik Notları

1. **Token Saklama**: Token'ı güvenli bir şekilde saklayın
2. **Süre Kontrolü**: 24 saatlik süreyi takip edin
3. **Yenileme**: Süre dolmadan token'ı yenileyin
4. **Hata Yönetimi**: Token geçersizse yeni token alın

## 🎯 Sonraki Adımlar

Token alındıktan sonra tüm API çağrılarında:
```
Authorization: Bearer {access_token}
```
header'ı kullanılmalıdır.
