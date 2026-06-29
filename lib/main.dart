import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sew_keeper/splash.dart';

import 'home.dart';
import 'order_storge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  final provider = OrdersProvider();
  await provider.loadOrders();
  runApp(ChangeNotifierProvider.value(value: provider, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sew Keeper',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xff6c63ff),
      useMaterial3: true,
    ),
    home: const SplashScreen(),
  );
}
