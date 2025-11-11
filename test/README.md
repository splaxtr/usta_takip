# Test Stratejisi

Bu klasör, Usta Takip uygulaması için uçtan uca test altyapısını barındırır. Hedefimiz; model, servis, repository, BLoC, widget ve entegrasyon katmanlarını kapsayarak minimum %90 genel code coverage sağlamaktır. Aşağıdaki matris, test türleri ve odak alanlarını özetler:

- **Unit (test/unit/)**: Modeller, repository'ler, servisler ve yardımcı fonksiyonlar için saf Dart testleri.
- **Bloc (test/bloc/)**: Her BLoC'un event → state akışını `bloc_test` ile doğrular, edge case ve hata senaryolarını kapsar.
- **Widget (test/widget/)**: Ekran ve bileşenlerin render, etkileşim ve görünürlük durumlarını `pumpApp` yardımcı fonksiyonu ile test eder.
- **Integration (integration_test/)**: Hive üzerinde gerçek veri ile çalışan uçtan uca kullanıcı senaryoları.
- **Performance (test/performance/)** ve **Scenarios (test/scenarios/)**: Büyük veri setleri, offline durumlar ve platforma özgü davranışlar için hedeflenen ileri seviye testler.

## Test Yardımcıları

- `helpers/hive_test_helper.dart`: İzole Hive box'ları için geçici dizin oluşturup temizler.
- `helpers/pump_app.dart`: Widget testlerinde ihtiyaca göre `MaterialApp`, tema ve bağımlılık enjekte eden sarmalayıcı.
- `helpers/mock_repositories.dart`: `mocktail` tabanlı repository mock'ları ve ortak stub fonksiyonları.
- `fixtures/test_data.dart`: Tip güvenli factory'ler, edge case verileri ve JSON fixture'ları.

Yeni bir test dosyası eklerken ilgili helper'ı değerlendirip tekrar eden kodu ortaklaştırın.

## Çalıştırma Komutları

- Tüm unit ve widget testleri: `flutter test`
- Belirli klasörü çalıştırma: `flutter test test/unit/repositories`
- Entegrasyon testleri: `flutter test integration_test`
- Coverage raporu: `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`

CI/CD aşamalarında `flutter test --coverage` adımı zorunludur. Raporu `coverage/html/index.html` üzerinden inceleyebilirsiniz.

## Troubleshooting

- **Hive kutusu açılamıyor**: Test başında `HiveTestHelper.initHive()` çağrıldığından emin olun, her test sonrası `tearDown` ile kutuyu temizleyin.
- **Mock hataları**: `mocktail` kullanırken null-safe stub tanımları için `when(() => ...)` kalıbını tercih edin; argüman eşleştirmede `any()` fonksiyonlarına dikkat edin.
- **Golden test farkları**: `golden_toolkit` senaryolarında `flutter config --enable-software-rendering` ve sabit font ayarlarını kontrol edin.
- **Flaky test**: Asenkron operasyonlarda `pumpAndSettle` ve `fakeAsync` kullanarak deterministik zamanlayıcılar sağlayın.

Ekibin yeni test eklerken `AAA (Arrange-Act-Assert)` düzenini izlemesi ve Türkçe açıklayıcı test isimleri yazması beklenir. Mevcut örnekler için `test/unit/repositories/project_repository_test.dart` dosyasına göz atabilirsiniz.
