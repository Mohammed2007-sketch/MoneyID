import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactImportButton extends StatelessWidget {
  final Function(String phone, String name) onContactSelected;

  const ContactImportButton({
    Key? key,
    required this.onContactSelected,
  }) : super(key: key);

  Future<void> _importContact(BuildContext context) async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            String phone = fullContact.phones.first.number.replaceAll(RegExp(r'\s+'), '');
            onContactSelected(phone, fullContact.displayName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('جهة الاتصال لا تحتوي على رقم هاتف')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('صلاحية الوصول لجهات الاتصال مطلوبة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء استيراد جهة الاتصال')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _importContact(context),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contact_phone, color: Color(0xFF06B6D4), size: 18),
            SizedBox(width: 8),
            Text(
              'استيراد من جهات الاتصال',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
