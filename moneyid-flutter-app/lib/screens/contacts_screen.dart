import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/db_service.dart';
import '../services/ussd_service.dart';
import '../widgets/contact_import_button.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<PayeeContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await DbService.getContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedChannel = 'بال باي';
    final channels = ['بال باي', 'جوال باي', 'بنك فلسطين'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('إضافة صديق جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'اسم الصديق',
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف / الحساب',
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ContactImportButton(
                        onContactSelected: (phone, name) {
                          setDialogState(() {
                            phoneCtrl.text = phone;
                            if (nameCtrl.text.isEmpty) {
                              nameCtrl.text = name;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedChannel,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'القناة المفضلة للتحويل',
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                      ),
                      items: channels.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedChannel = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                    await DbService.insertContact(PayeeContact(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      preferredChannel: selectedChannel,
                    ));
                    Navigator.pop(context);
                    _loadContacts();
                  },
                  child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuickTransferDialog(PayeeContact contact) {
    final amountCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تحويل إلى ${contact.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('القناة: ${contact.preferredChannel}\nالرقم: ${contact.phone}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.white24),
                  suffixText: '₪',
                  suffixStyle: const TextStyle(color: Color(0xFF10B981), fontSize: 20),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF06B6D4))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                if (amount == null || amount <= 0) return;
                
                Navigator.pop(context);
                if (contact.preferredChannel == 'بال باي') {
                  await UssdService.launchPalPay(phone: contact.phone, price: amount);
                } else if (contact.preferredChannel == 'جوال باي') {
                  await UssdService.launchJawwalPay(phone: contact.phone, price: amount);
                } else if (contact.preferredChannel == 'بنك فلسطين') {
                  await UssdService.launchBankOfPalestine(phone: contact.phone, price: amount);
                }
              },
              child: const Text('تنفيذ التحويل', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الدفع لصديق 👥', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF06B6D4),
        onPressed: _showAddContactDialog,
        child: const Icon(Icons.person_add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد أصدقاء محفوظين',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'أضف أصدقائك للتحويل الفوري بضغطة زر',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0] : '?',
                  style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${contact.preferredChannel} | ${contact.phone}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                  foregroundColor: const Color(0xFF10B981),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showQuickTransferDialog(contact),
                icon: const Icon(Icons.send, size: 16),
                label: const Text('تحويل 💸', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
