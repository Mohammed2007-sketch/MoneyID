import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class UssdService {
  /// PalPay (*370#): Automatically compiles *370*1*1*Phone*Price# and launches dialer
  static Future<bool> launchPalPay({
    required String phone,
    required double price,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final priceStr = price.toStringAsFixed(0); // integer or formatted price
    final ussdString = '*370*1*1*$cleanPhone*$priceStr#';
    final Uri telUri = Uri.parse('tel:${Uri.encodeComponent(ussdString)}');
    if (await canLaunchUrl(telUri)) {
      return await launchUrl(telUri);
    }
    return false;
  }

  /// Jawwal Pay (*110#): Copies phone and amount to clipboard, launches dialer with *110#
  static Future<bool> launchJawwalPay({
    required String phone,
    required double price,
  }) async {
    final textToCopy = 'رقم المستلم: $phone | المبلغ: ${price.toStringAsFixed(2)} ₪';
    await Clipboard.setData(ClipboardData(text: textToCopy));
    final Uri telUri = Uri.parse('tel:${Uri.encodeComponent("*110#")}');
    if (await canLaunchUrl(telUri)) {
      return await launchUrl(telUri);
    }
    return false;
  }

  /// Bank of Palestine (*267#): Copies phone and amount to clipboard, launches dialer with *267#
  static Future<bool> launchBankOfPalestine({
    required String phone,
    required double price,
  }) async {
    final textToCopy = 'حساب المستلم: $phone | المبلغ: ${price.toStringAsFixed(2)} ₪';
    await Clipboard.setData(ClipboardData(text: textToCopy));
    final Uri telUri = Uri.parse('tel:${Uri.encodeComponent("*267#")}');
    if (await canLaunchUrl(telUri)) {
      return await launchUrl(telUri);
    }
    return false;
  }

  /// Support Chat: Direct link to @MoneyID_Support_Bot
  static Future<void> openSupportChat() async {
    final Uri botUri = Uri.parse('https://t.me/MoneyID_Support_Bot');
    if (await canLaunchUrl(botUri)) {
      await launchUrl(botUri, mode: LaunchMode.externalApplication);
    }
  }
}
