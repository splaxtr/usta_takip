import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/employee_model.dart';
import '../models/patron_model.dart';
import '../models/mesai_model.dart';
import '../models/gelir_gider_model.dart';

/// Hive veritabanı işlemlerini yöneten servis sınıfı
///
/// Kullanım:
/// ```dart
/// await HiveService.init(); // main.dart içinde
/// final users = HiveService.getUsers();
/// ```
class HiveService {
  HiveService._();

  // Box isimleri
  static const String _usersBox = 'users';
  static const String _projectsBox = 'projects';
  static const String _employeesBox = 'employees';
  static const String _patronsBox = 'patrons';
  static const String _mesaiBox = 'mesai';
  static const String _gelirGiderBox = 'gelirGider';

  /// Hive'ı başlat ve tüm adapter'ları kaydet
  ///
  /// main.dart içinde WidgetsFlutterBinding.ensureInitialized()
  /// sonrası çağrılmalı
  static Future<void> init() async {
    await Hive.initFlutter();

    // Adapter'ları kaydet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ProjectModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ProjectStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(EmployeeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(EmployeeStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PatronModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(PatronTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(MesaiModelAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MesaiTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(MesaiStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(GelirGiderModelAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(PaymentMethodAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(RecurringPeriodAdapter());
    }

