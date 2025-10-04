import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectKey;

  const ProjectDetailScreen({
    super.key,
    required this.projectKey,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  final Box projeBox = Hive.box('projeler');
  final Box calisanBox = Hive.box('calisanlar');
  final Box mesaiBox = Hive.box('mesailer');
  final Box gelirGiderBox = Hive.box('gelirgider');

  late TabController _tabController;

  Map? projectData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProject();
  }

  void _loadProject() {
    setState(() {
      projectData = projeBox.getAt(widget.projectKey);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (projectData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF101922),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          projectData!['name'] ?? 'Proje Detayı',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Projeyi Tamamla Butonu
          IconButton(
            icon: Icon(
              projectData!['status'] == 'completed'
                  ? Icons.restart_alt
                  : Icons.check_circle_outline,
              color: projectData!['status'] == 'completed'
                  ? Colors.orange
                  : Colors.green,
            ),
            onPressed: () => _showCompleteProjectDialog(),
            tooltip: projectData!['status'] == 'completed'
                ? 'Projeyi Aktif Yap'
                : 'Projeyi Tamamla',
          ),
          // Projeyi Sil Butonu
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteProjectDialog(),
            tooltip: 'Projeyi Sil',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProjectSummary(),
          Container(
            color: const Color(0xFF101922),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Çalışanlar'),
                Tab(text: 'Finans'),
                Tab(text: 'Ödemeler'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmployeesTab(),
                _buildFinanceTab(),
                _buildPaymentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROJECT SUMMARY ====================
  Widget _buildProjectSummary() {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var key in gelirGiderBox.keys) {
      var item = gelirGiderBox.get(key);
      if (item['projectKey'] == widget.projectKey) {
        if (item['type'] == 'gelir') {
          totalIncome += (item['amount'] ?? 0.0);
        } else if (item['type'] == 'gider') {
          totalExpenses += (item['amount'] ?? 0.0);
        }
      }
    }

    double netBalance = totalIncome - totalExpenses;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.2),
                  image: projectData!['imageUrl'] != null
                      ? DecorationImage(
                          image: NetworkImage(projectData!['imageUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: projectData!['imageUrl'] == null
                    ? const Icon(Icons.construction,
                        color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectData!['name'] ?? 'Proje',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Başlangıç: ${projectData!['startDate'] ?? '-'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Gelir',
                  '${totalIncome.toStringAsFixed(0)}₺',
                  Colors.green.shade300,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Gider',
                  '${totalExpenses.toStringAsFixed(0)}₺',
                  Colors.red.shade300,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Net',
                  '${netBalance.toStringAsFixed(0)}₺',
                  netBalance >= 0 ? Colors.white : Colors.orange.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==================== ÇALIŞANLAR TAB ====================
  Widget _buildEmployeesTab() {
    return ValueListenableBuilder(
      valueListenable: mesaiBox.listenable(), // ✅ mesaiBox'ı dinle
      builder: (context, Box box, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddEmployeeDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Çalışan Ata'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Atanan Çalışanlar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildEmployeesList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmployeesList() {
    List<Map<String, dynamic>> projectEmployees = [];

    for (var key in mesaiBox.keys) {
      var mesai = mesaiBox.get(key);
      if (mesai['projectKey'] == widget.projectKey) {
        var employeeKey = mesai['employeeKey'];
        var employee = calisanBox.get(employeeKey);

        if (employee != null) {
          projectEmployees.add({
            'mesaiKey': key,
            'employeeKey': employeeKey,
            'employee': employee,
            'mesai': mesai,
          });
        }
      }
    }

    if (projectEmployees.isEmpty) {
      return _buildEmptyState(
        'Henüz çalışan atanmamış',
        'Bu projeye çalışan atamak için yukarıdaki butona tıklayın',
        Icons.people_outline,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projectEmployees.length,
      itemBuilder: (context, index) {
        var data = projectEmployees[index];
        var employee = data['employee'];
        var mesai = data['mesai'];

        // Günlük çalışma detaylarından toplam kazancı hesapla
        double totalEarnings = 0;
        int totalDays = 0;

        if (mesai['workDetails'] != null && mesai['workDetails'] is List) {
          List workDetails = mesai['workDetails'];
          for (var detail in workDetails) {
            totalEarnings += (detail['wage'] ?? 0.0);
            totalDays++;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      (employee['name'] ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'] ?? 'İsimsiz',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Standart: ${mesai['dailyWage']?.toStringAsFixed(0)}₺/gün',
                          style: TextStyle(
                            color: Colors.green[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalDays gün',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalEarnings.toStringAsFixed(0)}₺',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // SİLME BUTONU EKLENDI
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () => _showRemoveEmployeeDialog(
                      data['mesaiKey'],
                      employee['name'],
                      totalEarnings,
                    ),
                    tooltip: 'Projeden Çıkar',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Çalışma detayları varsa göster
              if (mesai['workDetails'] != null &&
                  mesai['workDetails'] is List &&
                  mesai['workDetails'].isNotEmpty)
                _buildWorkDetailsPreview(mesai['workDetails']),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddWorkDayDetailsDialog(
                        data['mesaiKey'],
                        data['employeeKey'],
                        mesai['dailyWage'],
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Gün Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showWorkDetailsDialog(
                        data['mesaiKey'],
                        employee['name'],
                        mesai['workDetails'],
                      ),
                      icon: const Icon(Icons.list, size: 16),
                      label: const Text('Detaylar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRemoveEmployeeDialog(
    int mesaiKey,
    String? employeeName,
    double totalEarnings,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Çalışanı Projeden Çıkar',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                children: [
                  const TextSpan(text: 'Bu işlem '),
                  TextSpan(
                    text: employeeName ?? 'çalışanı',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const TextSpan(text: ' projeden çıkaracak.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Silinecek Veriler:',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem(
                      'Toplam kazanç: ${totalEarnings.toStringAsFixed(0)}₺'),
                  _buildWarningItem('Tüm çalışma günleri ve detaylar'),
                  _buildWarningItem('Mesai kayıtları'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Not: Çalışan sadece bu projeden çıkarılır, sistemden silinmez.',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Çalışanı projeden çıkar (mesai kaydını sil)
              await mesaiBox.delete(mesaiKey);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$employeeName projeden çıkarıldı'),
                    backgroundColor: Colors.orange,
                    action: SnackBarAction(
                      label: 'Tamam',
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever, size: 20),
            label: const Text('Projeden Çıkar'),
          ),
        ],
      ),
    );
  }

// Uyarı listesi item'ı
  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.red[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.red[200],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Çalışma detaylarının kısa önizlemesi
  Widget _buildWorkDetailsPreview(List workDetails) {
    // Son 3 günü göster
    List lastThree = workDetails.reversed.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101922),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Çalışma Günleri:',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...lastThree.map((detail) {
            IconData icon;
            Color color;

            switch (detail['type']) {
              case 'full':
                icon = Icons.check_circle;
                color = Colors.green;
                break;
              case 'half':
                icon = Icons.timelapse;
                color = Colors.orange;
                break;
              case 'overtime':
                icon = Icons.star;
                color = Colors.amber;
                break;
              case 'custom':
                icon = Icons.edit;
                color = Colors.blue;
                break;
              default:
                icon = Icons.work;
                color = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 8),
                  Text(
                    detail['date'] ?? '-',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${detail['wage']?.toStringAsFixed(0)}₺',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (detail['note'] != null && detail['note'].isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail['note'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _showAddWorkDayDetailsDialog(
    int mesaiKey,
    int employeeKey,
    double? standardWage,
  ) async {
    var employee = calisanBox.get(employeeKey);
    String selectedType = 'full';
    DateTime selectedDate = DateTime.now();
    final wageController = TextEditingController(
      text: standardWage?.toStringAsFixed(0) ?? '2500',
    );
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            '${employee['name']} - Gün Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarih Seçimi
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.blue,
                              surface: Color(0xFF1E1E1E),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101922),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Çalışma Tipi
                Text(
                  'Çalışma Tipi',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                _buildWorkTypeOption(
                  'full',
                  'Tam Gün',
                  Icons.check_circle,
                  Colors.green,
                  selectedType,
                  standardWage ?? 2500,
                  (type) {
                    setState(() {
                      selectedType = type;
                      wageController.text =
                          standardWage?.toStringAsFixed(0) ?? '2500';
                    });
                  },
                ),
                _buildWorkTypeOption(
                  'half',
                  'Yarım Gün',
                  Icons.timelapse,
                  Colors.orange,
                  selectedType,
                  (standardWage ?? 2500) / 2,
                  (type) {
                    setState(() {
                      selectedType = type;
                      wageController.text =
                          ((standardWage ?? 2500) / 2).toStringAsFixed(0);
                    });
                  },
                ),
                _buildWorkTypeOption(
                  'overtime',
                  'Mesaili Gün',
                  Icons.star,
                  Colors.amber,
                  selectedType,
                  (standardWage ?? 2500) * 2,
                  (type) {
                    setState(() {
                      selectedType = type;
                      wageController.text =
                          ((standardWage ?? 2500) * 2).toStringAsFixed(0);
                    });
                  },
                ),
                _buildWorkTypeOption(
                  'custom',
                  'Özel Ücret',
                  Icons.edit,
                  Colors.blue,
                  selectedType,
                  0,
                  (type) {
                    setState(() {
                      selectedType = type;
                      wageController.clear();
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Ücret Girişi
                TextField(
                  controller: wageController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Ücret (₺)',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                        const Icon(Icons.attach_money, color: Colors.green),
                    filled: true,
                    fillColor: const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Not
                TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Not (Opsiyonel)',
                    hintText: 'Örn: 2 saat mesai yaptı',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.note, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                double wage = double.tryParse(wageController.text) ?? 0;
                if (wage > 0) {
                  var mesaiData = mesaiBox.get(mesaiKey);

                  // workDetails listesi yoksa oluştur
                  if (mesaiData['workDetails'] == null) {
                    mesaiData['workDetails'] = [];
                  }

                  // Yeni günü ekle
                  mesaiData['workDetails'].add({
                    'date': DateFormat('dd/MM/yyyy').format(selectedDate),
                    'type': selectedType,
                    'wage': wage,
                    'note': noteController.text.trim(),
                    'timestamp': DateTime.now().toString(),
                  });

                  await mesaiBox.put(mesaiKey, mesaiData);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Çalışma günü eklendi!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

// Çalışma tipi seçeneği widget'ı
  Widget _buildWorkTypeOption(
    String type,
    String label,
    IconData icon,
    Color color,
    String selectedType,
    double suggestedWage,
    Function(String) onSelect,
  ) {
    bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF101922),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (type != 'custom' && suggestedWage > 0)
                    Text(
                      '${suggestedWage.toStringAsFixed(0)}₺',
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showWorkDetailsDialog(
    int mesaiKey,
    String? employeeName,
    dynamic workDetails,
  ) async {
    List details = workDetails is List ? workDetails : [];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          '$employeeName - Çalışma Detayları',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: details.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz çalışma günü eklenmemiş',
                          style: TextStyle(color: Colors.grey[400]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    var detail = details[details.length -
                        1 -
                        index]; // Ters sıra (en yeni üstte)

                    IconData icon;
                    Color color;
                    String typeLabel;

                    switch (detail['type']) {
                      case 'full':
                        icon = Icons.check_circle;
                        color = Colors.green;
                        typeLabel = 'Tam Gün';
                        break;
                      case 'half':
                        icon = Icons.timelapse;
                        color = Colors.orange;
                        typeLabel = 'Yarım Gün';
                        break;
                      case 'overtime':
                        icon = Icons.star;
                        color = Colors.amber;
                        typeLabel = 'Mesaili';
                        break;
                      case 'custom':
                        icon = Icons.edit;
                        color = Colors.blue;
                        typeLabel = 'Özel';
                        break;
                      default:
                        icon = Icons.work;
                        color = Colors.grey;
                        typeLabel = 'Çalışma';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101922),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      detail['date'] ?? '-',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        typeLabel,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (detail['note'] != null &&
                                    detail['note'].toString().isNotEmpty)
                                  Text(
                                    detail['note'],
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${detail['wage']?.toStringAsFixed(0)}₺',
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () async {
                              // Silme onayı
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text('Günü Sil',
                                      style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                    'Bu çalışma gününü silmek istediğinize emin misiniz?',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('İptal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text('Sil',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                var mesaiData = mesaiBox.get(mesaiKey);
                                List workDetailsList = mesaiData['workDetails'];
                                workDetailsList
                                    .removeAt(details.length - 1 - index);
                                await mesaiBox.put(mesaiKey, mesaiData);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Çalışma günü silindi!'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // ==================== FİNANS TAB ====================
  Widget _buildFinanceTab() {
    return ValueListenableBuilder(
      valueListenable: gelirGiderBox.listenable(), // ✅ Box'ı dinle
      builder: (context, Box box, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddTransactionDialog('gelir'),
                      icon: const Icon(Icons.add),
                      label: const Text('Gelir Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddTransactionDialog('gider'),
                      icon: const Icon(Icons.remove),
                      label: const Text('Gider Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Finansal Özet
              _buildFinancialSummary(),
              const SizedBox(height: 20),

              const Text(
                'İşlemler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTransactionsList(),
            ],
          ),
        );
      },
    );
  }

// Finansal özet kartı
  Widget _buildFinancialSummary() {
    double totalIncome = 0;
    double totalExpenses = 0;
    Map<String, double> expensesByCategory = {};

    for (var key in gelirGiderBox.keys) {
      var item = gelirGiderBox.get(key);
      if (item['projectKey'] == widget.projectKey) {
        if (item['type'] == 'gelir') {
          totalIncome += (item['amount'] ?? 0.0);
        } else if (item['type'] == 'gider') {
          double amount = item['amount'] ?? 0.0;
          totalExpenses += amount;

          String category = item['category'] ?? 'Diğer';
          expensesByCategory[category] =
              (expensesByCategory[category] ?? 0) + amount;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryColumn('Gelir', totalIncome, Colors.green.shade300),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildSummaryColumn('Gider', totalExpenses, Colors.red.shade300),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildSummaryColumn(
                'Kalan',
                totalIncome - totalExpenses,
                (totalIncome - totalExpenses) >= 0
                    ? Colors.white
                    : Colors.orange.shade300,
              ),
            ],
          ),
          if (expensesByCategory.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: expensesByCategory.entries.map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(entry.key),
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${entry.key}: ${entry.value.toStringAsFixed(0)}₺',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)}₺',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    List<Map<String, dynamic>> transactions = [];

    for (var key in gelirGiderBox.keys) {
      var item = gelirGiderBox.get(key);
      if (item['projectKey'] == widget.projectKey) {
        transactions.add({
          'key': key,
          'data': item,
        });
      }
    }

    if (transactions.isEmpty) {
      return _buildEmptyState(
        'Henüz işlem yok',
        'Gelir veya gider eklemek için yukarıdaki butonları kullanın',
        Icons.receipt_long_outlined,
      );
    }

    transactions.sort((a, b) {
      DateTime dateA =
          DateTime.parse(a['data']['date'] ?? DateTime.now().toString());
      DateTime dateB =
          DateTime.parse(b['data']['date'] ?? DateTime.now().toString());
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        var transactionKey = transactions[index]['key'];
        var transaction = transactions[index]['data'];
        bool isIncome = transaction['type'] == 'gelir';
        String category =
            transaction['category'] ?? (isIncome ? 'Ödeme' : 'Diğer');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isIncome
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isIncome
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                transaction['description'] ?? category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${isIncome ? '+' : '-'}${transaction['amount']?.toStringAsFixed(0)}₺',
                              style: TextStyle(
                                color: isIncome ? Colors.green : Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isIncome ? Colors.green : Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(transaction['date']),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showEditTransactionDialog(
                      transactionKey,
                      transaction,
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Düzenle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showDeleteTransactionDialog(
                      transactionKey,
                      transaction,
                    ),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Sil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== ÖDEMELER TAB ====================
  Widget _buildPaymentsTab() {
    return ValueListenableBuilder(
      valueListenable: mesaiBox.listenable(), // ✅ Var olmalı
      builder: (context, Box box, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentSummary(),
              const SizedBox(height: 20),
              const Text(
                'Çalışan Ödemeleri',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildEmployeePaymentsList(),
            ],
          ),
        );
      },
    );
  }

// Ödeme özet kartı
  Widget _buildPaymentSummary() {
    double totalEarned = 0;
    double totalPaid = 0;
    int employeesWithDebt = 0;

    for (var key in mesaiBox.keys) {
      var mesai = mesaiBox.get(key);
      if (mesai['projectKey'] == widget.projectKey) {
        // Toplam kazanç
        if (mesai['workDetails'] != null && mesai['workDetails'] is List) {
          for (var detail in mesai['workDetails']) {
            totalEarned += (detail['wage'] ?? 0.0);
          }
        }

        // Toplam ödeme
        if (mesai['payments'] != null && mesai['payments'] is List) {
          for (var payment in mesai['payments']) {
            totalPaid += (payment['amount'] ?? 0.0);
          }
        }

        // Borçlu çalışan sayısı
        double earned = 0;
        if (mesai['workDetails'] != null && mesai['workDetails'] is List) {
          for (var detail in mesai['workDetails']) {
            earned += (detail['wage'] ?? 0.0);
          }
        }

        double paid = 0;
        if (mesai['payments'] != null && mesai['payments'] is List) {
          for (var payment in mesai['payments']) {
            paid += (payment['amount'] ?? 0.0);
          }
        }

        if (earned > paid) {
          employeesWithDebt++;
        }
      }
    }

    double remainingDebt = totalEarned - totalPaid;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: remainingDebt > 0
              ? [Colors.orange.shade700, Colors.orange.shade500]
              : [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (remainingDebt > 0 ? Colors.orange : Colors.green)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPaymentSummaryItem(
                'Toplam Hakediş',
                '${totalEarned.toStringAsFixed(0)}₺',
                Icons.account_balance_wallet,
              ),
              Container(width: 1, height: 60, color: Colors.white30),
              _buildPaymentSummaryItem(
                'Ödenen',
                '${totalPaid.toStringAsFixed(0)}₺',
                Icons.check_circle,
              ),
              Container(width: 1, height: 60, color: Colors.white30),
              _buildPaymentSummaryItem(
                'Kalan Borç',
                '${remainingDebt.toStringAsFixed(0)}₺',
                remainingDebt > 0 ? Icons.warning : Icons.done_all,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  employeesWithDebt > 0 ? Icons.people : Icons.celebration,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  employeesWithDebt > 0
                      ? '$employeesWithDebt çalışanın ödemesi bekliyor'
                      : 'Tüm ödemeler tamamlandı! 🎉',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// Çalışan ödemeleri listesi
  Widget _buildEmployeePaymentsList() {
    List<Map<String, dynamic>> employeePayments = [];

    for (var key in mesaiBox.keys) {
      var mesai = mesaiBox.get(key);
      if (mesai['projectKey'] == widget.projectKey) {
        var employeeKey = mesai['employeeKey'];
        var employee = calisanBox.get(employeeKey);

        if (employee != null) {
          // Toplam kazanç hesapla
          double totalEarned = 0;
          if (mesai['workDetails'] != null && mesai['workDetails'] is List) {
            for (var detail in mesai['workDetails']) {
              totalEarned += (detail['wage'] ?? 0.0);
            }
          }

          // Toplam ödeme hesapla
          double totalPaid = 0;
          if (mesai['payments'] != null && mesai['payments'] is List) {
            for (var payment in mesai['payments']) {
              totalPaid += (payment['amount'] ?? 0.0);
            }
          }

          double remaining = totalEarned - totalPaid;

          employeePayments.add({
            'mesaiKey': key,
            'employee': employee,
            'mesai': mesai,
            'totalEarned': totalEarned,
            'totalPaid': totalPaid,
            'remaining': remaining,
          });
        }
      }
    }

    if (employeePayments.isEmpty) {
      return _buildEmptyState(
        'Henüz çalışan yok',
        'Önce çalışan ekleyip çalışma günleri girmelisiniz',
        Icons.people_outline,
      );
    }

    // Borcu olanlara öncelik ver
    employeePayments.sort((a, b) => b['remaining'].compareTo(a['remaining']));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employeePayments.length,
      itemBuilder: (context, index) {
        var data = employeePayments[index];
        return _buildEmployeePaymentCard(data);
      },
    );
  }

  Widget _buildEmployeePaymentCard(Map<String, dynamic> data) {
    var employee = data['employee'];
    var mesai = data['mesai'];
    double totalEarned = data['totalEarned'];
    double totalPaid = data['totalPaid'];
    double remaining = data['remaining'];

    bool isPaid = remaining <= 0;
    int paymentCount = mesai['payments'] != null && mesai['payments'] is List
        ? mesai['payments'].length
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid
              ? Colors.green.withOpacity(0.5)
              : Colors.orange.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isPaid
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                child: isPaid
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 30)
                    : Text(
                        (employee['name'] ?? 'A')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee['name'] ?? 'İsimsiz',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isPaid)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check,
                                    color: Colors.green, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Ödendi',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPaymentInfoChip(
                          'Hakediş',
                          '${totalEarned.toStringAsFixed(0)}₺',
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentInfoChip(
                          'Ödenen',
                          '${totalPaid.toStringAsFixed(0)}₺',
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kalan borç
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPaid ? 'Ödeme Tamamlandı' : 'Kalan Borç',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${remaining.toStringAsFixed(0)}₺',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Aksiyonlar
          Row(
            children: [
              if (!isPaid)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddPaymentDialog(
                      data['mesaiKey'],
                      employee['name'],
                      remaining,
                    ),
                    icon: const Icon(Icons.payments, size: 18),
                    label: const Text('Ödeme Yap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (!isPaid) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: paymentCount > 0
                      ? () => _showPaymentHistoryDialog(
                            employee['name'],
                            mesai['payments'],
                            data['mesaiKey'],
                          )
                      : null,
                  icon: const Icon(Icons.history, size: 18),
                  label: Text('Geçmiş ($paymentCount)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

// Kategori ikonları
  IconData _getCategoryIcon(String category) {
    switch (category) {
      // Gelir kategorileri
      case 'Patron Ödemesi':
        return Icons.account_balance_wallet;
      case 'Avans':
        return Icons.payments;

      // Gider kategorileri
      case 'Yemek':
        return Icons.restaurant;
      case 'Market':
        return Icons.shopping_cart;
      case 'Araba':
      case 'Yakıt':
        return Icons.local_gas_station;
      case 'Malzeme':
        return Icons.hardware;
      case 'Araç/Gereç':
        return Icons.build;
      case 'Ulaşım':
        return Icons.directions_car;
      case 'Diğer':
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }

// Gelir kategorileri
  List<String> _getIncomeCategories() {
    return [
      'Patron Ödemesi',
      'Avans',
      'Diğer',
    ];
  }

// Gider kategorileri
  List<String> _getExpenseCategories() {
    return [
      'Yemek',
      'Market',
      'Araba',
      'Malzeme',
      'Araç/Gereç',
      'Ulaşım',
      'Diğer',
    ];
  }

  // ==================== YENİ DIALOGLAR - BURADAN BAŞLIYOR ====================

  // TOPLU ÇALIŞAN EKLEME DİALOGU
  Future<void> _showAddEmployeeDialog() async {
    if (calisanBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce çalışan eklemelisiniz!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Set<int> existingEmployees = {};
    for (var key in mesaiBox.keys) {
      var mesai = mesaiBox.get(key);
      if (mesai['projectKey'] == widget.projectKey) {
        existingEmployees.add(mesai['employeeKey']);
      }
    }

    Map<int, bool> selectedEmployees = {};
    Map<int, TextEditingController> wageControllers = {};

    for (var key in calisanBox.keys) {
      if (!existingEmployees.contains(key)) {
        selectedEmployees[key] = false;
        wageControllers[key] = TextEditingController(text: '500');
      }
    }

    if (selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm çalışanlar zaten bu projede!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Row(
            children: [
              const Text(
                'Çalışan Ekle',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    bool allSelected = selectedEmployees.values.every((v) => v);
                    for (var key in selectedEmployees.keys) {
                      selectedEmployees[key] = !allSelected;
                    }
                  });
                },
                child: Text(
                  selectedEmployees.values.every((v) => v) ? 'Hiçbiri' : 'Tümü',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: selectedEmployees.keys.map((employeeKey) {
                var employee = calisanBox.get(employeeKey);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101922),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedEmployees[employeeKey]!
                          ? Colors.blue
                          : Colors.grey.shade800,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: selectedEmployees[employeeKey],
                            onChanged: (value) {
                              setState(() {
                                selectedEmployees[employeeKey] = value ?? false;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            child: Text(
                              (employee['name'] ?? 'A')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee['name'] ?? 'İsimsiz',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (employee['specialty'] != null &&
                                    employee['specialty'].isNotEmpty)
                                  Text(
                                    employee['specialty'],
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (selectedEmployees[employeeKey]!)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextField(
                            controller: wageControllers[employeeKey],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Günlük Ücret (₺)',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: const Icon(
                                Icons.attach_money,
                                color: Colors.green,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1E1E1E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                int addedCount = 0;
                for (var employeeKey in selectedEmployees.keys) {
                  if (selectedEmployees[employeeKey]!) {
                    double dailyWage = double.tryParse(
                          wageControllers[employeeKey]!.text,
                        ) ??
                        0;

                    if (dailyWage > 0) {
                      await mesaiBox.add({
                        'projectKey': widget.projectKey,
                        'employeeKey': employeeKey,
                        'dailyWage': dailyWage,
                        'workDays': 0,
                        'createdAt': DateTime.now().toString(),
                      });
                      addedCount++;
                    }
                  }
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$addedCount çalışan eklendi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                'Ekle',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GÜN EKLEME DİALOGU
  Future<void> _showAddWorkDayDialog(int mesaiKey, int employeeKey) async {
    final daysController = TextEditingController(text: '1');
    var employee = calisanBox.get(employeeKey);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          '${employee['name']} - Gün Ekle',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Kaç gün çalıştı?',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: '1',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon:
                    const Icon(Icons.calendar_today, color: Colors.blue),
                filled: true,
                fillColor: const Color(0xFF101922),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Her gün için günlük ücret hesaplanacak',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              int additionalDays = int.tryParse(daysController.text) ?? 0;
              if (additionalDays > 0) {
                var mesaiData = mesaiBox.get(mesaiKey);
                mesaiData['workDays'] =
                    (mesaiData['workDays'] ?? 0) + additionalDays;
                await mesaiBox.put(mesaiKey, mesaiData);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$additionalDays gün eklendi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Ekle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // GÜNLÜK ÜCRETİ DÜZENLEME DİALOGU
  Future<void> _showEditDailyWageDialog(
      int mesaiKey, double? currentWage) async {
    final wageController = TextEditingController(
      text: currentWage?.toStringAsFixed(0) ?? '2500',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Günlük Ücreti Düzenle',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: wageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Yeni Günlük Ücret (₺)',
            labelStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
            filled: true,
            fillColor: const Color(0xFF101922),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              double newWage = double.tryParse(wageController.text) ?? 0;
              if (newWage > 0) {
                var mesaiData = mesaiBox.get(mesaiKey);
                mesaiData['dailyWage'] = newWage;
                await mesaiBox.put(mesaiKey, mesaiData);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Günlük ücret güncellendi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // GELİR/GİDER EKLEME DİALOGU
  Future<void> _showAddTransactionDialog(String type) async {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    bool isIncome = type == 'gelir';

    List<String> categories =
        isIncome ? _getIncomeCategories() : _getExpenseCategories();

    String selectedCategory = categories.first;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            isIncome ? 'Gelir Ekle' : 'Gider Ekle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori Seçimi
                Text(
                  'Kategori',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101922),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isIncome
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[400],
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                size: 20,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tutar
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tutar (₺)',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Açıklama
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Açıklama (Opsiyonel)',
                    hintText: 'Örn: Market alışverişi',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.note, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                double amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  await gelirGiderBox.add({
                    'projectKey': widget.projectKey,
                    'type': type,
                    'amount': amount,
                    'category': selectedCategory,
                    'description': descController.text.trim(),
                    'date': DateTime.now().toString(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isIncome ? 'Gelir eklendi!' : 'Gider eklendi!',
                        ),
                        backgroundColor: isIncome ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome ? Colors.green : Colors.red,
              ),
              child:
                  const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTransactionDialog(
    int transactionKey,
    Map transaction,
  ) async {
    final amountController = TextEditingController(
      text: transaction['amount']?.toStringAsFixed(0) ?? '',
    );
    final descController = TextEditingController(
      text: transaction['description'] ?? '',
    );

    bool isIncome = transaction['type'] == 'gelir';
    List<String> categories =
        isIncome ? _getIncomeCategories() : _getExpenseCategories();

    String selectedCategory = transaction['category'] ?? categories.first;
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            isIncome ? 'Geliri Düzenle' : 'Gideri Düzenle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori
                Text(
                  'Kategori',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101922),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isIncome
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                size: 20,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tutar
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tutar (₺)',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Açıklama
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.note, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                double amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  transaction['amount'] = amount;
                  transaction['category'] = selectedCategory;
                  transaction['description'] = descController.text.trim();

                  await gelirGiderBox.put(transactionKey, transaction);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('İşlem güncellendi!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child:
                  const Text('Güncelle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteTransactionDialog(
    int transactionKey,
    Map transaction,
  ) async {
    bool isIncome = transaction['type'] == 'gelir';
    String category = transaction['category'] ?? '';
    double amount = transaction['amount'] ?? 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: isIncome ? Colors.orange : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'İşlemi Sil',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu işlemi silmek istediğinize emin misiniz?',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF101922),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isIncome
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: isIncome ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${amount.toStringAsFixed(0)}₺',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction['description'] != null &&
                      transaction['description'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        transaction['description'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await gelirGiderBox.delete(transactionKey);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('İşlem silindi!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            icon: const Icon(Icons.delete_forever, size: 20),
            label: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPaymentDialog(
    int mesaiKey,
    String? employeeName,
    double remainingDebt,
  ) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    bool payFull = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        // dialogContext kullan
        builder: (context, setDialogState) => AlertDialog(
          // setDialogState kullan
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            '$employeeName - Ödeme Yap',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kalan borç bilgisi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kalan Borç:',
                        style: TextStyle(color: Colors.orange),
                      ),
                      Text(
                        '${remainingDebt.toStringAsFixed(0)}₺',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tam ödeme checkbox
                CheckboxListTile(
                  value: payFull,
                  onChanged: (value) {
                    setDialogState(() {
                      // setDialogState kullan
                      payFull = value ?? false;
                      if (payFull) {
                        amountController.text =
                            remainingDebt.toStringAsFixed(0);
                      } else {
                        amountController.clear();
                      }
                    });
                  },
                  title: const Text(
                    'Tüm borcu öde',
                    style: TextStyle(color: Colors.white),
                  ),
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),

                // Tutar girişi
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  enabled: !payFull,
                  decoration: InputDecoration(
                    labelText: 'Ödeme Tutarı (₺)',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'Örn: 1000',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon:
                        const Icon(Icons.attach_money, color: Colors.green),
                    filled: true,
                    fillColor: payFull
                        ? const Color(0xFF101922).withOpacity(0.5)
                        : const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Not
                TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Not (Opsiyonel)',
                    hintText: 'Örn: Nakit ödeme',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.note, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFF101922),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                double amount = double.tryParse(amountController.text) ?? 0;

                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen geçerli bir tutar girin!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (amount > remainingDebt) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ödeme tutarı kalan borçtan fazla olamaz!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                var mesaiData = mesaiBox.get(mesaiKey);

                // Payments listesi yoksa oluştur
                if (mesaiData['payments'] == null) {
                  mesaiData['payments'] = [];
                }

                // Yeni ödeme ekle
                mesaiData['payments'].add({
                  'amount': amount,
                  'date': DateTime.now().toString(),
                  'note': noteController.text.trim(),
                });

                await mesaiBox.put(mesaiKey, mesaiData);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${amount.toStringAsFixed(0)}₺ ödeme kaydedildi!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check),
              label: const Text('Ödemeyi Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPaymentHistoryDialog(
    String? employeeName,
    dynamic payments,
    int mesaiKey,
  ) async {
    List paymentList = payments is List ? payments : [];

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // dialogContext
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          '$employeeName - Ödeme Geçmişi',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: paymentList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payment_outlined,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz ödeme yapılmamış',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: paymentList.length,
                  itemBuilder: (context, index) {
                    var payment = paymentList[
                        paymentList.length - 1 - index]; // Ters sıra

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101922),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(payment[
                                      'date']), // _formatDate metodu var
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (payment['note'] != null &&
                                    payment['note'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      payment['note'],
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${payment['amount']?.toStringAsFixed(0)}₺',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _showDeletePaymentDialog(
                                  mesaiKey,
                                  paymentList.length - 1 - index,
                                  payment['amount'],
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeletePaymentDialog(
    int mesaiKey,
    int paymentIndex,
    double? amount,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // dialogContext
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Ödemeyi Sil', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bu ödemeyi silmek istediğinize emin misiniz?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Silinecek Tutar: ',
                    style: TextStyle(color: Colors.red),
                  ),
                  Text(
                    '${amount?.toStringAsFixed(0)}₺',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              var mesaiData = mesaiBox.get(mesaiKey);
              List payments = mesaiData['payments'];
              payments.removeAt(paymentIndex);
              await mesaiBox.put(mesaiKey, mesaiData);

              if (mounted) {
                // context.mounted yerine mounted
                Navigator.pop(dialogContext); // Silme dialogunu kapat
                Navigator.pop(dialogContext); // Geçmiş dialogunu kapat
                setState(() {}); // this. olmadan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ödeme silindi!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete_forever, size: 20),
            label: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

// Projeyi Tamamla/Aktif Yap Dialog
  Future<void> _showCompleteProjectDialog() async {
    bool isCompleted = projectData!['status'] == 'completed';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(
              isCompleted ? Icons.restart_alt : Icons.check_circle,
              color: isCompleted ? Colors.orange : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCompleted ? 'Projeyi Aktif Yap' : 'Projeyi Tamamla',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCompleted
                  ? 'Bu projeyi yeniden aktif hale getirmek istediğinize emin misiniz?'
                  : 'Bu projeyi tamamlamak istediğinize emin misiniz?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isCompleted ? Colors.orange : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCompleted
                          ? 'Proje aktif projelere geri dönecek'
                          : 'Proje tamamlananlar listesine taşınacak',
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.orange[300]
                            : Colors.green[300],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Proje durumunu değiştir
              projectData!['status'] = isCompleted ? 'active' : 'completed';
              projectData!['completedAt'] =
                  isCompleted ? null : DateTime.now().toString();

              await projeBox.putAt(widget.projectKey, projectData);

              setState(() {
                _loadProject();
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isCompleted
                          ? 'Proje aktif hale getirildi!'
                          : 'Proje tamamlandı!',
                    ),
                    backgroundColor: isCompleted ? Colors.orange : Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: Icon(isCompleted ? Icons.restart_alt : Icons.check),
            label: Text(isCompleted ? 'Aktif Yap' : 'Tamamla'),
          ),
        ],
      ),
    );
  }

// Projeyi Sil Dialog
  Future<void> _showDeleteProjectDialog() async {
    // Proje istatistiklerini hesapla
    int employeeCount = 0;
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var key in mesaiBox.keys) {
      var mesai = mesaiBox.get(key);
      if (mesai['projectKey'] == widget.projectKey) {
        employeeCount++;
      }
    }

    for (var key in gelirGiderBox.keys) {
      var item = gelirGiderBox.get(key);
      if (item['projectKey'] == widget.projectKey) {
        if (item['type'] == 'gelir') {
          totalIncome += (item['amount'] ?? 0.0);
        } else if (item['type'] == 'gider') {
          totalExpenses += (item['amount'] ?? 0.0);
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Projeyi Sil',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  children: [
                    const TextSpan(text: 'Bu işlem '),
                    TextSpan(
                      text: projectData!['name'] ?? 'projeyi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(
                        text:
                            ' ve tüm ilişkili verileri kalıcı olarak silecek.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Silinecek Veriler:',
                          style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildWarningItem('$employeeCount çalışan kaydı'),
                    _buildWarningItem(
                        '${totalIncome.toStringAsFixed(0)}₺ gelir kaydı'),
                    _buildWarningItem(
                        '${totalExpenses.toStringAsFixed(0)}₺ gider kaydı'),
                    _buildWarningItem('Tüm mesai ve ödeme kayıtları'),
                    _buildWarningItem('Tüm finansal işlemler'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu işlem geri alınamaz!',
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // 1. Mesai kayıtlarını sil
              List<int> mesaiKeysToDelete = [];
              for (var key in mesaiBox.keys) {
                var mesai = mesaiBox.get(key);
                if (mesai['projectKey'] == widget.projectKey) {
                  mesaiKeysToDelete.add(key);
                }
              }
              for (var key in mesaiKeysToDelete) {
                await mesaiBox.delete(key);
              }

              // 2. Gelir/Gider kayıtlarını sil
              List<int> gelirGiderKeysToDelete = [];
              for (var key in gelirGiderBox.keys) {
                var item = gelirGiderBox.get(key);
                if (item['projectKey'] == widget.projectKey) {
                  gelirGiderKeysToDelete.add(key);
                }
              }
              for (var key in gelirGiderKeysToDelete) {
                await gelirGiderBox.delete(key);
              }

              // 3. Projeyi sil
              await projeBox.deleteAt(widget.projectKey);

              if (context.mounted) {
                Navigator.pop(context); // Dialog'u kapat
                Navigator.pop(context); // Proje detay sayfasından çık

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Proje ve tüm ilişkili veriler silindi!'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever, size: 20),
            label: const Text('Projeyi Sil'),
          ),
        ],
      ),
    );
  }
}
