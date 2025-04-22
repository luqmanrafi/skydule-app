import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'home_screen.dart'; // Import home_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: Locale('id', 'ID'),
    home: HomeScreen(),
  ));
}