    // Box'ları aç
    await Hive.openBox<UserModel>(_usersBox);
    await Hive.openBox<ProjectModel>(_projectsBox);
    await Hive.openBox<EmployeeModel>(_employeesBox);
    await Hive.openBox<PatronModel>(_patronsBox);
    await Hive.openBox<MesaiModel>(_mesaiBox);
    await Hive.openBox<GelirGiderModel>(_gelirGiderBox);
  }

  /// Tüm box'ları kapat
  static Future<void> close() async {
    await Hive.close();
  }

  // ========== USER İŞLEMLERİ ==========

  /// Kullanıcı ekle
  static Future<void> addUser(UserModel user) async {
    final box = Hive.box<UserModel>(_usersBox);
    await box.put(user.id, user);
  }

  /// Kullanıcı güncelle
  static Future<void> updateUser(UserModel user) async {
    final box = Hive.box<UserModel>(_usersBox);
    await box.put(user.id, user);
  }

  /// Kullanıcı sil
  static Future<void> deleteUser(String userId) async {
    final box = Hive.box<UserModel>(_usersBox);
    await box.delete(userId);
  }

  /// Kullanıcı getir
  static UserModel? getUser(String userId) {
    final box = Hive.box<UserModel>(_usersBox);
    return box.get(userId);
  }

  /// Tüm kullanıcıları getir
  static List<UserModel> getUsers() {
    final box = Hive.box<UserModel>(_usersBox);
    return box.values.toList();
  }

  // ========== PROJECT İŞLEMLERİ ==========

  /// Proje ekle
  static Future<void> addProject(ProjectModel project) async {
    final box = Hive.box<ProjectModel>(_projectsBox);
    await box.put(project.id, project);
  }

  /// Proje güncelle
  static Future<void> updateProject(ProjectModel project) async {
    final box = Hive.box<ProjectModel>(_projectsBox);
    await box.put(project.id, project);
  }

  /// Proje sil
  static Future<void> deleteProject(String projectId) async {
    final box = Hive.box<ProjectModel>(_projectsBox);
    await box.delete(projectId);
  }

  /// Proje getir
  static ProjectModel? getProject(String projectId) {
    final box = Hive.box<ProjectModel>(_projectsBox);
    return box.get(projectId);
  }

  /// Tüm projeleri getir
  static List<ProjectModel> getProjects() {
    final box = Hive.box<ProjectModel>(_projectsBox);
    return box.values.toList();
  }

  /// Aktif projeleri getir
  static List<ProjectModel> getActiveProjects() {
    final box = Hive.box<ProjectModel>(_projectsBox);
    return box.values.where((project) => project.isActive).toList();
  }

  /// Patron'a göre projeleri getir
  static List<ProjectModel> getProjectsByPatron(String patronId) {
    final box = Hive.box<ProjectModel>(_projectsBox);
    return box.values.where((project) => project.patronId == patronId).toList();
  }

  // ========== EMPLOYEE İŞLEMLERİ ==========

  /// Çalışan ekle
  static Future<void> addEmployee(EmployeeModel employee) async {
    final box = Hive.box<EmployeeModel>(_employeesBox);
    await box.put(employee.id, employee);
  }

  /// Çalışan güncelle
  static Future<void> updateEmployee(EmployeeModel employee) async {
    final box = Hive.box<EmployeeModel>(_employeesBox);
    await box.put(employee.id, employee);
  }

  /// Çalışan sil
  static Future<void> deleteEmployee(String employeeId) async {
    final box = Hive.box<EmployeeModel>(_employeesBox);
    await box.delete(employeeId);
  }

  /// Çalışan getir
  static EmployeeModel? getEmployee(String employeeId) {
    final box = Hive.box<EmployeeModel>(_employeesBox);
    return box.get(employeeId);
  }

  /// Tüm çalışanları getir
  static List<EmployeeModel> getEmployees() {
    final box = Hive.box<EmployeeModel>(_employeesBox);
    return box.values.toList();
  }

  /// Aktif çalışanları getir
  static List<EmployeeModel> getActiveEmployees() {
    final box = Hive.box<EmployeeModel>(_employeesBox);
    return box.values.where((employee) => employee.isActive).toList();
  }

  // ========== PATRON İŞLEMLERİ ==========

  /// Patron ekle
  static Future<void> addPatron(PatronModel patron) async {
    final box = Hive.box<PatronModel>(_patronsBox);
    await box.put(patron.id, patron);
  }

  /// Patron güncelle
  static Future<void> updatePatron(PatronModel patron) async {
    final box = Hive.box<PatronModel>(_patronsBox);
    await box.put(patron.id, patron);
  }

  /// Patron sil
  static Future<void> deletePatron(String patronId) async {
    final box = Hive.box<PatronModel>(_patronsBox);
    await box.delete(patronId);
  }

  /// Patron getir
  static PatronModel? getPatron(String patronId) {
    final box = Hive.box<PatronModel>(_patronsBox);
    return box.get(patronId);
  }

  /// Tüm patronları getir
  static List<PatronModel> getPatrons() {
    final box = Hive.box<PatronModel>(_patronsBox);
    return box.values.toList();
  }

  /// Aktif patronları getir
  static List<PatronModel> getActivePatrons() {
    final box = Hive.box<PatronModel>(_patronsBox);
    return box.values.where((patron) => patron.isActive).toList();
  }

  // ========== MESAİ İŞLEMLERİ ==========

  /// Mesai ekle
  static Future<void> addMesai(MesaiModel mesai) async {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    await box.put(mesai.id, mesai);
  }

  /// Mesai güncelle
  static Future<void> updateMesai(MesaiModel mesai) async {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    await box.put(mesai.id, mesai);
  }

  /// Mesai sil
  static Future<void> deleteMesai(String mesaiId) async {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    await box.delete(mesaiId);
  }

  /// Mesai getir
  static MesaiModel? getMesai(String mesaiId) {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    return box.get(mesaiId);
  }

  /// Tüm mesaileri getir
  static List<MesaiModel> getAllMesai() {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    return box.values.toList();
  }

  /// Çalışana göre mesaileri getir
  static List<MesaiModel> getMesaiByEmployee(String employeeId) {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    return box.values.where((mesai) => mesai.employeeId == employeeId).toList();
  }

  /// Projeye göre mesaileri getir
  static List<MesaiModel> getMesaiByProject(String projectId) {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    return box.values.where((mesai) => mesai.projectId == projectId).toList();
  }

  /// Tarih aralığına göre mesaileri getir
  static List<MesaiModel> getMesaiByDateRange(DateTime start, DateTime end) {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    return box.values
        .where((mesai) =>
            mesai.date.isAfter(start.subtract(const Duration(days: 1))) &&
            mesai.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Ödenmemiş mesaileri getir
  static List<MesaiModel> getUnpaidMesai() {
    final box = Hive.box<MesaiModel>(_mesaiBox);
    return box.values.where((mesai) => !mesai.isPaid).toList();
  }

  // ========== GELİR-GİDER İŞLEMLERİ ==========

  /// Gelir/Gider ekle
  static Future<void> addGelirGider(GelirGiderModel gelirGider) async {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    await box.put(gelirGider.id, gelirGider);
  }

  /// Gelir/Gider güncelle
  static Future<void> updateGelirGider(GelirGiderModel gelirGider) async {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    await box.put(gelirGider.id, gelirGider);
  }

  /// Gelir/Gider sil
  static Future<void> deleteGelirGider(String gelirGiderId) async {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    await box.delete(gelirGiderId);
  }

  /// Gelir/Gider getir
  static GelirGiderModel? getGelirGider(String gelirGiderId) {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.get(gelirGiderId);
  }

  /// Tüm gelir/giderleri getir
  static List<GelirGiderModel> getAllGelirGider() {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.values.toList();
  }

  /// Sadece gelirleri getir
  static List<GelirGiderModel> getIncomes() {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.values.where((item) => item.isIncome).toList();
  }

  /// Sadece giderleri getir
  static List<GelirGiderModel> getExpenses() {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.values.where((item) => item.isExpense).toList();
  }

  /// Projeye göre gelir/giderleri getir
  static List<GelirGiderModel> getGelirGiderByProject(String projectId) {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.values.where((item) => item.projectId == projectId).toList();
  }

  /// Tarih aralığına göre gelir/giderleri getir
  static List<GelirGiderModel> getGelirGiderByDateRange(
      DateTime start, DateTime end) {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.values
        .where((item) =>
            item.date.isAfter(start.subtract(const Duration(days: 1))) &&
            item.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Toplam gelir hesapla
  static double getTotalIncome() {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.values
        .where((item) => item.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Toplam gider hesapla
  static double getTotalExpense() {
    final box = Hive.box<GelirGiderModel>(_gelirGiderBox);
    return box.values
        .where((item) => item.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Net kar/zarar hesapla
  static double getNetProfit() {
    return getTotalIncome() - getTotalExpense();
  }

  // ========== YARDIMCI İŞLEMLER ==========

  /// Tüm verileri temizle (dikkatli kullanın!)
  static Future<void> clearAllData() async {
    await Hive.box<UserModel>(_usersBox).clear();
    await Hive.box<ProjectModel>(_projectsBox).clear();
    await Hive.box<EmployeeModel>(_employeesBox).clear();
    await Hive.box<PatronModel>(_patronsBox).clear();
    await Hive.box<MesaiModel>(_mesaiBox).clear();
    await Hive.box<GelirGiderModel>(_gelirGiderBox).clear();
  }

  /// Belirli bir box'ı temizle
  static Future<void> clearBox(String boxName) async {
    switch (boxName) {
      case 'users':
        await Hive.box<UserModel>(_usersBox).clear();
        break;
      case 'projects':
        await Hive.box<ProjectModel>(_projectsBox).clear();
        break;
      case 'employees':
        await Hive.box<EmployeeModel>(_employeesBox).clear();
        break;
      case 'patrons':
        await Hive.box<PatronModel>(_patronsBox).clear();
        break;
      case 'mesai':
        await Hive.box<MesaiModel>(_mesaiBox).clear();
        break;
      case 'gelirGider':
        await Hive.box<GelirGiderModel>(_gelirGiderBox).clear();
        break;
    }
  }
}
