# MoneyID 🆔 - Master Mobile Application (Flutter)

An ultra-lightweight, offline-first digital payment orchestrator designed to streamline localized money transfers via dynamic QR codes and native USSD/GSM protocols without requiring internet access.

---

## 🏗️ Technical Architecture & Specs
- **Framework**: Flutter 3.x (Dart 3)
- **Target Architecture**: Android (APK) / iOS (IPA)
- **Optimized Size**: Target binary footprint `< 15MB` (built using split-per-ABI and code shrinking).
- **Offline Storage**: Local SQLite database (`sqflite`) for **Sales Ledger (دفتر المبيعات)** & **Financial Notes (دفتر الملاحظات المالي)**.
- **Security**: Lightweight AES encryption for QR payload data and sensitive identifiers.

---

## 📲 USSD Automated Integration Specs
1. **PalPay (*370#)**:
   - Formats string: `*370*1*1*Phone*Price#`
   - Automatically compiles payee phone and calculated price, then routes directly to the native phone dialer.
2. **Jawwal Pay (*110#)**:
   - Copies payee phone number and amount to system clipboard and launches dialer pre-filled with `*110#` for manual completion.
3. **Bank of Palestine (*267#)**:
   - Copies payee phone number and amount to system clipboard and launches dialer pre-filled with `*267#` for manual completion.

---

## 📦 How to Build Lightweight Production APK (< 15MB)
Run the following Flutter CLI command to build architecture-specific APKs:
```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./build/debug_info
```
This produces separate APKs for `arm64-v8a` and `armeabi-v7a`, typically weighing between **9MB and 12MB** each.
