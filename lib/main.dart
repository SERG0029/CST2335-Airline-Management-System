import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'customer/customer_list_page.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const AirlineManagementApp());
}

class AirlineManagementApp extends StatelessWidget {
  const AirlineManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airline Management System',
      debugShowCheckedModeBanner: false,

      // Localization support
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123B64),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F6FA),
      ),

      home: const CustomerListPage(),
    );
  }
}