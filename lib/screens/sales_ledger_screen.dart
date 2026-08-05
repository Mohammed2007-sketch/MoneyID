import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/db_service.dart';

class SalesLedgerScreen extends StatefulWidget {
  const SalesLedgerScreen({Key? key}) : super(key: key);

  @override
  State<SalesLedgerScreen> createState() => _SalesLedgerScreenState();
}

class _SalesLedgerScreenState extends State<SalesLedgerScreen> {
  String _searchQuery = '';
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);
    final list = await DbService.getTransactions(query: _searchQuery);
    setState(() {
      _transactions = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('دفتر المبيعات 📒', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم، رقم مستلم، أو وسيلة دفع...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _loadTransactions();
              },
            ),
          ),
          // Ledger List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد عمليات مسجلة حالياً في الدفتر الأوفلاين',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          final isOut = tx.type == 'outgoing';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isOut
                                    ? const Color(0xFFEF4444).withOpacity(0.3)
                                    : const Color(0xFF10B981).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isOut
                                        ? const Color(0xFFEF4444).withOpacity(0.15)
                                        : const Color(0xFF10B981).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isOut ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: isOut ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.payeeName.isNotEmpty ? tx.payeeName : 'مستلم: ${tx.payeePhone}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${tx.channel} • ${tx.timestamp}',
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${tx.amount.toStringAsFixed(2)} ₪',
                                  style: TextStyle(
                                    color: isOut ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
