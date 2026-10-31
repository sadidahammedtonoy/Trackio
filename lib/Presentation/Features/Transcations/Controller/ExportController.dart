import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sadid/Presentation/Features/Transcations/Model/tranModel.dart';

class ExportController extends GetxController {
  Future<void> generatePDFReport(List<TranItem> transactions, String monthKey) async {
    final pdf = pw.Document();
    final user = FirebaseAuth.instance.currentUser;
    
    // Create a local snapshot of the list to ensure data is preserved during PDF build
    final List<TranItem> reportItems = List.from(transactions);

    // Load assets
    final logoBytes = await rootBundle.load('assets/logo.jpeg');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    // Define colors
    const tableHeaderColor = PdfColor.fromInt(0xFFF2F2F2);
    const tableBorderColor = PdfColor.fromInt(0xFFCCCCCC);

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) {
          double totalIncome = 0;
          double totalExpense = 0;
          
          // Use the snapshot list for calculations
          for (var t in reportItems) {
            if (t.type == 'Income') totalIncome += t.amount;
            if (t.type == 'Expense') totalExpense += t.amount;
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(logoImage, user),

              pw.SizedBox(height: 30),

              // Title
              pw.Text("Bank Financial Statement", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              
              pw.SizedBox(height: 20),

              // Account Summary (No icons/bullets as requested)
              pw.Text("Account Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Paragraph(text: "The following is a summary of your account activity for the period:"),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Account Holder: ${user?.displayName ?? user?.email ?? 'N/A'}"),
                    pw.SizedBox(height: 2),
                    pw.Text("Account Number: ${user?.email ?? 'N/A'}"),
                    pw.SizedBox(height: 2),
                    pw.Text("Statement Period: $monthKey"),
                  ]
                )
              ),

              pw.SizedBox(height: 20),

              // Account Balances
              pw.Text("Account Balances", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              _buildBalancesTable(totalIncome, totalExpense, tableHeaderColor, tableBorderColor),

              pw.SizedBox(height: 20),

              // Transaction History
              pw.Text("Transaction History", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              _buildTransactionsTable(reportItems, tableHeaderColor, tableBorderColor),

              pw.Spacer(),

              // Footer (Important Notices)
              pw.Text("Important Notices", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Paragraph(
                text: "This is a computer-generated statement and does not require a signature. "
                      "Please review your transactions carefully. If you have any questions or notice any "
                      "discrepancies, please contact our customer support within 30 days.",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Trackio_Report_${monthKey.replaceAll(' ', '_')}.pdf",
    );
  }

  pw.Widget _buildHeader(pw.MemoryImage logoImage, User? user) {
    return pw.Container(
      height: 100,
      color: PdfColors.white,
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 20),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logoImage, width: 80, height: 80),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("Track.io", style: pw.TextStyle(color: PdfColors.black, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(user?.displayName ?? "", style: const pw.TextStyle(color: PdfColors.black, fontSize: 12)),
                pw.Text(user?.email ?? "", style: const pw.TextStyle(color: PdfColors.black, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildBalancesTable(double income, double expense, PdfColor headerColor, PdfColor borderColor) {
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 1.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: [
            _tableHeader("Account Type"),
            _tableHeader("Beginning Balance"),
            _tableHeader("Ending Balance"),
          ],
        ),
        _balanceRow("Income", 0.0, income),
        _balanceRow("Expense", 0.0, expense),
        _balanceRow("Net Flow", 0.0, income - expense, isTotal: true),
      ],
    );
  }

  pw.TableRow _balanceRow(String type, double start, double end, {bool isTotal = false}) {
    final style = isTotal ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : const pw.TextStyle();
    return pw.TableRow(
      children: [
        _tableCell(type, style: style),
        _tableCell("৳ ${start.toStringAsFixed(2)}", align: pw.Alignment.centerRight, style: style),
        _tableCell("৳ ${end.toStringAsFixed(2)}", align: pw.Alignment.centerRight, style: style),
      ],
    );
  }

  pw.Widget _buildTransactionsTable(List<TranItem> transactions, PdfColor headerColor, PdfColor borderColor) {
    double balance = 0.0;

    final List<pw.TableRow> rows = [];
    
    // Header Row
    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: headerColor),
        children: [
          _tableHeader("Date"),
          _tableHeader("Description"),
          _tableHeader("Amount"),
          _tableHeader("Balance"),
        ],
      ),
    );

    // Data Rows
    if (transactions.isEmpty) {
      rows.add(
        pw.TableRow(
          children: [
            _tableCell("No transactions for this period.", align: pw.Alignment.center),
            _tableCell(""),
            _tableCell(""),
            _tableCell(""),
          ],
        ),
      );
    } else {
      for (var item in transactions) {
        final amount = item.type == 'Expense' ? -item.amount : item.amount;
        balance += amount;
        rows.add(pw.TableRow(
          children: [
            _tableCell(DateFormat('MM/dd/yyyy').format(item.date)),
            _tableCell("${item.category} (${item.type})"),
            _tableCell(
              "৳ ${amount.toStringAsFixed(2)}",
              align: pw.Alignment.centerRight,
              style: pw.TextStyle(color: amount < 0 ? PdfColors.red : PdfColors.green)
            ),
            _tableCell("৳ ${balance.toStringAsFixed(2)}", align: pw.Alignment.centerRight),
          ],
        ));
      }
    }
    
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 1.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: rows,
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableCell(String text, {pw.Alignment align = pw.Alignment.centerLeft, pw.TextStyle style = const pw.TextStyle()}) {
     return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: align,
      child: pw.Text(text, style: style.copyWith(fontSize: 10), textAlign: align == pw.Alignment.center ? pw.TextAlign.center : (align == pw.Alignment.centerRight ? pw.TextAlign.right : pw.TextAlign.left)),
    );
  }
}
