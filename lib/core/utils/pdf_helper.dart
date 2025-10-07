import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PDFHelper {
  // Haftalık rapor PDF'i oluştur
  static Future<pw.Document> generateWeeklyReport({
    required String projectName,
    required String projectStartDate,
    required List<WeeklyReportData> weeklyReports,
    required List<TransactionData> allTransactions,
    required List<EmployeeWorkData> employeeWorkData,
    required double totalPatronPayments,
    required double totalEmployeeWages,
    required double totalExpenses,
    required double totalNet,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => _buildHeader(projectName, font, fontBold),
        footer: (context) => _buildFooter(context, font),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),

            // Proje Bilgileri
            _buildProjectInfo(projectName, projectStartDate,
                weeklyReports.length, font, fontBold),
            pw.SizedBox(height: 20),

            // Genel Özet (Renkli Box'lar)
            _buildColorfulSummary(
              totalPatronPayments,
              totalEmployeeWages,
              totalExpenses,
              totalNet,
              font,
              fontBold,
            ),
            pw.SizedBox(height: 25),

            // Kategori Bazlı Gider Dağılımı
            _buildExpensesByCategory(allTransactions, font, fontBold),
            pw.SizedBox(height: 25),

            // Haftalık Detaylar
            ..._buildDetailedWeeklyReports(
              weeklyReports,
              allTransactions,
              employeeWorkData,
              font,
              fontBold,
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  // Header
  static pw.Widget _buildHeader(
      String projectName, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue700, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'HAFTALIK FİNANS RAPORU',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                projectName,
                style: pw.TextStyle(font: fontBold, fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Rapor Tarihi',
                style: pw.TextStyle(
                    font: font, fontSize: 9, color: PdfColors.grey700),
              ),
              pw.Text(
                _formatDateTime(DateTime.now()),
                style: pw.TextStyle(font: fontBold, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Footer
  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Usta Takip App',
            style:
                pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style:
                pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  // Proje Bilgileri
  static pw.Widget _buildProjectInfo(
    String projectName,
    String projectStartDate,
    int weekCount,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Proje Adı', projectName, font, fontBold),
          _buildInfoItem('Başlangıç', projectStartDate, font, fontBold),
          _buildInfoItem('Rapor Dönemi', '$weekCount Hafta', font, fontBold),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(
      String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: font, fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 11)),
      ],
    );
  }

  // Renkli Özet Box'lar
  static pw.Widget _buildColorfulSummary(
    double totalIncome,
    double totalWages,
    double totalExpenses,
    double totalNet,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FİNANSAL ÖZET',
          style: pw.TextStyle(
              font: fontBold, fontSize: 14, color: PdfColors.grey900),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildSummaryBox(
                'Patron Ödemesi',
                totalIncome,
                PdfColors.green700,
                PdfColors.green50,
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _buildSummaryBox(
                'Çalışan Maaşları',
                totalWages,
                PdfColors.orange700,
                PdfColors.orange50,
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildSummaryBox(
                'Masraflar',
                totalExpenses,
                PdfColors.red700,
                PdfColors.red50,
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _buildSummaryBox(
                'Net Bakiye',
                totalNet,
                totalNet >= 0 ? PdfColors.blue700 : PdfColors.red900,
                totalNet >= 0 ? PdfColors.blue50 : PdfColors.red100,
                font,
                fontBold,
                isNet: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryBox(
    String label,
    double amount,
    PdfColor textColor,
    PdfColor bgColor,
    pw.Font font,
    pw.Font fontBold, {
    bool isNet = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: textColor.shade(0.3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 9, color: textColor),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${isNet && amount >= 0 ? '+' : ''}${amount.toStringAsFixed(0)}₺',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Kategori Bazlı Gider Dağılımı
  static pw.Widget _buildExpensesByCategory(
    List<TransactionData> transactions,
    pw.Font font,
    pw.Font fontBold,
  ) {
    Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction.type == 'gider') {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    if (categoryTotals.isEmpty) return pw.SizedBox();

    List<MapEntry<String, double>> sortedCategories = categoryTotals.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'GİDER DAĞILIMI (Kategorilere Göre)',
          style: pw.TextStyle(
              font: fontBold, fontSize: 14, color: PdfColors.grey900),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Kategori', fontBold, isHeader: true),
                _buildTableCell('Tutar', fontBold, isHeader: true),
                _buildTableCell('Oran', fontBold, isHeader: true),
              ],
            ),
            // Rows
            ...sortedCategories.map((entry) {
              double total = categoryTotals.values.reduce((a, b) => a + b);
              double percentage = (entry.value / total) * 100;

              return pw.TableRow(
                children: [
                  _buildTableCell(entry.key, font),
                  _buildTableCell('${entry.value.toStringAsFixed(0)}₺', font),
                  _buildTableCell('%${percentage.toStringAsFixed(1)}', font),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  // Detaylı Haftalık Raporlar
  static List<pw.Widget> _buildDetailedWeeklyReports(
    List<WeeklyReportData> reports,
    List<TransactionData> allTransactions,
    List<EmployeeWorkData> employeeData,
    pw.Font font,
    pw.Font fontBold,
  ) {
    List<pw.Widget> widgets = [];

    widgets.add(
      pw.Text(
        'HAFTALIK DETAYLAR',
        style: pw.TextStyle(
            font: fontBold, fontSize: 14, color: PdfColors.grey900),
      ),
    );
    widgets.add(pw.SizedBox(height: 12));

    for (int i = 0; i < reports.length; i++) {
      var report = reports[i];

      // Hafta başlığı
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue700,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(6),
              topRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'HAFTA ${i + 1}: ${report.weekRange}',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'Net: ${report.netBalance >= 0 ? '+' : ''}${report.netBalance.toStringAsFixed(0)}₺',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ),
      );

      // Hafta içeriği
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(6),
              bottomRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Özet
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildWeekStat('Gelir', report.patronPayments,
                      PdfColors.green600, font, fontBold),
                  _buildWeekStat('Maaş', report.employeeWages,
                      PdfColors.orange600, font, fontBold),
                  _buildWeekStat('Masraf', report.expenses, PdfColors.red600,
                      font, fontBold),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),

              // Bu haftanın işlemleri
              _buildWeekTransactions(
                  report.weekRange, allTransactions, font, fontBold),

              pw.SizedBox(height: 8),

              // Bu haftanın çalışan verileri
              _buildWeekEmployeeWork(
                  report.weekRange, employeeData, font, fontBold),
            ],
          ),
        ),
      );

      widgets.add(pw.SizedBox(height: 20));
    }

    return widgets;
  }

  static pw.Widget _buildWeekStat(
    String label,
    double amount,
    PdfColor color,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: pw.TextStyle(font: font, fontSize: 9, color: color)),
        pw.SizedBox(height: 4),
        pw.Text(
          '${amount.toStringAsFixed(0)}₺',
          style: pw.TextStyle(font: fontBold, fontSize: 11, color: color),
        ),
      ],
    );
  }

  static pw.Widget _buildWeekTransactions(
    String weekRange,
    List<TransactionData> allTransactions,
    pw.Font font,
    pw.Font fontBold,
  ) {
    // Bu haftaya ait işlemleri filtrele
    List<TransactionData> weekTransactions =
        allTransactions.where((t) => t.weekRange == weekRange).toList();

    if (weekTransactions.isEmpty) {
      return pw.Text(
        'Bu hafta işlem yok',
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'İşlemler:',
          style: pw.TextStyle(font: fontBold, fontSize: 10),
        ),
        pw.SizedBox(height: 6),
        ...weekTransactions.take(5).map((transaction) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    '${transaction.date} - ${transaction.description}',
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    transaction.category,
                    style: pw.TextStyle(
                        font: font, fontSize: 8, color: PdfColors.grey600),
                  ),
                ),
                pw.Text(
                  '${transaction.type == 'gelir' ? '+' : '-'}${transaction.amount.toStringAsFixed(0)}₺',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 8,
                    color: transaction.type == 'gelir'
                        ? PdfColors.green700
                        : PdfColors.red700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (weekTransactions.length > 5)
          pw.Text(
            '... ve ${weekTransactions.length - 5} işlem daha',
            style:
                pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
          ),
      ],
    );
  }

  static pw.Widget _buildWeekEmployeeWork(
    String weekRange,
    List<EmployeeWorkData> employeeData,
    pw.Font font,
    pw.Font fontBold,
  ) {
    List<EmployeeWorkData> weekEmployees =
        employeeData.where((e) => e.weekRange == weekRange).toList();

    if (weekEmployees.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 6),
        pw.Text(
          'Çalışan Mesaileri:',
          style: pw.TextStyle(font: fontBold, fontSize: 10),
        ),
        pw.SizedBox(height: 6),
        ...weekEmployees.map((employee) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  employee.employeeName,
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
                pw.Text(
                  '${employee.workDays} gün - ${employee.totalWage.toStringAsFixed(0)}₺',
                  style: pw.TextStyle(
                      font: fontBold, fontSize: 8, color: PdfColors.orange700),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // PDF Önizleme
  static Future<void> previewPDF(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // PDF Paylaş
  static Future<void> sharePDF(pw.Document pdf, String fileName) async {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: fileName,
    );
  }

  // PDF Kaydet
  static Future<File?> savePDF(pw.Document pdf, String fileName) async {
    try {
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      return null;
    }
  }
}

// Data modelleri
class WeeklyReportData {
  final String weekRange;
  final double patronPayments;
  final double employeeWages;
  final double expenses;
  final double netBalance;

  WeeklyReportData({
    required this.weekRange,
    required this.patronPayments,
    required this.employeeWages,
    required this.expenses,
    required this.netBalance,
  });
}

class TransactionData {
  final String date;
  final String type; // 'gelir' veya 'gider'
  final String category;
  final String description;
  final double amount;
  final String weekRange;

  TransactionData({
    required this.date,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.weekRange,
  });
}

class EmployeeWorkData {
  final String employeeName;
  final int workDays;
  final double totalWage;
  final String weekRange;

  EmployeeWorkData({
    required this.employeeName,
    required this.workDays,
    required this.totalWage,
    required this.weekRange,
  });
}
