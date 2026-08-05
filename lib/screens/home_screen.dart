import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/transaction_model.dart';
import '../services/db_service.dart';
import '../services/ussd_service.dart';
import '../services/preferences_service.dart';
import 'qr_scanner_screen.dart';
import 'sales_ledger_screen.dart';
import 'financial_notes_screen.dart';
import 'contacts_screen.dart';
import 'calculator_screen.dart';
import 'analytics_screen.dart';
import '../widgets/contact_import_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Ambient Background Glow
          Positioned(
            top: -100,
            left: -100,
            child: _buildGlowOrb(const Color(0xFF10B981).withOpacity(0.15)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildGlowOrb(const Color(0xFF06B6D4).withOpacity(0.15)),
          ),
          SafeArea(
            child: _buildBodyContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGlowOrb(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 1: return const CalculatorScreen();
      case 2: return const SalesLedgerScreen();
      case 3: return const FinancialNotesScreen();
      case 4: return const AnalyticsScreen();
      default: return _buildHomeDashboard();
    }
  }

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/logos/moneyid-logo.jpg', width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MoneyID 🆔', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                      Text(
                        PreferencesService.userName,
                        style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: _showMyQrDialog,
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code, color: Color(0xFF10B981), size: 22),
                          SizedBox(width: 8),
                          Text('هويتي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Hero Scan Card
          GestureDetector(
            onTap: _openQrScanner,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مسح رمز QR 📸', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        SizedBox(height: 6),
                        Text('للدفع الفوري الأوفلاين بسرعة وسهولة', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 36),

          const Text('محرك التحويل الفوري (USSD)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Quick Pay Grid (Glassmorphism)
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildPayCard(
                title: 'فلسطين',
                subtitle: '*267#',
                assetLogo: 'assets/logos/bank-of-palestine.jpg',
                onTap: () => _showPaymentDialog('بنك فلسطين', '*267#'),
              ),
              _buildPayCard(
                title: 'بال باي',
                subtitle: '*370#',
                assetLogo: 'assets/logos/PalPay.jpg',
                onTap: () => _showPaymentDialog('بال باي', '*370#'),
              ),
              _buildPayCard(
                title: 'جوال باي',
                subtitle: '*110#',
                assetLogo: 'assets/logos/JawwalPay.jpg',
                onTap: () => _showPaymentDialog('جوال باي', '*110#'),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Contacts Button
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsScreen())),
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.people_alt, color: Color(0xFF06B6D4)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الدفع لصديق 👥', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('تحويل سريع لجهات الاتصال المحفوظة', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Footer Branding
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'تطبيق رسمي • مطوّر التطبيق: Eng. Mohammed Abu Rashed\n(Creator & Cybersecurity Engineer)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 10, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPayCard({required String title, required String subtitle, required String assetLogo, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(assetLogo, width: 44, height: 44, fit: BoxFit.cover)),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.8),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF10B981),
            unselectedItemColor: Colors.white54,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            onTap: (index) {
              if (index == 5) {
                UssdService.openSupportChat();
              } else {
                setState(() => _currentIndex = index);
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'الحاسبة'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'المبيعات'),
              BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined), label: 'الملاحظات'),
              BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'الإحصائيات'),
              BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'الدعم'),
            ],
          ),
        ),
      ),
    );
  }

  void _showMyQrDialog() {
    showDialog(
      context: context,
      builder: (_) => MyQrDialog(
        userName: PreferencesService.userName,
        bop: PreferencesService.bopNumber,
        palpay: PreferencesService.palpayNumber,
        jawwalpay: PreferencesService.jawwalpayNumber,
      ),
    );
  }

  void _openQrScanner() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
    if (result != null && result is Map) {
      _showPaymentDialog('تحويل سريع', 'QR', defaultPhone: result['bop'] ?? result['palpay'] ?? result['jawwal'] ?? '');
    }
  }

  void _showPaymentDialog(String channel, String code, {String defaultPhone = ''}) {
    final phoneCtrl = TextEditingController(text: defaultPhone);
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: const Color(0xFF0F172A).withOpacity(0.9),
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('التحويل عبر $channel ($code)', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: phoneCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم المستلم / الحساب',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ContactImportButton(onContactSelected: (phone, name) => phoneCtrl.text = phone),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'المبلغ (₪ شيكل)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      final phone = phoneCtrl.text.trim();
                      final price = double.tryParse(priceCtrl.text) ?? 0;
                      if (phone.isNotEmpty && price > 0) {
                        Navigator.pop(ctx);
                        if (channel.contains('فلسطين')) await UssdService.launchBankOfPalestine(phone: phone, price: price);
                        else if (channel.contains('بال باي')) await UssdService.launchPalPay(phone: phone, price: price);
                        else if (channel.contains('جوال')) await UssdService.launchJawwalPay(phone: phone, price: price);
                        
                        final now = DateTime.now();
                        await DbService.insertTransaction(TransactionModel(
                          timestamp: '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}',
                          amount: price,
                          channel: channel,
                          payeePhone: phone,
                          payeeName: 'مستلم: $phone',
                          type: 'outgoing',
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                    ),
                    child: const Text('تنفيذ عبر USSD أوفلاين 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
