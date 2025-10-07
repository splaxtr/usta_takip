/// Uygulama genelinde kullanılan sabit metinler
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // Genel
  static const String appName = 'Usta Takip';
  static const String appVersion = '1.0.0';

  // Butonlar
  static const String btnOk = 'Tamam';
  static const String btnCancel = 'İptal';
  static const String btnSave = 'Kaydet';
  static const String btnEdit = 'Düzenle';
  static const String btnDelete = 'Sil';
  static const String btnAdd = 'Ekle';
  static const String btnSearch = 'Ara';
  static const String btnClear = 'Temizle';
  static const String btnConfirm = 'Onayla';
  static const String btnContinue = 'Devam Et';
  static const String btnBack = 'Geri';
  static const String btnNext = 'İleri';
  static const String btnFinish = 'Bitir';
  static const String btnClose = 'Kapat';
  static const String btnRetry = 'Tekrar Dene';

  // Form Validasyon
  static const String requiredField = 'Bu alan zorunludur';
  static const String invalidEmail = 'Geçerli bir e-posta adresi giriniz';
  static const String invalidPhone = 'Geçerli bir telefon numarası giriniz';
  static const String passwordTooShort = 'Şifre en az 6 karakter olmalıdır';
  static const String passwordsDoNotMatch = 'Şifreler eşleşmiyor';
  static const String invalidInput = 'Geçersiz giriş';

  // Mesajlar
  static const String success = 'İşlem başarılı';
  static const String error = 'Bir hata oluştu';
  static const String warning = 'Uyarı';
  static const String info = 'Bilgi';
  static const String loading = 'Yükleniyor...';
  static const String noData = 'Veri bulunamadı';
  static const String noResults = 'Sonuç bulunamadı';
  static const String tryAgain = 'Lütfen tekrar deneyin';

  // Ağ Hataları
  static const String networkError = 'İnternet bağlantınızı kontrol edin';
  static const String serverError = 'Sunucu hatası oluştu';
  static const String timeoutError = 'İşlem zaman aşımına uğradı';
  static const String unknownError = 'Bilinmeyen bir hata oluştu';

  // Onay Mesajları
  static const String deleteConfirmation =
      'Silmek istediğinizden emin misiniz?';
  static const String exitConfirmation = 'Çıkmak istediğinizden emin misiniz?';
  static const String discardChanges =
      'Değişiklikler kaydedilmeyecek, devam etmek istiyor musunuz?';

  // Placeholder
  static const String searchHint = 'Ara...';
  static const String emailHint = 'E-posta adresiniz';
  static const String passwordHint = 'Şifreniz';
  static const String phoneHint = 'Telefon numaranız';
  static const String nameHint = 'Adınız';
  static const String surnameHint = 'Soyadınız';

  // Tarih & Zaman
  static const String today = 'Bugün';
  static const String yesterday = 'Dün';
  static const String tomorrow = 'Yarın';
  static const String selectDate = 'Tarih Seçin';
  static const String selectTime = 'Saat Seçin';

  // Diller (Opsiyonel)
  static const String turkish = 'Türkçe';
  static const String english = 'English';

  // Boş Durum Mesajları
  static const String emptyListTitle = 'Henüz içerik yok';
  static const String emptyListDescription =
      'İçerik eklemek için butona tıklayın';

  // İzinler
  static const String permissionDenied = 'İzin reddedildi';
  static const String permissionRequired = 'Bu özellik için izin gerekiyor';
  static const String openSettings = 'Ayarları Aç';
}
