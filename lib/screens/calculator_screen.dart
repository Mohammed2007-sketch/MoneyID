import 'package:flutter/material.dart';
import '../services/ussd_service.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';
import '../widgets/contact_import_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _operation = '';
  double _firstOperand = 0;
  bool _isNewOperand = true;

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'C') {
        _display = '0';
        _operation = '';
        _firstOperand = 0;
        _isNewOperand = true;
      } else if (key == 'DEL') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (key == '+' || key == '-' || key == '*' || key == '/') {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operation = key;
        _isNewOperand = true;
      } else if (key == '=') {
        if (_operation.isNotEmpty) {
          final secondOperand = double.tryParse(_display) ?? 0;
          double result = 0;
          switch (_operation) {
            case '+': result = _firstOperand + secondOperand; break;
            case '-': result = _firstOperand - secondOperand; break;
            case '*': result = _firstOperand * secondOperand; break;
            case '/': result = secondOperand != 0 ? _firstOperand / secondOperand : 0; break;
          }
          _display = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2);
          _operation = '';
          _isNewOperand = true;
        }
      } else {
        if (_isNewOperand) {
          _display = key;
          _isNewOperand = false;
        } else {
          if (_display == '0' && key != '.') {
            _display = key;
          } else {
            if (key == '.' && _display.contains('.')) return;
            _display += key;
          }
        }
      }
    });
  }

  void _showChannelPicker() {
    final price = double.tryParse(_display) ?? 0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء حساب مبلغ صحيح أولاً')));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('اختر قناة الدفع للتحويل 💳', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildChannelOption(ctx, 'بنك فلسطين', 'assets/logos/bank-of-palestine.jpg', '*267#', price),
              _buildChannelOption(ctx, 'بال باي', 'assets/logos/PalPay.jpg', '*370#', price),
              _buildChannelOption(ctx, 'جوال باي', 'assets/logos/JawwalPay.jpg', '*110#', price),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelOption(BuildContext ctx, String name, String logo, String code, double price) {
    return ListTile(
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(logo, width: 40, height: 40)),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(code, style: const TextStyle(color: Color(0xFF10B981))),
      onTap: () {
        Navigator.pop(ctx);
        _showPaymentDialog(channel: name, code: code, price: price);
      },
    );
  }

  void _showPaymentDialog({required String channel, required String code, required double price}) {
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تحويل مبلغ $price ₪ عبر $channel', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                child: ContactImportButton(onContactSelected: (phone, name) => phoneCtrl.text = phone),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final phone = phoneCtrl.text.trim();
                  if (phone.isNotEmpty) {
                    Navigator.pop(ctx);
                    if (channel == 'بنك فلسطين') {
                      await UssdService.launchBankOfPalestine(phone: phone, price: price);
                    } else if (channel == 'بال باي') {
                      await UssdService.launchPalPay(phone: phone, price: price);
                    } else if (channel == 'جوال باي') {
                      await UssdService.launchJawwalPay(phone: phone, price: price);
                    }
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
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('تنفيذ عبر USSD أوفلاين 🚀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          alignment: Alignment.bottomLeft,
          color: const Color(0xFF1E293B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_operation.isNotEmpty ? '$_firstOperand $_operation' : '', style: const TextStyle(color: Colors.white54, fontSize: 24)),
              Text(_display, style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // Keypad
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(child: _buildRow(['C', 'DEL', '%', '/'])),
                Expanded(child: _buildRow(['7', '8', '9', '*'])),
                Expanded(child: _buildRow(['4', '5', '6', '-'])),
                Expanded(child: _buildRow(['1', '2', '3', '+'])),
                Expanded(child: _buildRow(['0', '.', '='])),
              ],
            ),
          ),
        ),
        // Golden Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _showChannelPicker,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
            ),
            child: const Text('← استخدام هذا المبلغ للتحويل الفوري (USSD) 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: keys.map((k) {
        return Expanded(
          flex: k == '0' ? 2 : 1,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: InkWell(
              onTap: () => _onKeyPress(k),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: ['/', '*', '-', '+', '='].contains(k) ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  k,
                  style: TextStyle(
                    color: ['C', 'DEL'].contains(k) ? Colors.redAccent : Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
