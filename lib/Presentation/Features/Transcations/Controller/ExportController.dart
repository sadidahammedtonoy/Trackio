import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sadid/Presentation/Features/Transcations/Model/tranModel.dart';

class ExportController extends GetxController {
  
  Future<void> generatePDFReport(List<TranItem> transactions, String monthName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(monthName),
          pw.SizedBox(height: 20),
          _buildSummary(transactions),
          pw.SizedBox(height: 20),
          _buildTable(transactions),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Sadid_Report_$monthName.pdf",
    );
  }

  pw.Widget _buildHeader(String monthName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Track.io Financial Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text("Month: $monthName", style: const pw.TextStyle(fontSize: 16)),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildSummary(List<TranItem> transactions) {
    final income = transactions.where((t) => t.type == "Income").fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == "Expense").fold(0.0, (sum, t) => sum + t.amount);
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Total Income:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("Total Expense:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("Net Balance:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("৳ ${income.toStringAsFixed(2)}", style: pw.TextStyle(color: PdfColors.green)),
            pw.Text("৳ ${expense.toStringAsFixed(2)}", style: pw.TextStyle(color: PdfColors.red)),
            pw.Text("৳ ${(income - expense).toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTable(List<TranItem> transactions) {
    final headers = ['Date', 'Category', 'Wallet', 'Note', 'Amount'];
    
    final data = transactions.map((t) {
      return [
        DateFormat('dd MMM').format(t.date),
        t.category,
        t.wallet,
        t.note,
        "${t.type == 'Expense' ? '-' : '+'}${t.amount.toStringAsFixed(0)}",
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      },
    );
  }
}
