import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/db_service.dart';
import '../services/ussd_service.dart';
import 'qr_scanner_screen.dart';
import 'sales_ledger_screen.dart';
import 'financial_notes_screen.dart';
import 'contacts_screen.dart';
import '../widgets/contact_import_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // User default financial identity
  String _userName = 'م. محمد أبو راشد';
  String _bopNumber = '102938475';
  String _palpayNumber = '0599000000';
  String _jawwalpayNumber = '0599000000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: _buildBodyContent(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 1:
        return const FinancialNotesScreen();
      case 2:
        return const SalesLedgerScreen();
      case 3:
        return const ContactsScreen();
      default:
        return _buildHomeDashboard();
    }
  }

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: App logo, avatar, My QR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/logos/moneyid-logo.jpg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MoneyID 🆔',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      Text(
                        _userName,
                        style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: _showMyQrDialog,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.qr_code, color: Color(0xFF10B981), size: 20),
                      SizedBox(width: 6),
                      Text(
                        'هويتي المالية',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Prominent Center Action: Scan QR Button
          GestureDetector(
            onTap: _openQrScanner,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مسح رمز QR للدفع الفوري',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'قراءة بيانات المستلم والتحويل دون إنترنت',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section Title
          const Text(
            'محرك التحويل الفوري أوفلاين (USSD/GSM)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'اختر البنك أو المحفظة لتنفيذ عملية التحويل مباشرة دون إنترنت',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),

          const SizedBox(height: 16),

          // Quick Pay Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              _buildPayCard(
                title: 'بنك فلسطين',
                subtitle: '*267# USSD',
                assetLogo: 'assets/logos/bank-of-palestine.jpg',
                onTap: () => _showPaymentDialog(
                  channel: 'بنك فلسطين',
                  code: '*267#',
                  onSubmit: (phone, price) async {
                    await UssdService.launchBankOfPalestine(phone: phone, price: price);
                    _recordTransaction('بنك فلسطين', phone, price);
                  },
                ),
              ),
              _buildPayCard(
                title: 'بال باي',
                subtitle: 'محفظتي *370#',
                assetLogo: 'assets/logos/PalPay.jpg',
                onTap: () => _showPaymentDialog(
                  channel: 'بال باي',
                  code: '*370#',
                  onSubmit: (phone, price) async {
                    await UssdService.launchPalPay(phone: phone, price: price);
                    _recordTransaction('بال باي', phone, price);
                  },
                ),
              ),
              _buildPayCard(
                title: 'جوال باي',
                subtitle: 'Jawwal Pay *110#',
                assetLogo: 'assets/logos/JawwalPay.jpg',
                onTap: () => _showPaymentDialog(
                  channel: 'جوال باي',
                  code: '*110#',
                  onSubmit: (phone, price) async {
                    await UssdService.launchJawwalPay(phone: phone, price: price);
                    _recordTransaction('جوال باي', phone, price);
                  },
                ),
              ),
              _buildPayCard(
                title: 'البنك الإسلامي',
                subtitle: 'Palestine Islamic',
                assetLogo: 'assets/logos/islamic-bank.jpg',
                onTap: () => _showPaymentDialog(
                  channel: 'البنك الإسلامي',
                  code: 'تطبيق / USSD',
                  onSubmit: (phone, price) async {
                    _recordTransaction('البنك الإسلامي', phone, price);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Management Cards: Ledger & Notes
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  title: 'دفتر المبيعات',
                  subtitle: 'سجل العمليات الأوفلاين',
                  icon: Icons.menu_book,
                  color: const Color(0xFF10B981),
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionTile(
                  title: 'دفتر الملاحظات',
                  subtitle: 'الديون والملاحظات',
                  icon: Icons.note_alt,
                  color: const Color(0xFF06B6D4),
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPayCard({
    required String title,
    required String subtitle,
    required String assetLogo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                assetLogo,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          if (index == 4) {
            // Support chat
            UssdService.openSupportChat();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: 'الملاحظات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'المبيعات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'الأصدقاء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'الدعم',
          ),
        ],
      ),
    );
  }

  void _showMyQrDialog() {
    showDialog(
      context: context,
      builder: (_) => MyQrDialog(
        userName: _userName,
        bop: _bopNumber,
        palpay: _palpayNumber,
        jawwalpay: _jawwalpayNumber,
      ),
    );
  }

  void _openQrScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null && result is Map) {
      // Auto fill payment dialog
      _showPaymentDialog(
        channel: 'تحويل سريع',
        code: 'QR',
        defaultPhone: result['bop'] ?? result['palpay'] ?? result['jawwal'] ?? '',
        onSubmit: (phone, price) async {
          _recordTransaction('QR الدفع السريع', phone, price);
        },
      );
    }
  }

  void _showPaymentDialog({
    required String channel,
    required String code,
    String defaultPhone = '',
    required Function(String phone, double price) onSubmit,
  }) {
    final phoneCtrl = TextEditingController(text: defaultPhone);
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التحويل عبر $channel ($code)',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم المستلم / الحساب',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ContactImportButton(
                  onContactSelected: (phone, name) {
                    phoneCtrl.text = phone;
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'المبلغ (₪ شيكل)',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final phone = phoneCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0;
                  if (phone.isNotEmpty && price > 0) {
                    Navigator.pop(ctx);
                    onSubmit(phone, price);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'تأكيد وتنفيذ عبر USSD أوفلاين 🚀',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _recordTransaction(String channel, String phone, double price) async {
    final now = DateTime.now();
    final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tx = TransactionModel(
      timestamp: timestamp,
      amount: price,
      channel: channel,
      payeePhone: phone,
      payeeName: 'مستلم: $phone',
      type: 'outgoing',
    );
    await DbService.insertTransaction(tx);
  }
}
