import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../../data/models/account_model.dart';
import '../../features/transactions/cubit/transactions_state.dart';

class ExportService {
  static Future<void> exportPdf(Account account, List<StatementEntry> statement) async {
    final doc = pw.Document();
    final currencyFormat = NumberFormat.simpleCurrency();
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Filter/Reverse statement if needed? Assuming statement is in display order (Newest First).
    // Usually statements are Oldest First. Let's reverse it for the PDF to look like a chronological bank statement.
    final chronologicalStatement = statement.reversed.toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Account Statement", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text("Account Name: ${account.name}"),
                  pw.Text("Account Number: ${account.accountNumber}"),
                  pw.Text("Generated Date: ${dateFormat.format(DateTime.now())}"),
                ],
              ),
            ),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['Date', 'Party / Description', 'Type', 'Amount', 'Balance'],
              data: chronologicalStatement.map((entry) {
                final tx = entry.transaction;
                return [
                  dateFormat.format(tx.date),
                  "${tx.partyName} ${tx.description ?? ''}",
                  tx.type.name.toUpperCase(),
                  currencyFormat.format(tx.amount),
                  currencyFormat.format(entry.balanceAfter),
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'statement_${account.name}.pdf');
  }

  static Future<void> exportCsv(Account account, List<StatementEntry> statement) async {
    final chronologicalStatement = statement.reversed.toList();
    final dateFormat = DateFormat('yyyy-MM-dd');

    List<List<dynamic>> rows = [];
    rows.add(["Date", "Party Name", "Description", "Type", "Amount", "Balance"]);

    for (var entry in chronologicalStatement) {
      final tx = entry.transaction;
      rows.add([
        dateFormat.format(tx.date),
        tx.partyName,
        tx.description ?? "",
        tx.type.name,
        tx.amount,
        entry.balanceAfter
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    if (Platform.isWindows || Platform.isLinux) {
      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/statement_${account.name}_${DateTime.now().millisecondsSinceEpoch}.csv");
      await file.writeAsString(csv);
      // Ideally notify user. We can't do UI here easily without context.
      // We will return the path.
    } else {
      // On Mobile, share
      await Printing.sharePdf(bytes: Uint8List.fromList(csv.codeUnits), filename: 'statement_${account.name}.csv');
    }
  }
}
