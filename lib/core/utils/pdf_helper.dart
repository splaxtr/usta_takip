import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

/// PDF oluşturma ve işlemler için yardımcı sınıf
///
/// Gerekli paketler:
/// dependencies:
///   pdf: ^3.10.8
///   printing: ^5.12.0
///   path_provider: ^2.1.2
class PdfHelper {
  PdfHelper._();

  /// Basit bir PDF belgesi oluştur
  ///
  /// Örnek:
  /// ```dart
  /// final pdf = PdfHelper.createSimpleDocument(
  ///   title: 'Rapor',
  ///   content: 'Bu bir test raporudur',
  /// );
  /// ```
  static pw.Document createSimpleDocument({
    required String title,
    required String content,
    String? author,
    String? subject,
  }) {
    final pdf = pw.Document(
      title: title,
      author: author,
      subject: subject,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                content,
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Fatura/Makbuz PDF'i oluştur
  ///
  /// Örnek kullanım için InvoiceData modeli oluşturulmalı
  static pw.Document createInvoice({
    required String invoiceNumber,
    required DateTime invoiceDate,
    required String customerName,
    required String customerAddress,
    required List<InvoiceItem> items,
    required double totalAmount,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? notes,
  }) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Başlık
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName ?? 'Firma Adı',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (companyAddress != null)
                        pw.Text(companyAddress,
                            style: const pw.TextStyle(fontSize: 10)),
                      if (companyPhone != null)
                        pw.Text(companyPhone,
                            style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FATURA',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('No: $invoiceNumber'),
                      pw.Text(
                          'Tarih: ${invoiceDate.day}.${invoiceDate.month}.${invoiceDate.year}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Müşteri Bilgileri
              pw.Text(
                'Müşteri Bilgileri',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(customerName),
              pw.Text(customerAddress),
              pw.SizedBox(height: 20),

              // Ürün/Hizmet Tablosu
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  // Başlık satırı
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Ürün/Hizmet', isHeader: true),
                      _buildTableCell('Miktar', isHeader: true),
                      _buildTableCell('Birim Fiyat', isHeader: true),
                      _buildTableCell('Toplam', isHeader: true),
                    ],
                  ),
                  // Ürün satırları
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item.name),
                        _buildTableCell(item.quantity.toString()),
                        _buildTableCell(
                            '${item.unitPrice.toStringAsFixed(2)} ₺'),
                        _buildTableCell('${item.total.toStringAsFixed(2)} ₺'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 10),

              // Toplam
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOPLAM: ${totalAmount.toStringAsFixed(2)} ₺',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Notlar
              if (notes != null) ...[
                pw.SizedBox(height: 30),
                pw.Text(
                  'Notlar:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(notes),
              ],
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Tablo hücresi oluştur
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  /// PDF'i dosya olarak kaydet
  ///
  /// Örnek:
  /// ```dart
  /// final file = await PdfHelper.savePdfFile(pdf, 'fatura_001.pdf');
  /// ```
  static Future<File> savePdfFile(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// PDF'i paylaş (print veya share)
  ///
  /// Örnek:
  /// ```dart
  /// await PdfHelper.sharePdf(pdf, 'Fatura');
  /// ```
  static Future<void> sharePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
  }

  /// PDF'i yazdır
  ///
  /// Örnek:
  /// ```dart
  /// await PdfHelper.printPdf(pdf);
  /// ```
  static Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// PDF önizleme göster
  ///
  /// Örnek:
  /// ```dart
  /// await PdfHelper.showPdfPreview(
  ///   context: context,
  ///   pdf: pdf,
  ///   fileName: 'Fatura',
  /// );
  /// ```
  static Future<void> showPdfPreview({
    required pw.Document pdf,
    required String fileName,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  /// Görseli PDF'e ekle
  ///
  /// Örnek:
  /// ```dart
  /// final image = await PdfHelper.loadImageFromAssets('assets/logo.png');
  /// ```
  static Future<pw.ImageProvider> loadImageFromAssets(String path) async {
    final bytes = await rootBundle.load(path);
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  /// Bytes'tan image provider oluştur
  static pw.ImageProvider imageFromBytes(Uint8List bytes) {
    return pw.MemoryImage(bytes);
  }

  /// Liste halinde PDF oluştur (Rapor, Liste vb.)
  static pw.Document createListDocument({
    required String title,
    required List<String> items,
    String? subtitle,
  }) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
              pw.SizedBox(height: 20),
              ...items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ', style: const pw.TextStyle(fontSize: 14)),
                      pw.Expanded(
                        child: pw.Text(item,
                            style: const pw.TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}

/// Fatura kalemi için model sınıf
class InvoiceItem {
  final String name;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
