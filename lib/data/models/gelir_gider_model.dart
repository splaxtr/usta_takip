import 'package:hive/hive.dart';

part 'gelir_gider_model.g.dart';

@HiveType(typeId: 11)
class GelirGiderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TransactionType type; // Gelir veya Gider

  @HiveField(2)
  String category; // Kategori (Malzeme, Maaş, Tahsilat vb.)

  @HiveField(3)
  double amount; // Tutar

  @HiveField(4)
  String? projectId; // İlişkili proje (opsiyonel)

  @HiveField(5)
  String? employeeId; // İlişkili çalışan (maaş ödemesi ise)

  @HiveField(6)
  String? patronId; // İlişkili patron (tahsilat ise)

  @HiveField(7)
  DateTime date; // İşlem tarihi

  @HiveField(8)
  String description; // Açıklama

  @HiveField(9)
  PaymentMethod paymentMethod; // Ödeme yöntemi

  @HiveField(10)
  String? invoiceNumber; // Fatura/Fiş numarası

  @HiveField(11)
  String? receiptImageUrl; // Makbuz/Fatura görseli

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime? updatedAt;

  @HiveField(14)
  String? notes; // Notlar

  @HiveField(15)
  bool isRecurring; // Tekrarlayan işlem mi?

  @HiveField(16)
  RecurringPeriod? recurringPeriod; // Tekrarlama periyodu

  GelirGiderModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.projectId,
    this.employeeId,
    this.patronId,
    required this.date,
    required this.description,
    this.paymentMethod = PaymentMethod.cash,
    this.invoiceNumber,
    this.receiptImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.isRecurring = false,
    this.recurringPeriod,
  });

  // JSON'dan model oluştur
  factory GelirGiderModel.fromJson(Map<String, dynamic> json) {
    return GelirGiderModel(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.expense,
      ),
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      projectId: json['projectId'] as String?,
      employeeId: json['employeeId'] as String?,
      patronId: json['patronId'] as String?,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
        orElse: () => PaymentMethod.cash,
      ),
      invoiceNumber: json['invoiceNumber'] as String?,
      receiptImageUrl: json['receiptImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPeriod: json['recurringPeriod'] != null
          ? RecurringPeriod.values.firstWhere(
              (e) =>
                  e.toString() == 'RecurringPeriod.${json['recurringPeriod']}',
              orElse: () => RecurringPeriod.monthly,
            )
          : null,
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'category': category,
      'amount': amount,
      'projectId': projectId,
      'employeeId': employeeId,
      'patronId': patronId,
      'date': date.toIso8601String(),
      'description': description,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'invoiceNumber': invoiceNumber,
      'receiptImageUrl': receiptImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod?.toString().split('.').last,
    };
  }

  // Model kopyalama
  GelirGiderModel copyWith({
    String? id,
    TransactionType? type,
    String? category,
    double? amount,
    String? projectId,
    String? employeeId,
    String? patronId,
    DateTime? date,
    String? description,
    PaymentMethod? paymentMethod,
    String? invoiceNumber,
    String? receiptImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool? isRecurring,
    RecurringPeriod? recurringPeriod,
  }) {
    return GelirGiderModel(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      projectId: projectId ?? this.projectId,
      employeeId: employeeId ?? this.employeeId,
      patronId: patronId ?? this.patronId,
      date: date ?? this.date,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
    );
  }

  // Gelir mi?
  bool get isIncome => type == TransactionType.income;

  // Gider mi?
  bool get isExpense => type == TransactionType.expense;

  // Tutarı işaretle (gelir +, gider -)
  double get signedAmount => isIncome ? amount : -amount;

  @override
  String toString() {
    return 'GelirGiderModel(id: $id, type: $type, category: $category, amount: $amount)';
  }
}

@HiveType(typeId: 12)
enum TransactionType {
  @HiveField(0)
  income, // Gelir

  @HiveField(1)
  expense, // Gider
}

@HiveType(typeId: 13)
enum PaymentMethod {
  @HiveField(0)
  cash, // Nakit

  @HiveField(1)
  bankTransfer, // Banka Havalesi

  @HiveField(2)
  creditCard, // Kredi Kartı

  @HiveField(3)
  check, // Çek

  @HiveField(4)
  other, // Diğer
}

@HiveType(typeId: 14)
enum RecurringPeriod {
  @HiveField(0)
  daily, // Günlük

  @HiveField(1)
  weekly, // Haftalık

  @HiveField(2)
  monthly, // Aylık

  @HiveField(3)
  yearly, // Yıllık
}

// Gelir/Gider kategorileri için yardımcı sınıf
class TransactionCategories {
  TransactionCategories._();

  // Gelir kategorileri
  static const List<String> incomeCategories = [
    'Proje Tahsilatı',
    'Avans Tahsilatı',
    'Hakedişi',
    'Diğer Gelir',
  ];

  // Gider kategorileri
  static const List<String> expenseCategories = [
    'Maaş Ödemesi',
    'Malzeme Alımı',
    'Ekipman Kiralama',
    'Ulaşım',
    'Yemek',
    'Yakıt',
    'Elektrik',
    'Su',
    'İnternet',
    'Kira',
    'Sigorta',
    'Vergi',
    'Bakım-Onarım',
    'Diğer Gider',
  ];

  // Tüm kategoriler
  static List<String> getAllCategories() {
    return [...incomeCategories, ...expenseCategories];
  }
}
