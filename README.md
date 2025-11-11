# Usta Takip – Clean Architecture MVP

Usta Takip artık Hive tabanlı, offline-first çalışan bir işçilik ve proje takip uygulamasıdır. Bu repo `lib/src` altında temiz, test edilebilir ve genişletilebilir bir yapı sunar. MVP (0–4. hafta) hedefleri tamamlandı:

- ✅ Katmanlı mimari (`data`, `domain`, `presentation`)
- ✅ Typed Hive modelleri + manuel adapterler
- ✅ Soft delete / archive bayrakları (`TrackableEntity`)
- ✅ Yevmiye defteri akışı (`RecordWorkDay → WageEntry + Expense`)
- ✅ Dashboard Cubit ile Pending vs Paid yevmiye kartları
- ✅ Min. 5 test (model, repository, widget)

## Dizim

```
lib/
├── main.dart                # bootstrap + app
└── src/
    ├── app.dart             # MaterialApp + bottom navigation
    ├── bootstrap/           # Hive init, adapter kayıtları
    ├── data/                # Hive modelleri + repository implementasyonları
    ├── domain/              # Repository arayüzleri + use case'ler
    └── presentation/        # Feature tabanlı UI (dashboard, projects, employees…)
```

Tüm UI katmanı repository'lere doğrudan erişmez, `RepositoryProvider`/`BlocProvider` üzerinden bağımlılık alır.

## Çalıştırma

```bash
flutter pub get
flutter run
```

Tests:

```bash
flutter test test/unit/models_test.dart
flutter test test/unit/repositories_test.dart
flutter test test/widget/dashboard_test.dart
```

## Öne Çıkan Akış – RecordWorkDay

1. `DashboardPage` üzerindeki “Mesai Kaydet” butonu kullanıcıdan proje / çalışan / tutar alır.
2. `DashboardCubit.recordWorkDay` → `RecordWorkDay` use case:
   - `WageEntry(status='recorded')` oluşturur.
   - Aynı ID ile `Expense(category='yevmiye', isPaid=false)` ekler.
3. Cubit yeniden `refresh()` çağırır ve dashboard kartları (Pending Wages, Paid Expenses, vb.) güncellenir.

Bu yapı, ileride `ApproveWagePayment` ve `ArchiveProject` gibi ek use case'lerle genişletilecektir.
