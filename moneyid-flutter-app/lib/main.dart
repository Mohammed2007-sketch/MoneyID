import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoneyIdApp());
}

class MoneyIdApp extends StatelessWidget {
  const MoneyIdApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyID 🆔',
      debugShowCheckedModeBanner: false,
      // Full RTL Arabic localization
      locale: const Locale('ar', 'PS'),
      supportedLocales: const [
        Locale('ar', 'PS'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF10B981),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Tajawal',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
