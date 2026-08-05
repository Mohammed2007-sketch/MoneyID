import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<TransactionModel> _transactions = [];
  double _totalBop = 0;
  double _totalPalpay = 0;
  double _totalJawwal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final txs = await DbService.getTransactions();
    double bop = 0, palpay = 0, jawwal = 0;
    for (var tx in txs) {
      if (tx.channel.contains('فلسطين')) bop += tx.amount;
      if (tx.channel.contains('بال باي')) palpay += tx.amount;
      if (tx.channel.contains('جوال')) jawwal += tx.amount;
    }
    setState(() {
      _transactions = txs;
      _totalBop = bop;
      _totalPalpay = palpay;
      _totalJawwal = jawwal;
    });
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('تقرير مبيعات MoneyID', style: pw.TextStyle(fontSize: 24))),
              pw.SizedBox(height: 20),
              pw.Text('إجمالي بنك فلسطين: $_totalBop شيكل'),
              pw.Text('إجمالي بال باي: $_totalPalpay شيكل'),
              pw.Text('إجمالي جوال باي: $_totalJawwal شيكل'),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                data: const <List<String>>[
                  <String>['Date', 'Amount', 'Channel', 'Payee'],
                  // ..._transactions.map((t) => [t.timestamp, t.amount.toString(), t.channel, t.payeePhone])
                ]..addAll(_transactions.map((t) => [t.timestamp, t.amount.toString(), t.channel, t.payeePhone])),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('الإحصائيات والتقارير 📊'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: const Color(0xFF10B981),
                      value: _totalBop > 0 ? _totalBop : 1,
                      title: 'بنك فلسطين',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF06B6D4),
                      value: _totalPalpay > 0 ? _totalPalpay : 1,
                      title: 'بال باي',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: const Color(0xFFF59E0B),
                      value: _totalJawwal > 0 ? _totalJawwal : 1,
                      title: 'جوال باي',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('تصدير تقرير PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
